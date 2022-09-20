function A01_runRSA_glmRN50(subjectID,level) 
% Run RSA super/basic/sub vs. RN50-1.
% 22.06.2022 by Zhuang
% example call: A01_runRSA_glmVGG('SUB03_19980219SNFS','basic')
% subjectID = 'SUB03_19980219SNFS';'SUB15_19970428MIRU'
addpath('/Users/zhuang/EEGNet/results_ica/npy-matlab-master/npy-matlab');
%set parameters
fprintf('Starting with subject %s\n', subjectID);
targetID = subjectID;
nRuns = 6;
smoothingVal = 0;
%type='_aligned-subject-3mm-standard-2mm';%'_aligned-subject-1mm';-standard-2mm
%set path
projectDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/UnSmoothed/';
targetDir = fullfile(projectDir, targetID);
dataDir = fullfile(targetDir, 'results');
rsaDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/' ;
outputDir = fullfile(rsaDir, 'RSA_glmRN50');

standardDir = '/usr/local/fsl/data/standard';
mask_fn = fullfile(standardDir, 'MNI152_T1_2mm_brain_mask.nii.gz');
%set dsm of RN50-1
modeldir='/Users/zhuang/Documents/MRI/Projects/Travel/data/Resnet50/outputs/';
matrixnames=dir([modeldir,'*.npy']);
data= readNPY([modeldir,matrixnames(1).name]);

modeldsm=squareform(VGG_reshape_to_fMRI(squeeze(data(1,:,:))));

ds = cell(nRuns,1);
for iRun = 1:nRuns
    data_fn = fullfile(dataDir, sprintf('t_Travel_run00%d_SS%d_aligned-subject-standard-2mm.nii.gz', iRun, smoothingVal));
    ds{iRun} = cosmo_fmri_dataset(data_fn, 'mask', mask_fn,'targets',1:72,'chunks',iRun);
    %ds{iRun}.sa.sub_class=reshape(repmat(1:12,6,1),72,1);%12 kinds of actions at suboridnate level; 6 exemplars.
    %ds{iRun}.sa.basic_class=reshape(repmat(1:6,12,1),72,1);%6 kinds of actions at basic level
    %ds{iRun}.sa.super_class=reshape(repmat(1:3,24,1),72,1);%3 actions at superordinate level
end

%ds: 1-72:
%‘1Motorrollerfahren’;‘2Fahrradfahren’;‘3Kraulenschwimmen’;‘4Rkenschwimmen’;‘5Biertrinken’;‘6Wassertrinken’;‘7Apfelessen’;‘8Kuchenessen’;‘9Fensterputzen’;‘10Geschirrabwaschen’;‘11Zhneputzen’;‘12Gesichtwaschen’

%convert individual runs into one.mat col:6runs*12condi=72   
%unique targets, labels
dsGroup = cosmo_stack(ds);
dsGroup = cosmo_remove_useless_data(dsGroup);
dsGroup = cosmo_fx(dsGroup,@(x)mean(x,1), 'targets', 1);  

%set dsm
dsmdir='/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/progs/';
load([dsmdir,level '.mat']);

% Set measure
modelTypeToDSM{1}=dsm;
modelTypeToDSM{2}=modeldsm;

measure = @cosmo_target_dsm_corr_measure;
measure_args = struct();
measure_args.glm_dsm = {modelTypeToDSM{1}, modelTypeToDSM{2}};
measure_args.center_data = true;
measure_args.metric='squaredeuclidean';

%for the searchlight, define neighborhood for each feature (voxel).
nvoxels_per_searchlight=100;
%choose radius for searchlight, find neighborhoods
fprintf('Creating neighborhoods\n')
nbrhood = cosmo_spherical_neighborhood(dsGroup, 'count', nvoxels_per_searchlight);

%run searchlight
fprintf('Starting glm searchlight with size %g voxels per searchlight\n', nvoxels_per_searchlight)
glm_res = cosmo_searchlight(dsGroup, nbrhood, measure, measure_args);

%Save the data
fprintf('Saving files...\n');
cosmo_map2fmri(glm_res, fullfile(outputDir, sprintf('%s_RN50_SS%d_%s.nii.gz', level,smoothingVal, subjectID)));
