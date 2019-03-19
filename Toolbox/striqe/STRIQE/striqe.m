%% The computation of the STRIQE index.
%%
%% Please cite the following work if you intend to use this code:
%% Sameeulla Khan Md, Appina Balasubramanyam, S. S. Channappayya, "Full-reference Stereo Image Quality Assessment Using Natural Stereo Scene Statistics," IEEE Signal Processing Letters.
function score  =  striqe(Il, Ir, il, ir, Dl, Dr, a)
tic;
%%
% Inputs:
% (Il, Ir) --> Ref Stereo Pair 
% (il, ir) --> Test Stereo Pair
% (Dl, Dr) --> Left and Right Disparity Map Of Ref Stereo Pair
% a    --> Alpha Power generally in the range [0.8, 0.85]
% Outputs:
% score --> Objective Quality Score Of Stereo Pair
%% Initializtons

scl_num  =  3; % No Of Scales
ort_num  =  6; % No Of Orientations

if (length(size(Il))  ==  3)
    Il  =  rgb2gray(Il);
    Ir  =  rgb2gray(Ir);
    il  =  rgb2gray(il);
    ir  =  rgb2gray(il);
end
Il  =  double(Il);
Ir = double(Ir);
il = double(il);
ir = double(ir);

%% Perform Steerable Pyramid Decomposition on Inputs
lum_l_ref = spyrdecomp(Il, scl_num, ort_num);
lum_r_ref = spyrdecomp(Ir, scl_num, ort_num);
dis_l_ref = spyrdecomp(Dl, scl_num, ort_num);
dis_r_ref = spyrdecomp(Dr, scl_num, ort_num);
lum_l_test = spyrdecomp(il, scl_num, ort_num);
lum_r_test = spyrdecomp(ir, scl_num, ort_num);

m = 1;
for i = 1:scl_num
    for j = 1:ort_num
        
        % Univariate Fitting of Subbands To Obtain GGD Parameters
        [p_lum_l_ref(m,1), s_lum_l_ref(m,1)] = univ_fit(lum_l_ref{i,j}(:));
        [p_lum_r_ref(m,1), s_lum_r_ref(m,1)] = univ_fit(lum_r_ref{i,j}(:));
        
        [p_lum_l_test(m,1), s_lum_l_test(m,1)] = univ_fit(lum_l_test{i,j}(:));
        [p_lum_r_test(m,1), s_lum_r_test(m,1)] = univ_fit(lum_r_test{i,j}(:));
        
        %Normalized  Root Mean Square Values Of Subbands
        rms_lum_l_ref = sqrt(mean((lum_l_ref{i,j}(:)).^2));
        rms_lum_r_ref = sqrt(mean((lum_r_ref{i,j}(:)).^2));
        rms_dis_l_ref = sqrt(mean((dis_l_ref{i,j}(:)).^2));
        rms_dis_r_ref = sqrt(mean((dis_r_ref{i,j}(:)).^2));
        rms_lum_l_test = sqrt(mean((lum_l_test{i,j}(:)).^2));
        rms_lum_r_test = sqrt(mean((lum_r_test{i,j}(:)).^2));
        
        nrms_lum_l_ref(m,1) = rms_lum_l_ref / (rms_lum_l_ref + rms_lum_r_ref);
        nrms_lum_r_ref(m,1) = rms_lum_r_ref / (rms_lum_l_ref + rms_lum_r_ref);
        nrms_dis_l_ref(m,1) = rms_dis_l_ref / (rms_dis_l_ref + rms_dis_r_ref);
        nrms_dis_r_ref(m,1) = rms_dis_r_ref / (rms_dis_l_ref + rms_dis_r_ref);
        nrms_lum_l_test(m,1) = rms_lum_l_test / (rms_lum_l_test + rms_lum_r_test);
        nrms_lum_r_test(m,1) = rms_lum_r_test / (rms_lum_l_test + rms_lum_r_test);
        
        %% Correlation Parameters
        G_l_ref(m,1) = corr(lum_l_ref{i,j}(:), dis_l_ref{i,j}(:));
        G_r_ref(m,1) = corr(lum_r_ref{i,j}(:), dis_r_ref{i,j}(:));
        
        G_l_test(m,1) = corr(lum_l_test{i,j}(:), dis_l_ref{i,j}(:));
        G_r_test(m,1) = corr(lum_r_test{i,j}(:), dis_r_ref{i,j}(:));
        
        m = m + 1;
    end
end

%% Pooling Of Parameters
p_ref = p_lum_l_ref .* nrms_lum_l_ref + p_lum_r_ref .* nrms_lum_r_ref;
s_ref = s_lum_l_ref .* nrms_lum_l_ref + s_lum_r_ref .* nrms_lum_r_ref;

p_test = p_lum_l_test .* nrms_lum_l_test + p_lum_r_test .* nrms_lum_r_test;
s_test = s_lum_l_test .* nrms_lum_l_test + s_lum_r_test .* nrms_lum_r_test;

G_ref = G_l_ref .* nrms_lum_l_ref + G_r_ref .* nrms_lum_r_ref;
G_test = G_l_test .* nrms_lum_l_test + G_r_test .* nrms_lum_r_test;

%% FeatureVectors
FV1_ref = [ p_ref ; s_ref];
FV2_ref = exp(G_ref);

FV1_test = [ p_test ; s_test];
FV2_test = exp(G_test);

%% Objective Scores
S1 = sum( abs(FV1_ref - FV1_test) ./ max( FV1_ref, FV1_test) );
S2 = sum( abs(FV2_ref - FV2_test) ./ max( FV2_ref, FV2_test) );

score = S1^(a)* S2^(1-a);

    toc;

