function [local_features, num_labels] = extract_features_local(N, F, idx)
    labels = F(:,idx);
    labels_nz = labels(labels~=0);
    
    [GC,GR] = groupcounts(labels_nz);
    if length(GC)>100
        top_hundred = maxk(GC,100);
        threshold = top_hundred(100);
        num_labels = 100;
    else
        threshold = 1;
        num_labels = length(GC);
    end
    
    dict = GR(GC>=threshold);
    
    OH_labels = onehotencode(labels',1,'ClassNames',dict)';
    OH_labels(isnan(OH_labels))=0;
    
    
    sym_ldoses = zeros(size(OH_labels,2),200);
    for j=1:size(OH_labels,2)
        sym_ldoses(j,:) = compute_ldos(N, OH_labels(:,j), 200);
    end

    if size(OH_labels,2)<=10
        r = 1:size(OH_labels,2);
        asym_ldoses = zeros(size(OH_labels,2),size(OH_labels,2)-1,200);
    else
        r = randsample(size(OH_labels,2),10,false)';
        asym_ldoses = zeros(10,9,200);
    end

    for j=r
        for k=r
            if j ~= k
                asym_ldoses(j,k,:) = compute_ldos_asym(N, OH_labels(:,j), OH_labels(:,k), 200, sym_ldoses(j,:), sym_ldoses(k,:));
            end
        end
    end

    local_features = [mean(sym_ldoses,1) squeeze(mean(asym_ldoses,[1,2]))'];

end

