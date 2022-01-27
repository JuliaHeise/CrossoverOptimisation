classdef MyDE < XOPERATOR
        
    properties (SetAccess = private)
        F  
    end
    
    methods(Access = public)
        function obj = MyDE(varargin)
            isStr = find(cellfun(@ischar, varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
            for i = isStr(ismember(varargin(isStr),{'F'}))
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.MIN_PARENTS = 3;
            if(isempty(obj.F))
                obj.F = 0.5;
            end
            obj.TAG = "DE" + string(obj.F);
        end
        
        function Offspring = Cross(obj, Parentpool)
            %% Parameter setting
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
            Offspring = Parent1;
            Offspring = Offspring + obj.F*(Parent2-Parent3);   

            if(restructure)
                 Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1), true);
            end
        end
    end
end