function GetXOPPlots2(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize)
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

    marker = ["-o" "-+" "-*" "-s" "-d" "-x" "-o" "-+" "-*" "-s" "-d" "-x"];
    lineColor = [0.1 0.9 0.1];

    TestSetting = TestSettings();

    %Operators = ["CMAX1", "DE0.5", "LCX3", "LX0.2", "RSBX", "SBX", "UX"];
    betterOpNames = ["CMAX", "DE", "LCX3", "LX", "RSBX", "SBX", "UX"];
    betterOpNames = [betterOpNames(6), betterOpNames(1), betterOpNames(7), betterOpNames(5), betterOpNames(4), betterOpNames(2), betterOpNames(3)];
    Operators = ["LCX3", "DE", "LX", "RSBX", "UX", "CMAX", "SBX"];
    
    HHNames = ["HHX-A", "HHX-E", "HHX-D", "HHX-S"];
    probNumber = 0;


    for exp = "HARDER" %["STD", "HARDER", "HARDEST"]
        for prob = [TestSetting.problemClasses]
            for q = 1:length(prob.versions)
                v = [prob.versions];
                v = v(q);
                probname = prob.name;
                %% Tidy up
                close all;
                %% Get All HV in one Array
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

                
                 
                for i = 1:length(TestSetting.hhAlgorithms)
                    if(i == 1 | i == 3)
                        f2 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off');  
                        t2 = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
                    end
                    t = append(HHNames(i), ", ", probname, string(v), ", M = ", string(M), ", D = ", string(D));
                    
                    data = results(join([results.problem; results.version],"",1)...
                            == append(probname, string(v))...
                        & [results.algorithm] ...
                            == TestSetting.hhAlgorithms(i)).data;

                    y = struct('OpDist', data.median_run.xOpProbs, ...
                        'TagDist', data.median_run.tagDist);

                    for k = 1:length(Operators)
                        opData(k) = struct('Operator', Operators(k), 'OpDist', y.OpDist(:,k));
                    end
                    opData = [opData(6), opData(1), opData(7), opData(5), opData(4), opData(2), opData(3)];
                    
                    
                    y.TagDist(y.TagDist == "LCX") = "LCX3";
                    y.TagDist(y.TagDist == "CMAX1") = "CMAX";
                    y.TagDist(y.TagDist == "DE0.5") = "DE";
                    y.TagDist(y.TagDist == "LX0.2") = "LX";
            
                    %% Cummaltive Pickrate    
                    x = 0:100:(length(y.TagDist)-1)*100;
                    nexttile 
                    p = {};
                    for j = 1:length(Operators)
                        model_series = [0; cumsum(sum(y.TagDist == opData(j).Operator, 2))]';
                        p{j} = plot(x, model_series, marker(j),'LineWidth', global_primeLine, 'MarkerIndices',j*2:10:length(model_series)-2);
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


                    set(gca,'FontSize', global_fontsize) 
                    if(i == 1 || i == 3)
                        ylabel('Offsprings produced','fontsize', global_fontsize);
                    end
                    xlabel('FEs','fontsize', global_fontsize);          
                    xlim([min(x) max(x)])
                    
                    title(t, 'fontsize', global_fontsize);
                    
                   % plo = get(gca,'Position');
                    %set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.1 plo(4)-0.2]);
    
                    grid on
                    hold off

                    labels = [TestSetting.singleAlgorithms];
                    labels(labels == 'NSGAII') = 'SBX';  

                    if(i == 2)
                        legend(Operators,'Location','bestoutside','fontsize', global_subfontsize);
                        %legend( flip([p{1:end}]), flip(betterOpNames), 'fontsize',global_subfontsize, 'Location','bestoutside') 
                        exportgraphics(f2, 'Plots/' + name(2) ...
                            + '_CUMPROD_' + "Old" ...
                            + '_' + name(4) + '.pdf', 'ContentType', 'vector');
                    elseif (i==4)
                        legend(Operators,'Location','bestoutside','fontsize', global_subfontsize);
                        %legend( flip([p{1:end}]), flip(betterOpNames), 'fontsize',global_subfontsize, 'Location','bestoutside') 
                        exportgraphics(f2, 'Plots/' + name(2) ...
                            + '_CUMPROD_' + "New" ...
                            + '_' + name(4) + '.pdf', 'ContentType', 'vector');
                    end
               
                end

            end
        end
    end
end