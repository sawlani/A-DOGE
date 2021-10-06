function load_congress_LS()
    
    data = load('data\raw\congress-LS\A-orig.mat', 'A');
    A_common = sparse(data.A);
    
    no_of_graphs = 200;
    all_graphs = cell(no_of_graphs,1);
    all_labels = cell(no_of_graphs,1);
    all_OH_labels = cell(no_of_graphs,1);
    
    for graph_index = 1:no_of_graphs
        if rem(graph_index, no_of_graphs/10)==0
            fprintf('.');
        end
        
        all_graphs{graph_index} = A_common;
        
        if graph_index <= 100
            all_labels{graph_index} = load('data\raw\congress-LS\low_shuf\labels_'+string(graph_index-1)+'.txt');
        else
            all_labels{graph_index} = load('data\raw\congress-LS\high_shuf\labels_'+string(graph_index-101)+'.txt');
        end
        
        all_OH_labels{graph_index} = onehotencode(categorical(all_labels{graph_index}),2);
    end
    
    if not(isfolder('data/processed/congress-LS'))
        mkdir('data/processed/congress-LS')
    end
    save('data/processed/congress-LS/congress-LS_all_graphs', 'all_graphs');
    save('data/processed/congress-LS/congress-LS_all_labels', 'all_labels');
    save('data/processed/congress-LS/congress-LS_all_OH_labels', 'all_OH_labels');
    
    graph_labels = zeros(200,1);
    graph_labels(101:200,1) = 1;
    fileID = fopen('data/processed/congress-LS/congress-LS_graph_labels.txt','wt');
    
    fprintf(fileID,'%d\n',graph_labels);
    fprintf('done!\n');
end
