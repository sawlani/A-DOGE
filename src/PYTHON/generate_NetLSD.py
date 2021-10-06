from __future__ import print_function
import networkx as nx
import numpy as np
import scipy.io as sio
from scipy import sparse
from os import path
import netlsd
import argparse
import time

def extract_netlsd_embeddings(root, dataset):

    print("Extracting NetLSD embeddings for dataset", dataset)

    As = sio.loadmat(root+dataset+'/'+dataset+'_all_graphs.mat')['all_graphs'].flatten()

    all_embeddings = []
    runtimes = np.zeros((len(As),3))

    for i in range(len(As)):
        print(i, end='\r')
        A = As[i]
        num_nodes = A.shape[0]
        num_edges = A.count_nonzero()
        G = nx.from_scipy_sparse_matrix(A)

        t = time.time()
        emb = netlsd.heat(G)
        elapsed = time.time() - t

        runtimes[i,:] = [num_nodes, num_edges, elapsed]

        all_embeddings.append(emb)

    return np.vstack(all_embeddings), runtimes


def main():
    parser = argparse.ArgumentParser(description='Generate NetLSD embeddings for graph dataset')
    parser.add_argument('--dataset', type=str,
                        help='name of dataset')
    args = parser.parse_args()

    root_orig='../../data/processed/'
    root_emb='../../embeddings/'
    #root_outputs='../../outputs/'

    embeddings, runtimes = extract_netlsd_embeddings(root=root_orig, dataset=args.dataset)
    np.savetxt(root_emb+args.dataset+'/'+args.dataset+'_NetLSD.csv', embeddings, delimiter=",")
    #np.savetxt(root_outputs+args.dataset+'/'+args.dataset+'_netlsd_runtimes.csv', runtimes, delimiter=",")

    print(np.sum(runtimes,axis=0))
        
if __name__ == '__main__':
    main()