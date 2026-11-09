clc; clear; close all % house keeping

aa.c1 = '_selfGNG';
aa.c2 = '_cueGNG';
aa.c3 = '_selfGNGFD';
aa.c4 = '_cueGNGFD';

aa.recording = aa.c4;
aa.filedir = fullfile(strcat('FSCVMEDPC', aa.recording, '.mat'));
load(aa.filedir, "FSCVMEDPC");

aa.regions = {'VMS'};
region = 'VMS';

aa.channels = {'Ch0', 'Ch1'};
aa.rewardedtype = {'correct','incorrect'};
aa.rewarded = 'correct';

aa.alignments = {
    'sm_moveAcue', ...
    'sm_nphold', ...
    'sm_magreach', ...
    };

al = 1;
alignment = aa.alignments{al};

aa.showstats = 'yes';
aa.analyse_indiv = 'yes'; % perform bootstrapping/permutation tests between animals ('yes') or between each trace

aa.p = 0.05;
aa.thres = 10;

if strcmp(aa.recording, '_selfGNGFD')
    aa.bars = ([-5 25]);
else
    aa.bars = ([-10 20]);
end
aa = setConditions(aa, 'alignment', alignment);

[FSCVMEDPC, aa.conditions] = fxmergeGo(FSCVMEDPC, aa);

summary.ratID = [];
for k = 1:length(aa.conditions)
    aa.condition = aa.conditions{k};
    summary.(aa.condition) = [];
    summary.(['avgDA' aa.condition]) = [];
end

