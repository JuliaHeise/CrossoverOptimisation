close all; clc;
%% Visualize Scoring
f = figure('Name', 'Scoring');
axis([0 10 0 10]);
x = 0:0.1:7;
y = (x - floor(7/2)).^3; 
x2 = 0:1:7;
y2 = (x2 - floor(7/2)).^3; 
plot(x, y,'b-',x2,y2, 'ro');
grid on

exportgraphics(f, 'Scoring.png','Resolution',300)
