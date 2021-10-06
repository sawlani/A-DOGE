function load_congress_mig_noise(name)
    
    data = load('data\raw\'+name+'\labels.mat', 'labels');
    labels_common = data.labels;
    OH_labels_common = onehotencode(categorical(labels_common),2);
    
    no_of_graphs = 200;
    all_graphs = cell(no_of_graphs,1);
    all_labels = cell(no_of_graphs,1);
    all_OH_labels = cell(no_of_graphs,1);
    
    for graph_index = 1:no_of_graphs
        if rem(graph_index, no_of_graphs/10)==0
            fprintf('.');
        end
        
        if graph_index <= 100
            temp = load('data\raw\'+name+'\within\B1-'+string(graph_index)+'.mat');
            all_graphs{graph_index} = sparse(temp.B1);
        else
            temp = load('data\raw\'+name+'\random\B2-'+string(graph_index-100)+'.mat');
            all_graphs{graph_index} = sparse(temp.B2);
        end
        
        all_labels{graph_index} = labels_common;
        all_OH_labels{graph_index} = OH_labels_common;        
    end
    
    if not(isfolder('data/processed/'+name))
        mkdir('data/processed/'+name)
    end
    save('data/processed/'+name+'/'+name+'_all_graphs', 'all_graphs', '-v7.3');
    save('data/processed/'+name+'/'+name+'_all_labels', 'all_labels');
    save('data/processed/'+name+'/'+name+'_all_OH_labels', 'all_OH_labels');
    
    graph_labels = zeros(200,1);
    graph_labels(101:200,1) = 1;
    fileID = fopen('data/processed/'+name+'/'+name+'_graph_labels.txt','wt');
    
    fprintf(fileID,'%d\n',graph_labels);
    
    fprintf('done!\n');
end
