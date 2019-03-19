close all;
clear all;
%%
% Place and adjust the input reference and distorted video paths.
addpath(genpath('/home/sathya/DeMo3D/Codes/Toolbox'));
LeftRefName = 'Left Video Reference Name';
RightRefName = 'Right Video Reference Name';
LeftDistName =  'Left Video Distorted Name';
RightDistName = 'Right Video Distorted Name';
a = 0.65;
%
[PristineFeatureSet] = MotionDepthJoint(LeftRefFramesWrite,RightRefFramesWrite);
[DistortedFeatureSet] = MotionDepthJoint(LeftDistFramesWrite,RightDistFramesWrite);

[PsiScore] = DistanceComp(PristineFeatureSet,DistortedFeatureSet);
[SpatialScore] = SQuality(LeftRefName,RightRefName,LeftDistName,RightDistName);

DeMo3D = ((SpatialScore.^(a)).*((1./PsiScore).^(1-(a))));


