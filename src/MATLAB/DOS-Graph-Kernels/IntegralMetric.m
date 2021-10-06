%% Define pointwise distance functions used to compute distance functions
% between graphs via integration of point-wise distance
%
% Some metrics, such as Wasserstein distance, are parametrized by a
% distance matrix, which is computed using the locations of histogram bins,
% so we need to pass in nodes where the functions are to be evaluated. In
% other cases, we might weigh function evaluations using quadrature
% weights, hence the need to pass in weights. 

classdef IntegralMetric 
   properties
       metric_name
       distance_function
       weights %could be quadrature weights or generic weights
       nodes
   end 
   methods %note that these are vector-valued functions
      function M = IntegralMetric(mtype, w, nodes) %w is column vector
         M.nodes = nodes;
         M.weights = w;
         M.metric_name = mtype;
         if mtype == "L2"
            M.distance_function = @(x, y) sqrt((x-y).^2) * w;
         elseif mtype == "L1"
             M.distance_function = @(x, y) abs(x-y) * w;
         elseif mtype == "Lhalf"
             M.distance_function = @(x, y) sqrt(abs(x-y)) * w;
         elseif mtype == "L.75"
             M.distance_function = @(x, y) (abs(x-y)).^(0.75) * w;
         elseif mtype == "L3" 
             M.distance_function = @(x, y) nthroot(sum((x-y).^3), 3) * w;
         elseif mtype == "L1.25" 
             M.distance_function = @(x, y) (abs(x-y)).^(1.25) * w;
         elseif mtype == "L1.5" 
             M.distance_function = @(x, y) (abs(x-y)).^(1.5) * w;
         elseif mtype == "squared"
             M.distance_function = @(x, y) (x-y).^2 * w;
         elseif mtype == "supnorm"
             M.distance_function = @(x, y) max(x, y) * w;
         elseif mtype == "infnorm"
             M.distance_function = @(x, y) min(x, y) * w;
         elseif mtype == "2.5"
             M.distance_function = @(x, y) (x-y).^2.5 * w;
         elseif mtype == "exponential"
             M.distance_function = @(x, y) 0.5 * exp(-20*(x-y).^2) * w; %-20, -25 are good choices 74.9% acc
         elseif mtype == "wasserstein"
             M.distance_function = @(x, y) my_wasserstein_distance(x, y, nodes);
         elseif mtype == "binned_wasserstein"
             M.distance_function = ...
                 @(x, y) my_binned_wasserstein_distance(x, y, nodes);
         elseif mtype == "LP2"
             M.distance_function = @(x, y) sqrt(abs( x.^2 - y.^2 )) * w;
         elseif mtype == "LP3"
             M.distance_function = @(x, y) nthroot(abs( x.^3 - y.^3 ), 3) * w;
         elseif mtype == "LP4"
             M.distance_function = @(x, y) nthroot(abs( x.^4 - y.^4 ), 4) * w;
         elseif mtype == "LP.75"
             M.distance_function = @(x, y) nthroot(abs( x.^(3/4) - y.^(3/4)), 4/3) * w;
         elseif mtype == "LP.5"
             M.distance_function = @(x, y) nthroot(abs( x.^(1/2) - y.^(1/2) ), 2) * w;
         elseif mtype == "KL" %bad
             M.distance_function = @(x, y) sum(x .* (log(x ./ y))) + sum(y .* (log(y ./x)));
         elseif mtype == "hellinger" %good
             M.distance_function = @(x, y) 1/sqrt(2) * sqrt(sum((sqrt(x)-sqrt(y)).^2));
         elseif mtype == "bhattacharyya" %ok?
             M.distance_function = @(x, y) -log(sum(sqrt(x .* y)));
         elseif mtype == "chi_squared" %bad, because removes effect of tall bins
             M.distance_function = @(x, y) 0.5*sum((x - y).^2 ./ (x + y)); 
         elseif mtype == "energy" %bad
             M.distance_function = @(x, y) energy_distance(x, y);
         elseif mtype == "kolmogorov_smirnov"
             M.distance_function = @(x, y) max(abs(x- y));
         elseif mtype == "mmd"
             M.distance_function = @(x, y)... 
             MMD(reshape(x, 1, length(x)), reshape(y, 1, length(y)));
         else
             error("mtype not found");
         end
      end
   end
end



