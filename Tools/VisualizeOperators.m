close all; clc;
%% Visualize Operator results
darkGrey =  [0.1 0.1 0.1];
grey = [0.5 0.5 0.5];
blueGrey = [0.7 0.7 0.8];
lightGrey = [0.2 0.2 0.2];
%% init
Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];
Operators = {MyDE(), MyLCX(), MyUX(),MySBX(), MyRSBX(), MyLX()};

%% Centric
for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG + '_centric');
    axis([0 1 0 1]);
    hold on
    scatter(Population(:,1), Population(:,2), 40, lightGrey, 'd', ...
        'filled', 'MarkerEdgeColor', darkGrey, 'LineWidth',1.5);

    Pop = Pop(randperm(length(Pop)),:);
    x = operator{1}.Cross(Pop);
    scatter(x(:,1), x(:,2), 20, blueGrey , 'filled');
    
    Pop = Pop(randperm(length(Pop)),:);
    x = operator{1}.Cross(Pop);
    scatter(x(:,1), x(:,2), 20, grey, '^', 'filled' );

    hold off

    exportgraphics(f, 'Images/Operators/' + operator{1}.TAG  + '_centric'+ '.png','Resolution',300);

end

%% 500 times
for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG);
    axis([0 1 0 1]);
    hold on
    for i=1:500
        Pop = Pop(randperm(length(Pop)),:);
        x = operator{1}.Cross(Pop);
        scatter(x(:,1), x(:,2), 5, grey , 'filled');
    end
    scatter(Population(:,1), Population(:,2), 40, lightGrey, 'd', ...
        'filled', 'MarkerEdgeColor', darkGrey, 'LineWidth',1.5);
    hold off

    exportgraphics(f,'Images/Operators/' +  operator{1}.TAG + '.png','Resolution',300);

end

%% with mutation
Pop = Population;
f = figure('Name', 'Original');
axis([0 1 0 1]);
hold on
for i=1:500
    Pop = Pop(randperm(length(Pop)),:);
    x = OperatorGA(Pop);
    scatter(x(:,1), x(:,2), 5, grey , 'filled');
end
scatter(Population(:,1), Population(:,2), 40, lightGrey, 'd', ...
    'filled', 'MarkerEdgeColor', darkGrey, 'LineWidth',1.5);
hold off


for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG);
    axis([0 1 0 1]);
    hold on
    for i=1:500
        Pop = Pop(randperm(length(Pop)),:);
        x = operator{1}.Cross(Pop);
        x = MyMutation(x);
        scatter(x(:,1), x(:,2), 5, grey , 'filled');
    end
    scatter(Population(:,1), Population(:,2), 40, lightGrey, 'd', ...
        'filled', 'MarkerEdgeColor', darkGrey, 'LineWidth',1.5);
    hold off

    exportgraphics(f,'Images/Operators/' +  operator{1}.TAG + '_mutated.png','Resolution',300);

end

%% CMAX
Operator = MyCMAX();
Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];

c = linspace(1,10,3);
Pop = Population;
f = figure('Name', Operator.TAG);
axis([0 1 0 1]);
hold on

[x, m, C] = Operator.Cross_(Population, {1, 500});
[y, ~, ~] = Operator.Cross_(Population, {0.25, 500});


%Plot ellipses, then change their color and other properties
h = plotcov(C, m); 
scatter(x(:,1), x(:,2), 5, blueGrey , 'filled');
scatter(y(:,1), y(:,2), 5, grey, '^', 'filled' );
scatter(Population(:,1), Population(:,2), 60, lightGrey, 'd', ...
    'filled', 'MarkerEdgeColor', darkGrey);
hold off

exportgraphics(f, 'Images/Operators/' +Operator.TAG + '.png','Resolution',300);




function h = plotcov(C, mu, varargin)
% Visualise a 2x2 covariance matrix by drawing ellipses at 1, 2 and 3 STD.
%
% Input arguments:
%  C         2x2 Covariance matrix.
%  MU        Optional 1x2 array defining the centre of the ellipses.
%            The default value is [0,0].
%  VARARGIN  Any keyword arguments can be passed to `plot`.
%
% Output arguments:
%  H         3x1 vector of plot handles. One per ellipse. In order, they
%            are the handles to the ellipses at 1, 2 and 3 STD.
%
  if nargin<2 || isempty(mu), mu=[0 0]; end
  
  % Find sorted eigenvectors and eigenvalues for C.
  [V,D]  = eig(C);
  [~,ix] = sort(diag(D), 'descend');
  D      = D(ix,ix);
  V      = V(:,ix);
  
  % Define the scales at which to draw the ellipses.
  stds   = [1]; % 1, 2 and 3 standard deviations.
  conf   = 2 * normcdf(stds) - 1;
  scale  = chi2inv(conf, 2);
  
  % Set up a circle. Will be scaled to ellipses.
  t = linspace(0, 2*pi, 100)';
  e = [cos(t) sin(t)];
  
  % Line styles (and handles) for the ellipses.
  styles = {
    {'LineWidth',2};    % 1 STD
    {};                 % 2 STD
    {'LineStyle',':'}   % 3 STD
  };
  h = zeros(numel(stds), 1);
  
  washold = ishold;
  
  for i = 1:numel(stds)
    % Set up the i-th scaled ellipse.
    VV    = V * sqrt(D * scale(i));
    ee    = bsxfun(@plus, e*(VV'), mu);
    
    % Draw with different properties for different ellipses.
    % Also, pick the colour from the first ellipse for aesthetics.
    if i == 1
      h(i) = plot(ee(:,1), ee(:,2), styles{i}{:}, varargin{:});
      c    = get(h(i), 'Color');
      hold on;
    else
      h(i) = plot(ee(:,1), ee(:,2), 'Color',c, styles{i}{:}, varargin{:});
    end
  end
  
  if ~washold
    hold off;
  end
end
