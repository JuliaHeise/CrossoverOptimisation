function IGDSubplots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine)
    %% Tidy up
    close all; clc;

    %% Setup Version + Prob + Algo combinations
    prefix = 'MedianRuns/';
    suffix1 = 'MEDIAN_';
    suffix2 = '_IGD_';

    imageSize = [0 0 0.35 0.3];

    marker = ["-o" "-+" "-^" "-s" "-d" "-x" "-*" "--" ":"];
    lineColor2 = [0.1 0.1 0.1];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();

    f1 = figure('units','normalized','outerposition',imageSize);%, 'Visible', 'off');
    t2 = tiledlayout(1,2,'TileSpacing','Tight','Padding','Compact');
    j = 0;
    for probname = ["RM2", "WFG5"]
        j = j + 1;
        %% Get All IGD in one Array
        filenames = append(prefix, suffix1, 'HARDER', suffix2, probname, '*');
        files_for_p = splitlines(string(ls(filenames)));

        for i = 1:length(TestSetting.algorithms)
            name = split(files_for_p(i),'_');
            alg = split(name(end),'.');
            results((j-1)*length(TestSetting.algorithms) + i,:)= ...
                struct('problem', probname, 'algorithm', ...
                alg(1), 'data', ...
                load(append(files_for_p(i))).res);
        end
        
        pro = str2func(append(probname));
        p = pro();
        M = p.M;
        D = p.D * 4;

        t = append(probname, ", M = ", string(M), ", D = ", string(D));
               
        HHNames = ["HHX-D", "HHX-S"];
        HHAlgs = TestSetting.hhAlgorithms(1:2);

        %% Hypervolume over time for single algorithms        
        nexttile
        axis tight;
        ylim([0.25 1.0]);
        if(j == 1)
            ylabel('IGD','fontsize', global_fontsize);
        else
            set(gca, 'yticklabel', {});
        end

        singleResults = struct('Algorithm',{},'FEs',{},'FullIGD',{},'LastIGD',{});
        hold on
        grid on
        singleAlgs = flip(TestSetting.singleAlgorithms);
        p = {};
        for i = 1:length(singleAlgs)
            data = results(join([results.problem],"",1) == probname...
            & [results.algorithm] == singleAlgs(i));

            singleResults(i) = ...
                struct('Algorithm', singleAlgs(i), ...
                'FEs', [data.data.median_run.result{:,1}], ...
                'FullIGD',  data.data.median_run.metric.IGD, ...
                'LastIGD', data.data.median_run.metric.IGD(end));

            p{i} = plot(singleResults(i).FEs./100, singleResults(i).FullIGD,...
                marker(i),'LineWidth',global_seconLine);
            if(i==1)
                color = [1-lineColor(1) 1-lineColor(2) lineColor(3)];
            else
                color = [lineColor(1)*(length(singleAlgs)/(i-1)), lineColor(2)/(length(singleAlgs)/(i-1)), 1-lineColor(3)*(length(singleAlgs)/(i-1))];
            end
            p{i}.Color = color;
            p{i}.MarkerFaceColor = color;
            p{i}.MarkerSize = global_markersize;
        end
        
        p = flip(p);

        for q = 1:length(HHAlgs)
            i = i +1;
            hold on

            data = results(...
            join([results.problem],"",1) == probname...
            & [results.algorithm] == HHAlgs(q));

            p{i} = plot([data.data.median_run.result{:,1}]/100,...
                data.data.median_run.metric.IGD,...
                marker(i),'LineWidth',global_primeLine*1.5);
            p{i} .Color = lineColor2; 
            p{i} .MarkerFaceColor = lineColor2; 
            p{i} .MarkerSize = global_markersize;
        end
        
        set(gca ,'FontSize',global_subfontsize);
        title(t, 'fontsize', global_fontsize);
        labels = [flip(singleAlgs) HHNames];
        labels(labels == 'NSGAII') = 'SBX';    
        labels = erase(labels, 'NSGAII');
        labels(labels == 'DE') = 'DEX';   
        if(j == 2)
            %legend(erase(labels, 'NSGAII'),'Location','bestoutside','fontsize', global_subfontsize);
            legend([p{1:end}], labels,'Location','bestoutside','fontsize',global_subfontsize);
            xlabel(t2, "Generation", 'fontsize', global_fontsize);
            exportgraphics(f1, 'Plots/' + name(2) ...
                + '_' + name(3) + '_Old.pdf', 'ContentType', 'vector');
        end
    end
end




