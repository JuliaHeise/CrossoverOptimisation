function GetIGDPlots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize)
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

    marker = ["-o" "-+" "-*" "-s" "-d" "-x" "-^" "--" ":"];
    lineColor2 = [0.1 0.1 0.1];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();

    first = true;

    probNumber = 0;

    for exp = "HARDER" %["STD", "HARDER", "HARDEST"]
        f1 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off');
        t2 = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
        for prob = [TestSetting.problemClasses]
            for q = 1:length(prob.versions)
                v = [prob.versions];
                v = v(q);
                probname = prob.name;
                %% Get All IGD in one Array
                filenames = append(prefix, suffix1, exp, suffix2, probname, string(v), '*');
                files_for_p = splitlines(string(ls(filenames)));

                for i = 1:length(TestSetting.algorithms)
                    name = split(files_for_p(i),'_');
                    alg = split(name(end),'.');
                    results(probNumber*length(TestSetting.algorithms) + i,:)= ...
                        struct('problem', probname, 'version', v, 'algorithm', ...
                        alg(1), 'data', ...
                        load(append(files_for_p(i))).res);
                end
                
                 pro = str2func(append(probname, string(v)));
                 p = pro();
                 if(exp == "STD")
                     M = p.M;
                     D = p.D;
                 elseif (exp == "HARDER")
                     M = p.M;
                     D = p.D * 4;
                 else
                     M = p.M;
                     D = p.D * 6;
                 end
                t = append(probname, string(v), ", M = ", string(M), ", D = ", string(D));
                
                if false
                    HHNames = ["HHX-D", "HHX-S"];
                    HHAlgs = TestSetting.hhAlgorithms(3:4);

                    %% Hypervolume over time for single algorithms        
                    nexttile
                    axis tight;
                    ylim([0.25 1.0]);
                    xlabel('FEs','fontsize', global_subfontsize);
                    if(first)
                        ylabel('IGD','fontsize', global_subfontsize);
                        first = false;
                    end
    
                    singleResults = struct('Algorithm',{},'FEs',{},'FullIGD',{},'LastIGD',{});
                    hold on
                    grid on
                    for i = 1:length(TestSetting.singleAlgorithms)
                        data = results(...
                        join([results.problem; results.version],"",1) == append(probname, string(v))...
                        & [results.algorithm] == TestSetting.singleAlgorithms(i));
    
                        singleResults(i) = ...
                            struct('Algorithm', TestSetting.singleAlgorithms(i), ...
                            'FEs', [data.data.median_run.result{:,1}], ...
                            'FullIGD',  data.data.median_run.metric.IGD, ...
                            'LastIGD', data.data.median_run.metric.IGD(end));
    
                        p = plot(singleResults(i).FEs, singleResults(i).FullIGD,...
                            marker(i),'LineWidth',global_primeLine);
                        if(i==1)
                            color = [1-lineColor(1) 1-lineColor(2) lineColor(3)];
                        else
                            color = [lineColor(1)*(length(TestSetting.singleAlgorithms)/(i-1)), lineColor(2)/(length(TestSetting.singleAlgorithms)/(i-1)), 1-lineColor(3)*(length(TestSetting.singleAlgorithms)/(i-1))];
                        end
                        p.Color = color;
                        p.MarkerFaceColor = color;
                        p.MarkerSize = global_markersize;
                    end
                    
                    for q = 1:length(HHAlgs)
                        hold on
    
                        data = results(...
                        join([results.problem; results.version],"",1) == append(probname, string(v))...
                        & [results.algorithm] == HHAlgs(q));
    
                        p = plot([data.data.median_run.result{:,1}],...
                            data.data.median_run.metric.IGD,...
                            marker(i+q),'LineWidth',global_primeLine*1.5);
                        p.Color = lineColor2; 
                        p.MarkerFaceColor = lineColor2; 
                        p.MarkerSize = global_markersize;
                    end
                    
                    set(gca ,'FontSize',global_subfontsize);
                    title(t, 'fontsize', global_subfontsize);
                    labels = [TestSetting.singleAlgorithms HHNames];
                    labels(labels == 'NSGAII') = 'SBX';                    

                %% Hypervolume over time for HH algorithms
                else
                    nexttile
                    axis tight;
                    xlabel('FEs','fontsize',global_fontsize);
                    ylabel('IGD','fontsize',global_fontsize);
                    
                    singleResults = struct('Algorithm',{},'FEs',{},'FullIGD',{},'LastIGD',{});
                    hold on
                    grid on
                    for i = 1:length(TestSetting.singleAlgorithms)
                        data = results(...
                        join([results.problem; results.version],"",1) == append(probname, string(v))...
                        & [results.algorithm] == TestSetting.singleAlgorithms(i));
    
                        singleResults(i) = ...
                            struct('Algorithm', TestSetting.singleAlgorithms(i), ...
                            'FEs', [data.data.median_run.result{:,1}], ...
                            'FullIGD',  data.data.median_run.metric.IGD, ...
                            'LastIGD', data.data.median_run.metric.IGD(end));
                    end
    
                    for i = 1:length(TestSetting.hhAlgorithms)
                        hold on
    
                        data = results(...
                        join([results.problem; results.version],"",1) == append(probname, string(v))...
                        & [results.algorithm] == TestSetting.hhAlgorithms(i));
    
                        p = plot([data.data.median_run.result{:,1}],...
                            data.data.median_run.metric.IGD,...
                            marker(i),'LineWidth',global_primeLine);
                        p.Color = lineColor.*(i/length(TestSetting.hhAlgorithms)); 
                        p.MarkerFaceColor = lineColor.*(i/length(TestSetting.hhAlgorithms)); 
                        p.MarkerSize = global_markersize;
                    end
    
                    [~,idx] = min([singleResults.LastIGD]);
    
                    p = plot(singleResults(idx).FEs,singleResults(idx).FullIGD, ...  
                        'k--', 'LineWidth', global_primeLine);
                    p.Color(4) = 0.75;
                    set(gca,'FontSize',global_fontsize)
                    
                    labels = [TestSetting.hhAlgorithms singleResults(idx).Algorithm];
                    labels(labels == 'NSGAII') = 'SBX';
                    labels(labels == 'SRXSNSGAII') = 'HHX-S';
                    labels(labels == 'SRXDNSGAII') = 'HHX-D';
                    labels(labels == 'AlternatingHHXNSGAII') = 'HHX-A';
                    labels(labels == 'CaterpillarHHXNSGAII') = 'HHX-E';
                    
                    grid on
    
                    title(t, 'fontsize', global_fontsize);
                    
                    hold off
                  
                    probNumber = probNumber + 1; 
                end
            end
            probNumber = 0;
        end
        %legend(erase(labels, 'NSGAII'),'Location','bestoutside','fontsize', global_subfontsize);
        legend(erase(labels, 'NSGAII'),'Location','bestoutside','fontsize',global_subfontsize);
        exportgraphics(f1, 'Plots/' + name(2) ...
            + '_' + name(3) + '_New.pdf', 'ContentType', 'vector');
    end
end




