import numpy as np
import scipy.io as sio
from scipy import sparse
from torch_geometric.datasets import GNNBenchmarkDataset
from torch_geometric.utils import to_scipy_sparse_matrix

root="../datasets/"
for dataset_name in ["MNIST", "CIFAR10"]:

    dataset_train = GNNBenchmarkDataset(root=root, name=dataset_name, split='train')
    dataset_val = GNNBenchmarkDataset(root=root, name=dataset_name, split='val')
    dataset_test = GNNBenchmarkDataset(root=root, name=dataset_name, split='test')

    total_len = len(dataset_train)+len(dataset_val)+len(dataset_test)

    all_graphs = np.zeros((total_len,1), dtype=np.object)
    all_attributes = np.zeros((total_len,1), dtype=np.object)
    all_labels = np.zeros(total_len)
    for i,data in enumerate(dataset_train+dataset_val+dataset_test):
        print(i)
        m = data.edge_index
        spm = to_scipy_sparse_matrix(m).astype(float) #do not leave this as INT, there is a bug in savemat when you use INT
        all_graphs[i,0] = spm

        attr = data.x.numpy()
        all_attributes[i,0] = attr

        label = data.y.numpy()
        all_labels[i] = label

    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_graphs.mat', {'all_graphs':all_graphs})
    sio.savemat(root+dataset_name+'/'+dataset_name+'_all_attributes.mat', {'all_attributes':all_attributes})
    np.savetxt(root+dataset_name+'/'+dataset_name+'_graph_labels.txt', all_labels, delimiter='\n', fmt='%d')