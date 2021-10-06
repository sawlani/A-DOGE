function load_TU_dataset(name)
    if isfile('data/raw/'+name+'/'+name+'_node_attributes.txt')
        attributed = 1;
    else
        attributed = 0;
    end
    if isfile('data/raw/'+name+'/'+name+'_node_labels.txt')
        labeled = 1;
    else
        labeled = 0;
    end
    
    indicator = load('data/raw/'+name+'/'+name+'_graph_indicator.txt');
    no_of_graphs = indicator(length(indicator));
    all_graphs = cell(no_of_graphs,1);
    if isfile('data/raw/'+name+'/'+name+'_node_labels.txt')
        all_labels = cell(no_of_graphs,1);
        all_OH_labels = cell(no_of_graphs,1);
    end
    if isfile('data/raw/'+name+'/'+name+'_node_attributes.txt')
        all_attributes = cell(no_of_graphs,1);
    end
    
    A = load('data/raw/'+name+'/'+name+'_A.txt');
    A = sparse(A(:,1),A(:,2),1);

    if attributed
        attributes = load('data/raw/'+name+'/'+name+'_node_attributes.txt');
    end
    if labeled
        labels = load('data/raw/'+name+'/'+name+'_node_labels.txt');
        onehot = onehotencode(categorical(labels),2);
    end
    
    first_vertex = zeros(no_of_graphs,1);
    last_vertex = zeros(no_of_graphs,1);
    j=1;
    for graph_index = 1:no_of_graphs
        if rem(graph_index, round(no_of_graphs/10))==0
            fprintf('.');
        end
        first_vertex(graph_index) = j;
        while (j <= length(indicator)) && graph_index == indicator(j)
            j = j+1;
        end
        last_vertex(graph_index) = j-1;
        all_graphs{graph_index} = A(first_vertex(graph_index):last_vertex(graph_index), first_vertex(graph_index):last_vertex(graph_index));
        if labeled
            all_labels{graph_index} = labels(first_vertex(graph_index):last_vertex(graph_index),:);
            all_OH_labels{graph_index} = onehot(first_vertex(graph_index):last_vertex(graph_index),:);
        end
        if attributed
            all_attributes{graph_index} = attributes(first_vertex(graph_index):last_vertex(graph_index),:);
        end
    end
    
    if not(isfolder('data/processed/'+name))
        mkdir('data/processed/'+name)
    end
    save('data/processed/'+name+'/'+name+'_all_graphs', 'all_graphs');
    if attributed
        save('data/processed/'+name+'/'+name+'_all_attributes', 'all_attributes');
    end
    if labeled
        save('data/processed/'+name+'/'+name+'_all_OH_labels', 'all_OH_labels');
        save('data/processed/'+name+'/'+name+'_all_labels', 'all_labels');
    end
    copyfile('data/raw/'+name+'/'+name+'_graph_labels.txt', 'data/processed/'+name+'/'+name+'_graph_labels.txt');
    fprintf('done!\n');
end
