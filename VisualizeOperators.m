close all; clc;
%% Visualize Operator results
%% init
Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];

Operators = {MyUX(), MyDE(), MySBX(), MyRSBX(), MyLX(), MyLCX()};
% Operators = {MySBX(), MyRSBX()};


for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG + '_centric');
    axis([0 1 0 1]);
    hold on
    scatter(Population(:,1), Population(:,2), 40, [0.1 0.1 0.1], 'd', 'filled');

    Pop = Pop(randperm(length(Pop)),:);
    x = operator{1}.Cross(Pop);
    scatter(x(:,1), x(:,2), 20, [0.5 0.5 0.7] , 'filled');
    
    Pop = Pop(randperm(length(Pop)),:);
    x = operator{1}.Cross(Pop);
    scatter(x(:,1), x(:,2), 20, [0.3 0.3 0.5],'x' );

    hold off

   % exportgraphics(f, operator{1}.TAG + '.png','Resolution',300)

end

Operators = {MySBX(), MyRSBX(), MyLX(), MyLCX()};

for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG);
    axis([0 1 0 1]);
    hold on
    for i=1:500
        Pop = Pop(randperm(length(Pop)),:);
        x = operator{1}.Cross(Pop);
        scatter(x(:,1), x(:,2), 3, 'r', 'filled');
    end
    scatter(Pop(:,1), Pop(:,2), 'd', 'filled', 'b');
    hold off

   % exportgraphics(f, operator{1}.TAG + '.png','Resolution',300)

end

Operators = {MyUX(), MyDE()};

for operator = Operators
    Pop = Population;
    f = figure('Name', operator{1}.TAG);
    axis([0 1 0 1]);
    hold on
    for i=1:500
        Pop = Pop(randperm(length(Pop)),:);
        x = operator{1}.Cross(Pop);
        scatter(x(:,1), x(:,2), 20, 'r', 'filled');
    end
    scatter(Pop(:,1), Pop(:,2), 'd', 'filled', 'b');
    hold off

   % exportgraphics(f, operator{1}.TAG + '.png','Resolution',300)

end

Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];

% Operator = MyCMAX();
% Population = [0.3 0.4; 0.6 0.2; 0.5 0.7];
% 
% c = linspace(1,10,3);
% Pop = Population;
% f = figure('Name', Operator.TAG);
% axis([0 1 0 1]);
% hold on
% 
% [x, m, C] = Operator.Cross_(Population, {1, 500});
% [y, ~, ~] = Operator.Cross_(Population, {0.25, 500});


% Plot ellipses, then change their color and other properties
% h = plotcov(C, m); 
% scatter(x(:,1), x(:,2), 3, 'r', 'filled');
% scatter(y(:,1), y(:,2), 3, 's', 'filled');
% scatter(Population(:,1), Population(:,2), 'filled', 'b');
% hold off
% 
% exportgraphics(f, Operator.TAG + '.png','Resolution',300)




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
