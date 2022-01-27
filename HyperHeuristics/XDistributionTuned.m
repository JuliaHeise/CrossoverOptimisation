classdef XDistributionTuned
            
    properties
        Let_Op_Die
        Old_Population
        Reward_Handle
        Score_Handle
        Rewards
        Operators
        Min_Parents_Per_Op
        Num_Operators
        Distribution
        Runs
    end
    
    methods(Access = public)
        function obj = XDistributionTuned(Old_Population, Operators, Reward_Handle, varargin)
            isStr = find(cellfun(@ischar,varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
            for i = isStr(ismember(varargin(isStr),{'Score_Handle','Let_Op_Die'}))
                obj.(varargin{i}) = varargin{i+1};
            end
            if(isempty(obj.Let_Op_Die))
                 obj.Let_Op_Die = false;
            end
            if(isempty(obj.Score_Handle))
                 obj.Score_Handle = @Scoring.Cubic;
            end
            
            obj.Old_Population = Old_Population;
            obj.Operators = Operators;
            obj.Num_Operators = size(Operators, 2);
            for i=1:obj.Num_Operators
                obj.Min_Parents_Per_Op(i) = obj.Operators{i}.MIN_PARENTS;
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
                obj.Rewards(j) = max([0 obj.Rewards(j) + obj.Score_Handle(ranking(j), floor(obj.Num_Operators/2))]);
            end
            if(all(obj.Rewards == obj.Rewards(1)))
                obj.Distribution = ones(1, obj.Num_Operators)./obj.Num_Operators;
            else
                obj.Distribution = obj.Rewards./sum(obj.Rewards);
            end
        end
        
        function obj = SetOldPopulation(obj, New_Population)
            obj.Old_Population = New_Population;
        end
        
        function Offspring = ExecX(obj, Parents)
            N = size(Parents, 2);
            last = 1;
            
            if(obj.Let_Op_Die)
                toDistribute = N - sum(obj.Min_Parents_Per_Op(obj.Distribution~=0));
            else
                toDistribute = N - sum(obj.Min_Parents_Per_Op);
            end
            
            numParents = round(obj.Distribution .* toDistribute);
                        
            if(sum(numParents) < toDistribute)
                m = toDistribute - sum(numParents);
                u = randperm(obj.Num_Operators, m);
                if(obj.Let_Op_Die)
                    while(numParents(u) == 0)
                        u = randperm(obj.Num_Operators, m);
                    end
                end
                numParents(u) = numParents(u) + 1;
            elseif(sum(numParents) > toDistribute)
                m = sum(numParents)- toDistribute;
                u = randperm(obj.Num_Operators,m);
                while(any(numParents(u) == 0))
                    u = randperm(obj.Num_Operators, m);
                end
                numParents(u) = numParents(u) - 1;
            end
            
            if(obj.Let_Op_Die)
                numParents(obj.Distribution==0) = - obj.Min_Parents_Per_Op(obj.Distribution==0);
            end
            
            Offspring = [];
            for i=1:obj.Num_Operators
                x = obj.Operators{i};
                xOp = @x.Cross;
                
                nP = numParents(i) + x.MIN_PARENTS;
                if(nP == 0) 
                    continue; 
                end            
                Offspring = [Offspring xOp(Parents(last:last+nP-1))];
                last = last+nP;
            end
        end
        
    end
end

