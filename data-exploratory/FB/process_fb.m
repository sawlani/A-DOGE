function [runtime, feature_matrix] = process_fb()
    dict_full = cell(1,2);
    myDir = "datasets/unused/FB/attributed-facebook100";
    myFiles = dir(fullfile(myDir,'*.mat'));
    for k = 1:length(myFiles)
        loaded = load("datasets/unused/FB/attributed-facebook100/"+myFiles(k).name);
        local_info = loaded.local_info;
        for i = 1:2
            dict_full{i} = [dict_full{i}, local_info(:,i)'];
        end
    end

    for i = 1:2
            dict_full{i} = unique(dict_full{i});
            dict_full{i}(ismember(dict_full{i},0)) = [];
    end
    
    runtime.nodesizes = zeros(length(myFiles),1);
    runtime.edgesizes = zeros(length(myFiles),1);
    runtime.times = zeros(length(myFiles),1);
    runtime.num_vectors = zeros(length(myFiles),1);
    feature_matrix = zeros(length(myFiles),3000);
    for k = 1:length(myFiles)
        disp(k)
        loaded = load(myDir+"/"+myFiles(k).name);
        runtime.nodesizes(k) = length(loaded.A);
        runtime.edgesizes(k) = sum(loaded.A, 'all')/2;
        %tic
        [f, nv] = extract_features(loaded.A, loaded.local_info, dict_full);
        feature_matrix(k,:) = f;
        runtime.num_vectors(k) = nv;
        %if length(loaded.A)<1e4
        %    [f, nv] = extract_features_explicit(loaded.A, loaded.local_info, dict_full);
        %    feature_matrix(k,:) = f';
        %    runtime.num_vectors(k) = nv;
        %end
        
        %runtime.times(k) = toc;
        %format longG
        %disp([k runtime.nodesizes(k) runtime.edgesizes(k) runtime.times(k) runtime.num_vectors(k)])
        
    end
    writematrix(feature_matrix, "FB_features_3000.csv");
    disp(size(feature_matrix))
end