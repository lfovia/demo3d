%%
%% Computation of Stereoque score
% Stereoque is a NR-Stereosocpic IQA metric
%% Please cite this paper:-B. Appina, S. Khan, and S. S. Channappayya, "No-reference stereoscopic image quality assessment using natural scene statistics," Signal Processing Image Communication, vol. 43, pp. 1 - 14, 2016.
%% Please download the steerable pyramid tool box and path of toolbox (link:http://www.cns.nyu.edu/~eero/steerpyr/')
%% The result of Stereoque have a set of 18 beta, 18 alpha and 18 correlation parameters.
% stereoque_features --> have the set of stereoque features
%%
function stereoque_features = stereoque(im_left,im_right)

addpath('.../add path to matlabpyrtools Toolbox');
%% steerable filters
filts = 'sp3Filters';
[lo0filt,hi0filt,lofilt,bfilts,steermtx,harmonics] = eval(filts);
fsz = round(sqrt(size(bfilts,1))); fsz =  [fsz fsz];
nfilts = size(bfilts,2);
nrows = floor(sqrt(nfilts));
im_lum_left=double(rgb2gray(im_left));
im_lum_right=double(rgb2gray(im_right));
im_lum_left_log=log(1+im_lum_left);
im_lum_right_log=log(1+im_lum_right);
%% disparity calculation
i1=im_lum_left;
i2=im_lum_right;
maxs=15;
% left image disparity
[fdsp_l dsp_l confidence_l difference_l] = mj_stereo_SSIM(i1,i2, maxs);
dis_l=log(fdsp_l+1);
% right umage disparity
l=flip(im_lum_left,2);
r=flip(im_lum_right,2);
[fdsp_r dsp_r confidence_r difference_r] = mj_stereo_SSIM(i2,i1, maxs);
Dmap_R=flip(dsp_r,2);
dis_r=log(dsp_r+1);
%% Perform Steerable pyramid decomposition on left and right images & disparity maps
[pyr_lum_left,pind_lum_left] = buildSpyr(im_lum_left_log, 'auto', filts);
[pyr_lum_right,pind_lum_right] = buildSpyr(im_lum_right_log, 'auto', filts);
[pyr_dis_left,pind_dis_left] = buildSpyr(dis_l, 'auto', filts);
[pyr_dis_right,pind_dis_right] = buildSpyr(dis_r, 'auto', filts);

m=1;
for i=1:3
    for j=1:6
        %% for luminance images
        %for left image
        [lev_lum_left,lind_lum_left] = spyrLev(pyr_lum_left,pind_lum_left,i);
        lev2_lum_left = reshape(lev_lum_left,prod(lind_lum_left(1,:)),size(bfilts,2));
        steered_im_lum_left{i,j} = steer(lev2_lum_left,(j-1)*pi/6, harmonics, steermtx);
        %for right image
        [lev_lum_right,lind_lum_right] = spyrLev(pyr_lum_right,pind_lum_right,i);
        lev2_lum_right = reshape(lev_lum_right,prod(lind_lum_right(1,:)),size(bfilts,2));
        steered_im_lum_right{i,j} = steer(lev2_lum_right,(j-1)*pi/6, harmonics, steermtx);
        %% for left dsparity map
        [lev_dis_left,lind_dis_left] = spyrLev(pyr_dis_left,pind_dis_left,i);
        lev2_dis_left = reshape(lev_dis_left,prod(lind_dis_left(1,:)),size(bfilts,2));
        steered_im_dis_left{i,j} = steer(lev2_dis_left,(j-1)*pi/6, harmonics, steermtx);
        % for right disparity map
        [lev_dis_right,lind_dis_right] = spyrLev(pyr_dis_right,pind_dis_right,i);
        lev2_dis_right = reshape(lev_dis_right,prod(lind_dis_right(1,:)),size(bfilts,2));
        steered_im_dis_right{i,j} = steer(lev2_dis_right,(j-1)*pi/6, harmonics, steermtx);
        
        
        
        %% RMS calculation
        
        s_steered=size(steered_im_lum_left);
        s1_steered=s_steered(1);
        s2_steered=s_steered(2);
        for i1=1:s1_steered
            for j1=1:s2_steered
                rms_lum_left{i1,j1}=rms(steered_im_lum_left{i1,j1});
                rms_lum_right{i1,j1}=rms(steered_im_lum_right{i1,j1});
                rms_disp_left{i1,j1}=rms(steered_im_dis_left{i1,j1});
                rms_disp_right{i1,j1}=rms(steered_im_dis_right{i1,j1});
            end
        end
        
        %%
        for i3=1:s1_steered
            for j3=1:s2_steered
                pro_left{i3,j3}=rms_lum_left{i3,j3}.* rms_disp_left{i3,j3};
                pro_right{i3,j3}=rms_lum_right{i3,j3}.* rms_disp_right{i3,j3};
            end
        end
        
        
        %%
        
        % Weights calculation
        for i2=1:s1_steered
            for j2=1:s2_steered
                ratio_lum_left{i2,j2}=pro_left{i2,j2}/(pro_left{i2,j2}+pro_right{i2,j2});
                ratio_lum_right{i2,j2}=pro_right{i2,j2}/(pro_left{i2,j2}+pro_right{i2,j2});
            end
        end
        
        %% p,s calculation for left image and disparity map
        
        bin_lum_left=binimage(steered_im_lum_left{i,j});
        bin_lum_right=binimage(steered_im_lum_right{i,j});
        bin_dis_left=binimage(steered_im_dis_left{i,j});
        bin_dis_right=binimage(steered_im_dis_right{i,j});
        %% computing beta nad alpha for the sets(left,right)
        [M_ld1, alpha_ld_l{i,j}, beta_ld_l{i,j}, fitted_ld_l]=FitMGGD([steered_im_lum_left{i,j}'; steered_im_dis_left{i,j}'], bin_lum_left, bin_dis_left);
        [M_ld2, alpha_ld_r{i,j}, beta_ld_r{i,j}, fitted_ld_r]=FitMGGD([steered_im_lum_right{i,j}'; steered_im_dis_right{i,j}'], bin_lum_right, bin_dis_right);
        
        
        %% computing correlation
        
        corr_left{i,j}=corr((steered_im_lum_left{i,j}),(steered_im_dis_left{i,j}));
        corr_right{i,j}=corr((steered_im_lum_right{i,j}),(steered_im_dis_right{i,j}));
        
        %% feature vectors
        
        overall_p=ratio_lum_left{i,j}.*(beta_ld_l{i,j})+ratio_lum_right{i,j}.*beta_ld_r{i,j};
        overall_s=ratio_lum_left{i,j}.*(alpha_ld_l{i,j})+ratio_lum_right{i,j}.*alpha_ld_r{i,j};
        overall_corr=ratio_lum_left{i,j}.*(corr_left{i,j})+ratio_lum_right{i,j}.*corr_right{i,j};
        
        gamma_overall(m,1)=(overall_corr);
        beta_overall(m,1)=overall_p;
        alpha_overall(m,1)=overall_s;
        
        
        m=m+1;
        
    end
    
end
stereoque_features=[beta_overall;alpha_overall;gamma_overall ];
