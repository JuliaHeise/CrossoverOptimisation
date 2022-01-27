classdef XSelectionTuned
     
    properties
        Min_Prob
        Min_Exploration_Per_Op
        Reward_Rate
        Old_Population
        Num_Operators       
        Reward_Handle
        Score_Handle
        Runs
        Operator_Objects
        Num_Selection
        Selection
        Exploration_Rewards
        Rewards
        Probabilities
    end

    methods(Access = public)
        function [obj, Operator] = XSelectionTuned(Old_Population, Operator_Objects, Reward_Handle, varargin)
            isStr = find(cellfun(@ischar,varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
            for i = isStr(ismember(varargin(isStr),{'Score_Handle','Min_Prob', 'Min_Exploration_Per_Op', 'Reward_Rate'}))
                obj.(varargin{i}) = varargin{i+1};
            end
            if(isempty(obj.Min_Prob))
                 obj.Min_Prob = 0.001;
            end
            if(isempty(obj.Score_Handle))
                 obj.Score_Handle = @Scoring.Cubic;
            end
            if(isempty(obj.Min_Exploration_Per_Op))
                 obj.Min_Exploration_Per_Op = 3;
            end
            if(isempty(obj.Reward_Rate))
                 obj.Reward_Rate = 1;
            end
            
            %% set from input
            obj.Old_Population = Old_Population;
            obj.Operator_Objects = Operator_Objects;
            obj.Num_Operators = size(Operator_Objects, 2);
            obj.Reward_Handle = Reward_Handle;           
            
            %% initials
            obj.Rewards = zeros(1,obj.Num_Operators);
            obj.Exploration_Rewards = obj.Rewards;
            obj.Probabilities = zeros(1,obj.Num_Operators);  
            obj.Runs = 0;
            obj.Num_Selection = zeros(1, obj.Num_Operators);
            obj.Selection = 1;
            x = obj.Operator_Objects{obj.Selection};
            Operator = @x.Cross;
        end
        
        function [obj, Operator] = SelectX(obj, New_Population)
            obj.Runs = obj.Runs + 1;
            %% use new Information to calculate Rewards
            new_reward = obj.Reward_Handle(obj.Old_Population, ...
                New_Population);
            
            obj.Exploration_Rewards(obj.Selection) = ...
                max([0 new_reward]);
            
            %% Update Rewards after Exploration and after every few runs
            if(obj.Runs == obj.Num_Operators * obj.Min_Exploration_Per_Op...
                    || mod(obj.Runs, obj.Reward_Rate) == 0)
                
                %% Update internal state
                [~,~,ranking] = unique(obj.Exploration_Rewards, 'sorted');            
                % Scoring Function
                for j=1:obj.Num_Operators
                    obj.Rewards(j) = max([0 obj.Rewards(j) + obj.Score_Handle(ranking(j),floor(obj.Num_Operators/2))]);
                end
                if(all(obj.Rewards == obj.Rewards(1)))
                    obj.Probabilities = ones(1, obj.Num_Operators)./obj.Num_Operators;
                else
                    obj.Probabilities = obj.Rewards./sum(obj.Rewards);
                    val = sum(obj.Probabilities < obj.Min_Prob);
                    obj.Probabilities = obj.Rewards./(sum(obj.Rewards) + sum(obj.Rewards) * val * obj.Min_Prob);                    
                    obj.Probabilities(obj.Probabilities < obj.Min_Prob) = obj.Min_Prob;
                end
            end  
            
            if(obj.Runs <= obj.Num_Operators * obj.Min_Exploration_Per_Op)
                %% Exploration
                % select the next Operator
                obj.Selection = mod(obj.Runs, obj.Num_Operators) + 1;
                obj.Num_Selection(obj.Selection) ...
                    = obj.Num_Selection(obj.Selection) + 1;                       
            else
                %% Exploitation
                % Use new Reward Array with Roulette Wheel 
                obj = RouletteWheelSelection(obj);
            end
                       
            % Use Selection to return the current Operator Handle
            x = obj.Operator_Objects{obj.Selection};
            Operator = @x.Cross;
        end
        
        function obj = SetOldPopulation(obj, New_Population)
            obj.Old_Population = New_Population;
        end
    end
        
    methods(Access = private)      
        function obj = RouletteWheelSelection(obj)
            picker = rand(1);
            tmp = 0;
            for i = 1:obj.Num_Operators
                tmp = tmp + obj.Probabilities(1,i);
                if(picker <= tmp)
                    obj.Selection = i;
                    obj.Num_Selection(obj.Selection) ...
                        = obj.Num_Selection(obj.Selection) + 1;
                    break;
                end
            end
        end
    end
end

