from __future__ import print_function, division
import numpy as np
import scipy.io as sio
from scipy import sparse
from os import path
from grakel import Graph
import argparse
import time

from grakel.kernels import WeisfeilerLehman, VertexHistogram, Propagation, PropagationAttr, WeisfeilerLehmanOptimalAssignment

def convert_to_grakel(A, labels):
    labeldict = {i: labels[i] for i in range(len(labels))}
    G = Graph(A, node_labels=labeldict)
    return G

def grakel_dataset(root, dataset, use_attributes):
    if path.exists(root+dataset+'/'+dataset+'_all_labels.mat'):
        labeled = True
        print("Using node labels")
    else:
        labeled = False

    if use_attributes and path.exists(root+dataset+'/'+dataset+'_all_attributes.mat'):
        attributed = True
        print("Using node attributes")
    else:
        attributed = False
        

    As = sio.loadmat(root+dataset+'/'+dataset+'_all_graphs.mat')['all_graphs'].flatten()

    if labeled and (not attributed):
        Fs = sio.loadmat(root+dataset+'/'+dataset+'_all_labels.mat')['all_labels']
    elif (not labeled) and attributed:
        Fs = sio.loadmat(root+dataset+'/'+dataset+'_all_attributes.mat')['all_attributes']
    elif labeled and attributed:
        LBLs = sio.loadmat(root+dataset+'/'+dataset+'_all_OH_labels.mat')['all_OH_labels']
        ATTRs = sio.loadmat(root+dataset+'/'+dataset+'_all_attributes.mat')['all_attributes']
        Fs = [np.concatenate((LBL[0], ATTR[0]),axis=1) for LBL,ATTR in zip(LBLs, ATTRs)]

    
    all_graphs = []
    
    for i in range(len(As)):
        print(i, end='\r')
        A = As[i]

        if attributed and (not labeled):
            F = Fs[i][0]
        elif labeled and (not attributed):
            F = Fs[i][0].flatten()
        elif labeled and attributed:
            F = Fs[i]
        else:
            F = np.maximum(1,np.asarray(np.sum(A,axis=1)).flatten())
        
        labeldict = {j: F[j] for j in range(len(F))}
        G = Graph(A, node_labels=labeldict)
        
        all_graphs.append(G)
    return all_graphs


def main():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--dataset', type=str,
                        help='name of dataset')
    parser.add_argument('--kernel', type=str,
                        choices=['PK', 'WL', 'WLOA'],
                        help='type of kernel')
    args = parser.parse_args()

    root_orig='../../data/processed/'
    root_emb='../../embeddings/'
    #root_outputs='../../outputs/'

    if path.exists(root_orig+args.dataset+'/'+args.dataset+'_all_attributes.mat'):
        attributed = True
    else:
        attributed = False

    kernels={
    'PK': PropagationAttr(normalize=True, verbose=1) if attributed else Propagation(normalize=True, verbose=1),
    'WL': WeisfeilerLehman(base_graph_kernel=VertexHistogram, normalize=True, verbose=1),
    'WLOA': WeisfeilerLehmanOptimalAssignment(normalize=True, verbose=1)
    }

    if args.kernel=="PK":
        use_attributes = True
    else:
        use_attributes = False

                
    all_graphs = grakel_dataset(root=root_orig, dataset=args.dataset, use_attributes=use_attributes)

    print("generating", args.kernel, "kernel...", end='')
    t = time.time()
    kernel = kernels[args.kernel]
    K = kernel.fit_transform(all_graphs)
    elapsed = time.time() - t
    print("done! In time ", end='')
    print(elapsed)
    np.savetxt(root_emb+args.dataset+'/'+args.dataset+'_'+args.kernel+'.csv', K, delimiter=",")    
        
if __name__ == '__main__':
    main()