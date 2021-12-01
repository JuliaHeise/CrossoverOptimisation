classdef MyCMAX < XOPERATOR
            
    methods(Access = public)
         function obj = MyCMAX()
             obj.TAG = "CMAX";
             obj.MIN_PARENTS = 2;
         end

         function Offspring = Cross(obj, Parentpool, Parameter)
             if(nargin > 2)
                [Offspring, ~, ~] = obj.Cross_(Parentpool, Parameter);
             else
                 [Offspring, ~, ~] = obj.Cross_(Parentpool);
             end
         end
         
         function [Offspring, m, C] = Cross_(obj, Parentpool, Parameter)
            %% Parameter Setting
            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
                restructure = true;
            else
                restructure = false;
            end

            if nargin > 2
                [sigma, N] = deal(Parameter{:});
                D =  size(Parentpool,2);
                
            else
                % Number of parents
                [N, D] = size(Parentpool);
                sigma = 1;
            end            

            % Center point 
            m = mean(Parentpool);

            %% Covariance Matrix Adaption  
            C = cov(Parentpool);            
            Samples = mvnrnd(zeros(1,D), C, N);

            Offspring = m + sigma .* Samples;
            
             if(restructure)
                 Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1), true);
             end
        end
    end
end