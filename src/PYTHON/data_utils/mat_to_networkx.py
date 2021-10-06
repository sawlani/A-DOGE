import networkx as nx
import numpy as np
from os import path
import scipy.io as sio

def mat_to_networkx(root, dataset):

    if path.exists(root+dataset+'/'+dataset+'_all_labels.mat'):
        labeled = True    
    else:
        labeled = False

    if path.exists(root+dataset+'/'+dataset+'_all_attributes.mat'):
        attributed = True    
    else:
        attributed = False

    As = sio.loadmat(root+dataset+'/'+dataset+'_all_graphs.mat')['all_graphs'].flatten()

    if labeled:
        Fs = sio.loadmat(root+dataset+'/'+dataset+'_all_labels.mat')['all_labels'].flatten()
    elif attributed:
        Fs = sio.loadmat(root+dataset+'/'+dataset+'_all_attributes.mat')['all_attributes'].flatten()
    
    all_graphs = []
    for i in range(len(As)):
        print(i, end='\r')
        A = As[i]
        if labeled or attributed:
            F = Fs[i].todense()
            attrs = {j: {'feature': np.array(F[j]).flatten()} for j in range(F.shape[0])}
        else:
            attrs = {}

        G = nx.from_scipy_sparse_matrix(A)
        nx.set_node_attributes(G, attrs)

        all_graphs.append(G)

    return all_graphs
