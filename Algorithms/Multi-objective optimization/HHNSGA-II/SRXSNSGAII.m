classdef SRXSNSGAII < ALGORITHM
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
            Operators = {MyCMAX(), MyDE(), MyLCX(), MyLX(), MyRSBX(), MySBX(), MyUX()};
            [XSel, Operator] = XSelection(Population, Operators, @SurvivalReward);
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);
            run = 1;
            Algorithm.SaveDist(XSel.Rewards, run);

            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring = Operator(Population(MatingPool));
                Offspring = MyMutation(Offspring);
                XSel = XSel.SetOldPopulation(Offspring);
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                [XSel, Operator] = XSel.SelectX(Population);
                run = run + 1;
                Algorithm.SaveDist(XSel.Rewards, run);
            end
        end
    end
end