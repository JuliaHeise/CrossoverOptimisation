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
                weights = rand(1, lambda);
                randomWeights = true;
            end

            %% result array
            [N,D] = size(Parentpool);
            Offspring = zeros(N,D);
            
            %% randomizing area
            b = 0.00025;
            f = 0.5;


            %% loop configuration
            selection = randperm(N);
            p = floor(N/lambda) * lambda;
            m = N - p;

            %% Combine random lambda parents with normalized weights 
            for i = 1:p/lambda
                % repeat lambda times with random weights, to get lambda
                % offsprings
                for j = 1:lambda
                    if(randomWeights == true)
                        weights = rand(1, lambda);
                        beta = zeros(1,lambda);
                        beta(weights<=f) = b*(reallog(2 * weights(weights<=f)));
                        beta(weights>f) = - b*(reallog(2 * (1-weights(weights>f))));
                        n = 1./sum(weights, 2);
                        weights = weights .* n + beta;      
                    end
                    parents = Parentpool(selection((i-1)*lambda+1:i*lambda),:);
                    offspringIndex = (i-1)*lambda+j;
                    Offspring(offspringIndex, :) =  weights * parents;
                end
            end


            %% Last Combination
            if(randomWeights == true)
                weights = rand(1, lambda);
                beta = zeros(1,lambda);
                beta(weights<=f) = b*(reallog(2 * weights(weights<=f)));
                beta(weights>f) = - b*(reallog(2 * (1-weights(weights>f))));
                n = 1./sum(weights, 2);
                weights = weights .* n + beta;      
            else
                weights = weights(:, 1:m);
            end
            parents = [Parentpool(selection(p+1:N),:); Parentpool(selection(1:lambda-m),:)] ;
            
            Offspring(end, :) =  weights * parents;

            
            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1));
            end
        end
    end
end