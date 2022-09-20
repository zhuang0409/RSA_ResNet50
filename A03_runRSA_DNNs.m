function A03_runRSA_DNNs(subjectID,foldername) 
% Run RSA:RN50-49
% A03_runRSA_DNNs(subjectID,'RNaction44') 
% A03_runRSA_DNNs(subjectID,'RNobject44') 
% 22.06.2022 by Zhuang
%clc;clear;
% foldername='RNaction44';
% subjectID = 'SUB03_19980219SNFS';
nRuns = 6;
smoothingVal = 0;
%type='_aligned-subject-standard-2mm';%'_aligned-subject-1mm';-standard-2mm
%set path
addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/UnSmoothed/';
rsaDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/' ;
outputDir = fullfile(rsaDir, sprintf('RSA_%s/',foldername));
mkdir (outputDir);

standardDir = '/usr/local/fsl/data/standard';
mask_fn = fullfile(standardDir, 'MNI152_T1_2mm_brain_mask.nii.gz');
%set dsm
modeldir='/Users/zhuang/Documents/MRI/Projects/Travel/data/Resnet50/outputs/';
matrixnames=dir([modeldir,'*.npy']);
switch foldername(3:end-2)
    case 'action'
        data= readNPY([modeldir,matrixnames(1).name]);
    case 'object'
        data= readNPY([modeldir,matrixnames(2).name]);
end
%dsm=squareform(VGG_reshape_to_fMRI(squeeze(data(53,:,:))));%second last
dsm=squareform(VGG_reshape_to_fMRI(squeeze(data(44,:,:))));%layer4.0.conv1


targetID=subjectID;
targetDir = fullfile(projectDir, targetID);
dataDir = fullfile(targetDir, 'results');
ds = cell(nRuns,1);
for iRun = 1:nRuns
    data_fn = fullfile(dataDir, sprintf('t_Travel_run00%d_SS%d_aligned-subject-standard-2mm.nii.gz', iRun,smoothingVal));
    ds{iRun} = cosmo_fmri_dataset(data_fn, 'mask', mask_fn,'targets',1:72,'chunks',iRun);
end

%convert individual runs into one.mat col:6runs*72condi
%ds: 1-72:
%‘1Motorrollerfahren’;‘2Fahrradfahren’;‘3Kraulenschwimmen’;‘4Rkenschwimmen’;‘5Biertrinken’;‘6Wassertrinken’;‘7Apfelessen’;‘8Kuchenessen’;‘9Fensterputzen’;‘10Geschirrabwaschen’;‘11Zhneputzen’;‘12Gesichtwaschen’
%dsm
%‘1Motorrollerfahren’;‘2Fahrradfahren’;‘3Kraulenschwimmen’;‘4Rkenschwimmen’;‘5Biertrinken’;‘6Wassertrinken’;‘7Apfelessen’;‘8Kuchenessen’;‘9Fensterputzen’;‘10Zhneputzen’;‘11Geschirrabwaschen’;‘12Gesichtwaschen’
%change dsgroup to dsm label
dsGroup = cosmo_stack(ds);
dsGroup = cosmo_remove_useless_data(dsGroup);
dsGroup = cosmo_fx(dsGroup,@(x)mean(x,1), 'targets', 1);

% Set measure
measure = @cosmo_target_dsm_corr_measure;
measure_dnn = struct();
measure_dnn.target_dsm = dsm;
measure_dnn.metric='squaredeuclidean';

%for the searchlight, define neighborhood for each feature (voxel).
nvoxels_per_searchlight=100;
%choose radius for searchlight, find neighborhoods
fprintf('Creating neighborhoods\n')
nbrhood = cosmo_spherical_neighborhood(dsGroup, 'count', nvoxels_per_searchlight);

%run searchlight
fprintf('Starting MDS searchlight with size %g voxels per searchlight\n', nvoxels_per_searchlight)
mds_res = cosmo_searchlight(dsGroup, nbrhood, measure, measure_dnn);

%Save the data
fprintf('Saving %s...\n',targetID);
cosmo_map2fmri(mds_res, fullfile(outputDir, sprintf('%s_SS%d_%s.nii.gz', foldername,smoothingVal, targetID)));


