function [Q, T] = lan(A, q, k)
% An Implementation of the Lanczos Algorithm
% Inputs:
% A        = nxn real matrix
% q        = nx1 starting vector (does not need to be normalized)
% k        = The Rank of the Approximation
% Outputs:
% Q        = nxk matrix with orthogonal columns
% T        = kxk tridiagonal matrix

n = length(q);
Q = zeros(n, k+1);
T = zeros(k+1, k+1);

Q(:,1) = q/norm(q);

if isnumeric(A)
  A = @(x)(A*x);
end

for i = 1:k
  if i == 1
    q = A(Q(:,i));
  else
    q = A(Q(:,i)) - T(i-1,i)*Q(:,i-1);
  end
  alpha = q'*Q(:,i);
  q = q - alpha*Q(:,i);
  q = q - Q(:,1:i-1)*(Q(:,1:i-1)'*q); % Reorthogonalization step
  beta = norm(q);
  Q(:,i+1) = q/beta;
  T(i,i) = alpha;
  T(i+1,i) = beta;
  T(i,i+1) = beta;
end

% Debug: Check correctness
%norm( A*Q(:, 1:k) - Q(:, 1:k+1)*T(1:k+1, 1:k), 'fro')

Q = Q(:, 1:k);
T = T(1:k, 1:k);
