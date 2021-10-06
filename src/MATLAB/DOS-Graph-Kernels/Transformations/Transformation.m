%% Define transformation functions that can be applied to the DOS before
% computing the distance between them.
classdef Transformation 
   properties
       transformation_name
       transformation_function
       nodes
   end 
   methods %note that these are vector-valued functions, which operate on
           % the interval [0, 2], and are typically symmetric about x=1.
      function T = Transformation(Ttype, nodes)
          % Some transformations depend on x-value, some depend on y-value
          % and some depend on both. For this reason, we pass in both 
          % x and y, which are arrays of quadrature nodes and function
          % evaluations at those nodes.
          % INPUTS:  x: quadrature nodes
          %          y: DOS evaluations at quadrature nodes
          
          T.transformation_name = Ttype;
          T.nodes = nodes;
         
          if Ttype == "id"
            g = @(y) y;
          elseif Ttype == "tan"
            %emphasize extremal eigenvalues
            g = @(y) abs(tan(pi/2 * (nodes - 1))) .* y;
          elseif Ttype == "abs"
            %emphasize extremal eigenvalues
            g = @(y) abs(nodes - 1) .* y;
          end
          T.transformation_function = g; 
      end
   end
end 
