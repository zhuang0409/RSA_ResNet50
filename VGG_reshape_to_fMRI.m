%% convert the order of stimuli as the same with fMRI data
function X_sorted=VGG_reshape_to_fMRI(X)

orderOfActions=[1:1:54,61:1:66,55:1:60,67:1:72];

X_sorted=X(orderOfActions, orderOfActions);