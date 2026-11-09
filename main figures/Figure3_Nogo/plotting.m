clc; clear; close all % house keeping

aa.c1 = '_selfGNG';
aa.c2 = '_cueGNG';
aa.c3 = '_selfGNGFD';
aa.c4 = '_cueGNGFD';

aa.recording = aa.c4;
aa.recordingname = strcat('FSCVMEDPC', aa.recording);
addpath '\\vs03\VS03-NandB-1\Eugenia\FSCV_Rat_Striatum_GoNogo\Methods_and_materials\MATLAB_publication';
aa.filedir = fullfile(strcat(aa.recordingname, '.mat'));
load(aa.filedir, "FSCVMEDPC");

regions = {'VMS'};
region = 'VMS';
sel_cr = {'ID', 'trialnumber','nogo_nphold', 'NPlight', 'magspeed'}; % to get variable names from MEDPC
sel_nogo = {'nogo_vigor', 'nogo_digging', 'nogo_turning', 'nogo_biting'};

aa.channels = {'Ch0', 'Ch1'};
aa.rewardedtype = {'correct','incorrect'};
aa.rewarded = 'correct';

aa.alignments = {'sm_moveAcue'};

al = 1;
alignment = aa.alignments{al};

aa = setConditions(aa, 'alignment', alignment);

printtext = false;

%% Read the No-go table
filedir = 'clustered.csv';
% Read data
df = readtable(filedir);
% Train a Decision Tree Model
tree3 = fitctree(df(:,["Vig" "Dig" "Turn" "Bite"]), df.clusters3);

% % view(tree3) % text description
% view(tree3,'mode','graph') % graphic description

%%
summary=[];
for l = 1:length(regions)
    region = regions{l};
    if ~contains(region, 'VMS')
        continue
    end
    sel_struc.(region).DAsignal = []; % initialise the DAsignal array
    sel_struc.(region).meanDAsignal = []; % initialise the meanDAsignal array
    sel_struc.(region).rewarddelivery = []; % initialise the rewarddeivery array
    sel_struc.(region).magreach = [];
    summary.(region) = [];

    % initialise MEDPC arrays
    for icr = 1:length(sel_cr)
        sel_struc.(region).(sel_cr{icr}) = [];
    end

    % initialise the sel_nogo arrays
    for in = 1:length(sel_nogo)
        sel_struc.(region).(sel_nogo{in}) = [];
    end
    i = 1;
    aa.index = false(1,size(FSCVMEDPC,2));
    for i = 1:size(FSCVMEDPC,2)
        if strfind(FSCVMEDPC(i).region, region)
            summary.(region)(i).ratID = FSCVMEDPC(i).ratID;
            summary.(region)(i).MEDPC = FSCVMEDPC(i).MEDPC.correctNogo;
            try
            summary.(region)(i).magspeed = FSCVMEDPC(i).DLC_outputs.correctNogo.neck.speed2mag;
            end
            % enter each field and check for empties
            fn2check = fieldnames(summary.(region)(i).MEDPC);
            fn = 1;
            for fn = 1:length(fn2check)
                ce = 1;
                for ce = 1:size(summary.(region)(i).MEDPC,2)
                    % replace that element with NaN
                    if isempty(summary.(region)(i).MEDPC(ce).(fn2check{fn}))
                        summary.(region)(i).MEDPC(ce).(fn2check{fn}) = -1;
                    end
                end
            end
            try
                summary.(region)(i).nogo_score = FSCVMEDPC(i).nogo_score;
                summary.(region)(i).nogo_score = table2array(summary.(region)(i).nogo_score);
                summary.(region)(i).DAsignal = FSCVMEDPC(i).(alignment).Nogo(:,2:end)';
                [aa.dataOutput] = FSCVMEDPC_avgperanimal(FSCVMEDPC(i).(alignment).Nogo(:,2:end), aa.time)';
                summary.(region)(i).meanDA = aa.dataOutput;
                summary.(region)(i).rewarddelivery = FSCVMEDPC(i).realignment_times.Nogo.rewarddelivery;
                summary.(region)(i).magreach = FSCVMEDPC(i).realignment_times.Nogo.magreach2reward  ;
            end

            % in case there is no manual scoring done
            if isempty(summary.(region)(i).nogo_score)
                aa.index(i) = false;
            else
                aa.index(i) = true; % Set corresponding index to true
            end
        end
    end
    summary.(region) = summary.(region)(aa.index==1);