%% Create structs
for k = 1:length(aa.conditions)
    aa.condition = aa.conditions{k};
    for i = 1:size(FSCVMEDPC, 2) % check lengths of FSCVMEDPC
        if strfind(FSCVMEDPC(i).region, region)
            summary(i).ratID =  FSCVMEDPC(i).ratID;
            summary2(i).ratID =  FSCVMEDPC(i).ratID;
            % Check the number of trial types
            try
                [aa.dataOutput] = FSCVMEDPC_avgperanimal(FSCVMEDPC(i).(alignment).(aa.condition)(:,2:end), aa.time);

                if sum(aa.dataOutput(:,4))/350 > 1
                    summary(i).(aa.condition) = aa.dataOutput;
                    [window_mean, ~] = FSCVMEDPC_window(FSCVMEDPC(i).(alignment).(aa.condition), aa.recording);
                    summary(i).(['avgDA' aa.condition]) = window_mean;
                    if strcmp(aa.condition, 'Go')
                        summary(i).(['reward_' aa.condition]) = mean([FSCVMEDPC(i).realignment_times.GoL.rewarddelivery; FSCVMEDPC(i).realignment_times.GoR.rewarddelivery], 'omitnan');
                        try
                            summary(i).(['orient_' aa.condition]) = mean([FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoL']).neck.orient_s; FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoR']).neck.orient_s], 'omitnan');
                            summary(i).(['speed2mag_' aa.condition]) = mean([FSCVMEDPC(i).DLC_outputs.correctGoL.neck.speed2mag; FSCVMEDPC(i).DLC_outputs.correctGoR.neck.speed2mag], 'omitnan');
                            summary(i).(['magreach_' aa.condition]) = mean([FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoL']).neck.mag_reach_s; FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoR']).neck.mag_reach_s], 'omitnan');

                        catch
                            try
                                summary(i).(['orient_' aa.condition]) = mean(cell2mat([FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoL']).neck.orient_s; FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoR']).neck.orient_s]), 'omitnan');
                                summary(i).(['speed2mag_' aa.condition]) = mean(cell2mat([FSCVMEDPC(i).DLC_outputs.correctGoL.neck.speed2mag; FSCVMEDPC(i).DLC_outputs.correctGoR.neck.speed2mag]), 'omitnan');
                                summary(i).(['magreach_' aa.condition]) = mean(cell2mat([FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoL']).neck.mag_reach_s; FSCVMEDPC(i).DLC_outputs.([aa.rewarded 'GoR']).neck.mag_reach_s]), 'omitnan');

                            catch
                                summary(i).(['orient_' aa.condition]) = [];
                                summary(i).(['speed2mag_' aa.condition]) = [];
                                summary(i).(['magreach_' aa.condition]) = [];

                            end
                        end
                    else
                        summary(i).(['reward_' aa.condition]) = mean(FSCVMEDPC(i).realignment_times.(aa.condition).rewarddelivery, 'omitnan');
                        try
                            summary(i).(['orient_' aa.condition]) = mean(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.orient_s, 'omitnan');
                            summary(i).(['speed2mag_' aa.condition]) = mean(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.speed2mag, 'omitnan');
                            summary(i).(['magreach_' aa.condition]) = mean(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.mag_reach_s, 'omitnan');

                        catch
                            try
                                summary(i).(['orient_' aa.condition]) = mean(cell2mat(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.orient_s), 'omitnan');
                                summary(i).(['speed2mag_' aa.condition]) = mean(cell2mat(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.speed2mag), 'omitnan');
                                summary(i).(['magreach_' aa.condition]) = mean(cell2mat(FSCVMEDPC(i).DLC_outputs.([aa.rewarded aa.condition]).neck.mag_reach_s), 'omitnan');


                            catch
                                summary(i).(['orient_' aa.condition]) = [];
                                summary(i).(['speed2mag_' aa.condition]) = [];
                                summary(i).(['magreach_' aa.condition]) = [];

                            end
                        end

                    end

                    % Get all the trials
                    summary2(i).(aa.condition) = FSCVMEDPC(i).(alignment).(aa.condition);

                    % Get the average latencies of first and last lever presses
                    if strcmp(aa.condition, 'Go')
                        tmp1 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).firstL_LPframe];
                        tmp2 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).firstR_LPframe];
                        tmp = [tmp1 tmp2];
                        summary2(i).([aa.condition 'firstpress']) = mean(tmp, 'omitnan');

                        clearvars tmp tmp1 tmp2

                        tmp1 = [];
                        for tmp = 1:length(FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]))
                            if length(FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition])(tmp).leverpress) > 0
                                tmp1 = [tmp1; length(FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition])(tmp).leverpress)];
                            end
                        end

                        summary2(i).([aa.condition 'mean_presses']) = mean(tmp1, 'omitnan');
                        summary2(i).([aa.condition 'std_presses']) = std(tmp1, 'omitnan');
                        summary2(i).([aa.condition 'min_presses'])  = min(tmp1);
                        summary2(i).([aa.condition 'max_presses'])  = max(tmp1);
                        clearvars tmp tmp1

                        tmp1 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).lastL_LPframe];
                        tmp2 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).lastR_LPframe];
                        tmp = [tmp1 tmp2];
                        summary2(i).([aa.condition 'lastpress']) = mean(tmp, 'omitnan');

                        clearvars tmp tmp1 tmp2
                        tmp1 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).rewardedL_LPframe];
                        tmp2 = [FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).rewardedR_LPframe];
                        tmp = [tmp1 tmp2];
                        summary2(i).([aa.condition 'rewardedpress']) = mean(tmp, 'omitnan');
                    end

                    tmp = lower(string(aa.condition));

                    summary2(i).([aa.condition '_npexit']) = mean([FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).([tmp '_nphold'])]);
                    summary2(i).([aa.condition '_nplight']) = mean([FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).('NPlight')]);
                    summary2(i).([aa.condition '_Acue']) = mean([FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).('Acue')]);
                    summary2(i).([aa.condition '_N']) = length([FSCVMEDPC(i).MEDPC.([aa.rewarded aa.condition]).('NPlight')]);

                else
                    summary(i).(aa.condition) = aa.dataOutput;
                    summary(i).(['avgDA' aa.condition]) = [];

                    summary2(i).(aa.condition) = [];
                end
                aa.index(i) = true; % Set corresponding index to true
            catch
                continue
                fprintf("check")
            end
        end
    end
