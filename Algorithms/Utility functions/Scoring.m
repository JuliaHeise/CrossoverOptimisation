classdef Scoring
    methods(Access = public, Static)
        function score = Cubic(rank, zeroPointsRank)
            score = (rank-zeroPointsRank).^3;
        end
        
        function score = Linear(rank, zeroPointsRank)
            score = rank-zeroPointsRank;
        end
        
        function score = Logistic(rank, zeroPointsRank)
            score = 1./(1+exp(2.*(zeroPointsRank-rank)))-0.5;
        end
    end
end

