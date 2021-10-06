myFolder = 'C:\Users\Saurabh\Git\FastGEM\datasets\StateNeighbors';
adjFiles = dir(fullfile(myFolder,'*-A.mat'));
labelFiles = dir(fullfile(myFolder,'*-inout.mat'));

state_inout_histograms = zeros(size(adjFiles,1),150);
statelist = cell(size(adjFiles,1),1);

for state = 1:size(adjFiles,1)
    disp(state)
    load(fullfile(myFolder, adjFiles(state).name));
    load(fullfile(myFolder, labelFiles(state).name));
    
    statelist{state} = adjFiles(state).name(4:5);
    
    N = matrix_normalize(A,'s');
    in = 1-labels;
    out = labels;
    
    indos = compute_ldos(full(N), in);
    state_inout_histograms(state,1:50) = indos;
    outdos = compute_ldos(full(N), out);
    state_inout_histograms(state,51:100) = outdos;
    inoutdos = compute_ldos_asym(full(N), out, in);
    state_inout_histograms(state,101:150) = inoutdos;
    
    
end

writecell(statelist, "statelist.txt")
writematrix(state_inout_histograms, "state_inout_histograms.csv")