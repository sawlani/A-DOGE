load('C:\Users\Saurabh\Git\FastGEM\datasets\CongressUS_ALL\A-orig.mat')
N = matrix_normalize(A,'s');
F = readmatrix('datasets\CongressUS_ALL\onehotlabels.txt');

polarization_histograms = zeros(size(F,2)/2,150);
for congress=1:size(F,2)/2
    disp(congress)
    dem = F(:,2*congress - 1);
    rep = F(:,2*congress);
    demdos = compute_ldos(full(N), dem);
    polarization_histograms(congress,1:50) = demdos;
    repdos = compute_ldos(full(N), rep);
    polarization_histograms(congress,51:100) = repdos;
    drdos = compute_ldos_asym(full(N), rep, dem);
    polarization_histograms(congress,101:150) = drdos;
end

writematrix(polarization_histograms, "polarization_histograms.csv")