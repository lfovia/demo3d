%%
% load corrosponding DMoS and Model parameters 

dataset_model = input('Dataset model parameters .mat file');
dataset_dmos = input('Dataset dmos .mat file');
%%
load (dataset_model)
load (dataset_dmos)

%% Input images
left_image = input('Enter left image file name');
right_image = input('Enter right image file name');
% load left and right images from corrosponding dataset
im_left=imread(left_image);
im_right=imread(right_image);

%% Compute features
stereoque_features = stereoque(im_left,im_right);
%% Perform regression
[predict_label,accuracy, dec_values] = svmpredict(DMoS, stereoque_features', model);





