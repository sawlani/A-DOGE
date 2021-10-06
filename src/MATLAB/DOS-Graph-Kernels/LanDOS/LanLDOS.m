function [mu] = LanLDOS(NL,z,k)
% Applies Lanczos Quadrature to computing the LOCAL density of states
% Uses area 1 gaussians with variance 2/k for mu (chosen arbitrarily for
% initial testing)
% Note: Theoretically, mu should only be supported inside [0,2], but there
% will often be some mass outside this interval due to approximation error.
% Inputs:
% NL       = NxN Normalized graph laplacian
% z        = Nx1 Feature vector
% k        = Rank of approximation
% Outputs:
% mu       = density of states function handle
% Compute Lanczos factorization
NL = sparse(NL); % Tell Matlab NL is sparse to accelerate computation
[~,T] = lan(NL,z,k); % Is z a good choice of starting vector?
[V,D] = eigs(T,k); % Compute eigenvector-eigenvalue pairs for T
tau = diag(D);
p = V(1,:);
% Define unit area gaussian function handle
g = @(x,sigma,MU) (1./sigma./sqrt(2*pi)).*exp(-.5*(x-MU).^2./sigma.^2);
% Generate mu
mu = @(lambda) norm(z)^2.*((p).^2*g(lambda,2/k,tau));
end

