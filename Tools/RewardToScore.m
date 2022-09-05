close all; clc;

global_fontsize = 20;
global_subfontsize = 13;
global_markersize = 8;
global_midisize = 40;
global_minisize = 5;
global_primeLine = 2;
global_seconLine = 1;
global_imagesize = [0 0 0.3 0.5];

darkGrey =  [0.1 0.1 0.1];
grey = [0.5 0.5 0.5];
blueGrey = [0.7 0.7 0.8];
lightGrey = [0.2 0.2 0.2];

%% Visualize Scoring
f1 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off'); 

set(gca,'FontSize', global_fontsize) 
ylabel('Offsprings produced','fontsize', global_fontsize);
xlabel('FEs','fontsize', global_fontsize);    
                    
axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Cubic(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Cubic(x2, floor(7/2)); 
plot(x, y,'k-',x2,y2, 'ko', 'LineWidth', global_primeLine, ...
    'MarkerSize', global_markersize, 'MarkerFaceColor', blueGrey);
grid on

exportgraphics(f1, 'ScoringCubic.pdf', 'ContentType', 'vector');

%% Visualize Scoring
f2 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off');
set(gca,'FontSize', global_fontsize) 
ylabel('Offsprings produced','fontsize', global_fontsize);
xlabel('FEs','fontsize', global_fontsize);    

axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Linear(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Linear(x2, floor(7/2)); 
plot(x, y,'k-',x2,y2, 'ko', 'LineWidth', global_primeLine, ...
    'MarkerSize', global_markersize, 'MarkerFaceColor', blueGrey);
grid on

exportgraphics(f2, 'ScoringLinear.pdf', 'ContentType', 'vector');

%% Visualize Scoring
f3 = figure('units','normalized','outerposition',global_imagesize);%, 'Visible', 'off');

set(gca,'FontSize', global_fontsize) 
ylabel('Offsprings produced','fontsize', global_fontsize);
xlabel('FEs','fontsize', global_fontsize);    
axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Logistic(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Logistic(x2, floor(7/2)); 
plot(x, y,'k-',x2,y2, 'ko', 'LineWidth', global_primeLine, ...
    'MarkerSize', global_markersize, 'MarkerFaceColor', blueGrey);
grid on

exportgraphics(f3, 'ScoringLogistic.pdf', 'ContentType', 'vector');
