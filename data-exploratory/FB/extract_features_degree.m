function degree_features = extract_features_degree(N, degrees)
    degrees = degrees - mean(degrees);    
    degree_features = compute_ldos(N, degrees, 200);
end

