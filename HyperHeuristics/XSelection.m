classdef XSelection
 
    properties (Constant)
        MIN_REWARD = 0.001;
        MIN_EXPLORE_RUN_PER_OP = 3;
        REWARD_UPDATE_RATE = 1;
        EXPLOIT_START = 20;
    end
    
    properties
        Old_Population
        Num_Operators       
        Reward_Handle
        Runs
        Operator_Objects
        Num_Selection
        Selection
        Exploration_Rewards
        Rewards
        Probabilities
    end

    methods(Access = public)
        function [obj, Operator] = XSelection(Old_Population, Operator_Objects, Reward_Handle)
            %% set from input
            obj.Old_Population = Old_Population;
            obj.Operator_Objects = Operator_Objects;
            obj.Num_Operators = size(Operator_Objects, 2);
            obj.Reward_Handle = Reward_Handle;           
            
            %% initials
            obj.Rewards = ones(1,obj.Num_Operators) * obj.MIN_REWARD;
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
                max([obj.MIN_REWARD new_reward]);

            if(obj.Runs <= obj.Num_Operators * obj.MIN_EXPLORE_RUN_PER_OP)
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
            
            %% Update Rewards after Exploration and after every few runs
            if(obj.Runs == obj.Num_Operators * obj.MIN_EXPLORE_RUN_PER_OP...
                    || mod(obj.Runs, obj.REWARD_UPDATE_RATE) == 0)
                
                %% Update internal state
                [~,~,ranking] = unique(obj.Exploration_Rewards, 'sorted');            
                % Scoring Function
                for j=1:obj.Num_Operators
                    obj.Rewards(j) = max([0 obj.Rewards(j) + (ranking(j)-floor(obj.Num_Operators/2))^3]);
                end
                if(all(obj.Rewards == obj.Rewards(1)))
                    obj.Probabilities = ones(1, obj.Num_Operators)./obj.Num_Operators;
                else
                    obj.Probabilities = obj.Rewards./sum(obj.Rewards);
                end
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

