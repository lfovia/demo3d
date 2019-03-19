% Spatial quality computation
function[SpatialScore] = SQuality(LeftRefName,RightRefName,LeftDistName,RightDistName)
addpath(genpath('/home/sathya/DeMo3D/Codes/Toolbox'));
RefLeftFramePath  = addpath(['/DeMo3D/Codes/' numstr(LeftRefName)]);
RefRightFramePath  = addpath(['/DeMo3D/Codes/' numstr(RightRefName)]);
DistLeftFramePath  = addpath(['/DeMo3D/Codes/' numstr(LeftDistName)]);
DistRightFramePath  = addpath(['/DeMo3D/Codes/' numstr(RightDistName)]);
for i = 1:245
    RefLeftFrameGray  = imread([num2str(LeftRefName) '_' num2str(i) '.png']);
    RefRightFrameGray  = imread([num2str(RightRefName) '_' num2str(i) '.png']);
    DistLeftFrameGray  = imread([num2str(LeftDistName) '_' num2str(i) '.png']);
    DistRightFrameGray  = imread([num2str(RightDistName) '_' num2str(i) '.png']);
    
    SpatialQualityVideo(i,1) = 0.5*(msssim(RefLeftFrameGray, DistLeftFrameGray) + msssim(RefRightFrameGray, DistRightFrameGray));
    
end

SpatialScore = mean(SpatialQualityVideo(:));

end