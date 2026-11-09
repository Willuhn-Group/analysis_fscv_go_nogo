% 16/04/2025 
% Eugenia
% This script is to plot the magazine entries during the ITI of the go/no-go task. 
% The cut file timings were calculated from DLC files, where the animal was far away 
% and then moved to the magazine, but it had to be the second movement to the magazine because the first 
% movement would be related to either checking magazine when it was an incorrect trial, or for reward collection.
% NOT INCLUDING start pellet checks

close all
clear
clc

load("Figure 2_ITI\ITI_selfGNGFD.mat")
Overall = struct();
time = -14.9:0.1:20 ;

ratIDs = fieldnames(FSCVdata);
legend_strings = {};
colour = hex2rgb('#6c3eb6');
FSCVfile = readtable("Figure 2_ITI\selfGNGFD_ITI_magazine_entries.csv");


for r = 1:length(ratIDs)
    ratID = ratIDs{r};
    Overall(r).ratID = ratID;
    Overall(r).region = 'VMS';
    Overall(r).sm_magentry = FSCVdata.(ratID).filterVMS;
    Overall(r).MagEntries = FSCVMEDPC_avgperanimal(FSCVdata.(ratID).filterVMS(:,2:end), time);
    
    % plot_settings(Overall(r).MagEntries', colours, r, time);
    legend_strings = [legend_strings, ratID]; % add rat ID to legend_strings

    idx = strcmp(FSCVfile.Animal, ratID) & ~strcmp(FSCVfile.condition, 'StartPellet') & ~isnan(FSCVfile.mag_reach_s_iti);
    filtered_data = FSCVfile(idx, :);
    orient2magreach = filtered_data.orient_s_iti - filtered_data.mag_reach_s_iti;

    % Filter and compute the average of Orientation
    Overall(r).average_orientation = mean(orient2magreach);
end

xline(0, 'LineStyle','--')
xlim([-3 8])
ylim([-10 15])

title('Aligned to ITI magazine entry')
legend(legend_strings)

[textoutput, data4export, avgpercond4export] = FSCVMEDPC_plotall(Overall , {'MagEntries'}, time, 'suppressplot', true);
summary = FSCVMEDPC_avgperanimal(cell2mat(data4export(2:end,:)), time);

figure
plot_settings(summary', colour, 1, time)

% plot the orientation time 
xline(mean([Overall.average_orientation]), 'Color', colour, 'LineWidth', 1.5, ...
    'LineStyle', '--', 'HandleVisibility', 'off', 'Alpha', 0.8);

figname = 'Aligned to magazine entry in ITI';
title(figname);
text(max(xlim) + 0.25, min(ylim), textoutput, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')

fontsize(gcf, 18, "points")
xlim([-3 8])
ylim([-10 15])

recording_name = 'GNG_free_delay_noNP';
aa.lines = 'no';

figureSettings(recording_name, aa.lines, Overall(1).region);
legend('ITI', 'location', 'northeastoutside')

