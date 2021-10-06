import numpy as np
import scipy.io as sio
from scipy import sparse
from sklearn.preprocessing import OneHotEncoder

root="../../../datasets/"

enc = OneHotEncoder()

for dataset_name in ["congress-LS"]:
    A = sio.loadmat(root+dataset_name+'/'+'A-orig.mat')['A']
    A = sparse.csr_matrix(A).astype(float)
    
    total_len = 200

    all_graphs = np.zeros((total_len,1), dtype=np.object)
    all_labels = np.zeros((total_len,1), dtype=np.object) #these are node labels
    all_OH_labels = np.zeros((total_len,1), dtype=np.object) #these are node labels
    
    for i in range(total_len):
        print(i)
        all_graphs[i,0] = A
        if i < 100:
            L = np.loadtxt(root+dataset_name+'/low_shuf/labels_'+str(i)+'.txt')
        else:
            L = np.loadtxt(root+dataset_name+'/high_shuf/labels_'+str(i-100)+'.txt')

        
        one_hot = enc.fit_transform(L.reshape(-1,1))
        all_OH_labels[i,0] = one_hot
        all_labels[i,0] = L

    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_graphs.mat', {'all_graphs':all_graphs})
    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_labels.mat', {'all_labels':all_labels})
    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_OH_labels.mat', {'all_labels':all_OH_labels})
    np.savetxt(root+dataset_name+'/'+dataset_name+'_graph_labels.txt', [0]*100 + [1]*100, delimiter='\n', fmt='%d')