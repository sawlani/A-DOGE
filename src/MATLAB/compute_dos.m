function dos = compute_dos(normalized_adj, Nbins)
    if nargin<2
        Nbins = 50;
    end
    
    c = moments_cheb_dos(normalized_adj);
    cf = filter_jackson(c);
    x = linspace(-1,1,Nbins+1);
    dos = plot_chebhist(cf,x);
    
end

