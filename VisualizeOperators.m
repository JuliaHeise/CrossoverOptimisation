close all; clc; clear all;
%% Visualize Operator results
%% init
Population = [0.4 0.4; 0.4 0.6; 0.6 0.5];

Operators = {MyCMAX(), MyDE(), MyLCX(), MyLX(), MyRSBX(), MySBX(), MyUX()};
%Operators = {MyCMAX()};


for operator = Operators
    c = linspace(1,10,3);
    Pop = Population;
    figure('Name', operator{1}.TAG)
    axis([0 1 0 1]);
    hold on
    for i=1:100
        x = operator{1}.Cross(Pop);
        scatter(x(:,1), x(:,2), 3, 'r', 'filled');
%        Pop = x;
    end
    scatter(Population(:,1), Population(:,2), 'filled', 'b');
    hold off
end

