function CummuSubplots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine)
    %% Tidy up
    close all; clc;

    %% Setup Version + Prob + Algo combinations
    prefix = 'MedianRuns/';
    suffix1 = 'MEDIAN_';
    suffix2 = '_IGD_';

    imageSize = [0 0 0.4 0.3];

    marker = ["-o" "-+" "-*" "-s" "-d" "-x" "-o" "-+" "-*" "-s" "-d" "-x"];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();

    %Operators = ["CMAX1", "DE0.5", "LCX3", "LX0.2", "RSBX", "SBX", "UX"];
    betterOpNames = ["CMAX", "DEX", "LCX3", "LX", "RSBX", "SBX", "UX"];
    betterOpNames = [betterOpNames(6), betterOpNames(1), betterOpNames(7), betterOpNames(5), betterOpNames(4), betterOpNames(2), betterOpNames(3)];
    Operators = flip(["LCX3", "DEX", "LX", "RSBX", "UX", "CMAX", "SBX"]);
    
    HHNames = ["HHX-D", "HHX-S"];

    probname = "WFG5";

    %% Tidy up
    close all;
    %% Get All HV in one Array
    filenames = append(prefix, suffix1, 'HARDER', suffix2, probname, '*');
    files_for_p = splitlines(string(ls(filenames)));

    for i = 1:length(TestSetting.algorithms)
        name = split(files_for_p(i),'_');
        alg = split(name(end),'.');
        results(i,:)= ...
            struct('algorithm', alg(1), ...
            'data', load(append(files_for_p(i))).res);
    end

    pro = str2func(probname);
    p = pro();
    M = p.M;
    D = p.D * 4;

    f2 = figure('units','normalized','outerposition',imageSize);%, 'Visible', 'off');  
    t2 = tiledlayout(1,2,'TileSpacing','Tight','Padding','Compact');

    for i = 1:2                
        data = results([results.algorithm] == TestSetting.hhAlgorithms(i)).data;

        y = struct('OpDist', data.median_run.xOpProbs, ...
            'TagDist', data.median_run.tagDist);

        for k = 1:length(Operators)
            opData(k) = struct('Operator', Operators(k), 'OpDist', y.OpDist(:,k));
        end
        opData = [opData(6), opData(1), opData(7), opData(5), opData(4), opData(2), opData(3)];
        
        
        y.TagDist(y.TagDist == "LCX") = "LCX3";
        y.TagDist(y.TagDist == "CMAX1") = "CMAX";
        y.TagDist(y.TagDist == "DE0.5") = "DEX";
        y.TagDist(y.TagDist == "DE") = "DEX";
        y.TagDist(y.TagDist == "LX0.2") = "LX";

        %% Cummaltive Pickrate    
        x = 0:100:(length(y.TagDist)-1)*100;
        nexttile 
        p = {};
        for j = 1:length(Operators)
            model_series = [0; cumsum(sum(y.TagDist == Operators(j), 2))]';
            p{j} = plot(x./100, model_series, marker(j),'LineWidth', global_primeLine, 'MarkerIndices',j*2:10:length(model_series)-2);
            p{j}.MarkerSize = global_markersize;
            if(j==1)
                color = [1-lineColor(1) 1-lineColor(2) lineColor(3)];
            else
                color = [lineColor(1)*(length(Operators)/(j-1)), lineColor(2)/(length(Operators)/(j-1)), 1-lineColor(3)*(length(Operators)/(j-1))];
            end
            p{j}.MarkerFaceColor = color;
            p{j}.Color = [color 0.5];
            hold on
        end


        set(gca,'FontSize', global_subfontsize) 
        if(i == 2)
            set(gca, 'yticklabel', {});
        end      
        
        xlim([min(x)/100 max(x)/100+1]);
        title(HHNames(i), 'fontsize', global_fontsize);
        
        grid on
        hold off
        axis tight

        if(i == 2)
            legend(flip([p{1:end}]), flip(Operators), 'Location','bestoutside','fontsize', global_subfontsize);
            title(t2, append(probname, ", M = ", string(M), ", D = ", string(D)));
            xlabel(t2, "Generation", 'fontsize', global_fontsize);
            ylabel(t2, "Offsprings produced", 'fontsize', global_fontsize);

            exportgraphics(f2, 'Plots/' + name(2) ...
                + '_CUMPROD_' + "Old" ...
                + '_' + name(4) + '.pdf', 'ContentType', 'vector');
        end
    end
end