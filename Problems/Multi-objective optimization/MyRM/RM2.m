classdef RM2 < PROBLEM
% <multi> <real> <large/none> <expensive/none>
% Benchmark MOP proposed by Zitzler, Deb, and Thiele

%------------------------------- Reference --------------------------------
% E. Zitzler, K. Deb, and L. Thiele, Comparison of multiobjective
% evolutionary algorithms: Empirical results, Evolutionary computation,
% 2000, 8(2): 173-195.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        %% Default settings of the problem
        function Setting(obj)
            obj.M = 2;
            if isempty(obj.D); obj.D = 30; end
                        
            if ~isempty(obj.DMulti); obj.D = obj.D*obj.DMulti; end
            
            obj.lower    = zeros(1,obj.D);
            obj.upper    = ones(1,obj.D);
            obj.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            PopObj(:,1) = PopDec(:,1);
             g = 1 + 9*sum((PopDec(:,3:end)-PopDec(:,2)).^2,2)/(size(PopDec,1)-1);
            h = 1 - (PopObj(:,1)./g).^2;
            PopObj(:,2) = g.*h;
        end
        %% Generate points on the Pareto front
        function R = GetOptimum(obj,N)
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^2;
        end
        %% Generate the image of Pareto front
        function R = GetPF(obj)
            R = obj.GetOptimum(100);
        end
    end
end