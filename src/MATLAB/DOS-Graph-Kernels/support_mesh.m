% class representing underlying mesh, constructed by specifying type of
% nodes, uniform or Gaussian quadrature, and desired and support for 
% integration I, a subset of [0, 2]
%
% For example, I can be 
% [0, 0.5; 1.2 1.7], i.e. two disjoint intervals belonging to [0, 2]
%
% In this case we can divide up quadrature or uniform nodes between segments
% in proportion to segment size
% 
%
% Te simplest arguments would be 
%
% I = [0, 2], type = "Gaussian", num_nodes = 200
classdef support_mesh
    properties
        I
        type
        num_nodes
        all_nodes
        weights    %weights must sum to 1
        distribution
        interval_lengths
    end
    methods
        function sm = support_mesh(I, type, num_nodes)
            % first compute number of nodes allocated to each bin -- this 
            % number should be proportional to size of bin, aka length of 
            % subinterval
            sm.I = I;
            sm.type = type;
            sm.num_nodes = num_nodes;

            assert (isstring(type) || ischar(type));
            k = size(I, 1); %check number of intervals
            interval_lengths = zeros(k, 1);
            for i = 1:k
                assert (I(i, 2)>I(i, 1));
                interval_lengths(i) = I(i, 2) - I(i, 1);
            end
            total_length = sum(interval_lengths);
            fprintf("total length: %f \n", total_length);
            distribution = zeros(k, 1);
            for i = 1:k
                %disp(interval_lengths(i))
                %disp((interval_lengths(i)/total_length));
                %disp(num_nodes)
                %disp(floor((interval_lengths(i)/total_length) * num_nodes));
                distribution(i) = floor((interval_lengths(i)/total_length) * num_nodes);
            end 
            disp(distribution)
            remainder = num_nodes - sum(distribution);
            disp(remainder)
            for i = 1:remainder
                distribution(mod(i, k)+1) = distribution(mod(i, k)+1) + 1;
            end
            assert(sum(distribution) == num_nodes);
            sm.distribution = distribution;
            sm.interval_lengths = interval_lengths;
            if string(type) == "uniform"
                all_nodes = [];
                for i = 1:k
                    step_size = interval_lengths(i)/(distribution(i)-1);
                    cur_nodes = I(i, 1):step_size:I(i, 2);
                    all_nodes = cat(1, all_nodes, cur_nodes'); 
                end
                sm.weights = ones(num_nodes, 1)/num_nodes;

            elseif string(type) == "gaussian"
                all_nodes = [];
                all_weights = [];
                    for i = 1:k
                        cur_num = distribution(i);
                        bounds = I(i, :);
                        [cur_nodes, cur_weights] = lgwt(cur_num, bounds(1), bounds(2));
                        all_nodes = cat(1, all_nodes, cur_nodes); 
                        all_weights = cat(1, all_weights, cur_weights); 
                    end
                sm.weights = all_weights;
            else
                error("Unsupported support_mesh type");
            end
            sm.all_nodes = all_nodes;
            %checks that nodes and weights vectors are column vectors
            size_nodes = size(sm.all_nodes);
            size_weights = size(sm.weights);
            assert(size_nodes(1)>=size_nodes(2));
            assert(size_weights(1)>=size_weights(2));
        end
        function [NNodes, nodes, weights] = get_attr(obj)
            NNodes = obj.num_nodes;
            nodes = obj.all_nodes;
            weights = obj.weights;
        end
            
    end
end