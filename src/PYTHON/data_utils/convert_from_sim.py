import numpy as np
import scipy.io as sio
from scipy import sparse
from sklearn.preprocessing import OneHotEncoder

root="../../../datasets/"

enc = OneHotEncoder()

for dataset_name in ["congress-sim3", "mig-sim3"]:

    L = sio.loadmat(root+dataset_name+'/labels.mat')['labels']

    one_hot = enc.fit_transform(L)
    
    total_len = 200

    all_graphs = np.zeros((total_len,1), dtype=np.object)
    #all_labels = np.zeros((total_len,1), dtype=np.object) #these are node labels
    
    for i in range(total_len):
        print(i)
        if i < 100:
            A = sio.loadmat(root+dataset_name+'/within/B1-'+str(i+1)+'.mat')['B1']
        else:
            A = sio.loadmat(root+dataset_name+'/random/B2-'+str(i-99)+'.mat')['B2']

        A = sparse.csr_matrix(A).astype(float)
        all_graphs[i,0] = A

        #all_labels[i,0] = one_hot

    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_graphs.mat', {'all_graphs':all_graphs})
    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_labels.mat', {'all_labels':all_labels})
    np.savetxt(root+dataset_name+'/'+dataset_name+'_graph_labels.txt', [0]*100 + [1]*100, delimiter='\n', fmt='%d')