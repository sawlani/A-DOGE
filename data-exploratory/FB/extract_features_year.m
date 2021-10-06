function year_features = extract_features_year(N, F)
    idx = 6; % YEAR
    
    years = F(:,idx);
    years(years~=0) = years(years~=0) - mean(years(years~=0));
    year_features = compute_ldos(N, years, 200);    
end

