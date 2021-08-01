classdef MyDE < XOPERATOR
        
    methods(Access = public)
        function obj = MyDE()
            obj.TAG = "DE";
            obj.MIN_PARENTS = 3;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter setting
            if nargin > 4
                [CR,F,~,~] = deal(Parameter{:});
            else
                [CR,F,~,~] = deal(1,0.5,1,20);
            end

            MatingPooly = randperm(length(Parentpool));
            MatingPoolz = randperm(length(MatingPooly));

            Parent1 = Parentpool;
            Parent2 = Parentpool(MatingPooly);
            Parent3 = Parentpool(MatingPoolz);

            if isa(Parent1(1),'SOLUTION')
                Parent1 = Parent1.decs;
                Parent2 = Parent2.decs;
                Parent3 = Parent3.decs;
            end

            [N,D]   = size(Parent1);

            %% Differental evolution
            Site = rand(N,D) < CR;
            Offspring       = Parent1;
            Offspring(Site) = Offspring(Site) + F*(Parent2(Site)-Parent3(Site));   

            Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1));
        end
    end
end