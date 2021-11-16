classdef MyLX < XOPERATOR
        
    methods(Access = public)
        function obj = MyLX()
            obj.TAG = "LX";
            obj.MIN_PARENTS = 2;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter setting
            if nargin > 2
                [a,b] = deal(Parameter{:});
            else
                [a,b] = deal(0,0.2);
            end

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
            beta(u<=f) = a + b*(reallog(2 * u(u<=f)));
            beta(u>f) = a - b*(reallog(2 * (1-u(u>f))));

            Offspring = [Parent1 + beta' .* (Parent1-Parent2)
                Parent2 - beta' .* (Parent1-Parent2)];
            
             %% Offspring Generation
            u = rand(1,1);
            m = rand(1,1);
            x = randi (N-1,1,1);
            if(u <=f)
                beta_rest = a + b*(reallog(2 * u));
            else
                beta_rest = a - b*(reallog(2 * (1-u)));
            end
            
            if(m <=f)
                 Offspring = [Offspring 
                     Rest + beta_rest' .* (Rest-Parentpool(x,:))];

            else
                Offspring = [Offspring
                    Rest - beta_rest' .* (Rest-Parentpool(x,:))];
            end
            

            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1));
            end
        end
    end
end

