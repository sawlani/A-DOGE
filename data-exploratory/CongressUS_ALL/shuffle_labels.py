import numpy as np
labels = np.loadtxt("labels.txt")
boundaries = [0]
for i in range(1,len(labels)):
    if labels[i-1]>labels[i] and labels[i]==1:
        boundaries.append(i)

boundaries.append(len(labels))
np.savetxt("boundaries.txt", boundaries, delimiter='\n', fmt='%d')
no_of_congresses = len(boundaries)-1

for i in range(100):
    congress = np.random.randint(no_of_congresses)
    print(i,congress)
    changed_labels = np.copy(labels)
    for _ in range(50):
        a,b = np.random.randint(boundaries[congress], boundaries[congress+1], size=2)
        changed_labels[a], changed_labels[b] = changed_labels[b], changed_labels[a]

    np.savetxt("low_shuf/labels_"+str(i)+".txt", changed_labels, delimiter='\n', fmt='%d')



for i in range(100):
    congress = np.random.randint(no_of_congresses)
    print(i,congress)
    changed_labels = np.copy(labels)
    for _ in range(300):
        a,b = np.random.randint(boundaries[congress], boundaries[congress+1], size=2)
        changed_labels[a], changed_labels[b] = changed_labels[b], changed_labels[a]

    np.savetxt("high_shuf/labels_"+str(i)+".txt", changed_labels, delimiter='\n', fmt='%d')