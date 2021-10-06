function student_features = extract_features_student(N, F, dict_full)
    
    idx = 1; % STUDENT/NONSTUDENT
    
    labels = F(:,idx);
    dict = dict_full{idx};
    
    OH_labels = onehotencode(labels',1,'ClassNames',dict)';
    OH_labels(isnan(OH_labels))=0;
    
    students = OH_labels(:,1);
    nonstudents = OH_labels(:,2)+OH_labels(:,3)+OH_labels(:,4)+OH_labels(:,5);
    
    ldos_s = compute_ldos(N, students, 200);
    ldos_n = compute_ldos(N, nonstudents, 200);
    ldos_sn = compute_ldos_asym(N, students, nonstudents, 200, ldos_s, ldos_n);
    student_features = [ldos_s ldos_n ldos_sn];    
end