end

%% ----------------- loop over ratIDs and write each substruct filter + region
for l = 1:length(regions)
    region = regions{l};
    if ~contains(region, 'VMS')
        continue
    end
    i = 1;
    for i = 1:size(summary.(region),2)

        try
            nogo_result = summary.(region)(i).DAsignal; % get the full trace DA concentration
            nogo_mean = summary.(region)(i).meanDA(2,:);% get the mean DA concentration within specified window, 1 x n arr
            nogo_rewarddelivery = summary.(region)(i).rewarddelivery;
            nogo_score =summary.(region)(i).nogo_score;
            nogo_magreach = summary.(region)(i).magreach;
            try
                nogo_score = nogo_score/1; % there are some importing issues, need to make sure they're numbers
            catch
                nogo_score = str2double(nogo_score);
            end
            in = 1;
            for in = 1:length(sel_nogo)
                field_name = sel_nogo{in};
                sel_struc.(region).(field_name) = [sel_struc.(region).(field_name); nogo_score(:,in)];
            end

            icr = 1;

            % Add the MEDPC data in the sel_struc struct from sel_cr
            for icr = 1:length(sel_cr)
                if strcmp(sel_cr{icr}, 'ID')
                    tmp = strsplit(summary.(region)(i).ratID, 'Rat');
                    tmp = str2double(tmp{2});
                    tmp2 = repmat(tmp,1,size(summary.(region)(i).MEDPC,2))';
                    sel_struc.(region).(sel_cr{icr}) = cat(1,sel_struc.(region).(sel_cr{icr}), tmp2);
                elseif strcmp(sel_cr{icr}, 'magspeed')
                    if iscell(summary.(region)(i).magspeed)
                        n = numel(summary.(region)(i).magspeed);
                        magspeedArray = NaN(n, 1);  % Default to NaN
                        for checking = 1:n
                            val = summary.(region)(i).magspeed{checking};
                            if ~isempty(val)
                                magspeedArray(checking) = val;
                            end
                        end
                    else
                        magspeedArray = summary.(region)(i).magspeed;
                    end
                    sel_struc.(region).(sel_cr{icr}) = cat(1,sel_struc.(region).(sel_cr{icr}), [magspeedArray]);
                else
                    sel_struc.(region).(sel_cr{icr}) = cat(1,sel_struc.(region).(sel_cr{icr}), [summary.(region)(i).MEDPC.(sel_cr{icr})]');
                end
            end
            sel_struc.(region).DAsignal = vertcat(sel_struc.(region).DAsignal, nogo_result);
            sel_struc.(region).meanDAsignal = vertcat(sel_struc.(region).meanDAsignal, nogo_mean);
            sel_struc.(region).rewarddelivery = vertcat(sel_struc.(region).rewarddelivery, nogo_rewarddelivery);
            sel_struc.(region).magreach = vertcat(sel_struc.(region).magreach, nogo_magreach);

        end
    end

    sel_struc.(region).nogo_all = [sel_struc.(region).nogo_vigor sel_struc.(region).nogo_digging...
        sel_struc.(region).nogo_turning sel_struc.(region).nogo_biting];
    sel_struc.(region).cluster = predict(tree3, sel_struc.(region).nogo_all);
end

%% ----------------- PLOT NOGO TRIALS -----------------
counter = 0;
legend_names = [];
nogo_pie = [];
sel_DA_value_array = []; % for plotting histograms

COND_SCALAR = -1;
COND_NOMINAL = -2;
COND_NOGO = -3; % for finding nogo scores


figure
np=1;

windows = 4;
region = 'VMS';
export_matrix =[];
% for np = 1:length(unique(sel_struc.VMS.cluster))+1
for np = 1:windows
    counter = counter + 1;
    if np == 1
        clusno = 0;
        legend_input = 'Nogo';
    elseif np == 2
        % figure
        clusno = clusno + 1;
        legend_input = strcat('Clus', string(clusno));
    else
        clusno = clusno + 1;
        legend_input = strcat('Clus', string(clusno));
    end

    %%%%%%%%%%%%%%%%% FILL IN %%%%%%%%%%%%%%%%%%
    sel_conditions.ID = [COND_NOMINAL];
    sel_conditions.trialnumber = [COND_SCALAR];            % set limits, scalar e.g. [0 200], which is 0 to 2000 ms
    sel_conditions.nogo_nphold = [COND_SCALAR];        % set limits, scalar e.g. [0 200], which is 0 to 2000 ms
    sel_conditions.NPlight = [COND_SCALAR];     % set limits, scalar e.g. [0 200], which is 0 to 2000 ms
    sel_conditions.cluster = [COND_NOGO clusno];

    % --------- run function to select trials (matrix_cond) ---------
    [sel_struc, matrix_cond, figure_name]  = idxtrials(region, sel_cr, sel_struc, sel_conditions, 'sel_nogo', sel_nogo);

    extracted_filteredratID = sel_struc.(region).ID(matrix_cond.(region).final, :); % select ratIDs that satisfy conditions above
    extracted_filteredratID = tabulate(extracted_filteredratID); % get a breakdown of the ratIDs > 0% for score(s)
    extracted_filteredratID = extracted_filteredratID(extracted_filteredratID(:,2) ~= 0, :);

    % --------- this part only works if it's with the clusters ---------
    extracted_filteredratID(:,4) = clusno;

    tmp = (0.1:0.1:length(sel_struc.(region).filtered_row)/10);  % add a timestamp in column 1, 10 Hz

    [tmp] = DA_conc_periods(sel_struc.(region), matrix_cond.(region).final, aa.recording);
    tmp(:,5) = clusno;
    sel_DA_value_array = [sel_DA_value_array; tmp]; % split into [ratID | trialsignal | AcueON | correct | cluster]
    % nogo_pie.(['cluster' num2str(clusno)]) = extracted_filteredratID(:,1:2);

    nogo_pie = [nogo_pie; extracted_filteredratID(:,[1 2 4])]; % column 1 = ratID, 2 = number of traces, 3 = cluster (0 = all animals)

    nogo_medpc.([figure_name 'ID'])= sel_struc.(region).ID(matrix_cond.(region).final, :);
    nogo_medpc.([figure_name 'nphold'])= sel_struc.(region).nogo_nphold(matrix_cond.(region).final, :);
    nogo_medpc.([figure_name 'NPlight'])= sel_struc.(region).NPlight(matrix_cond.(region).final, :);
    rewarddelivery_avg = sel_struc.(region).rewarddelivery(matrix_cond.(region).final, :);
    if strcmp(alignment, 'sm_magreach')
        tmp = sel_struc.(region).magreach(matrix_cond.(region).final, :);
        rewarddelivery_avg = cell2mat(tmp);
    end

    % plot average of traces
    myhexvalues = {'#ffffff'; '#5724C7'; '#3BB9AB'; '#750000'}; % when plotting clusters, first is 'no-go' for all

    colours = hex2rgb(myhexvalues);
    plot_data = [aa.time; sel_struc.(region).filtered_meanDAsignal_avg];
    plot_settings(plot_data, colours, counter, aa.time, 'nogo', true)

    if counter == 1
        fontsize(gcf, 18, "points")

        figureSettings(aa.recording, aa.lines, region,...
            'alignment', alignment,...
            'rewardtype', aa.rewarded,...
            'once', counter);
    else
        if strcmp(alignment, 'sm_moveAcue')
            timing_mean = mean(rewarddelivery_avg, 'omitnan');

            idx = find(round(aa.time,1) == round(timing_mean,1));
            idx_DA = sel_struc.(region).filtered_meanDAsignal_avg(1,idx);

            plot(timing_mean, idx_DA, 'o', 'MarkerSize', 15,  'Color', colours(counter,:), 'LineWidth', 3,  'HandleVisibility', 'off')
        end
    end

    if printtext
        string4text = strcat(string(legend_input), ...
            ' Rats: ', num2str(height(extracted_filteredratID)), ...
            ' Traces:  ', num2str(sum(extracted_filteredratID(:,2))), ...
            ' RatID:', num2str(extracted_filteredratID(:,1)'));

        text(min(xlim) + 0.5, max(ylim)-counter*0.5*2, string4text, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontSize', 10)
        fprintf('%s\n', string4text)
    end

    legend_names = [legend_names; string(legend_input)];
    hold on

    if np ~= 1 && strcmp(alignment, "sm_moveAcue")
        % Extract ID and DA signal
        ID = sel_struc.VMS.filtered_ratID;              % n x 1 vector
        group = repmat(string(legend_input), length(ID),1);
        nphold = sel_struc.VMS.filtered_nogo_nphold;
        magspeed = sel_struc.VMS.filtered_magspeed;
        DA = sel_struc.VMS.filtered_meanDAsignal;    % n x 250 matrix

        % Generate column headers for DA signals
        numDAcols = size(DA, 2);
        DA_headers = arrayfun(@(x) sprintf('DA_%d', x), 1:numDAcols, 'UniformOutput', false);

        % Concatenate ID and DA into a single matrix
        tmp = [ID, group, nphold, magspeed, DA];
        export_matrix = [export_matrix; tmp];
    end

end

legend(legend_names, "Location","bestoutside", "Interpreter","none", 'FontSize',18)

% ----------------- PLOT GO TRIALS ONTOP OF NOGO PLOTS -----------------
[FSCVMEDPC, aa.conditions] = fxmergeGo(FSCVMEDPC, aa);
aa.index = false(1,size(FSCVMEDPC,2));
i = 1;
summary = [];
for i = 1:size(FSCVMEDPC, 2) % check lengths of FSCVMEDPC
    if strfind(FSCVMEDPC(i).region, region)
        summary(i).ratID =  FSCVMEDPC(i).ratID;
        try
            [aa.dataOutput] = FSCVMEDPC_avgperanimal(FSCVMEDPC(i).(alignment).Go(:,2:end), aa.time);
            summary(i).Go = aa.dataOutput;

            if sum(aa.dataOutput(:,4))/350 > 2

            else
                summary(i).Go = [];
            end
            aa.index(i) = true; % Set corresponding index to true

        end
    end
end

% only plot the go lines when the alignment is to the auditory cue, not any
% others. Looks messy otherwise
if strcmp(alignment, 'sm_moveAcue')
    hold on

    gcf
    FSCVMEDPC_plotall(summary, {'Go'}, aa.time); % add the go trace to the no-go clustered plot
    legend(legend_names, "Location","bestoutside", "Interpreter","none", 'FontSize',18)
end
title(strcat(region, '_', aa.recordingname, '_', alignment, ': No-go sorted by cluster'), 'Interpreter','none')

aa.figname = strcat(region, '_Nogo_indiv_cluster_', aa.recordingname, '_', alignment);
aa.figname2 = strcat('Nogo_indiv_cluster_', aa.recordingname, '_', alignment, '.png');

%% Make a function for selecting criteria in details
function [sel_struc, matrix_cond, figure_name] = idxtrials(region, sel_cr, sel_struc, sel_conditions, varargin)
% exit if not VMS (quick fix for now)
if ~contains(region, 'VMS')
    return
end

% Create an inputParser object
p = inputParser;

% Add optional 'sel_nogo' parameter
addParameter(p, 'sel_nogo', [], @(x) iscell(x) || isempty(x)); % Default is empty, expect a cell if passed
addParameter(p, 'avg_across_individuals', false, @(x)validateattributes(x, {'logical'}, {'scalar'}));

% Parse the input arguments, including varargin
parse(p, varargin{:});

% Extract the 'sel_nogo' parameter from the parsed results
sel_nogo = p.Results.sel_nogo;
avg_across_individuals = p.Results.avg_across_individuals;

COND_SCALAR = -1;
COND_NOMINAL = -2;
COND_NOGO = -3; % for finding nogo scores

filtered_data = [];
export_ratIDs = [];
figure_name = [];


%%%%%%%%%%%%%%%% MAKE THE LOGICAL MATRICES! %%%%%%%%%%%%%%%%

for ma = 1:length(sel_cr) % choosing the criteria from above (line 146)
    matrix_cond.(region).(sel_cr{ma}) = zeros(1,height(sel_struc.(region).(sel_cr{ma})))'; %initialise all other vectors
end
if ~isempty(sel_nogo)
    for mb = 1:length(sel_nogo)
        matrix_cond.(region).(sel_nogo{mb}) = zeros(1,height(sel_struc.(region).(sel_nogo{mb})))'; %initialise all other vectors
    end
end

combined_condition.(region).final = ones(1,height(sel_struc.(region).(sel_cr{ma})))'; %has to be ones, as they have to all be satisfied later
matrix_cond.(region).final = zeros(1,height(sel_struc.(region).(sel_cr{ma})))'; % just use the last sel_struc struct to make a 1 x n zero array


% --------- Process the conditions ---------
for cr = 1:length(fieldnames(sel_conditions))
    condition_names = fieldnames(sel_conditions);
    condition_name = condition_names{cr};

    if ~isempty(sel_nogo)
        if sel_conditions.(condition_name)(1) == COND_NOGO % nogo conditions
            if length(sel_conditions.(condition_name)) == 1 %#ok<ISCL>
                combined_condition.(region).(condition_name) = ones(height(sel_struc.(region).(condition_name)),1);
            else
                combined_condition.(region).(condition_name) = zeros(height(sel_struc.(region).(condition_name)),1);
                for nm = 2:length(sel_conditions.(condition_name))
                    tmp = sel_conditions.(condition_name)(nm);
                    combined_condition.(region).(condition_name) = combined_condition.(region).(condition_name) | (sel_struc.(region).(condition_name) == tmp);
                    figure_name = [figure_name strcat(condition_name, num2str(tmp), '_')];
                end

            end

            combined_condition.(region).final = combined_condition.(region).final & combined_condition.(region).(condition_name);

            if sum(combined_condition.(region).final) == 0
                combined_condition.(region).final = ones(height(combined_condition.(region).final),1); % if there was no criteria set, make them all ones!
            end
        end
    end

    if sel_conditions.(condition_name)(1) == COND_NOMINAL
        % nominal conditions
        for nm = 2:length(sel_conditions.(condition_name))
            tmp = sel_conditions.(condition_name)(nm);
            matrix_cond.(region).(condition_name) = matrix_cond.(region).(condition_name) | (sel_struc.(region).(condition_name) == tmp);

            % name it by ratID or other nominal condition, first iteration has condition included
            if nm == 2
                figure_name = [figure_name strcat(condition_name, num2str(tmp), '_')];
            else
                figure_name = [figure_name strcat(num2str(tmp), '_')];
            end
        end
        matrix_cond.(region).final = matrix_cond.(region).final | matrix_cond.(region).(condition_name);

    elseif sel_conditions.(condition_name)(1) == COND_SCALAR
        % scalar conditions
        if length(sel_conditions.(condition_name)) == 3 % set limits, range of values
            tmp_max = sel_conditions.(condition_name)(3);
            tmp_min = sel_conditions.(condition_name)(2);
            matrix_cond.(region).(condition_name) = (sel_struc.(region).(condition_name) >= tmp_min) & (sel_struc.(region).(condition_name) <= tmp_max);
            % name it with range
            figure_name = [figure_name strcat(condition_name, '_', num2str(tmp_min/100),'to', num2str(tmp_max/100), 's | ')];
        elseif length(sel_conditions.(condition_name)) == 2 % set limit, greater than this value only
            tmp_min = sel_conditions.(condition_name)(2);
            matrix_cond.(region).(condition_name) = (sel_struc.(region).(condition_name) >= tmp_min);
            figure_name = [figure_name strcat(condition_name, num2str(tmp_min/100), 's_')];
        elseif length(sel_conditions.(condition_name)) == 1 %#ok<ISCL> % no limit
            matrix_cond.(region).(condition_name) = zeros(height((sel_struc.(region).(condition_name))),1); %give it all ones if not defined
        end
        matrix_cond.(region).final = matrix_cond.(region).final | matrix_cond.(region).(condition_name);
    end
end

if sum(matrix_cond.(region).final) == 0
    matrix_cond.(region).final = ones(height(matrix_cond.(region).final),1); % if there was no criteria set, make them all ones!
end

matrix_cond.(region).final = matrix_cond.(region).final & combined_condition.(region).final;


% --------- GET THE STRUCTS FOR SELECTED NOGO BEHAVIOUR ---------
DAsignal = sel_struc.(region).DAsignal;

% only select the columns that give a 1 ---- IMPORTANT
filtered_DAsignal = DAsignal(matrix_cond.(region).final, :);

sel_struc.(region).filtered_ratID = sel_struc.(region).ID(matrix_cond.(region).final,:);
sel_struc.(region).filtered_meanDAsignal = filtered_DAsignal;
try
    sel_struc.(region).filtered_nogo_nphold = sel_struc.(region).nogo_nphold(matrix_cond.(region).final,:);
    sel_struc.(region).filtered_magspeed = sel_struc.(region).magspeed(matrix_cond.(region).final,:);
end

if avg_across_individuals
    % if have to sort by IDs
    [uniqueIDs, ~, groupIdx] = unique(sel_struc.(region).filtered_ratID);

    nIDs = numel(uniqueIDs);
    avgSignal = zeros(nIDs, size(filtered_DAsignal, 2));

    % Compute mean per group
    for col = 1:size(filtered_DAsignal, 2)
        avgSignal(:, col) = accumarray(groupIdx,  filtered_DAsignal(:, col), [], @(x)mean(x, 'omitnan'));
    end

    sel_struc.(region).filtered_ID_avg_ID = uniqueIDs;
    sel_struc.(region).filtered_ID_avg_meanDAsignal = avgSignal;

    % Get averages, SD and N
    % sel_struc.(region).filtered_meanDAsignal_avg = [sel_struc.(region).filtered_meanDAsignal_avg; nanstd(sel_struc.(region).filtered_ID_avg_meanDAsignal/sqrt(sum(~isnan(sel_struc.(region).filtered_ID_avg_meanDAsignal(1,:)))), 0,1)];

else
    avgSignal = filtered_DAsignal;
end

N = sum(~isnan(avgSignal),1);
meanVals = mean(avgSignal,1,'omitnan');
stdVals = std(avgSignal,0,1,'omitmissing');
semVals = stdVals ./ sqrt(N);

sel_struc.(region).filtered_meanDAsignal_avg = [meanVals; semVals; N];

% for another function -- fix later
sel_struc.(region).filtered_row = filtered_DAsignal;  % only select the columns that give a 1
sel_struc.(region).filtered_row_avg = sel_struc.(region).filtered_meanDAsignal_avg;

end

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