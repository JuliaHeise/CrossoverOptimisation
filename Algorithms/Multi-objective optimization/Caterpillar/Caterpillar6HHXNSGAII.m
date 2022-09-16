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
            secondTransition = true;

            % Set Caterpillar Parameter
            p1 = 0.4;
            p2 = 0.4;

            %% Optimization
            while Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);

                %% First Step "Caterpillar": 
                % Distribution of generation to all operators
                if(Problem.FE < p1*Problem.maxFE)
                    % Execute evolutionary Operator
                    Offspring = XDist.ExecX(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    % Save for statistics
                    Algorithm.SaveTags(Offspring.tags, run);

                    % Update Archive of Distribution
                    XDist = XDist.SetOldPopulation([Population,Offspring]);

                    %Finish this generation
                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                    
                    % Calculate next Distribution
                    XDist = XDist.CalcDist(Population);

                    % Save for statistics
                    run = run + 1;
                    Algorithm.SaveDist(XDist.Distribution, run);
                    continue;
                end

                %% First Transition: Dist. - Sel.                
                if (firstTransition)
                    % Only entered once
                    firstTransition = false;
                    
                    % Update Rewards for selection with current reward
                    XSel = XSel.SetRewards(XDist.Rewards);

                    % Select the current best according to Rewards for the
                    % first selection
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    Operator = @op.Cross;
                end

                %% Second Step "Cocoon"
                % Selection of one Operator each generation
                if and(Problem.FE >= p1*Problem.maxFE, Problem.FE < (1-p2)*Problem.maxFE)  
                    % Execute selected Operator
                    Offspring = Operator(Population(MatingPool));
                    Offspring = MyMutation(Offspring);

                    % Save for statistics
                    Algorithm.SaveTags(Offspring.tags, run);

                    % Update Archive
                    XSel = XSel.SetOldPopulation(Population);

                    % Finish this generation
                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                    
                    % Select next operator
                    [XSel, Operator] = XSel.SelectX(Population);

                    % Save for statistics
                    run = run + 1;
                    Algorithm.SaveDist(XSel.Probabilities, run);
                    continue;
                end

                %% Second Transition: Sel. - Exploit 
                if (secondTransition)
                    % Only entered once
                    secondTransition = false;
                    
                    % Select the current best according to Rewards
                    [~, idx] = max(XSel.Rewards);
                    op = Operators{idx};
                    finalXOP = @op.Cross;

                    % Set to fixed values for statistics
                    probabilities = zeros(size(Operators));
                    probabilities(idx) = 1;
                end
                
                %% Last Step "Butterfly":
                % Exploit the best operator
                % Execute evolutionary operators
                Offspring = finalXOP(Population(MatingPool));
                Offspring = MyMutation(Offspring);

                % Save for statistics
                Algorithm.SaveTags(Offspring.tags, run);

                % Finish this generation
                [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);

                % Save for statistics
                Algorithm.SaveDist(probabilities, run);
            end
        end

    end
end