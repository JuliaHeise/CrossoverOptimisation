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
                restructure = true;
            else
                restructure = false;
            end
            [N,D]   = size(Parentpool);
            
            portion = floor(N/2);
            rest = N - portion * 2;
            
            Parent1 = Parentpool(1:portion,:);
            Parent2 = Parentpool(portion+1:portion*2,:);
            o = randi(portion*2, rest, 1);
            Rest = [Parentpool(portion*2+1:end,:); Parentpool(o,:)];

            %% Genetic operators for real encoding
            % Simulated binary crossover
            beta = zeros(portion,D);
            mu   = rand(portion,D);
            beta(mu<=0.5) = (2*mu(mu<=0.5)).^(1/(disC+1));
            beta(mu>0.5)  = (2-2*mu(mu>0.5)).^(-1/(disC+1));
            beta = beta.*(-1).^randi([0,1],portion,D);
            beta(rand(portion,D)<0.5) = 1;
            beta(repmat(rand(portion,1)>proC,1,D)) = 1;

            Offspring = [(Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2
                         (Parent1+Parent2)/2-beta.*(Parent1-Parent2)/2];
                     
             if(rest ~= 0)
                beta = zeros(1,D);
                mu   = rand(1,D);
                beta(mu<=0.5) = (2*mu(mu<=0.5)).^(1/(disC+1));
                beta(mu>0.5)  = (2-2*mu(mu>0.5)).^(-1/(disC+1));
                beta = beta.*(-1).^randi([0,1],1,D);
                beta(rand(1,D)<0.5) = 1;
                beta(repmat(rand(1,1)>proC,1,D)) = 1;
                u = rand(1,1);
                Parent1 = Rest(1,:);
                Parent2 = Rest(2,:);
                if(u > 0.5)
                    Offspring = [Offspring
                        (Parent1+Parent2)/2-beta.*(Parent1-Parent2)/2];
                else
                    Offspring = [Offspring
                        (Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2];
                end
             end
             if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1), true);   
             end
        end
    end
end