%% Tidy up
clc; clear; close all;
global_fontsize = 15;
global_subfontsize = 13;
global_markersize = 5;
global_primeLine = 1.5;
global_seconLine = 1;
global_imagesize = [0 0 0.4 0.5];

%% After Saving all Data, get those runs with median HV and median IGD
fprintf('Get Median Runs')
%GetMedianRuns;

%% Generate Plots of HV over Time (per Alg+Prob comination)
%fprintf('Get HV Plots')
%GetHVPlots(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize);

%% Generate Plots of IGD over Time (per Alg+Prob comination)
fprintf('Get IGD Plots')
%GetIGDPlots2(global_fontsize, global_subfontsize, global_markersize,global_primeLine, global_seconLine, global_imagesize);

%% Generate Plots of Operator Selection Data
fprintf('Get XOP Plots')
%GetXOPPlots3(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize);

%% Generate Plots of Operator Selection Data
fprintf('Get XOP Plots')
DistPanels(global_fontsize, global_subfontsize, global_markersize, global_primeLine, global_seconLine, global_imagesize);