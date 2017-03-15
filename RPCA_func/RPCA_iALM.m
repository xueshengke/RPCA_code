function [A_hat, E_hat, iter, Y] = RPCA_iALM(D, lambda, tolerance, maxIter)
%--------------------------------------------------------------------------
% Xue Shengke, Zhejiang University, March 2017.
% Contact information: see readme.txt
%--------------------------------------------------------------------------
%   RASL inner inexact ALM algorithm
%   
%   Inputs:
%       D            --- batch image matrix
%       lambda       --- trade-off parameter
%       tolerance    --- stop iteration threshold
%       maxIter      --- maximum iteration
%
%   Outputs: 
%       A_hat        --- low-rank component
%       E_hat        --- sparse component
%       iter         --- number of iterations
%       Y            --- Lagrange multiplier
%--------------------------------------------------------------------------
% objective function:
% min ||A||_* + lambda ||E||_1 s.t. D = A + E
% Lagrangian function:
% L(A, E, Y) = ||A||_* + lambda ||E||_1 + <Y, D - A - E> + mu/2 ||D - A - E||_F^2
%--------------------------------------------------------------------------
[m, n] = size(D);

if nargin < 2
    lambda = 1 / sqrt(m);
end

if nargin < 3
    tolerance = 1e-7;
end

if nargin < 4
    maxIter = 1000;
end

DISPLAY_EVERY = 10 ;

Y = D;
norm_two = norm(Y, 2);
norm_inf = norm(Y(:), inf) / lambda;
dual_norm = max(norm_two, norm_inf);
Y = Y / dual_norm;

A_hat = zeros(m, n);
E_hat = zeros(m, n);

mu = 1.25 / norm(D);
rho = 1.25;
mu_max = 1e+10;

d_norm = norm(D, 'fro');

iter = 0;
converged = false;
%% start optimization
while ~converged       
    iter = iter + 1;
    
    % A
    temp_T = D - E_hat + (1/mu)*Y;
    temp_T(isnan(temp_T)) = 0;
    temp_T(isinf(temp_T)) = 0;
    [U, S, V] = svd(temp_T, 'econ');
    diagS = diag(S);
    A_hat = U * diag( pos(diagS-1/mu) ) * V';
    
    % E
    temp_T = D - A_hat + (1/mu)*Y;
    E_hat = sign(temp_T) .* pos( abs(temp_T) - lambda/mu );
%     E_hat = max(temp_T - lambda/mu, 0) + min(temp_T + lambda/mu, 0);
    
    % Y
    Z = D - A_hat - E_hat;
    Y = Y + mu * Z;
    
    % mu
    mu = min(mu*rho, mu_max);    
    
    obj_value = D(:)' * Y(:); 
    
    stop_condition = norm(Z, 'fro') / d_norm;
    rank_A = rank(A_hat);
    E_0 = length(find(abs(E_hat)>0));
    
    if mod(iter, DISPLAY_EVERY) == 0
        disp(['#Iter ' num2str(iter) '  rank(A) ' num2str(rank_A) ...
            '  ||E||_0 ' num2str(E_0) '  obj_value ' num2str(obj_value) ...
            '  stop condition ' num2str(stop_condition)]);
    end        
    
    if stop_condition <= tolerance
        disp('RASL inner loop is converged at:');
        disp(['#Iter ' num2str(iter) '  rank(A) ' num2str(rank_A) ...
            '  ||E||_0 ' num2str(E_0) '  obj_value ' num2str(obj_value) ...
            '  stop condition ' num2str(stop_condition)]);
        converged = true ;
    end
    
    if ~converged && iter >= maxIter
        disp('Maximum iterations reaches') ;
        converged = true ;       
    end
end
