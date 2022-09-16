classdef Alternating5HHXNSGAII < ALGORITHM
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
            %% Initialize Optimization Modules
            % Start with random Population
            Population = Problem.Initialization();

            % Init operator pool
            Operators = {MyCMAX(), MyDE(), MyLCX(), MyLX(), MyRSBX(), MySBX(), MyUX()};
            
            % Init both selection mechanics
            XDist = XDistribution(Population, Operators, @SurvivalReward);
            XSel = XSelection(Population, Operators, @SurvivalReward);

            % First population evaluation
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);

            % Save for statistics
            run = 1;
            Algorithm.SaveDist(XDist.Distribution, run);

            firstTransition = true;

            % Set Cycle Parameter
            pDist = 0.8;
            iterations = 5;

            % Use Cycle Paramter to get the "Turning Points" 
            partitions = Problem.maxFE/iterations;
            pFE = partitions * pDist;
            
            i = 0;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);

                %% Distribution starts in the first part
                if(Problem.FE < i * partitions + pFE)
                    % Execute Evolutionary Operators with Distribution
                    Offspring = XDist.ExecX(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    % Save for statistics
                    Algorithm.SaveTags(Offspring.tags, run);

                    % Update Archive for dist mechanism
                    XDist = XDist.SetOldPopulation([Population,Offspring]);
                    
                    % Finish this generation
                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);

                    % Calculate the next Distrubtion
                    XDist = XDist.CalcDist(Population);
                    
                    % Save for statistics
                    run = run + 1;
                    Algorithm.SaveDist(XDist.Distribution, run);
                    continue;
                end

                %% Turning point - Init Selection
                if (firstTransition)
                    % Close init of Selection
                    firstTransition = false;

                    % Transfer current Rewards to Selection
                    XSel = XSel.SetRewards(XDist.Rewards);

                    % Select the currently best operator for the first turn
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    Operator = @op.Cross;
                end

                %% Selection starts after Distribution 
                % it fills generation until the next partition is reached 
                if and(Problem.FE >= i * partitions + pFE, Problem.FE < (i+1) * partitions)  

                    % Use selected Crossover operator and Mutation
                    Offspring = Operator(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    % Save for statistics
                    Algorithm.SaveTags(Offspring.tags, run);
                    
                    % Update the Selection Archive
                    XSel = XSel.SetOldPopulation(Population);

                    % Finish this generation
                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);

                    % Calculate next selection
                    [XSel, Operator] = XSel.SelectX(Population);

                    % Save for statistics
                    run = run + 1;
                    Algorithm.SaveDist(XSel.Probabilities, run);
                    continue;
                end 

                %% Second Turning Point - Last selection
                Offspring = Operator(Population(MatingPool));
                Offspring = MyMutation(Offspring);

                % Save for statistic
                Algorithm.SaveTags(Offspring.tags, run);

                % Prepare XDist
                XDist = XDist.SetOldPopulation([Population,Offspring]);
                XDist = XDist.SetRewards(zeros(size(XDist.Rewards)));
                Algorithm.SaveDist(XDist.Distribution, run);    

                % finish this generation
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                run = run + 1;
                
                % prepare next cycle
                i = i + 1;
                firstTransition = true;
            end
        end

    end
end