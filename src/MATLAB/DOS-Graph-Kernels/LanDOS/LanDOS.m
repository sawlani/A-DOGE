function [mu,mu_cdf] = LanDOS(NL,k,N,s)
% Applies Lanczos Quadrature to computing the density of states
% Uses area 1 gaussians with variance 2/k for mu (chosen arbitrarily for
% initial testing)
% Note: Theoretically, mu should only be supported inside [0,2], but there
% will often be some mass outside this interval due to approximation error.
% Inputs:
% NL       = Normalized graph laplacian
% k        = Rank of approximation
% N        = Number of runs to average over
% s        = The standard deviation of the Gaussian approximation of the
%            delta function.
% Outputs:
% mu       = density of states function handle
% mu_cdf   = cumulative dos function (both  erf and step function versions available) 
% Compute Lanczos factorization
NL = sparse(NL); % Tell Matlab NL is sparse to accelerate computation (may already be sparse)
% Iterate to get average DOS
tau = zeros(N*k,1); % Preallocate tau
p = zeros(1,N*k); % Preallocate p
for i = 1:1:N
    while(1) %sometimes restarts necessary becuase of ill-conditioning...e.g. for protein
        try 
            z = rand(size(NL,1),1); % Choose random starting vector
            k = min(k, size(NL, 1)); %don't wan't k to be larger than NL
            [~,T] = lan(NL,z,k); % Compute approximate Lanczos factorization
            [V,D] = eigs(T,k); % Compute eigenvector-eigenvalue pairs for T
            tau((i-1)*k+1:i*k,1) = diag(D); % Store ritz values for this iteration
            p(1,(i-1)*k+1:i*k) = V(1,:); % Store needed part of ritz vector for this iteration
            break;
        catch error
        end
    end
end 
% Generate mu
% Compute normalization factor
c = sqrt(2)/s;
MU = 1/2.*(p).^2*(erf(c*(2-tau))-erf(-c*tau));
% Define the unit area gaussian function handle
g = @(x,sigma,mU) (1./sigma./sqrt(2*pi)).*exp(-.5*(x-mU).^2./sigma.^2);
% Generate function handle for mu (vectorized sum)
mu = @(lambda) ((p).^2*g(lambda,s,tau))/MU;
% Error function CDF
mu_cdf = @(lambda) 1/2.*(p).^2*(erf(c*(lambda-tau))-erf(-c*tau))./MU;
% Step Function CDF
%mu_cdf = @(lambda) (p.^2)*(heaviside(lambda-tau)-heaviside(-tau))/((p.^2)*(heaviside(2-tau)-heaviside(-tau)));
end

