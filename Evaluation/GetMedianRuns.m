clc; close all;

prefix = 'FinalData/';
numberOfRuns = 31;
Tests = TestSettings();
settings = Tests.Get;

for set = settings
    setting = set{1};
    % find files
    filename = append(setting.algorithm, '/', ...
        setting.algorithm, ...
        '_', setting.dataset, ...
        '_M',string(setting.M), '_D', ...
        string(setting.D), '_');
    resultsEnd = {};
    resultsMid = {};
    
    % Collect BackupData of Median Runs
    for run = 1:numberOfRuns
        file = append(prefix, filename, string(run), '.mat');
        res = load(file);
        % Save Median runs HV/IGD
        resultsMid(run,:) = {file, res.metric.HV(6), res.metric.IGD(6)};
        resultsEnd(run,:) = {file, res.metric.HV(end), res.metric.IGD(end)};
    end
 
%     hv_sort = sortrows(resultsEnd, 2);
%     res = struct('name', hv_sort{19,1}, ...
%         'median_run', load(hv_sort{19,1}), ...
%         'iqrMid', iqr(cell2mat(resultsMid(:,2))), ...
%         'iqrEnd', iqr(cell2mat(resultsEnd(:,2))));
%     
%     dest = append('Evaluation/MedianRuns/', 'MEDIAN_', ...
%         setting.setup, '_', 'HV_', setting.dataset, '_', ...
%         setting.algorithm, '.mat')
%     save(dest, 'res');
%     
    igd_sort = sortrows(resultsEnd, 3);
    res = struct('name', igd_sort{19,1}, ...
        'median_run', load(igd_sort{19,1}), ...
        'iqrMid', iqr(cell2mat(resultsMid(:,3))), ...
        'iqrEnd', iqr(cell2mat(resultsEnd(:,3))));
    
    dest = append('MedianRuns/', 'MEDIAN_', ...
        setting.setup, '_', 'IGD_', setting.dataset, '_', ...
        setting.algorithm, '.mat');
    save(dest, 'res');
end