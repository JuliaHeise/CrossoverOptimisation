%% Process and Visualize
% In this Skript all Results of the Hyperheuristics shall be loaded and
% processed. For this, all Results Files are loaded and combined.
% Afterwards the results are visualized and the images are safed and the
% result tables are stored in latex format.

% The Results that are supposed to be calculated:
% 1. Distribution/ Probabilities over Time as line graphs 
% 2. Cummulative number of offspring as Barchart 

%% Data Loading 
prefix = 'C:\Users\Julia\Documents\MasterRepo\EAXOpt\ToEvaluate\TestDataSet\';
numberOfRuns = 31;
TestSettings = {};

% R2RXDNSGAII
%TestSettings{end+1} = ...
 %   struct('algorithm', 'R2RXDNSGAII', 'dataset', 'RM1', 'M', 2, 'D', 30);

TestSettings{end+1} = ...
    struct('algorithm', 'R2RXDNSGAII', 'dataset', 'WFG3', 'M', 3, 'D', 12);

% RLXDNSGAII
% SRXNSGAII
% URXNSGAII

for i=1:length(TestSettings)
    % find files
    filename = append(TestSettings{i}.algorithm, '\', ...
        TestSettings{i}.algorithm, ...
        '_', TestSettings{i}.dataset, ...
        '_M',string(TestSettings{i}.M), '_D', ...
        string(TestSettings{i}.D), '_');
    result = {};
    for run = 1: numberOfRuns
        res = load(append(prefix, filename, string(run), '.mat'));
        result{run} = res.xOpProbs;        
    end
    
    % Calulation and Plotting
    
end
