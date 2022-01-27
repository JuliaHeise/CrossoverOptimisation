classdef MyLX < XOPERATOR
        
    properties (SetAccess = private)
        A
        B
    end
    
    methods(Access = public)
        function obj = MyLX(varargin)
            isStr = find(cellfun(@ischar, varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
            for i = isStr(ismember(varargin(isStr),{'B'}))
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.MIN_PARENTS = 2;
            obj.A = 0;
            if(isempty(obj.B))
                obj.B = 0.2;
            end
            obj.TAG = "LX" + string(obj.B);
        end
        
        function Offspring = Cross(obj, Parentpool)
            %% Parameter setting
            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
                restructure = true;
            else
                restructure = false;
            end
            
            N = size(Parentpool, 1);
            
            if(mod(N,2) == 0)
                M = N/2;
            else
                M = floor(N/2);         
            end
            
            Parent1 = Parentpool(1:M,:);
            Parent2 = Parentpool(M+1:M*2,:);
            
            Rest = Parentpool(M*2+1:end,:);
            
            %% Offspring Generation
            u = rand(M,1);
            f = 1/2;
            beta(u<=f) = obj.A + obj.B*(reallog(2 * u(u<=f)));
            beta(u>f) = obj.A - obj.B*(reallog(2 * (1-u(u>f))));

            Offspring = [Parent1 + beta' .* (Parent1-Parent2)
                Parent2 - beta' .* (Parent1-Parent2)];
            
             %% Offspring Generation
            u = rand(1,1);
            m = rand(1,1);
            x = randi (N-1,1,1);
            if(u <=f)
                beta_rest = obj.A + obj.B*(reallog(2 * u));
            else
                beta_rest = obj.A - obj.B*(reallog(2 * (1-u)));
            end
            
            if(m <=f)
                 Offspring = [Offspring 
                     Rest + beta_rest' .* (Rest-Parentpool(x,:))];

            else
                Offspring = [Offspring
                    Rest - beta_rest' .* (Rest-Parentpool(x,:))];
            end
            

            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1), true);
            end
        end
    end
end

