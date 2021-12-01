classdef MyUX < XOPERATOR
        
    methods(Access = public)
        function obj = MyUX()
            obj.TAG = "UX";
            obj.MIN_PARENTS = 2;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
                restructure = true;
            else
                restructure = false;
            end
            
            %% result array
            [N,D] = size(Parentpool);
            portion = floor(N/2);
            Parents = cell(2,1);
            Parents{1} = Parentpool(1:portion, :); 
            Parents{2} = Parentpool(portion+1:(portion)*2, :);            
            

            %% Offspring creation by random selection of parent per value
            mu = rand([portion,D]);
            o1 = zeros(portion,D);
            o2 = zeros(portion,D);
            o1(mu<=0.5) = Parents{1}(mu<=0.5);
            o1(mu>0.5) = Parents{2}(mu>0.5);
            o2(mu<=0.5) = Parents{2}(mu<=0.5);
            o2(mu>0.5) = Parents{1}(mu>0.5);
            Offspring = [o1;o2];
            
            if(size(Offspring, 1) == N-1)
                P1 = Parentpool(end,:);
                P2 = Parentpool(randi(N-1, 1),:);
                o = zeros(1,D);
                u = rand([1,D]);
                t = rand([1,1]);
                if(t <= 0.5)
                    o(u<=0.5) = P1(u<=0.5);
                    o(u>0.5) = P2(u>0.5);
                else
                    o(u<=0.5) = P2(u<=0.5);
                    o(u>0.5) = P1(u>0.5);
                end
                Offspring = [Offspring; o];
            end
           
            
            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1), true);
            end
        end
    end
end