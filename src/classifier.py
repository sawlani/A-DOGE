from __future__ import print_function, division

import numpy as np
import pandas as pd

import argparse
from sklearn.model_selection import train_test_split, cross_validate, RepeatedStratifiedKFold, PredefinedSplit
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import GridSearchCV
from scipy.spatial import distance


def create_aggregate_features(ldos, family='cheb', no_func=100, hist_dim=50):

    functions = {}

    if family=='poly':
        functions['lambda1'] = np.arange(-1+(1/hist_dim), 1+(1/hist_dim), 2/hist_dim)
        functions['lambda-1'] = 1./functions['lambda1']
        for i in range(2,1+(no_func//2)):
            functions['lambda'+str(i)] = np.multiply(functions['lambda1'], functions['lambda'+str(i-1)])
            functions['lambda-'+str(i)] = 1./functions['lambda'+str(i)]

    elif family=='cheb':

        functions['cheb0'] = np.ones(hist_dim)
        functions['cheb1'] = np.arange(-1+(1/hist_dim), 1+(1/hist_dim), 2/hist_dim)
        for i in range(2,no_func):
            functions['cheb'+str(i)] = np.multiply(2*functions['cheb1'], functions['cheb'+str(i-1)]) - functions['cheb'+str(i-2)]

    aggregate_features = np.zeros((ldos.shape[0],len(functions)))

    for i,key in enumerate(functions):
        val = functions[key]
        aggregate_features[:,i] = np.matmul(ldos,val)
    return aggregate_features


def create_aggregate_df(feat_df, family='cheb', no_func=100, hist_dim=50):
    print("Creating aggregate features")

    agg_feat_df = np.zeros((feat_df.shape[0], int(feat_df.shape[1]*no_func/hist_dim)))

    for i in range(feat_df.shape[1]//hist_dim):
        curr_ldos = feat_df[:,i*hist_dim:(i+1)*hist_dim]
        agg_feat_df[:,i*no_func:(i+1)*no_func] = create_aggregate_features(curr_ldos, family=family, no_func=no_func, hist_dim=hist_dim)

    return agg_feat_df


def compute_gamma(embeddings, samples = 100):
    indices = np.random.choice(embeddings.shape[0], 100, replace=False)
    sampled_embeddings = embeddings[indices,:]
    
    pairwise_distances = distance.cdist(sampled_embeddings, sampled_embeddings)**2
    median_of_distances = np.median(pairwise_distances)
    gamma = 1/median_of_distances

    return gamma


def run_classification(features, labels, kernel='precomputed', outer_iters = 10, scaling='std'):

    if kernel=='precomputed':
        scaling='none'

    if scaling=='minmax':
        scaler = MinMaxScaler()
        X = scaler.fit_transform(features)
    elif scaling=='std':
        scaler = StandardScaler()
        X = scaler.fit_transform(features)
    elif scaling=='kernel':
        X = features
    else:
        X = features
    
    y = labels

    
    model = SVC(kernel=kernel)

    if kernel=="rbf":
        parameter_space = {
            'C': [10**i for i in range(-3,4)],
            #'gamma': [10**i for i in range(-3,4)]+[compute_gamma(X)],
            'gamma': [compute_gamma(X)],
        }
    else:
        parameter_space = {
            'C': [10**i for i in range(-3,4)]
        }

    
    rskfcv = RepeatedStratifiedKFold(n_splits=10, n_repeats=outer_iters, random_state=4702149)
    clf = GridSearchCV(model, parameter_space, cv=rskfcv, verbose=3, return_train_score=True, n_jobs=-1)
    clf.fit(X, y)

    means = clf.cv_results_['mean_test_score']
    train_means = clf.cv_results_['mean_train_score']
    stds = clf.cv_results_['std_test_score']
    train_stds = clf.cv_results_['std_train_score']
    param_list = clf.cv_results_['params']

    return means, train_means, stds, train_stds, param_list


def run_single_split_classification(features, labels, TVT_split, kernel='precomputed', scaling='std'):

    if kernel=='precomputed':
        scaling='none'

    if scaling=='minmax':
        scaler = MinMaxScaler()
        X = scaler.fit_transform(features)
    elif scaling=='std':
        scaler = StandardScaler()
        X = scaler.fit_transform(features)
    else:
        X = features
    
    y = labels


    num_train, num_val, num_test = TVT_split

    if kernel == "precomputed":
        X = X[:, :num_train+num_val]
    
    X_trainval = X[:num_train+num_val, :]
    y_trainval = y[:num_train+num_val]

    X_test = X[num_train+num_val:, :]
    y_test = y[num_train+num_val:]


    model = SVC(kernel=kernel)

    if kernel=="rbf":
        parameter_space = {
            'C': [10**i for i in range(-3,4)],
            'gamma': [compute_gamma(X)]
        }
    else:
        parameter_space = {
            'C': [10**i for i in range(-3,4)]
        }

    validation_fold = [-1]*num_train + [0]*num_val
    ps = PredefinedSplit(test_fold=validation_fold)

    clf = GridSearchCV(model, parameter_space, cv=ps, verbose=3, return_train_score=True, n_jobs=-1)
    clf.fit(X_trainval, y_trainval)

    validation_means = clf.cv_results_['mean_test_score']
    train_means = clf.cv_results_['mean_train_score']
    validation_stds = clf.cv_results_['std_test_score']
    train_stds = clf.cv_results_['std_train_score']
    param_list = clf.cv_results_['params']

    test_score = clf.best_estimator_.score(X_test, y_test)

    return validation_means, train_means, validation_stds, train_stds, param_list, test_score


def main():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--dataset', type=str,
                        help='name of dataset')
    parser.add_argument('--embedder', type=str,
                        help='type of embedder/kernel')
    parser.add_argument('--dos_features', type=str, default="all",
                        choices=['all', 'hist', 'poly', 'cheb', 'polycheb'],
                        help='subset of DOS/LDOS features used (default: all')
    parser.add_argument('--hist_dim', type=int, default=50,
                        help='histogram dimension (default: 50')
    parser.add_argument('--agg_feature_count', type=int, default=100,
                        help='number of aggregate poly/cheb features used (default: 100')
    args = parser.parse_args()

    print("Dataset:", args.dataset)
    print("Embedder:", args.embedder)

    root_emb='../embeddings/'+args.dataset+'/'
    root_orig='../data/processed/'+args.dataset+'/'
    #root_outputs='../outputs/'+args.dataset+'/'

    feat = pd.read_csv(root_emb+args.dataset+"_"+args.embedder+".csv", header=None).values
    labels = pd.read_csv(root_orig+args.dataset+"_graph_labels.txt", header=None).values.flatten()
    
    if 'dos' in args.embedder:
        
        kernel = 'rbf'
        scaling = "std"

        if args.dos_features=='poly':
            poly = create_aggregate_df(feat, family='poly', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            feat = poly
        elif args.dos_features=='cheb':
            cheb = create_aggregate_df(feat, family='cheb', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            feat = cheb
        elif args.dos_features=='polycheb':
            poly = create_aggregate_df(feat, family='poly', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            cheb = create_aggregate_df(feat, family='cheb', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            feat = np.concatenate((poly, cheb),axis=1)
        elif args.dos_features=='all':
            poly = create_aggregate_df(feat, family='poly', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            cheb = create_aggregate_df(feat, family='cheb', no_func=args.agg_feature_count, hist_dim=args.hist_dim)
            feat = np.concatenate((feat, poly, cheb), axis=1)


    elif args.embedder in ['PK', 'WL', 'WLOA', 'DOSGK']:
        kernel='precomputed'
        scaling='none'
    else:
        kernel='rbf'
        scaling='std'

    print("Feature matrix size:", feat.shape)
    print("Running classification with", kernel, "kernel.")
    if args.dataset == "BANDPASS":
        TVT_split = (3000,1000,1000)
        means, train_means, stds, train_stds, param_list, test_score = run_single_split_classification(feat, labels, TVT_split, kernel=kernel, scaling=scaling)
    else:
        means, train_means, stds, train_stds, param_list = run_classification(feat, labels, kernel=kernel, scaling=scaling)

    for mean, std, train_mean, train_std, params in zip(means, stds, train_means, train_stds, param_list):
        print("Train: %0.3f (+/-%0.03f) for %r" % (train_mean, train_std, params), end='\t')
        print("Test: %0.3f (+/-%0.03f) for %r" % (mean, std, params))

    if args.dataset in ["BANDPASS"]:
        print("\nTEST SCORE=", test_score)

if __name__ == '__main__':
    main()