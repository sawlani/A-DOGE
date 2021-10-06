function process_congress_ls()

    adjacency_matrix = load("datasets/CongressUS_ALL/A-orig.mat").A;
    N = matrix_normalize(adjacency_matrix,'s');
    
    total_features=3;
    output_features = zeros(200,(1+0.5*total_features*(total_features+1))*50);

    for i = 1:200
        if mod(i,1) == 0
            disp(i)
        end
        if i <= 100
            labels = readmatrix("datasets/CongressUS_ALL/low_shuf/labels_"+string(i-1)+".mat");
            onehot = onehotencode(categorical(labels),2);
        else
            labels = readmatrix("datasets/CongressUS_ALL/high_shuf/labels_"+string(i-101)+".mat");
            onehot = onehotencode(categorical(labels),2);
        end
            

        output_features(i,1:50) = compute_dos(full(N));

        feature_vectors = onehot;
        j=1;
        for k = 1:total_features
            output_features(i,(50*j)+1:50*(j+1)) = compute_ldos(full(N), feature_vectors(:,k));
            j = j+1;
        end
        for k = 1:total_features
            for l=k+1:total_features
                output_features(i,(50*j)+1:50*(j+1)) = compute_ldos_asym(full(N), feature_vectors(:,k), feature_vectors(:,l));
                j = j+1;
            end
        end    
    end

    writematrix(real(output_features), "datasets\CongressUS_ALL\congress-sim3_dos_ldos_lldos.csv");
end