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
algorithm = 'R2RXDNSGAII';
%TestSettings{end+1} = ...
 %   struct('algorithm', 'R2RXDNSGAII', 'dataset', 'RM1', 'M', 2, 'D', 30);
TestSettings{end+1} = ...
    struct('algorithm', algorithm , 'dataset', 'WFG3', 'M', 3, 'D', 12);

% RLXDNSGAII
%algorithm = 'RLXDNSGAII';
% SRXNSGAII
%algorithm = 'SRXNSGAII';
% URXNSGAII
%algorithm = 'URXNSGAII';

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
    
    %% calculate averages
    average = result{1};
    fe_count = ones(size(average,1),1);
    N = size(average, 2);
    
    for j = 2:size(result,2)
        next = result{j};
        size_avg = size(average,1);
        size_nxt = size(next,1);
        size_fe = size(fe_count, 1);
        
        % Zeilen summieren
        if(size_avg == size_nxt)
            average = average + next;
        elseif(size_avg < size_nxt)
            average = (average + next(1:size_avg, :));
            average = [average; next(size_avg+1:end, :)];
        else
            average(1:size_nxt, :) = (average(1:size_nxt, :) + next);
        end
        
        % count number of fe's
        if(size_fe < size_nxt)
            fe_count = [fe_count + ones(size_fe,1); ones(size_nxt - size_fe,1)];
        else
            fe_count(1:size_nxt) = fe_count(1:size_nxt) + ones(size_nxt, 1);
        end
    end
    
    
    average = average ./ repmat(fe_count, [1,N]);
    average = average ./ repmat(sum(average,2), [1,N]);
    average = vecnorm(average, 2, 1);
    
    % TODO Save Data and Plots
    
    %% Calculate Median
    Len_tmp = cellfun(@(c) size(c,1), result, 'UniformOutput', false);
    Len =  cat(1,Len_tmp{:});
    
    medians = zeros(min(Len), size(result{1},2)); 
    for m=1:size(result{1},2)
        for n=1:min(Len)
            medians(n,m) = median(cell2mat(cellfun(@(c) c(n,m), result, 'UniformOutput', false)));
        end
    end
    
    %TODO Norm medias so that they add up to 1?
    
     % TODO Save Data and Plots
    
end