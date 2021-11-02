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
            idx = 1;
            for i = 1:2
               Parents{i} = Parentpool(idx:idx+portion-1, :); 
               idx = idx+portion;
            end            
            
            Offspring = zeros(portion*2,D);

            %% Offspring creation by random selection of parent per value
           % for i = 1:2:portion*2 
                mu = rand([portion,D]);
                o1 = zeros(portion,D);
                o2 = zeros(portion,D);
                o1(mu<=0.5) = Parents{1}(mu<=0.5);
                o1(mu>0.5) = Parents{2}(mu>0.5);
                o2(mu<=0.5) = Parents{2}(mu<=0.5);
                o2(mu>0.5) = Parents{1}(mu>0.5);
                Offspring = [o1;o2];
         %   end
            
            if(restructure)
                Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, length(Offspring), 1));
            end
        end
    end
end