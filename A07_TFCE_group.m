function A07_TFCE_group(foldername,level)
%TFCE_group('RNaction','RNaction')
%TFCE_group('RNobject','RNobject')
%foldername='MDS';
%level='mds';
nSub = 23;
%nSub = 15;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
mkdir(projectDir);

ds = cosmo_fmri_dataset(fullfile(projectDir, sprintf('GROUP_%s.nii.gz',level)));
%dsGroup = cosmo_slice(ds, length(ds.samples(:,1)), 1);
ds = cosmo_slice(ds, 1:nSub, 1);
ds.sa.targets = ones(nSub,1);
ds.sa.chunks = (1:nSub)';
ds = cosmo_remove_useless_data(ds);
nbrhood = cosmo_cluster_neighborhood(ds);

ds_z = cosmo_montecarlo_cluster_stat(ds, nbrhood, opt);

cosmo_map2fmri(ds_z, fullfile(projectDir, sprintf('TFCE_%s.nii.gz',level)));
%statistics map
[~,p,~,stats] = ttest(ds.samples);  %change   
ds.samples(end+1,:) = mean(ds.samples);
ds.samples(end+1,:) = stats.tstat; %t map 
k=nSub+1;
s=nSub+2;
ds.sa.targets(k:s,1) = 3;   %% I definied the targets for the mean and tstat as 3       
ds.sa.chunks(k:s,1) = nSub+1;   %% I definied the chunks for the mean and tstat as nSubs+1

dstarget = cosmo_slice(ds, length(ds.samples(:,1)), 1);
dstarget.samples(ds_z.samples<1.649)=0;
cosmo_map2fmri(dstarget,fullfile(projectDir,sprintf('TFCE_%s_statmap.nii.gz',level)));

