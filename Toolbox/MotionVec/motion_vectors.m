addpath('/home/balu/Desktop/Depth_Motion');
for v=10:1:10
    filepath = ['src0',num2str(v),'_hrc00_s1920x1080p25n400v0.avi_Color_Video.mat'];
    if v==10
        filepath = ['src10_hrc00_s1920x1080p25n325v0.avi_Color_Video.mat'];
    end
video = load(filepath);
frames = video.VideoSeqFrameExt;

for i=1:1:14
frame1 = rgb2gray(frames(:,:,:,i));
frame2 = rgb2gray(frames(:,:,:,i+1));

% hbm = vision.BlockMatcher('ReferenceFrameSource','Input port','BlockSize',[8 8]);

% motion = step(hbm,frame1,frame2);
% halphablend = vision.AlphaBlender;
% img12 = step(halphablend,frame2,frame1);

disp('Started')
tic
motion = motionEstTSS(frame2,frame1,8,7);
toc
filename = ['mv_v',num2str(v),'_',num2str(i),'.mat'];
save(filename,'motion')
% imshow(img12);
% hold on;
% quiver(X(:),Y(:),real(motion(:)),imag(motion(:)),0);

end
end