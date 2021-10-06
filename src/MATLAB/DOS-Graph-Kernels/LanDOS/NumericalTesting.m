%{
% Testing the Performance of Generating Graph DOS (wrt k)
[V] = ReadGraph(".\datasets\CA-CondMat.txt"); % Read graph data
NL = NLap(V); % Generate Normalized Laplacian
N = 20;
times = zeros(40,1);
for k = 5:5:200
    k
    tic;
    LanDOS(NL,k,N);
    times(k/5)=toc;
end
steps = [5:5:200];
plot(steps,times);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title("Log-log axes plot of runtime as a function of k");
xlabel("k");
ylabel("mean computation time (seconds)")
order = log(times(end-1)/times(1))/log(steps(end-1)/steps(1))
%}
%{
% Testing the Performance of Generating Graph DOS (wrt N)
[V] = ReadGraph("CA-CondMat.txt"); % Read graph data
NL = NLap(V); % Generate Normalized Laplacian
k = 30;
times = zeros(40,1);
for N = 5:5:200
    N
    tic;
    LanDOS(NL,k,N,.01);
    times(N/5)=toc;
end
steps = [5:5:200];
plot(steps,times);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title("Log-log axes plot of runtime as a function of N");
xlabel("N");
ylabel("mean computation time (seconds)")
order = log(times(end-1)/times(1))/log(steps(end-1)/steps(1))
%}
%{
% Test DOS function evaluation time on nodes
[V] = ReadGraph(".\datasets\CA-CondMat.txt"); % Read graph data
% Generate quadrature nodes
NNodes = 100;
[nodes,w] = lgwt(NNodes,0,2);
NL = NLap(V); % Generate Normalized Laplacian
N = 20;
EvalTimes = zeros(40,1);
ProdTimes = zeros(40,1);
for k = 5:5:200
    k
    mu = LanDOS(NL,k,N);
    v = zeros(size(nodes))';
    for i = 1:1:1000
        tic;
        v = mu(nodes');
        EvalTimes(k/5) = EvalTimes(k/5)/1000 + toc;
    end
    EvalTimes(k/5)=toc;
    for i = 1:1:1000
        tic;
        I = v*nodes;
        ProdTimes(k/5) = ProdTimes(k/5)/1000 + toc;
    end
end
steps = [5:5:200];
plot(steps,EvalTimes);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title("Log-log axes plot of runtime as a function of k");
xlabel("k");
ylabel("mean computation time (seconds)")
order = log(EvalTimes(end-1)/EvalTimes(1))/log(steps(end-1)/steps(1))
%}
% Test Kernel Computation Performance
[V,idx, ys] = ReadReddit();
k = 20;
times = zeros(10,1);
for N = 10:10:100
    N
    tic;
    [KL1] = BarebonesGenerateKernel(V,idx,N,k,.005,[0,2]);
    times(N/10)=toc;
end
steps = [10:10:100];
plot(steps,times);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title("Log-log Axes Plot of Kernel Generation Runtime as a Function of N");
xlabel("N");
ylabel("mean computation time (seconds)")
order = log(times(end-1)/times(1))/log(steps(end-1)/steps(1))

