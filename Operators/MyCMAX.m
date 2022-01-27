classdef MyCMAX < XOPERATOR
          
    properties (SetAccess = private)
        Sigma        
    end
    
    methods(Access = public)
         function obj = MyCMAX(varargin)
            isStr = find(cellfun(@ischar, varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
            for i = isStr(ismember(varargin(isStr),{'Sigma'}))
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.MIN_PARENTS = 2;
            if(isempty(obj.Sigma))
               obj.Sigma = 1;
            end
            obj.TAG = "CMAX" + string(obj.Sigma);
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
            end            

            % Center point 
            m = mean(Parentpool);

            %% Covariance Matrix Adaption  
            C = cov(Parentpool);            
            Samples = mvnrnd(zeros(1,D), C, N);

            Offspring = m + obj.Sigma .* Samples;
            
             if(restructure)
                 Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1), true);
             end
        end
    end
end