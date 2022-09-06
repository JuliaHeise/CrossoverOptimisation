classdef Caterpillar6HHXNSGAII < ALGORITHM
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
            secondTransition = true;

            p1 = 0.6;
            p2 = 0.2;

            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);

                                % First evolution: Distribution, use all Operators
                if(Problem.FE < p1*Problem.maxFE)
                    %disp("Dist")
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

                % After a while, all Operators are evaluated through
                % distribution. 2nd Evolution: Selection
                if (firstTransition)
                    firstTransition = false;
                    %disp("Current Rewards")
                    %disp(XDist.Rewards)
                    XSel = XSel.SetRewards(XDist.Rewards);
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    Operator = @op.Cross;
                    %disp("Current Best Operator")
                    %disp(op.TAG)
                    %disp("Transistion to Second form")
                end
                if and(Problem.FE >= p1*Problem.maxFE, Problem.FE < (1-p2)*Problem.maxFE)  
                    %disp("Sel")
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

                % Last evolution: Exploit the best operator so far
                if (secondTransition)
                    secondTransition = false;
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    finalXOP = @op.Cross;
                    %disp("Current Rewards")
                    %disp(XSel.Rewards)
                    %disp("Final XOP")
                    %disp(op.TAG)
                    %disp("Transition to final Form")
                    probabilities = zeros(size(Operators));
                    probabilities(idx) = 1;
                end
                %disp(op.TAG)
                Offspring = finalXOP(Population(MatingPool));
                Offspring = MyMutation(Offspring);
                Algorithm.SaveTags(Offspring.tags, run);
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                Algorithm.SaveDist(probabilities, run);
                
            end
        end

    end
end