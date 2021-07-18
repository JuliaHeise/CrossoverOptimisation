classdef XDistribution
    
    properties
        Old_Population
        Reward_Handle
        Rewards
        Num_Operators
        Distribution
    end
    
    methods(Access = public)
        function obj = XDistribution(Old_Population, Num_Operators, Reward_Handle)
            obj.Old_Population = Old_Population;
            obj.Num_Operators = Num_Operators;
            obj.Reward_Handle = Reward_Handle;
            obj.Rewards = ones(1,obj.Num_Operators)./obj.Num_Operators;
        end
        
        function [obj, Dist] = CalcDist(obj, New_Population)
            % use new Information to calculate Reward Array
            obj.Rewards = obj.Reward_Handle(obj.Old_Population, New_Population, obj.Rewards);
            % update Distribution of Operators
            Dist = obj.Rewards./sum(obj.Rewards)
            % Update internal state
            obj.Old_Population = New_Population;
            obj.Distribution = Dist;
        end
    end
end

