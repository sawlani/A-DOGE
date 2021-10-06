import numpy as np
import scipy.io as sio
from scipy import sparse

root="../datasets/"
dataset_name = "BANDPASS"

dataset = sio.loadmat(root+dataset_name+'/'+dataset_name+'.mat')
As = dataset['A']
Fs = dataset['F']
Ys = dataset['Y'].flatten()

total_len = As.shape[0]

all_graphs = np.zeros((total_len,1), dtype=np.object)
all_attributes = np.zeros((total_len,1), dtype=np.object)
all_labels = np.zeros(total_len)
for i in range(total_len):
    print(i)
    A = sparse.csr_matrix(As[i]).astype(float)
    all_graphs[i,0] = A

    all_attributes[i,0] = Fs[i].reshape(-1,1)

    all_labels[i] = Ys[i]

sio.savemat(root+dataset_name+'/'+dataset_name+'_all_graphs.mat', {'all_graphs':all_graphs})
sio.savemat(root+dataset_name+'/'+dataset_name+'_all_attributes.mat', {'all_attributes':all_attributes})
np.savetxt(root+dataset_name+'/'+dataset_name+'_graph_labels.txt', all_labels, delimiter='\n', fmt='%d')