import numpy as np
from sklearn.preprocessing import OneHotEncoder

labels = np.loadtxt("labels.txt")
new_labels = np.copy(labels)

state_number = 0
categories = [1,2]
for i in range(1,len(labels)):
    if labels[i-1]>labels[i] and labels[i]==1:
        state_number += 1
        categories.extend([3*state_number+1, 3*state_number+2])
    new_labels[i] += state_number*3

print(categories)

enc = OneHotEncoder(categories = np.array(categories).reshape(1,-1), handle_unknown="ignore", sparse=False)
onehot = enc.fit_transform(new_labels.reshape(-1,1))


np.savetxt("state_aff_labels.txt", new_labels, delimiter='\n', fmt='%d')
np.savetxt("onehotlabels.txt", onehot, delimiter=',', fmt='%d')