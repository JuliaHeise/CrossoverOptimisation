function GetXOPPlots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize)
    %% Tidy up
    close all; clc;

    %% Setup Version + Prob + Algo combinations
    prefix = 'Evaluation\MedianRuns\';
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
    Operators = ["CMAX", "DE", "LCX3", "LX", "RSBX", "SBX", "UX"];
    
    HHNames = ["HHX-A", "HHX-E", "HHX-S", "HHX-D"];
    probNumber = 0;


    for exp = "HARDER" %["STD", "HARDER", "HARDEST"]
        for prob = [TestSetting.problemClasses]
            for q = 1:length(prob)
                v = [prob.versions];
                v = v(q);
                probname = [prob.name];
                probname = probname(q);
                %% Tidy up
                close all;
                %% Get All HV in one Array
                filenames = append(prefix, suffix1, exp, suffix2, probname, string(v),'_SRXSNSGAII.mat');
                files_for_p = string(ls(filenames));

                for i = 1:length(TestSetting.algorithms)
                    name = split(files_for_p(1),'_');
                    alg = split(name(end),'.');
                    results(probNumber*length(TestSetting.algorithms) + 1,:)= ...
                        struct('problem', probname, 'version', v, 'algorithm', ...
                        alg(1), 'data', ...
                        load(append(prefix, files_for_p(1))).res);
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

                     
                for i = 1%:length(TestSetting.hhAlgorithms)
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
                    %% Dist/Sel probabilities  
                    f1 = figure('units','normalized','outerposition',global_imagesize, 'Visible', 'off');   
                    
                    x = 0:100:length(y.OpDist)*100-1;
                    model_series = [opData.OpDist] .* 100;
                    b = bar(x, model_series, 'stacked');
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

                    legend(flip(b), flip(betterOpNames), 'fontsize',global_subfontsize, 'Location','bestoutside') 

                    set(gca,'FontSize', global_fontsize) 
                    ylim([0 100])
                    xlim([min(x) max(x)])
                    ytickformat('percentage')

                    if(contains(TestSetting.hhAlgorithms(i), 'XS'))
                        ylabel('Selection Probability','fontsize', global_fontsize);
                    else
                        ylabel('Generation Distribution','fontsize', global_fontsize);
                    end

                    xlabel('FEs','fontsize', global_fontsize);
                    
                    grid on
                    hold off

                    title(t, 'fontsize', global_fontsize);
                    
                    plo = get(gca,'Position');
                    set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.1 plo(4)-0.2]);
                                        
                    exportgraphics(f1,  'Evaluation/Plots/' + name(2) ...
                       + '_OPDIST_' + TestSetting.hhAlgorithms(i) ...
                       + '_' + name(4) + '.pdf', 'ContentType', 'vector');


                    %% Cummaltive Pickrate    
                    f2 = figure('units','normalized','outerposition',global_imagesize, 'Visible', 'off');    
                    x = 0:100:(length(y.TagDist)-1)*100;

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
                    legend( flip([p{1:end}]), flip(betterOpNames), 'fontsize',global_subfontsize, 'Location','bestoutside') 

                    set(gca,'FontSize', global_fontsize) 
                    ylabel('Offsprings produced','fontsize', global_fontsize);
                    xlabel('FEs','fontsize', global_fontsize);          
                    xlim([min(x) max(x)])
                    
                    title(t, 'fontsize', global_fontsize);
                    
                    plo = get(gca,'Position');
                    set(gca,'Position',[plo(1) plo(2)+0.1 plo(3)-0.1 plo(4)-0.2]);
    
                    grid on
                    hold off
                
                    exportgraphics(f2, 'Evaluation/Plots/' + name(2) ...
                        + '_CUMPROD_' + TestSetting.hhAlgorithms(i) ...
                        + '_' + name(4) + '.pdf', 'ContentType', 'vector');
                end
            end
        end
    end
end