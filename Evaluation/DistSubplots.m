function DistSubplots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine)
    %% Tidy up
    close all; clc;

    %% Setup Version + Prob + Algo combinations
    prefix = 'MedianRuns/';
    suffix1 = 'MEDIAN_';
    suffix2 = '_IGD_';
    darkGrey =  [0.1 0.1 0.1];
    grey = [0.5 0.5 0.5];
    blueGrey = [0.2 0.4 0.6];
    lightGrey = [0.85 0.85 0.85];
    imageSize = [0 0 0.3 0.35];

    marker = ["-o" "-+" "-*" "-s" "-d" "-x" "-o" "-+" "-*" "-s" "-d" "-x"];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();

    betterOpNames = ["CMAX", "DEX", "LCX3", "LX", "RSBX", "SBX", "UX"];
    betterOpNames = [betterOpNames(6), betterOpNames(1), betterOpNames(7), betterOpNames(5), betterOpNames(4), betterOpNames(2), betterOpNames(3)];
    Operators = ["LCX3", "DEX", "LX", "RSBX", "UX", "CMAX", "SBX"];
    
    HHNames = ["HHX-D", "HHX-S", "HHX-E", "HHX-A"];
    probNumber = 0;

    probname = "WFG5";
    %% Tidy up
    close all;
    %% Gether Data
    filenames = append(prefix, suffix1, 'HARDER', suffix2, probname, '*');
    files_for_p = splitlines(string(ls(filenames)));

    for i = 1:length(TestSetting.algorithms)
        name = split(files_for_p(i),'_');
        alg = split(name(end),'.');
        results(probNumber*length(TestSetting.algorithms) + i,:)= ...
            struct('problem', 'WFG', 'version', '5', 'algorithm', ...
            alg(1), 'data', ...
            load(append(files_for_p(i))).res);
    end

    pro = str2func(probname);
    p = pro();
    M = p.M;
    D = p.D * 4;

    %% Prepare Visualization
    f1 = figure('units','normalized','outerposition', imageSize);%, 'Visible', 'off');  
    t2 = tiledlayout(2,2);
    t2.TileSpacing = 'tight';
    t2.Padding = 'compact';
    %axis tight;
    
    for i = 1:4
        %% perpare data
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
        y.TagDist(y.TagDist == "LX0.2") = "LX";

        %% Dist/Sel probabilities 
        nexttile;
        x = 0:100:length(y.OpDist)*100-1;
        model_series = [opData.OpDist] .* 100;
        b = bar(x./100, model_series, 'stacked');
        for j = 1:length(Operators)
            if(j==1)
                color = [1-lineColor(1) 1-lineColor(2) lineColor(3)];
            else
                color = [lineColor(1)*(length(Operators)/(j-1)), lineColor(2)/(length(Operators)/(j-1)), 1-lineColor(3)*(length(Operators)/(j-1))];
            end
            b(j).FaceColor = color;
            b(j).LineWidth = 0.0001;
            b(j).EdgeAlpha = 0.5;
        end
        hold on

        %legend(flip(b), flip(betterOpNames), 'fontsize',global_subfontsize, 'Location','bestoutside') 

        set(gca,'FontSize', global_subfontsize) 
        ylim([0 100])
        xlim([min(x)/100 max(x)]/100)
        xticks([0:10:100]);
        
        ytickformat('percentage')
        if(i == 1)
            set(gca, 'xticklabel', {});
        elseif(i == 2)
            legend(flip(b), flip(betterOpNames),'Location','bestoutside','fontsize', global_subfontsize);
            set(gca, 'xticklabel', {});
            set(gca, 'yticklabel', {});
        elseif(i == 4) 
            set(gca, 'yticklabel', {});
        end
        
        title(HHNames(i), 'fontsize', global_fontsize);
        if (i==4)
            title(t2, append('Score Distribution on ', probname, ", M = ", string(M), ", D = ", string(D)), 'Fontsize', global_fontsize)
            xlabel(t2, 'Generation','fontsize', global_fontsize);            
            ylabel(t2, 'Distribution','fontsize', global_fontsize);
            exportgraphics(f1, 'Plots/' + name(2) ...
                + '_OPDIST_' + "New" ...
                + '_' + name(4) + '.pdf', 'ContentType', 'vector');
            %matlab2tikz('myfigure.tex', 'standalone', true);%'figurehandle', f1, 'Plots/' + name(2) ...
                %+ '_OPDIST_' + "New" ...
                %+ '_' + name(4) + '.tex');
        end
    end
end
  