end

%% Plot Figure 2c) Action-cue onset
figure
[n, summary4, summary5] = FSCVMEDPC_plotall(summary, aa.conditions, aa.time); % n = get the number of rats for function figureSettings
summary5 = cell2table(summary5(2:end, :), "VariableNames", summary5(1,:));
fontsize(gcf, 18, "points")
figureSettings(aa.recording, aa.lines, region, 'textinput', n, 'alignment', alignment, 'rewardtype', aa.rewarded, 'ylimit',aa.bars);
if strcmp(alignment, 'sm_moveAcue')
    figureAddOns_moveAcue(summary, summary5, 'orient_lines', 0)
end
aa.figname = strcat('ALL_', region, '_', aa.recording, '__', alignment);
title(aa.figname, 'Interpreter', 'none', 'FontSize', 10);

% Run the stats
aa.sig = 0.05;
aa.numboots = 5000;
[stats, btsrp] = fxmergestats(summary, aa);

% Run a nested loop to iterate over combinations for permutation tests
i=1; j=1;
for i = 1:numel(aa.conditions)
    for j = i+1:numel(aa.conditions)
        fprintf('%s + %s\n', aa.conditions{i}, aa.conditions{j});
        aa.name = strcat(aa.conditions{i}, '_', aa.conditions{j});
        [tmp] = boot_within_diffCIexp(stats.(aa.conditions{i}), stats.(aa.conditions{j}), 5000, aa.p);
        btsrp_within_diff_CI.(aa.name) = (tmp(1,:) >= 0) & (tmp(2,:) <= 0); % If CI range is above/below 0, then return a 0, otherwise return 1 (because f(x) for plotting below looks for 0s)
    end
end

fxshowstatsbars(btsrp_within_diff_CI, aa);

aa.figname = strcat('Fig 2c) Action-cue onset_', aa.recording);
title(aa.figname, 'Interpreter', 'none');

%% Plot Figure 2d) Nosepoke exit
al = 2;
alignment = aa.alignments{al};
aa = setConditions(aa);

summary_nphold = generate_summary_flex(FSCVMEDPC, aa, region, 'alignment', alignment, 'headers', {'orient', 'reward', 'magreach'});
summary_nphold = getmaxDAdetails(summary_nphold, aa, 'nphold', 1);


figure
aa.lines = 'no';
[n, summary4, summary5] = FSCVMEDPC_plotall(summary_nphold, aa.conditions, aa.time); % n = get the number of rats for function figureSettings
summary5 = cell2table(summary5(2:end, :), "VariableNames", summary5(1,:));

fontsize(gcf, 18, "points")
figureSettings(aa.recording, aa.lines, region, 'textinput', n, 'alignment', alignment, 'rewardtype', aa.rewarded, 'ylimits', 1);

if strcmp(aa.recording, '_cueGNGFD')
    figureAddOns(summary_nphold, summary5, 'action_lines', 0 , 'reward', 1, 'orient_lines', 1, 'max_arrow', 1, 'custom_go_search', 130)
else
    figureAddOns(summary_nphold, summary5, 'action_lines', 0 , 'reward', 1, 'orient_lines', 1, 'max_arrow', 1)
end

% Saving figures and tables
aa.figname = strcat('Fig 2d) Nose-poke exit_', aa.recording);
title(aa.figname, 'Interpreter', 'none', 'FontSize', 10);

%% Plot Figure 2e) Magazine arrival
al = 3;
alignment = aa.alignments{al};
aa = setConditions(aa);

summary_magreach = generate_summary_flex(FSCVMEDPC, aa, region, 'alignment', alignment, 'headers', {'reward', 'orient', 'lastinter'});
summary_magreach = getmaxDAdetails(summary_magreach, aa);

figure
[n, ~, summary5] = FSCVMEDPC_plotall(summary_magreach, aa.conditions, aa.time); % n = get the number of rats for function figureSettings
summary5 = cell2table(summary5(2:end, :), "VariableNames", summary5(1,:));

