
% =========================================================================
% This function is part of the software release, "Bivariate and
% Spatial-Oriented Correlation Models of Natural Images".
%
% Author: Che-Chun Su (ccsu@utexas.edu)
% =========================================================================

function [ M , alpha , beta , fitted ] = FitMGGD ( x , bin1, bin2 )

% This function fits the data to a multivariate generalized Gaussian
% distribution and finds the three corresponding parameters, M(scatter
% matrix), alpha(scale) and beta(shape).
%
% Input:
%       - x: an D-by-N array representing the data to be fitted, where
%       N is the total number of samples, and D is the dimension.
%       - bin: a cell structure storing D bins, each represents the bin
%       along each dimension. Now only D=2 is supported.
% Output:
%       - M: the scatter matrix
%       - alpha: the scale parameter
%       - beta: the shape parameter
%       - fitted: the fitted distribution/histogram based on the input bins

[ D , N ] = size ( x );

num_iter = 1000;
M_0 = eye ( D );
beta_0 = 0.1;

for i = 1:num_iter
    if det(M_0) == 0
        break;
    end
    
    y = sum ( (x'/M_0.*x') , 2 )'; % 1-by-N
    
    % estimate M ------
    y_temp = y.^beta_0;
    y_temp = repmat ( sum ( y_temp ) , [ 1 N ] ) - y_temp;
    M = x.*repmat ( N*D./(y+y.^(1-beta_0).*y_temp) , [ D 1 ] )*x'/N;
    
    M_0 = M;
    % ------
    
    % estimate beta ------
    beta =( beta_0 - UpdateMGGD_Beta ( N , D , y , beta_0 ) /( UpdateMGGD_Beta_d ( N , D , y , beta_0 )));
    
    if ( abs ( beta - beta_0 ) < 0.0001 )
        break;
    end
    if beta < 0
        beta_0 = abs(beta);
    else
        beta_0 = (beta);
    end
    % ------
    
end

alpha = (beta*sum ( sum ( (x'/M)'.*x ).^beta )/(D*N))^(1/beta);

[ bin_2 , bin_1 ] = meshgrid ( bin2 , bin1 );
bin_x = [ bin_1(:)' ; bin_2(:)' ];
bin_x = sum ( (bin_x'/M.*bin_x') , 2 )'; % 1-by-N

pdf_mggaussian = @( x , N , D , alpha , beta , M ) (1/(det(M)^(1/2)))*(beta*gamma(D/2)/(pi^(D/2)*gamma(D/(2*beta))*2^(D/(2*beta))))*(1/(alpha^(D/2)))*exp(-(x.^beta)/(2*(alpha^beta)));

fitted = pdf_mggaussian ( bin_x , N , D , alpha , beta , M );
fitted = fitted / sum ( fitted(:) );
fitted = reshape ( fitted , size ( bin_2 ) );
fitted_log=log(fitted);


figure, mesh(bin2, bin1, (fitted));grid on;xlabel('Luminance'), ylabel('Disparity');% colormap([0 0 0]);title('with bivariate GGD fitting joint histogram');
xlabel('Disparity'), ylabel('Motion vector');
 figure, contour(bin2, bin1, (fitted_log),'Linewidth',1.5);grid on;
xlabel('Disparity'), ylabel('Motion vector');
%

