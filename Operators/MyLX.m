classdef MyLX < XOPERATOR
        
    methods(Access = public)
        function obj = MyLX()
            obj.TAG = "LX";
            obj.MIN_PARENTS = 3;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter setting
            if nargin > 2
                [a,b] = deal(Parameter{:});
            else
                [a,b] = deal(0,0.5);
            end

            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
                restructure = true;
            else
                restructure = false;
            end
            
            Parent1 = Parentpool(1:floor(end/2),:);
            Parent2 = Parentpool(floor(end/2)+1:floor(end/2)*2,:);
            N = size(Parentpool, 1);

            %% Offspring Generation
            u = rand(N,1);
            beta(u<=0.5) = a - b*reallog(u(u<=0.5));
            beta(u>0.5) = a + b*reallog(u(u>0.5));

            Offspring = [Parent1 + beta(1:floor(end/2))' .* abs(Parent1-Parent2) % abs(Parent1-Parent2) 
                Parent2 + beta(floor(end/2)+1:floor(end/2)*2)' .* abs(Parent1-Parent2)]; %abs(Parent1-Parent2) 

            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1));
            end
        end
    end
end

