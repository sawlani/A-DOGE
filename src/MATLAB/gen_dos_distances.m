function K = gen_dos_distances(N,k,s, support_mesh, mtype, ttype, dataset, varargin)
% Generates kernel matrix for selected dataset
% Inputs:
% N        = Number of terms to average for global DOS
% k        = Rank of approximation
% s        = The standard deviation of the Gaussian approximation of the
%            delta function.
% I        = Interval of integration (I=[a,b] should be a subset of [0,2])
% mtype    = metric type, or type of distance function we use to compare
%            DOS graphs
%            Options: 'squared', 'wasserstein', 'L1', etc. See Metrics
%            folder
%
% ttype    = transformation type which may be applied to 
%            Options: 'id', 'tan', etc. See Transformations folder
%            
% Outputs:
% K        = kernel matrix

p=inputParser();
default_edge_duplicated = true; 
default_edge_attributed = false;
addParameter(p, "edge_duplicated", default_edge_duplicated, @islogical);
addParameter(p, "edge_attributed", default_edge_attributed, @islogical);
parse(p, varargin{:});
tic;
fprintf('Reading Graph Data...');

all_graphs = load("data/processed/"+dataset+"/"+dataset+"_all_graphs.mat");
all_graphs = all_graphs.all_graphs;

[fileGL, msg] = fopen('./data/processed/'+dataset+"/"+dataset+'_graph_labels.txt','r');
if fileGL < 0 
     error('Failed to open file "%s" because: "%s"',...
        './data/processed/'+dataset+"/"+dataset+'_graph_labels.txt', msg); 
end
GL = textscan(fileGL,'%f'); % Read graph indicator
GL = cell2mat(GL);
fclose(fileGL);

NG = length(GL);
fprintf(' completed in %f seconds.\n',toc);
% Generate DOS for each graph
tic;
fprintf("Generating DOS for each graph");
MU = cell(NG,1); % Initialize cell array of DOS functions (one per graph)
for i = 1:NG
    if rem(i, round(NG/10))==0
            fprintf('.');
        end
    %fprintf("is duplicated %f\n ", p.Results.edge_duplicated)
    %disp(".")
    %disp(".")
    %disp(which("/NLap"))
    A = all_graphs{i};
    NA = matrix_normalize(A,'s');
    NL = eye(size(A,1))-NA;
    %NL = NLap(V(idx(i):idx(i+1)-1,:),"edge_duplicated", is_duplicated);
    [~, mu_cdf] = LanDOS(NL,k,N,s); % Compute DOS
    MU{i} = mu_cdf;
end
% Generate DOS for graphs 1 through NG
fprintf(' completed in %f seconds.\n',toc);
tic;
fprintf("Generating the kernel matrix");

% Generate gauss quadrature nodes
%NNodes = 20;
%[nodes,w] = lgwt(NNodes,I(1),I(2));
[NNodes, nodes, w] = get_attr(support_mesh);

% Perform initial evaluation of each DOS function at the prescribed nodes
M = zeros(NG,NNodes);
for i = 1:1:NG
    for j = 1:NNodes
        M(i,j) = MU{i}(nodes(j));
    end
end

% store TRANSFORMED rows of M, so we can individually pass them into parfor loop, instead
% of passing in M and then slicing + apply transformation
trans = Transformation(ttype, nodes).transformation_function;
M_rows = cell(NG, 1);
for i = 1:NG
    M_rows{i} = trans(M(i, :)); 
end
%fprintf("."); 

% Generate the kernel matrix using prespecified metric
K = zeros(NG, NG);
func = IntegralMetric(mtype, w, nodes).distance_function;
for i = 1:NG
    row_i = M_rows{i};
    %fprintf("%f\n", i);
    for j = 1:1:NG
        %fprintf("(%f, %f)\n", i, j);
        row_j = M_rows{j};
        cur_dist = func(row_i, row_j); 
        K(i, j) = cur_dist;
    end
    %if mod(i, floor(0.05*NG)) == 0 %5 percent mark, track progress
    %    fprintf(".");  
    %end
end 
fprintf('. Completed in %f seconds.\n',toc);
end
