classdef XOP16_NCRXDNSGAII < ALGORITHM
% <multi> <real/binary/permutation> <constrained/none>
% Nondominated sorting genetic algorithm II

%------------------------------- Reference --------------------------------
% K. Deb, A. Pratap, S. Agarwal, and T. Meyarivan, A fast and elitist
% multiobjective genetic algorithm: NSGA-II, IEEE Transactions on
% Evolutionary Computation, 2002, 6(2): 182-197.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

   
    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Population = Problem.Initialization();
            Operators = {MyCMAX('Sigma', 0.2), MyCMAX('Sigma', 0.5), ...
                MyCMAX(), MyDE('F', 0.5), MyDE('F', 0.8), MyDE('F', 1), ...
                MyLCX('Parents', 2), MyLCX('Parents', 3), ...
                MyLCX('Parents', 5), MyLCX('Parents', 10), ...
                MyLX(), MyLX('B', 0.5), MyLX('B', 0.8), ...
                MyRSBX(), MySBX(), MyUX()};
            XDist = XDistributionTuned(Population, Operators, @NCReward, @Scoring.Linear);
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);
            run = 1;
            Algorithm.SaveDist(XDist.Distribution, run);

            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring = XDist.ExecX(Population(MatingPool));
                Offspring = MyMutation(Offspring);
                Algorithm.SaveTags(Offspring.tags, run);
                XDist = XDist.SetOldPopulation(Population);
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                XDist = XDist.CalcDist(Population);
                run = run + 1;
                Algorithm.SaveDist(XDist.Distribution, run);
            end
        end
    end
end