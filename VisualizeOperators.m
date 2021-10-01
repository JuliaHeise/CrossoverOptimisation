close all; clc;
%% Visualize Operator results
%% init
Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];

Operators = {MyDE(), MyLCX(), MyLX(), MyRSBX(), MySBX(), MyUX()};
for operator = Operators
    c = linspace(1,10,3);
    Pop = Population;
    f = figure('Name', operator{1}.TAG);
    axis([0 1 0 1]);
    hold on
    for i=1:100
        Pop = Pop(randperm(length(Pop)),:);
        x = operator{1}.Cross(Pop);
        scatter(x(:,1), x(:,2), 5, 'r', 'filled');
    end
    scatter(Population(:,1), Population(:,2), 'filled', 'b');
    hold off
    
    exportgraphics(f, operator{1}.TAG + '.png','Resolution',300)
end


Operator = MyCMAX();
Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];

c = linspace(1,10,3);
Pop = Population;
f = figure('Name', Operator.TAG);
axis([0 1 0 1]);
hold on
for i=1:100
    Pop = Pop(randperm(length(Pop)),:);
    x = Operator.Cross(Pop);
    scatter(x(:,1), x(:,2), 5, 'r', 'filled');
end
scatter(Population(:,1), Population(:,2), 'filled', 'b');
hold off

%exportgraphics(f, Operator.TAG + '.png','Resolution',300)


