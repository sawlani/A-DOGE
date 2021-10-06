from __future__ import print_function
import networkx as nx
import numpy as np
import scipy.io as sio
from scipy import sparse
from os import path
import argparse
from karateclub import Graph2Vec
import time


def extract_g2v_embeddings(root, dataset):

    print("Extracting Graph2Vec embeddings for dataset ", dataset)

    if path.exists(root+dataset+'/'+dataset+'_all_labels.mat'):
        labeled = True
        print("Using node labels")
    else:
        labeled = False
        print("Using node degrees as labels")

    As = sio.loadmat(root+dataset+'/'+dataset+'_all_graphs.mat')['all_graphs'].flatten()

    if labeled:
        Fs = sio.loadmat(root+dataset+'/'+dataset+'_all_labels.mat')['all_labels'].flatten()
    
    model = Graph2Vec(attributed=labeled, min_count=1, dimensions=1024, wl_iterations=5, workers=1)
    
    all_graphs = []

    for i in range(len(As)):
        print(i, end='\r')
        A = As[i]

        if labeled:
            F = Fs[i].flatten()
            attrs = {j: {'feature': F[j]} for j in range(len(F))}
        else:
            F = A.sum(axis=0)
            attrs = {j: {'feature': F[j]} for j in range(len(F))}

        G = nx.from_scipy_sparse_matrix(A)
        nx.set_node_attributes(G, attrs)
        all_graphs.append(G)

    print("Getting embeddings...", end='')
    t = time.time()
    model.fit(all_graphs)
    embs = model.get_embedding()
    elapsed = time.time() - t
    print("done! In time ", end='')
    print(elapsed)

    return embs


def main():
    parser = argparse.ArgumentParser(description='Generate G2V embeddings for a graph dataset')
    parser.add_argument('--dataset', type=str, help='name of dataset')
    args = parser.parse_args()

    root_orig='../../data/processed/'
    root_emb='../../embeddings/'
    #root_outputs='../../outputs/'

    embeddings = extract_g2v_embeddings(root=root_orig, dataset=args.dataset)
    np.savetxt(root_emb+args.dataset+'/'+args.dataset+'_G2V.csv', embeddings, delimiter=",")

if __name__ == '__main__':
    main()