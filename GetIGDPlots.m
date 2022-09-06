function GetIGDPlots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize)
    %% Tidy up
    close all; clc;

    %% Setup Version + Prob + Algo combinations
    prefix = 'F:\MasterCode\MedianRuns\';
    suffix1 = 'MEDIAN_';
    suffix2 = '_IGD_';
    darkGrey =  [0.1 0.1 0.1];
    grey = [0.5 0.5 0.5];
    blueGrey = [0.2 0.4 0.6];
    lightGrey = [0.85 0.85 0.85];

    marker = ["-o" "-+" "-*" "-s" "-d" "-x" "-o" "--" ":"];
    lineColor2 = [0.1 0.1 0.1];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();
    
    HHNames = ["HHX-S", "HHX-D"];

    probNumber = 0;

    for exp = "HARDER" %["STD", "HARDER", "HARDEST"]
        for prob = [TestSetting.problemClasses]
            for q = 1:length(prob)
                v = [prob.versions];
                v = v(q);
                probname = [prob.name];
                probname = probname(q);
                %% Get All IGD in one Array
                filenames = append(prefix, suffix1, exp, suffix2, probname, string(v), '*');
                files_for_p = string(ls(filenames));

                for i = 1:length(TestSetting.algorithms)
                    name = split(files_for_p(i),'_');
                    alg = split(name(end),'.');
                    results(probNumber*length(TestSetting.algorithms) + i,:)= ...
                        struct('problem', probname, 'version', v, 'algorithm', ...
                        alg(1), 'data', ...
                        load(append(prefix, files_for_p(i))).res);
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
                
                %% Hypervolume over time for single algorithms        
                f1 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off');
                axis tight;
                xlabel('FEs','fontsize', global_subfontsize);
                ylabel('IGD','fontsize', global_subfontsize);

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
                
                for q = 1:length(TestSetting.hhAlgorithms)
                    hold on

                    data = results(...
                    join([results.problem; results.version],"",1) == append(probname, string(v))...
                    & [results.algorithm] == TestSetting.hhAlgorithms(q));

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
                legend(erase(labels, 'NSGAII'),'Location','best','fontsize', global_subfontsize, 'NumColumns',2);

                plo = get(gca,'Position');
                set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.2 plo(4)-0.2]);
                
                exportgraphics(f1, 'Paper/Images/Plots/' + name(2) ...
                + '_' + name(3) + '_' + name(4) + '_S.pdf', 'ContentType', 'vector');
                hold off

                %% Hypervolume over time for HH algorithms
                f2 = figure('units','normalized','outerposition',global_imagesize, 'Visible', 'off');
               
                axis tight;
                xlabel('FEs','fontsize',global_fontsize);
                ylabel('IGD','fontsize',global_fontsize);

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
                    'k--', 'LineWidth', global_seconLine);
                p.Color(4) = 0.75;
                set(gca,'FontSize',global_fontsize)
                
                labels = [TestSetting.hhAlgorithms singleResults(idx).Algorithm];
                labels(labels == 'NSGAII') = 'SBX';
                labels(labels == 'SRXSNSGAII') = 'HHX-S';
                labels(labels == 'SRXDNSGAII') = 'HHX-D';
                
                legend(erase(labels, 'NSGAII'),...
                    'Location','best','fontsize',global_subfontsize, 'NumColumns',2);
                grid on

                title(t, 'fontsize', global_fontsize);
                
                plo = get(gca,'Position');
                set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.2 plo(4)-0.2]);
                                 
                exportgraphics(f2, 'Paper/Images/Plots/' + name(2) ...
                + '_' + name(3) + '_' + name(4) + '_HH.pdf', 'ContentType', 'vector');
                hold off
                

               %% IGD Ranking
                for i = 1:length(TestSetting.algorithms)
                    data = results(join([results.problem; results.version],"",1)...
                            == append(probname, string(v))...
                        & [results.algorithm] ...
                            == TestSetting.algorithms(i)).data;

                        n = TestSetting.algorithms(i);
                        if(n == "NSGAII")
                            n = "SBX";
                        elseif (n == "SRXSNSGAII")
                            n = "HHX-S";
                        elseif (n == "SRXDNSGAII")
                            n = "HHX-D";
                        end
                            
                    y(i) = struct('name', n, ... 
                        'endResult', data.median_run.metric.IGD(end), ...
                        'endIQR', data.iqrEnd, ...
                        'midResult', data.median_run.metric.IGD(6), ...
                        'midIQR', data.iqrMid);
                end

                mind = min([[y.endResult]-[y.endIQR] [y.midResult]-[y.midIQR]]);
                maxi = max([[y.endResult]+[y.endIQR] [y.midResult]+[y.midIQR]]);

                f3 = figure('units','normalized','outerposition', [0 0 0.7 0.7], 'Visible', 'off');  
                x = categorical(erase([y.name], "NSGAII"));
                x = reordercats(x,string(x));

                model_series = [y.midResult;y.endResult]';
                b = bar(x, model_series, 'grouped', 'BarWidth', 1);    
                hold on
                [ngroups,nbars] = size(model_series);

                % Get the x coordinate of the bars
                z = nan(nbars, ngroups);
                for i = 1:nbars
                    z(i,:) = b(i).XEndPoints;
                end
                e = errorbar(z',model_series, [y.midIQR; y.endIQR]', 'k', 'linestyle','none'); 

                if(mind ~= maxi)
                    ylim([max([0 mind-0.6*(maxi-mind)]) maxi+0.02*(maxi-mind)]);
                end

                b(1).FaceColor = lightGrey;
                b(1).LineStyle = ':';
                b(1).LineWidth = 0.1;

                b(2).FaceColor = blueGrey;
                b(2).LineWidth = 0.1;
               
                                
                rectangle('Position',[0  min([singleResults.LastIGD])...
                    length(x)+1 max([singleResults.LastIGD])-min([singleResults.LastIGD]),], ...
                    'FaceColor', [grey 0.25], 'LineStyle', 'none');
                
                xline(7.5, 'k--', 'LineWidth', 0.4);
                
                % Legend will show names for each color
                set(get(get(e(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                legend({'at 3.000 FEs',...
                'at 10.000 FEs','Interquartile Range'}, 'fontsize', global_subfontsize/1.5, 'Location', 'north', 'NumColumns', 3); 

                set(gca,'FontSize', global_fontsize) 
                ylabel('IGD','fontsize', global_fontsize);

                grid on
                hold off
                
                title(t, 'fontsize', global_fontsize);
                
                plo = get(gca,'Position');
                set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.2 plo(4)-0.2]);

                exportgraphics(f3, 'Paper/Images/Plots/' + name(2) + '_' ... 
                + name(3) + '_' + name(4) + '_Summary.pdf', 'ContentType', 'vector');

                probNumber = probNumber + 1; 
            end
            probNumber = 0;
        end
    end
end




