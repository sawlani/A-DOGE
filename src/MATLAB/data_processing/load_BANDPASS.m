function load_BANDPASS()
    
    dataset = load('data\raw\BANDPASS\BANDPASS.mat');
    
    no_of_graphs = size(dataset.Y, 1);
    all_graphs = cell(no_of_graphs,1);
    all_attributes = cell(no_of_graphs,1);
    
    
    for graph_index = 1:no_of_graphs
        if rem(graph_index, no_of_graphs/10)==0
            fprintf('.');
        end
        
        all_graphs{graph_index} = sparse(squeeze(dataset.A(graph_index,:,:)));
        all_attributes{graph_index} = dataset.F(graph_index,:)';
    end
    
    if not(isfolder('data/processed/BANDPASS'))
        mkdir('data/processed/BANDPASS')
    end
    save('data/processed/BANDPASS/BANDPASS_all_graphs', 'all_graphs');
    save('data/processed/BANDPASS/BANDPASS_all_attributes', 'all_attributes');
    
    graph_labels = dataset.Y;
    fileID = fopen('data/processed/BANDPASS/BANDPASS_graph_labels.txt','wt');
    fprintf(fileID,'%d\n',graph_labels);
    fprintf('done!\n');
end
