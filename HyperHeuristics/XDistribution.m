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
            obj.Distribution = obj.Rewards./sum(obj.Rewards);
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
        end
        
        function obj = SetOldPopulation(obj, New_Population)
            obj.Old_Population = New_Population;
        end
        
        function Offspring = ExecX(obj, Parents)
            N = size(Parents, 2);
            last = 1;
            for i=1:obj.Num_Operators
                x = obj.Operators{i};
                xOp = @x.Cross;
                numParents = max([x.MIN_PARENTS floor(obj.Distribution(i)*N)]);
                if(i == 1)
                    Offspring = xOp(Parents(last:last+numParents));
                    last = last+numParents;
                    continue;
                end                
                if(last+numParents > N)
                    RestParents = [Parents(last:end)...
                        Parents(1, randi(N, [(last+numParents)-(N+1) 1]),:)];
                    Offspring = [Offspring xOp(RestParents)];
                else
                    Offspring = [Offspring xOp(Parents(last:last+numParents))];
                end
                last = last+numParents;
            end
        end
    end
end