fontsize(gcf, 18, "points")
figureSettings(aa.recording, aa.lines, region, 'textinput', n, 'alignment', alignment, 'rewardtype', aa.rewarded, 'ylimits', 1);
% ylim([-15 15])

if strcmp(aa.recording, '_cueGNGFD')
    figureAddOns(summary_magreach, summary5, 'action_lines', 0 , 'reward', 1, 'orient_lines', 1, 'max_arrow', 1, 'custom_go_search', 130)
else
    figureAddOns(summary_magreach, summary5, 'action_lines', 0 , 'reward', 1, 'orient_lines', 1, 'max_arrow', 1)
end

aa.figname = strcat('Fig 2e) Magazine arrival_', aa.recording);
title(aa.figname, 'Interpreter', 'none', 'FontSize', 10);
%% Functions
function figureAddOns_moveAcue(summary, summary_averages, varargin)
p = inputParser;
addRequired(p, 'summary');
addRequired(p, 'summary_averages');

addParameter(p, 'orient_lines', 1, @isnumeric);

parse(p, summary, summary_averages, varargin{:})

plot_orient_lines = p.Results.orient_lines;

figure(gcf)
ax = gca; % Get the current axes
hold(ax, 'on'); % Ensure new elements are added to the same plot

ylimits = ylim(ax); % Get y-axis limits for the active axes

if any(contains(fieldnames(summary), 'GoL'))
    myhexvalues = containers.Map({'GoL', 'GoR', 'Nogo', 'Free'}, ...
        {'#00c000', '#005a00', '#ff0000', '#0080ff'});
else
    myhexvalues = containers.Map({'Go', 'Nogo', 'Free'}, ...
        {'#5CC54D', '#D00202', '#0080ff'});
end

fnames = fieldnames(summary);
idx = contains(fnames, '_');
timings = fnames(idx);

for i = 1:length(timings)
    timing_info = strsplit(timings{i}, '_');
    timing_values = summary.(timings{i});
    timing_mean = mean([summary.(timings{i})], 'omitnan');
    timing_sd = std([summary.(timings{i})], 'omitnan');
    condition = timing_info{2};

    % Calculate SEM
    n_samples = sum(~isnan(timing_values)); % Count of non-NaN samples
    timing_sem = timing_sd / sqrt(n_samples); % Compute SEM

    % Ensure key exists before accessing the map
    if isKey(myhexvalues, condition)
        colour = myhexvalues(condition);
    else
        colour = '#000000'; % Default color if key is missing
    end

    if contains(timing_info{1}, "orient") && plot_orient_lines
        xline(timing_mean, 'Color', colour, 'LineWidth', 1.5, ...
            'LineStyle', '--', 'HandleVisibility', 'off', 'Alpha', 0.8);

        x_rect = [timing_mean - timing_sem, timing_mean + timing_sem, ...
            timing_mean + timing_sem, timing_mean - timing_sem];
        y_rect = [ylimits(1), ylimits(1), ylimits(2), ylimits(2)];
        colour_rgb = hex2rgb(colour); % Convert hex to RGB
        fill(ax, x_rect, y_rect, colour_rgb, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'HandleVisibility', 'off');

    elseif contains(timing_info{1}, "reward")
        % Get the idx where the number matches and the dopamine value for the trialtype
        idx = find(round(summary(1).Nogo(:,1),1) == round(timing_mean,1));
        idx_DA = summary_averages.(condition)(idx);

        plot(timing_mean, idx_DA, 'o', 'MarkerSize', 15,  'Color', colour, 'LineWidth', 3,  'HandleVisibility', 'off')

    end
end
end

function figureAddOns(summary, summary_averages, varargin)
p = inputParser;
addRequired(p, 'summary');
addRequired(p, 'summary_averages');

