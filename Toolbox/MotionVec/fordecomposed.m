clc;clear all;
addpath('/home/balu/Desktop/Depth_Motion/MotionVectors');

name = {'Barrier','Basket','Boxers','Hall','Laboratory','Persons_reporting','Phone_call','Soccer','Tree_branches','Umbrella'};
frame_list = zeros(10,15);
for i = 1:1:10
    for j = 1:1:5
        frame_list(i,j) = j;
    end
end

frame_list(1,6:10) = 151:155;
frame_list(1,11:15) = 316:320;
frame_list(2,6:10) = 271:275;
frame_list(2,11:15) = 371:375;
frame_list(3,6:15) = 6:15;
frame_list(4,6:15) = 6:15;
frame_list(5,6:15) = 201:210;
frame_list(6,6:15) = 6:15;
frame_list(7,6:15) = 6:15;
frame_list(8,6:10) = 176:180;
frame_list(8,11:15) = 201:205;
frame_list(9,6:15) = 6:15;
frame_list(10,6:15) = 6:15;

depth_bins = 200;
motion_bins = 200;

for i = 1:10
    path1 = [pwd,'/correct_plots/decomposed/','video_',num2str(i)];
    mkdir(path1);
    for j = 1:14
        
        if i == 8 || i == 10
            break;
        end
        
        path = [path1,'/','frame_',num2str(frame_list(i,j))];
        mkdir(path)
        motion_file = ['mv_v',num2str(i),'_',num2str(j),'.mat'];
        motion_struct = load(motion_file);
        mv = motion_struct.motion;
        m_u = reshape(mv(1,:),[240,135])';
        motu = flip(m_u);
        m_v = reshape(mv(2,:),[240,135])';
        motv = flip(m_v);
        m_mag_1 = sqrt(m_u.^2 + m_v.^2);
        m_dec_mag = spyrdecomp(m_mag_1,1,1);
        m_mag = m_dec_mag{1,1};
     
  
        depth_file = [name{i},'_s960x540p25n400v0_forward_frame0',num2str(frame_list(i,j),'%03i'),'.dbl'];
        actual_depth = read_depthmap_dbl(depth_file);
        actual_depth = actual_depth + abs(min(actual_depth(:))); %Making depth positives
        fun = @(block_struct)mean2(block_struct.data);
        reduced_depth_1 = blockproc(actual_depth,[4,4],fun);
        red_dec_depth = spyrdecomp(reduced_depth_1,1,1);
        reduced_depth = red_dec_depth{1,1};
          
        mat_mag_depth = [reduced_depth(:) m_mag(:)];

        joint_hist_mag_depth = hist3(mat_mag_depth,[depth_bins motion_bins]);
        joint_prob_mag_depth = joint_hist_mag_depth./sum(joint_hist_mag_depth(:));
        
        hist_mag = hist(m_mag(:),motion_bins);
        prob_mag =  hist_mag./sum(hist_mag(:));
        
        hist_depth = hist(reduced_depth(:),depth_bins);
        prob_depth = hist_depth./sum(hist_depth(:));
        
        multi_prob_mag_depth = prob_depth'*prob_mag;
        
        cor_matrix = corrcoef(reduced_depth,m_mag);
        
        
        hist(m_mag(:),motion_bins);title('Histogram of motionMag');
        saveas(gcf,[[path,'/'],['histogram_mag_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        hist(reduced_depth(:),depth_bins);title('Histogram of Depth');
        saveas(gcf,[[path,'/'],['histogram_depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        mesh(joint_prob_mag_depth);xlabel('MotionMag');ylabel('Depth');title('Joint Prob of Depth and Mag');
        saveas(gcf,[[path,'/'],['Joint_prob_mag_depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
               
        mesh(multi_prob_mag_depth);xlabel('MotionMag');ylabel('Depth');title('Multiplied prob of Depth and Mag');
        saveas(gcf,[[path,'/'],['Multi_prob_mag_depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        contour(joint_prob_mag_depth);xlabel('Motion_mag');ylabel('Depth');title('Joint Contour of Depth and Mag');
        saveas(gcf,[[path,'/'],['Joint_contour_mag_depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.fig']])

        contour(multi_prob_mag_depth);xlabel('Motion_mag');ylabel('Depth');title('Multiplied Contour of Depth and Mag');
        saveas(gcf,[[path,'/'],['Multi_contour_mag_depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.fig']])
       
        quiver(motu,motv);axis off;
        saveas(gcf,[[path,'/'],['Quiver_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        imshow(reduced_depth,[]);
        saveas(gcf,[[path,'/'],['Decomp_Disparity_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        imshow(reduced_depth_1,[]);
        saveas(gcf,[[path,'/'],['Disparity_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        imshow(m_mag_1,[]);
        saveas(gcf,[[path,'/'],['Magnitude_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        imshow(m_mag,[]);
        saveas(gcf,[[path,'/'],['Decomp_Magnitude_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.png']])
        
        save([[path,'/'],['Reduced_decomp_Depth_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.mat']],'reduced_depth')
        save([[path,'/'],['Decomp_magnitude_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.mat']],'m_mag')
        save([[path,'/'],['Correlation_coeff_vid',num2str(i,'%02i'),'frame',num2str(frame_list(i,j),'%03i'),'.mat']],'cor_matrix')
        
    end
end
 
        
        
 
        