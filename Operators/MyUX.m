classdef MyUX < XOPERATOR
        
    methods(Access = public)
        function obj = MyUX()
            obj.TAG = "UX";
            obj.MIN_PARENTS = 3;
        end
        
        function Offspring = Cross(obj, Parentpool, Parameter)
            %% Parameter setting
            if nargin > 2
                lambda = Parameter;
            else
                lambda = 2;
            end

            if isa(Parentpool(1),'SOLUTION')
                Parentpool = Parentpool.decs;
            end

            %% Prepare loop
            [N,D]   = size(Parentpool);
            RandomizedParents =  zeros(N,D,lambda);
            Offspring = zeros(N,D);

            for  i=1:lambda
                MatingPool = randperm(size(Parentpool,1));
                RandomizedParents(:,:,i) = Parentpool(MatingPool, :);
            end

            %% Offspring creation by random selection of parent per value
            p = randi([1,lambda],[N,D]);
            for j=1:N
                for k=1:D
                    Offspring(j,k) = RandomizedParents(j,k,p(j,k));
                end
            end
            Offspring = SOLUTION(Offspring,[], repelem(obj.TAG, N, 1));
        end
    end
end