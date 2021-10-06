function plotDOS(V, idx, n, m, N, k, color)
    for i = n:m
        fprintf("iteration: %d\n", i-n+1);
        mu2 = GetDOS(V, idx, N, k, .01, i);
        hold on;
        plot(.0005:.0005:2.0, mu2(.0005:.0005:2.0), 'color', color);
    end
end

%501 - 1500 is negative class
%density of eigenvalues instead of granular view of eigenvalues
