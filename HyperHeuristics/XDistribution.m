classdef XDistribution
    
    properties (Constant)
        MIN_REWARD = 0.001;
        MIN_EXPLORE_RUN_PER_OP = 3;
        REWARD_UPDATE_RATE = 1;
        EXPLOIT_START = 20;
    end
        
    properties
        Old_Population
        Reward_Handle
        Rewards
        Operators
        Num_Operators
        Distribution
        Runs
    end
    
    methods(Access = public)
        function obj = XDistribution(Old_Population, Operators, Reward_Handle)
            obj.Old_Population = Old_Population;
            obj.Operators = Operators;
            obj.Num_Operators = size(Operators, 2);
            obj.Reward_Handle = Reward_Handle;
            obj.Rewards = zeros(1, obj.Num_Operators);
            obj.Distribution = ones(1, obj.Num_Operators)./obj.Num_Operators;
            obj.Runs = 0;
        end
        
        function obj = CalcDist(obj, New_Population)
            obj.Runs = obj.Runs + 1;
            %% use new Information to calculate Reward Array
            types = New_Population.tags;
            value = zeros(1, obj.Num_Operators);
            for i=1:obj.Num_Operators
                new_pop = New_Population(strcmp(types, obj.Operators{i}.TAG));
                if(size(new_pop, 2) == 0)
                    value(i) = obj.MIN_REWARD;
                else
                    value(i) = max([obj.MIN_REWARD...
                        obj.Reward_Handle(obj.Old_Population, new_pop)]);
                end
            end            
            %% Update internal state
            [~,ranking] = sort(value);            
            % Scoring Function
            for j=1:obj.Num_Operators
                obj.Rewards(ranking(j)) = max([obj.Rewards(ranking(j)) + (j-floor(obj.Num_Operators/2))^3 obj.MIN_REWARD]);
            end
            obj.Distribution = obj.Rewards./sum(obj.Rewards);
            for j=1:obj.Num_Operators
                obj.Distribution(j) = max([obj.Operators{j}.MIN_PARENTS/size(New_Population, 2) obj.Distribution(i)]);
            end
            obj.Distribution = obj.Distribution./sum(obj.Distribution);
        end
        
        function obj = SetOldPopulation(obj, New_Population)
            obj.Old_Population = New_Population;
        end
        
        function Offspring = ExecX(obj, Parents)
            N = size(Parents, 2);
            last = 1;
            numParents = round(obj.Distribution.*N);
            if(sum(numParents) < N)
                m = N - sum(numParents);
                u = randperm(obj.Num_Operators,m);
                numParents(u) = numParents(u) + 1;
            elseif(sum(numParents) > N)
                m = sum(numParents)-N;
                u = randperm(obj.Num_Operators,m);
                numParents(u) = numParents(u) - 1;
            end
            for i=1:obj.Num_Operators
                x = obj.Operators{i};
                xOp = @x.Cross;
                
                if(i == 1)
                    Offspring = xOp(Parents(last:last+numParents(i)-1));
                    last = last+numParents(i);
                    continue;
                end                
                Offspring = [Offspring xOp(Parents(last:last+numParents(i)-1))];
                last = last+numParents(i);
            end
        end
    end
end

