function generate_FGSD(dataset_name, scale_down)

    if nargin<2
        scale_down = 1;
    end
    %Load mat file containg cell of graphs adjacency matrices.

    load("data/processed/"+dataset_name+"/"+dataset_name+"_all_graphs.mat");
    
    %Set histogram parameters.
    nbins=14000/scale_down;   
    binwidth=0.001*scale_down;

    %Create empty (sparse) feature matrix;
    X=zeros(size(all_graphs,1),nbins); %or X=sparse(N,nbins) for memory efficiency.
    
    runtimes = zeros(size(all_graphs,1), 3);
    full_start = tic();
    for i=1:size(all_graphs,1)
        if rem(i, round(size(all_graphs,1)/10))==0
            fprintf('.');
        end

        %Load adjacency matrix.
        A=all_graphs{i};
        num_nodes = size(A,1);
        num_edges = nnz(A);

        %Compute graph Laplacian L (or Lnorm or Lrw).
        L=diag(sum(A,2))-A;
        %L=eye(size(A,1))- matrix_normalize(A, 's');


        %Compute f(L).
        local_start = tic();
        fL=fast_compute_fgsd(L,'polyharmonic',1);

        %Create all-one column vector.
        ones_vector=ones(length(A),1);

        %Compute FGSD matrix.
        S=diag(fL)*ones_vector'+ones_vector*diag(fL)'-2*fL;

        %Compute (sparse) feature matrix.
        X(i,:)= histcounts(S(:),nbins,'Binwidth',binwidth,'BinLimits',[0,nbins*binwidth]); %Note that MATLAB histcounts function can limit the maximum nbins that are allowed. You can increase the limit by editing the histcounts.m file.
        elapsed = toc(local_start);
        runtimes(i,:) = [num_nodes, num_edges, elapsed];
    end
    
    total_elapsed = toc(full_start);
    fprintf("done in time %f seconds\n", total_elapsed);
    %dlmwrite("outputs/"+dataset_name+"/"+dataset_name+"_FGSD_runtimes_"+string(nbins)+".csv", runtimes);
    
    %Remove all zeros-column from feature matrix.
    X(:,~any(X,1)) = [];
    
    if not(isfolder('embeddings/'+dataset_name))
        mkdir('embeddings/'+dataset_name)
    end
    
    dlmwrite("embeddings/"+dataset_name+"/"+dataset_name+"_FGSD.csv", X);
    

end