addParameter(p, 'reward', 0, @isnumeric);
addParameter(p, 'action_lines', 1, @isnumeric);
addParameter(p, 'orient_lines', 1, @isnumeric);
addParameter(p, 'max_arrow', 0, @isnumeric);
addParameter(p, 'custom_go_search', 0, @isnumeric);

parse(p, summary, summary_averages, varargin{:})

plot_stars = p.Results.reward;
plot_action_lines = p.Results.action_lines;
plot_orient_lines = p.Results.orient_lines;
plot_max_arrow = p.Results.max_arrow;
custom_go_search = p.Results.custom_go_search;

figure(gcf)
ax = gca; % Get the current axes
hold(ax, 'on'); % Ensure new elements are added to the same plot

ylimits = ylim(ax); % Get y-axis limits for the active axes

if any(contains(fieldnames(summary), 'GoL'))
    myhexvalues = containers.Map({'GoL', 'GoR', 'Nogo', 'Free'}, ...
        {'#00c000', '#005a00', '#D00202', '#0080ff'});
else
    myhexvalues = containers.Map({'Go', 'Nogo', 'Free'}, ...
        {'#5CC54D', '#D00202', '#0080ff'});
end

fnames = fieldnames(summary);
idx = contains(fnames, 'lastinter2');

if all(idx == false)
    idx = contains(fnames, 'magreach2');
    if all(idx == false)
        idx = contains(fnames, 'nphold2');
    end
end
timings = fnames(idx);

for i = 1:length(timings)
    timing_info = strsplit(timings{i}, '_');
    timing_values = summary.(timings{i});
    timing_mean = mean([summary.(timings{i})], 'omitnan');
    timing_sd = std([summary.(timings{i})], 'omitnan');
    condition = timing_info{2};

    % Calculate SEM
    n_samples = sum(~isnan(timing_values)); % Count of non-NaN samples
    timing_sem = timing_sd / sqrt(n_samples); % Compute SEM

    % Ensure key exists before accessing the map
    if isKey(myhexvalues, condition)
        colour = myhexvalues(condition);
    else
        colour = '#000000'; % Default color if key is missing
    end

    if contains(timing_info{1}, "orient") && plot_orient_lines
        xline(timing_mean, 'Color', colour, 'LineWidth', 1.5, ...
            'LineStyle', '--', 'HandleVisibility', 'off', 'Alpha', 0.8);
    elseif contains(timing_info{1}, "reward") && plot_stars
        % Get the idx where the number matches and the dopamine value for the trialtype
        idx = find(round(summary(1).Nogo(:,1),1) == round(timing_mean,1));
        idx_DA = summary_averages.(condition)(idx);

        plot(timing_mean, idx_DA, 'o', 'MarkerSize', 15,  'Color', colour, 'LineWidth', 3,  'HandleVisibility', 'off')

    elseif contains(timing_info{1}, "2lastinter") && plot_action_lines
        xline(timing_mean, 'Color', colour, 'LineWidth', 1.5, ...
            'LineStyle', '-.', 'HandleVisibility', 'off', 'Alpha', 0.8);
    end

end

if plot_max_arrow
    % get the moment of the max value
    for ii = 1:width(summary_averages)
        condition = summary_averages.Properties.VariableNames{ii};
        % get the maxDA conc and idx of it
        if custom_go_search > 0 && contains(condition, 'Go')
            [maxDA, idx] = max(summary_averages.(condition)(custom_go_search:custom_go_search+30));
            idx = custom_go_search-1+idx;
        else
            [maxDA, idx] = max(summary_averages.(condition));
        end

        timeMax = summary(1).Nogo(idx); % since there is always a Nogo trial, get the time

        gap = 5;
        triangleSize = 350; % marker size, adjust as needed
        yl = ylim;
        y_triangle = yl(2) -5;
        scatter(timeMax, y_triangle - ii/2, triangleSize, ...
            'v', 'MarkerFaceColor', myhexvalues(condition), ...
            'MarkerEdgeColor', 'none', 'HandleVisibility', 'off'); % 'v' = downward triangle
    end
end
end
