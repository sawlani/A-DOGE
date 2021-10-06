function [mu] = GetDOS(V,idx,N,k,s,i)
% Generates DOS function from Reddit/Collab dataset
% Inputs:
% V        = Adjacency vector (from Read___())
% idx      = Graph index vector (from Read___())
% N        = Number of terms to average for DOS
% k        = Rank of approximation
% s        = The standard deviation of the Gaussian approximation of the
%            delta function.
% i        = The index of the graph to compute the DOS for
% Outputs:
% mu       = ith DOS function from the Reddit dataset
% Generate Normalized Laplacian
if ((i < size(idx,2))&&(i~=1))
    NL = NLap(V(idx(i-1)+1:idx(i),:));
    % Compute DOS
    mu = LanDOS(NL,k,N,s);
elseif i == size(idx,2)
    NL = NLap(V(idx(end-1)+1:end,:));
	mu = LanDOS(NL,k,N,s);
elseif i == 1
    NL = NLap(V(1:idx(1),:));
	mu = LanDOS(NL,k,N,s);
end
end



