classdef XDistribution
    
    properties (Constant)
        MIN_EXPLORE_RUN_PER_OP = 3;
        REWARD_UPDATE_RATE = 1;
        EXPLOIT_START = 20;
    end
        
    properties
        Old_Population
        Reward_Handle
        Rewards
        Operators
        min_parents_per_op
        Num_Operators
        Distribution
        Runs
    end
    
    methods(Access = public)
        function obj = XDistribution(Old_Population, Operators, Reward_Handle)
            obj.Old_Population = Old_Population;
            obj.Operators = Operators;
            obj.Num_Operators = size(Operators, 2);
            for i=1:obj.Num_Operators
                obj.min_parents_per_op(i) = obj.Operators{i}.MIN_PARENTS;
            end
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
                    value(i) = 0;
                else
                    value(i) = obj.Reward_Handle(obj.Old_Population, new_pop);
                end
            end            
            %% Update internal state
            [~,~,ranking] = unique(value, 'sorted');            
            % Scoring Function
            for j=1:obj.Num_Operators
                obj.Rewards(j) = max([0 obj.Rewards(j) + (ranking(j)-floor(obj.Num_Operators/2))^3]);
            end
            if(all(obj.Rewards == obj.Rewards(1)))
                obj.Distribution = ones(1, obj.Num_Operators)./obj.Num_Operators;
            else
                obj.Distribution = obj.Rewards./sum(obj.Rewards);
            end
        end
                
        function Offspring = ExecX(obj, Parents)
            N = size(Parents, 2);
            last = 1;
            toDistribute = N - sum(obj.min_parents_per_op);
            numParents = round(obj.Distribution .* toDistribute);
            if(sum(numParents) < toDistribute)
                m = toDistribute - sum(numParents);
                u = randperm(obj.Num_Operators, m);
                numParents(u) = numParents(u) + 1;
            elseif(sum(numParents) > toDistribute)
                m = sum(numParents)- toDistribute;
                u = randperm(obj.Num_Operators,m);
                while(any(numParents(u) == 0))
                    u = randperm(obj.Num_Operators, m);
                end
                numParents(u) = numParents(u) - 1;
            end
            for i=1:obj.Num_Operators
                x = obj.Operators{i};
                xOp = @x.Cross;
                
                nP = numParents(i) + x.MIN_PARENTS;
                
                if(i == 1)
                    Offspring = xOp(Parents(last:last+nP-1));
                    last = last+nP;
                    continue;
                end                
                Offspring = [Offspring xOp(Parents(last:last+nP-1))];
                last = last+nP;
            end
        end

        function obj = SetOldPopulation(obj, New_Population)
            obj.Old_Population = New_Population;
        end

        function obj = SetRewards(obj, Rewards)
            obj.Rewards = Rewards;
            if(all(obj.Rewards == obj.Rewards(1)))
                obj.Distribution = ones(1, obj.Num_Operators)./obj.Num_Operators;
            else
                obj.Distribution = obj.Rewards./sum(obj.Rewards);
            end
        end

    end
end

