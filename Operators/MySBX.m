classdef MySBX < XOPERATOR
            
    methods(Access = public)
        function obj = MySBX()
            obj.TAG = "SBX";
            obj.MIN_PARENTS = 2;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter setting
            if nargin > 2
                [proC,disC] = deal(Parameter{:});
            else
                [proC,disC] = deal(1,20);
            end

            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
            end

            Parent1 = Parentpool(1:floor(end/2),:);
            Parent2 = Parentpool(floor(end/2)+1:floor(end/2)*2,:);
            [N,D]   = size(Parent1);

            %% Genetic operators for real encoding
            % Simulated binary crossover
            beta = zeros(N,D);
            mu   = rand(N,D);
            beta(mu<=0.5) = (2*mu(mu<=0.5)).^(1/(disC+1));
            beta(mu>0.5)  = (2-2*mu(mu>0.5)).^(-1/(disC+1));
            beta = beta.*(-1).^randi([0,1],N,D);
            beta(rand(N,D)<0.5) = 1;
            beta(repmat(rand(N,1)>proC,1,D)) = 1;

            Offspring = [(Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2
                         (Parent1+Parent2)/2-beta.*(Parent1-Parent2)/2];
            Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N*2, 1));
        end
    end
end