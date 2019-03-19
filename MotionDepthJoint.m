% BGGD feature computation
function [FeatureSet] = MotionDepthJoint(LeftVideoName,RightVideoName)
FrameExt(LeftVideoName);
FrameExt(RightVideoName);
addpath(genpath('/home/sathya/DeMo3D/Codes/Toolbox'));
addpath(['/DeMo3D/Codes/' numstr(LeftVideoName)]);
addpath(['/DeMo3D/Codes/' numstr(RightVideoName)]);
%LeftFramePath  = ['/DeMo3D/Codes/' numstr(LeftVideoName)];
%RightFramePath  = ['/DeMo3D/Codes/' numstr(RightVideoName)];
for i = 1:245
    VideoSeqLeftFrameGray  = imread([num2str(LeftVideoName) '_' num2str(i) '.png']);
    VideoSeqLeftFrameGray1  = imread([num2str(LeftVideoName) '_' num2str(i+1) '.png']);
    VideoSeqRightFrameGray  = imread([num2str(RightVideoName) '_' num2str(i) '.png']);
    FrameResol = size(VideoSeqLeftFrameGray);
    
    motion = motionEstTSS(VideoSeqLeftFrameGray1,VideoSeqLeftFrameGray,8,7);
    H1 = floor(FrameResol(1)/8);
    V1 = floor(FrameResol(2)/8);
    motion1=motion(:,1:H1*V1);
    m_u = reshape(motion1(1,:),[H1,V1])';
    m_v = reshape(motion1(2,:),[H1,V1])';
    Motionmag = sqrt((m_u.^2) + (m_v.^2));
    
    Depth_vi_left_right  =  mj_stereo_SSIM(VideoSeqLeftFrameGray, VideoSeqRightFrameGray, 36);
    Depthfr=Depth_vi_left_right(:,1:FrameResol(1));
    
    for j1=1:3
        for k1=1:6
            Motionsubband1 = spyrdecomp(Motionmag,j1,k1);
            Depthsubband1 = spyrdecomp(Depthfr,j1,k1);
        end
    end
    m=1
    for j2=1:3
        for k2=1:6
            Motionsubband = Motionsubband1{j2,k2};
            Flow=Motionsubband(:);
            
            Depthsubband1 = Depthsubband1{j2,k2};
            fun = @(block_struct)mean2(block_struct.data);
            red_dep_leftref = blockproc(Depthsubband1,[8 8],fun);
            DepthSubband=red_dep_leftref(:);
            
            bin_lum_left=binimage(Flow(:));
            bin_lum_right=binimage(DepthSubband(:));
            [M_ld1, alpha_ld_l, beta_ld_l, fitted_ld_l]=FitMGGD([Flow'; DepthSubband'], bin_lum_left, bin_lum_right);
            
            EigVal = eig(M_ld1);
            EigValMin = min(EigVal(:));
            EigValMax = max(EigVal(:));
            PsiScore = ((EigValMax-EigValMin)./(EigValMax+EigValMin)).^2;
            
            covarmat(m,i)=PsiScore;
            
            m=m+1;
            FeatureSet = covarmat;
            
            
        end
    end
    
end

end

