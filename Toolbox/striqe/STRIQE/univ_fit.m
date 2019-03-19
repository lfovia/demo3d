%% Extraction of Univariate Genaralized Gaussian (UGGD) parameters
%%
%% The UGGD fit is performed on histogram probabilites. 
%% Please cite the following work if you intend to use this code:

function [expo_p, A_p_sigma]=univ_fit(steered_im)
l=length(steered_im);
mean_abs=(1/l)*sum(abs(steered_im)); % calculating absolute mean
var_abs=(1/l)*sum(abs((steered_im.^2))); % calculating absolute variance
sigma_abs=sqrt(var_abs);
generalized_gaussian_function=(((mean_abs)*(mean_abs)/var_abs)); %the  generalized_gaussian_function variable is helpful in finding the 'expo_p' value
p=0.1:0.1:10;
l=length(p);
n=hist(steered_im,200); % histogram of the input samples
pmf_lum=n/sum(n); % probability density function of the histogram
m=min(steered_im):(max(steered_im)-min(steered_im))/199:max(steered_im);

for i=1:l
    M(i)=((gamma(2/p(i))*gamma(2/p(i)))/(gamma(1/p(i))*gamma(3/p(i)))); % Calcuating the "generalized Gaussian function ratio=M"
end
%plot(p,pq,'r');
xData=M;
yData=p;
y = interp1(xData,yData,generalized_gaussian_function); % extracting the 'expo_p' value from M based on the interpolation
expo_p=y;
A_p_sigma=(sqrt((var_abs*gamma(1/expo_p))/(gamma(3/expo_p)))); % calcualting the 'A_p_sigma' value

%% fitting the GGD curve %%

x=min(steered_im):(max(steered_im)-min(steered_im))/199:max(steered_im);
l=length(x);
for i=1:l
    gg(i)=(expo_p/(2*gamma((1/expo_p))*A_p_sigma))*exp(-(abs((x(i))/A_p_sigma).^(expo_p))); % UGGD samples calculation
end
sum_gg=sum(gg(:));
prob_gg=gg./sum_gg;
figure;plot(prob_gg);
title ('gussian fit');
figure;plot(x,(prob_gg),'b',x,(pmf_lum),'r');title('luminance plot with the GGD Fitting');

figure;plot(x,log(pmf_lum),x,log(prob_gg),'r','LineWidth',2.5); set(gca,'FontSize',14);  % plottening of UGGD curve with unfitted samples
legend({'Before Fitting','After Fitting'},'Location','NorthWest')
xlabel('Coefficients','FontSize',14), ylabel('log(pdf)','FontSize',14), title('GGD Fitting','FontSize',14)
grid on
graph fit