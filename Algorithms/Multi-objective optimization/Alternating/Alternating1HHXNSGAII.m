classdef Alternating1HHXNSGAII < ALGORITHM
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
            XDist = XDistribution(Population, Operators, @SurvivalReward);
            XSel = XSelection(Population, Operators, @SurvivalReward);
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);
            run = 1;
            Algorithm.SaveDist(XDist.Distribution, run);

            firstTransition = true;

            p1 = 0.5;
            p2 = 0.5;
            iterations = 5;

            partitions = Problem.maxFE/iterations;
            pFE2 = partitions * p1;
            pFE1 = partitions * p2;

            i = 0;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                
                if(Problem.FE < i * partitions + pFE1)
                    Offspring = XDist.ExecX(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    Algorithm.SaveTags(Offspring.tags, run);
                    XDist = XDist.SetOldPopulation([Population,Offspring]);

                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);

                    XDist = XDist.CalcDist(Population);
                    run = run + 1;

                    Algorithm.SaveDist(XDist.Distribution, run);
                    continue;
                end

                if (firstTransition)
                    firstTransition = false;
                    XSel = XSel.SetRewards(XDist.Rewards);
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    Operator = @op.Cross;
                end

                if and(Problem.FE >= i * partitions + pFE1, Problem.FE < (i+1) * partitions)  
                    Offspring = Operator(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    Algorithm.SaveTags(Offspring.tags, run);
                    XSel = XSel.SetOldPopulation(Population);

                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                    [XSel, Operator] = XSel.SelectX(Population);

                    run = run + 1;

                    Algorithm.SaveDist(XSel.Probabilities, run);
                    continue;
                end 

                Offspring = Operator(Population(MatingPool));
                Offspring = MyMutation(Offspring);

                Algorithm.SaveTags(Offspring.tags, run);
                XSel = XSel.SetOldPopulation(Population);

                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                [XSel, Operator] = XSel.SelectX(Population);

                run = run + 1;

                XDist = XDist.SetRewards(zeros(size(XDist.Rewards)));
                Algorithm.SaveDist(XDist.Distribution, run);
                
                i = i + 1;
                firstTransition = true;
            end
        end

    end
end