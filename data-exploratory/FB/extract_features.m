function [features,num_vectors] = extract_features(A, F, dict_full)

    degrees = sum(A);
    num_vectors = 0;
    N = matrix_normalize(A,'s');
    
    graph_features = compute_dos(N, 200);
    %graph_features = [graph_features.dos graph_features.dosfunctions.A' graph_features.dosfunctions.L'];
    
    student_features = extract_features_student(N, F, dict_full);
    %student_features = [student_features.ldos(:,1)' student_features.ldosfunctions.A(:,1)' student_features.ldosfunctions.L(:,1)' student_features.ldos(:,2)' student_features.ldosfunctions.A(:,2)' student_features.ldosfunctions.L(:,2)'];
    num_vectors = num_vectors + 3;
    
    gender_features = extract_features_gender(N, F, dict_full);
    %gender_features = [gender_features.ldos(:,1)' gender_features.ldosfunctions.A(:,1)' gender_features.ldosfunctions.L(:,1)' gender_features.ldos(:,2)' gender_features.ldosfunctions.A(:,2)' gender_features.ldosfunctions.L(:,2)'];
    num_vectors = num_vectors + 3;
    
    year_features = extract_features_year(N, F);
    %year_features = [year_features.ldos(:,1)' year_features.ldosfunctions.A(:,1)' year_features.ldosfunctions.L(:,1)'];
    num_vectors = num_vectors + 1;
    
    degree_features = extract_features_degree(N, degrees');
    %degree_features = [degree_features.ldos(:,1)' degree_features.ldosfunctions.A(:,1)' degree_features.ldosfunctions.L(:,1)'];
    num_vectors = num_vectors + 1;
    
    [major_features, nv] = extract_features_local(N, F, 3);
    %major_features = [mean(major_features.ldosfunctions.A, 2)' std(major_features.ldosfunctions.A, 0, 2)' mean(major_features.ldosfunctions.L, 2)' std(major_features.ldosfunctions.L, 0, 2)'];
    num_vectors = num_vectors + nv;
    %writematrix(major_features, "FB_major.csv");
    
    [dorm_features, nv] = extract_features_local(N, F, 5);
    %dorm_features = [mean(dorm_features.ldosfunctions.A, 2)' std(dorm_features.ldosfunctions.A, 0, 2)' mean(dorm_features.ldosfunctions.L, 2)' std(dorm_features.ldosfunctions.L, 0, 2)'];
    num_vectors = num_vectors + nv;
    %writematrix(dorm_features, "FB_dorm.csv");
    
    [hs_features, nv] = extract_features_local(N, F, 7);
    %hs_features = [mean(hs_features.ldosfunctions.A, 2)' std(hs_features.ldosfunctions.A, 0, 2)' mean(hs_features.ldosfunctions.L, 2)' std(hs_features.ldosfunctions.L, 0, 2)'];
    num_vectors = num_vectors + nv;
    %writematrix(hs_features, "FB_hs.csv");
    
    features = [graph_features student_features gender_features year_features degree_features major_features dorm_features hs_features];
end

