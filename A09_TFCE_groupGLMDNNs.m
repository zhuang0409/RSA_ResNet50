function A09_TFCE_groupGLMDNNs(foldername,level)
%A09_TFCE_groupGLMDNNs('glmRNactionvsobject','RN50')
%A09_TFCE_groupGLMDNNs('glmRNobjectvsaction44','RN50')
%foldername='glmlevelsVGG';
%level='levels_vgg';
%nSub = 23;
nSub = 15;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TFCE
opt = struct();
opt.cluster_stat = 'tfce';
%opt.cluster_stat = 'maxsum';%maxsum
opt.niter = 5000;         % usually should be > 1000
opt.h0_mean = 0;%1/c;
%opt.p_uncorrected=0.001;%maxsum
opt.dh = 0.1;
opt.nproc = 4;
%FOLDER
pathDir = '/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA/';
projectDir = fullfile(pathDir, sprintf('RSA_%s/Group/',foldername));

ds = cosmo_fmri_dataset(fullfile(projectDir, sprintf('GROUP_%s.nii.gz',level)));

ds_sliced = cosmo_slice(ds, 1:(2*nSub), 1);
A = (1:2)';
ds_sliced.sa.targets = repmat(A,nSub,1);
B = (repmat(1:nSub,2,1));
ds_sliced.sa.chunks = B(:);

% Slicing the dataset by targets
split_ds = cosmo_split(ds_sliced, 'targets', 1);
%% object
split_ds{1} = cosmo_remove_useless_data(split_ds{1});

nbrhood2 = cosmo_cluster_neighborhood(split_ds{1});

ds_object = cosmo_montecarlo_cluster_stat(split_ds{1}, nbrhood2, opt);

cosmo_map2fmri(ds_object, fullfile(projectDir, sprintf('TFCE_%s.nii.gz','objectRN50')));

dstarget=struct();
dsGroup=struct();
stats=struct();
dsGroup=split_ds{1};
[~,p,~,stats] = ttest(dsGroup.samples);  %change   
dsGroup.samples(end+1,:) = mean(dsGroup.samples);
dsGroup.samples(end+1,:) = stats.tstat; %t map 
k=nSub+1;
s=nSub+2;
dsGroup.sa.targets(k:s,1) = 3;   %% I definied the targets for the mean and tstat as 3       
dsGroup.sa.chunks(k:s,1) = nSub+1;   %% I def

dstarget = cosmo_slice(dsGroup, length(dsGroup.samples(:,1)), 1);
dstarget.samples(ds_object.samples<1.649)=0;

cosmo_map2fmri(dstarget,fullfile(projectDir, sprintf('TFCE_%s_statmap.nii.gz','objectRN50')));

%% action
split_ds{2} = cosmo_remove_useless_data(split_ds{2});

nbrhood = cosmo_cluster_neighborhood(split_ds{2});

ds_action= cosmo_montecarlo_cluster_stat(split_ds{2}, nbrhood, opt);

cosmo_map2fmri(ds_action, fullfile(projectDir, sprintf('TFCE_%s.nii.gz','actionRN50')));

dstarget=struct();
dsGroup=struct();
dsGroup=split_ds{2};
[~,p,~,stats] = ttest(dsGroup.samples);  %change   
dsGroup.samples(end+1,:) = mean(dsGroup.samples);
dsGroup.samples(end+1,:) = stats.tstat; %t map 
k=nSub+1;
s=nSub+2;
dsGroup.sa.targets(k:s,1) = 3;   %% I definied the targets for the mean and tstat as 3       
dsGroup.sa.chunks(k:s,1) = nSub+1;   %% I def
dstarget = cosmo_slice(dsGroup, length(dsGroup.samples(:,1)), 1);
dstarget.samples(ds_action.samples<1.649)=0;
cosmo_map2fmri(dstarget,fullfile(projectDir, sprintf('TFCE_%s_statmap.nii.gz','actionRN50')));

