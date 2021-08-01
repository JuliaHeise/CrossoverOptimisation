classdef MyCMAX < XOPERATOR
            
    methods(Access = public)
         function obj = MyCMAX()
             obj.TAG = "CMAX";
             obj.MIN_PARENTS = 2;
         end

        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter Setting
            Problem = PROBLEM.Current();
            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
            end

            if nargin > 2
                sigma = deal(Parameter{:});
            else
                sigma = 1;
            end

            % Number of parents
            N = size(Parentpool,1);

            % Center point 
            centerPoint = mean(Parentpool);


            %% Covariance Matrix Adaption  
            Cov = cov(Parentpool);
            Samples = mvnrnd(zeros(1,Problem.D), Cov, N);
            Offspring = centerPoint + sigma .* Samples;
            Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1));
        end
    end
end