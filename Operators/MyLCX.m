classdef MyLCX < XOPERATOR
        
    methods(Access = public)
        function obj = MyLCX()
            obj.TAG = "LCX";
            obj.MIN_PARENTS = 3;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter Setting
            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
                restructure = true;
            else
                restructure = false;
            end

            %% Weights of linear combinations from parameter or random
            if nargin > 2
                if(size(Parameter,2) == 1)
                    lambda = Parameter;
                    weights = rand(1, lambda);
                    randomWeights = true;
                else
                    [lambda, weights] = deal(Parameter{:});
                    % normalize weights
                    n = 1./sum(weights, 2);
                    weights = weights .* n;
                    randomWeights = false;
                end
            else
                lambda  = 3;
                randomWeights = true;
            end

            %% result array
            [N,D] = size(Parentpool);
            portion = floor(N/lambda);
            Parents = cell(lambda,1);
            idx = 1;
            for i = 1:lambda
               Parents{i} = Parentpool(idx:idx+portion-1, :); 
               idx = idx+portion;
            end
            RestParents = Parentpool(idx:end,:);
            rest = size(RestParents, 1);
            
            Offspring = zeros(N,D);
            
            %% randomizing area
            b = 0.025;
            f = 0.5;
            
            offspringIndex = 1;
            for i = 1:portion
                if(randomWeights == true)
                    weights = rand(1, lambda);
                    beta = zeros(1,lambda);
                    beta(weights<=f) = b*(reallog(2 * weights(weights<=f)));
                    beta(weights>f) = - b*(reallog(2 * (1-weights(weights>f))));
                    n = 1./sum(weights, 2);
                    weights = repmat(weights .* n + beta,1, 2);      
                end
                for j = 1:lambda                    
                    for k = 1:lambda
                        Offspring(offspringIndex+k-1, :) = ...
                            Offspring(offspringIndex+k-1, :) ...
                            + weights(1,j+k) * Parents{j}(i,:);   
                    end                   
                end
                offspringIndex = offspringIndex+k;
            end
            
            if(randomWeights == true)
                weights = rand(1, rest);
                beta = zeros(1,rest);
                beta(weights<=f) = b*(reallog(2 * weights(weights<=f)));
                beta(weights>f) = - b*(reallog(2 * (1-weights(weights>f))));
                n = 1./sum(weights, 2);
                weights = repmat(weights .* n + beta,1, 2);      
            end
            for j = 1:rest                    
                for k = 1:rest
                    Offspring(offspringIndex+k-1, :) = ...
                        Offspring(offspringIndex+k-1, :) ...
                        + weights(1,j+k) * RestParents(i,:);   
                end                   
            end
            
            
            
            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1));
            end
        end
    end
end