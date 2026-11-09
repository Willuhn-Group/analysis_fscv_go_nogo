function [stats, btsrp] = fxmergestats(summary, aa, varargin)
p = inputParser;
addRequired(p, 'summary');
addRequired(p, 'aa');

parse(p, summary, aa, varargin{:})

for k = 1:length(aa.conditions)
    aa.condition = aa.conditions{k};
    stats.(aa.condition) = [];
    stats.([aa.condition '_ratID']) = [];
    stats.All_DA = [];
end

k=1;
for k = 1:length(aa.conditions)
    aa.condition = aa.conditions{k};
    % If comparing traces based on AVERAGE of individual traces
    if strcmp(aa.analyse_indiv, 'yes')
        for i = 1:length(summary)
            % make sure ratIDs are there
            stats.([aa.condition '_ratID']) = [stats.([aa.condition '_ratID']); string(summary(i).ratID)];
            % get the mean values for animal
            trial_mean_values = summary(i).(aa.condition)(:,2)';
            % Concatenate the average trace per animal
            stats.(aa.condition) = [stats.(aa.condition); trial_mean_values];
            stats.All_DA = [stats.All_DA; trial_mean_values];
            clear trial_mean_values
        end

        % If comparing traces based on INDIVIDUAL traces
    else
        for i = 1:length(summary)
            % make a row just for names
            for tr = 2:size(summary(i).(aa.condition),2)
                stats.([aa.condition '_ratID']) = [stats.([aa.condition '_ratID']); string(summary(i).ratID)];
            end
            % get the traces values
            trial_mean_values = summary(i).(aa.condition)(:,2:end)';
            % Concatenate the average trace per animal, split by condition
            stats.(aa.condition) = [stats.(aa.condition); trial_mean_values];
            % Concatenate the average trace per animal, all concatenated
            stats.All_DA = [stats.All_DA; trial_mean_values];
            clear trial_mean_values
        end
    end
    aa.combineddata = stats.(aa.condition);

    % run the bootstrapping
    trial_mean_values = bootstrap_data(aa.combineddata, aa.numboots, aa.sig);
    % CIadjust(LCI,UCI,est,n,adj_type)
    significant_boots = CIadjust(trial_mean_values(1,:),trial_mean_values(2,:),trial_mean_values,size(aa.combineddata, 1),2);
    btsrp.(aa.condition) = significant_boots;

    clear trial_mean_values
end
end