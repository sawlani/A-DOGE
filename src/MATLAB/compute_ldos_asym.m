function cldos = compute_ldos_asym(normalized_adj, v1, v2, Nbins, ldos_v1, ldos_v2)
    if nargin<4
        Nbins = 50;
    end
    
    if nargin<6
        ldos_v2 = compute_ldos(normalized_adj, v2, Nbins);
    end
    
    if nargin<5
        ldos_v1 = compute_ldos(normalized_adj, v1, Nbins);
    end
    
    if norm(v1)~=0
        v1 = v1/norm(v1);
    end
    if norm(v2)~=0
        v2 = v2/norm(v2);
    end
    
    ldos_v1_plus_v2 = compute_ldos(normalized_adj, v1+v2, Nbins)*norm(v1+v2)*norm(v1+v2);
    cldos = (ldos_v1_plus_v2 - ldos_v1 - ldos_v2)/2;
end

