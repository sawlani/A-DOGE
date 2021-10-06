function generate_ADOGE(dataset_name, Nbins)
    
    if nargin<2
        Nbins = 50;
    end
    
    load("data/processed/"+dataset_name+"/"+dataset_name+"_all_graphs.mat");
    dataset.all_graphs = all_graphs;
    clear all_graphs;
    
    is_attr = isfile('data/processed/'+dataset_name+'/'+dataset_name+'_all_attributes.mat');
    is_lbl = isfile('data/processed/'+dataset_name+'/'+dataset_name+'_all_OH_labels.mat');
    
    total_features = 0;

    if is_lbl
        load("data/processed/"+dataset_name+"/"+dataset_name+"_all_OH_labels.mat");
        dataset.all_OH_labels = all_OH_labels;
        clear all_labels;
        total_features = total_features + size(dataset.all_OH_labels{1},2);
    end

    
    if is_attr
        load("data/processed/"+dataset_name+"/"+dataset_name+"_all_attributes.mat");
        dataset.all_attributes = all_attributes;
        clear all_attributes;
        total_features = total_features + size(dataset.all_attributes{1},2);
    end
    
    if total_features == 0
        total_features = 1;
    end
    output_features = zeros(size(dataset.all_graphs,1),(1+0.5*total_features*(total_features+1))*Nbins);
    
    runtimes = zeros(size(dataset.all_graphs,1), 4);
    full_start = tic();
    for i = 1:size(dataset.all_graphs,1)
        if rem(i, round(size(dataset.all_graphs,1)/10))==0
            fprintf('.');
        end
        adjacency_matrix = dataset.all_graphs{i};
        num_nodes = size(adjacency_matrix,1);
        num_edges = nnz(adjacency_matrix);
        
        N = real(matrix_normalize(adjacency_matrix,'s'));
        
        if ~is_lbl && ~is_attr % use degrees as feature if no other feature
            degrees = full(sum(adjacency_matrix))';
            feature_vectors = degrees - mean(degrees);
            total_features=1;
        else
            feature_vectors = [];
            if is_lbl
                feature_vectors = [feature_vectors double(dataset.all_OH_labels{i})];
            end
            if is_attr
                feature_vectors = [feature_vectors double(dataset.all_attributes{i} - mean(dataset.all_attributes{i},1))];
            end
        end
        
        local_start = tic();

        output_features(i,1:Nbins) = compute_dos(full(N), Nbins);

        j=1;
        for k = 1:total_features
            output_features(i,(Nbins*j)+1:Nbins*(j+1)) = compute_ldos(full(N), feature_vectors(:,k), Nbins);
            j = j+1;
        end
        for k = 1:total_features
            for l=k+1:total_features
                output_features(i,(Nbins*j)+1:Nbins*(j+1)) = compute_ldos_asym(full(N), feature_vectors(:,k), feature_vectors(:,l), Nbins, output_features(i,(Nbins*k)+1:Nbins*(k+1)), output_features(i,(Nbins*l)+1:Nbins*(l+1)));
                j = j+1;
            end
        end
        elapsed = toc(local_start);
        runtimes(i,:) = [num_nodes, num_edges, total_features, elapsed];
    end
    total_elapsed = toc(full_start);
    fprintf("done in time %f seconds\n", total_elapsed);
    %dlmwrite("outputs\"+dataset_name+"\"+dataset_name+"_aDOGE_runtimes_"+string(Nbins)+".csv", runtimes);
    
    if not(isfolder('embeddings/'+dataset_name))
        mkdir('embeddings/'+dataset_name)
    end
    
    dlmwrite("embeddings/"+dataset_name+"/"+dataset_name+"_dos_ldos_cldos.csv", real(output_features));
    dlmwrite("embeddings/"+dataset_name+"/"+dataset_name+"_dos.csv", real(output_features(:,1:Nbins)));
    dlmwrite("embeddings/"+dataset_name+"/"+dataset_name+"_dos_ldos.csv", real(output_features(:,1:Nbins*(1+total_features))));
end