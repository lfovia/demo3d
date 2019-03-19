%% 
%% Extraction of certain band of samples with steerable pyramid decomposition
%% Please download the steerable pyramid tool box from the below link 
%% link:-'http://www.cns.nyu.edu/~eero/steerpyr/'
%% Please cite this paper:- Simoncelli, Eero P., and William T. Freeman. "The steerable pyramid: A flexible architecture for multi-scale derivative computation." ICIP. IEEE, 1995.
%%
function [ subband ] = spyrdecomp( img ,  scl_num, ort_num  ) % extracting certain band of samples 
I=log(1+img);
filts = 'sp3Filters';
[lo0filt,hi0filt,lofilt,bfilts,steermtx,harmonics] = eval(filts);
fsz = round(sqrt(size(bfilts,1))); fsz =  [fsz fsz];
nfilts = size(bfilts,2);
nrows = floor(sqrt(nfilts));

%%
[pyr,pind] = buildSpyr(I, 'auto', filts); % building steerable pyramid 

for i=1:scl_num
    for j=1:ort_num
        [lev, lind] = spyrLev(pyr,pind,i);
        lev2 = reshape(lev,prod(lind(1,:)),size(bfilts,2));
        k = steer(lev2,(j-1)*pi/6, harmonics, steermtx); % applying scaling and orientation
        subband{i,j}=reshape(k,lind(1,1),lind(1,2));
        clear k lev lev2
    end
end       