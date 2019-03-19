close all;
clear all;
%%
im=double(imread('wont.bmp'));
[c,l] = wavedec(im,1,'db1');
imr=reshape(c,[533 1016]);
imshow(imr,[]);
