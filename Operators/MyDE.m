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
            
            if isa(Parentpool(1),'SOLUTION')
                Parent1 = Parentpool;
                Parent2 = Parentpool(MatingPooly);
                Parent3 = Parentpool(MatingPoolz);

                Parent1 = Parent1.decs;
                Parent2 = Parent2.decs;
                Parent3 = Parent3.decs;
                restructure = true;
            else
                Parent1 = Parentpool;
                Parent2 = Parentpool(MatingPooly,:);
                Parent3 = Parentpool(MatingPoolz,:);

                restructure = false;
            end
            
            %% Differental evolution
            Offspring       = Parent1;
            Offspring = Offspring + F*(Parent2-Parent3);   

            if(restructure)
                 Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1), true);
            end
        end
    end
end