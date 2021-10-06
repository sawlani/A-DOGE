function gender_features = extract_features_gender(N, F, dict_full)

    idx = 2; % GENDER
    
    labels = F(:,idx);
    dict = dict_full{idx};
    
    OH_labels = onehotencode(labels',1,'ClassNames',dict)';
    OH_labels(isnan(OH_labels))=0;
    
    female = OH_labels(:,1);
    male = OH_labels(:,2);
    
    ldos_f = compute_ldos(N, female, 200);
    ldos_m = compute_ldos(N, male, 200);
    ldos_fm = compute_ldos_asym(N, female, male, 200, ldos_f, ldos_m);
    gender_features = [ldos_f ldos_m ldos_fm];
        
end

