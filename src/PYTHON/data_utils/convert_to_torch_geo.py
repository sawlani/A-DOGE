import numpy as np
import torch

from torch_geometric.data import InMemoryDataset
from torch_geometric.utils import from_networkx

class SimpleGraphDataset(InMemoryDataset):
    def __init__(self, name, data_list):
        self.name = name
        self.data, self.slices = self.collate(data_list)

        self.__indices__ = None
        self.transform = None

    @property
    def num_node_labels(self):
        if self.data.x is None:
            return 0
        for i in range(self.data.x.size(1)):
            x = self.data.x[:, i:]
            if ((x == 0) | (x == 1)).all() and (x.sum(dim=1) == 1).all():
                return self.data.x.size(1) - i
        return 0

    @property
    def num_node_attributes(self):
        if self.data.x is None:
            return 0
        return self.data.x.size(1) - self.num_node_labels

    @property
    def num_edge_labels(self):
        if self.data.edge_attr is None:
            return 0
        for i in range(self.data.edge_attr.size(1)):
            if self.data.edge_attr[:, i:].sum() == self.data.edge_attr.size(0):
                return self.data.edge_attr.size(1) - i
        return 0

    @property
    def num_edge_attributes(self):
        if self.data.edge_attr is None:
            return 0
        return self.data.edge_attr.size(1) - self.num_edge_labels

    def __repr__(self):
        return '{}({})'.format(self.name, len(self))


def convert_to_torch_geo(root, dataset):

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
    
    if emb=='G2V':
        model = Graph2Vec(attributed=labeled, min_count=1, dimensions=1024, wl_iterations=5)
    elif emb=='FGSD':
        model = FGSD()
    elif emb=='NetLSD':
        model = NetLSD()

    all_embeddings = []
    runtimes = np.zeros((len(As),3))

    for i in range(len(As)):
        print(i, end='\r')
        A = As[i]
        num_nodes = A.shape[0]
        num_edges = A.count_nonzero()

        if labeled:
            F = Fs[i].flatten()
            attrs = {j: {'feature': F[j]} for j in range(len(F))}
        else:
            attrs = {}

        t = time.time()
        emb = A_to_emb(A,attrs, model)
        elapsed = time.time() - t

        runtimes[i,:] = [num_nodes, num_edges, elapsed]

        all_embeddings.append(emb)

    return np.vstack(all_embeddings), runtimes

