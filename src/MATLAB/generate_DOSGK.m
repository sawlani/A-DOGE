function generate_DOSGK(dataset_name)
    N = 100; % cheb moments
    k = 20; 
    s = 0.005; 
    sm = support_mesh([0, 2], "uniform", 200); % histogram size
    mtype = "L1"; % distance for kernel
    ttype = "id";
    
    generation_time = tic();
    K_DOS_distances = gen_dos_distances(N,k,s, sm, mtype, ttype, dataset_name);
    gamma = 1/median(K_DOS_distances, 'all');
    K_DOS_kernel = exp(-1*gamma*K_DOS_distances);
    total_elapsed = toc(generation_time);
    fprintf("Total time: %f seconds\n", total_elapsed);

    %writematrix(K_DOS_kernel, "datasets\"+dataset+"\"+dataset+"_DOSGK.csv");
    if not(isfolder('embeddings/'+dataset_name))
        mkdir('embeddings/'+dataset_name)
    end
    dlmwrite("embeddings/"+dataset_name+"/"+dataset_name+"_DOSGK.csv", K_DOS_kernel);
    
    %S = 50; %length of random walk
    %Nz = 2000; % no of probe vectors
    
    %[K_PDOS, ~, ~] = gen_LDOS_moment_kernel(S, Nz, dataset);
    
    %writematrix(K_PDOS, "..\..\FastGEM\datasets\doskernels\"+dataset+"_PDOSGK.csv");
    %writematrix((K_DOS+K_PDOS)/2, "..\..\FastGEM\datasets\doskernels\"+dataset+"_DOSPDOSGK.csv");
end

