close all; clc;
%% Visualize Scoring
f1 = figure('Name', 'Scoring');
axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Cubic(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Cubic(x2, floor(7/2)); 
plot(x, y,'b-',x2,y2, 'ro');
grid on

%exportgraphics(f1, 'Scoring.png','Resolution',300)

%% Visualize Scoring
f2 = figure('Name', 'Scoring');
axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Linear(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Linear(x2, floor(7/2)); 
plot(x, y,'b-',x2,y2, 'ro');
grid on

%exportgraphics(f2, 'Scoring.png','Resolution',300)

%% Visualize Scoring
f = figure('Name', 'Scoring');
axis([0 10 0 10]);
x = 0:0.1:7;
y = Scoring.Logistic(x, floor(7/2)); 
x2 = 0:1:7;
y2 = Scoring.Logistic(x2, floor(7/2)); 
plot(x, y,'b-',x2,y2, 'ro');
grid on

%exportgraphics(f3, 'Scoring.png','Resolution',300)
