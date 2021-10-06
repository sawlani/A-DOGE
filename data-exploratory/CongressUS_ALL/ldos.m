

function ldos(V,E, l, val)

len = length(l);
l1 = zeros(len,1);
l1(l==val)=1;
sum(l1)

e=diag(E);

[se, sind] = sort(e,'ascend');

V = V(:,sind);



sqrldos = (l1'*V).^2;



bins = -1:0.05:1;
numbins = length(bins)-1;

ldosheights = zeros(numbins,1);

for i=1:numbins-1
    ind = (se >= bins(i) & se < bins(i+1));
    
    ldosheights(i) = sum( sqrldos(ind) );
end
ind = (se >= bins(numbins) & se <= bins(numbins+1));
ldosheights(end) = sum( sqrldos(ind) );

figure;
bar(1:numbins, ldosheights)

end






