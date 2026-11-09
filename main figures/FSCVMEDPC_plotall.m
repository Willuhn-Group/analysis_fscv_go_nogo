
function [textoutput, data4export, avgpercond4export] = FSCVMEDPC_plotall(summary, conditions, time, varargin)
% Create an inputParser object
p = inputParser;

% Add optional 'nogo' or 'go' parameter
addParameter(p, 'summary', summary); %
addParameter(p, 'conditions', conditions); %
addParameter(p, 'time', time);

addOptional(p, 'suppressplot', false)


% Parse the input arguments, including varargin
parse(p, varargin{:});

% Extract the 'nogo' parameter from the parsed results
summary = p.Results.summary;
conditions = p.Results.conditions;
time = p.Results.time;
suppressplot = p.Results.suppressplot;


if sum(strcmp(conditions, 'GoL')) >= 1
    myhexvalues = ['#00c000'; '#005a00'; '#ff0000'; '#0080ff']; % colours in the order of GoL, GoR, Nogo, Free
else
    myhexvalues = ['#5CC54D'; '#EF0000'; '#0080ff']; % colours in the order of Go, Nogo, Free
end
colours = hex2rgb(myhexvalues);

if size(conditions,2) > 1
    data4export = [];
    avgpercond4export = [];
    legend_strings = {};

    for ii = 1:length(conditions)
        condition = conditions{ii};
        allanimals.(condition) = [];
    end

    for k = 1:length(conditions)
        condition = conditions{k};
        counter = 0;
        message = [];
        for i = 1:size(summary,2)
            ratID = summary(i).ratID;
            try
                data = summary(i).(condition)';
                x = time';
                y = data(2,:)';
                sem = data(3,:)';

                allanimals.(condition) = [allanimals.(condition) y]; % concatenate all the animals into one struct
                % to make the headers for the table later
            catch
                allanimals.(condition) = [allanimals.(condition) nan(length(time),1)];
                continue
            end
            headers{i} = strcat(condition,'_', ratID);
        end

        data = allanimals.(condition);

        %Make an array with values
        condition4export = [headers; num2cell(data)];
        data4export = [data4export condition4export];

        tmp = [condition; num2cell(mean(data,2,'omitnan'))];
        avgpercond4export = [avgpercond4export tmp];

        % Get the mean, sdev, n, sem
        for le = 1:length(data)
            mean_data(le) = mean(data(le,:), 'omitnan');
            sdev(le) = nanstd(data(le,:));
            n(le) = sum(~isnan(data(le,:)));
            sem(le) = sdev(le)/(sqrt(n(le)));
        end

        meansemn_all.(condition) = [time; mean_data; sem'; n]; % get the means, sem and n of each trial, and put into another struct

        data = meansemn_all.(condition);

        if ~suppressplot
            plot_settings(data, colours, k, time);

            legend_strings = [legend_strings, condition]; % add rat ID to legend_strings
            legend(legend_strings, 'Location', 'northeastoutside'); % Add the legend outside the subplots and include all the rats in each condition.
        end
    end
    textoutput = strcat('n=', num2str(max(n)));
else % this part is just to add the go trials in the clustered no-go traces!!
    data4export = [];
    avgpercond4export = [];
    condition = conditions{1};
    allanimals.(condition) = [];

    hold on
    gcf;
    for i = 1:size(summary,2)
        ratID = summary(i).ratID;
        try
            data = summary(i).(condition)';
            %             x = data(1,:)';
            x = time';
            y = data(2,:)';
            sem = data(3,:)';

            allanimals.(condition) = [allanimals.(condition) y]; % concatenate all the animals into one struct
        catch
            allanimals.(condition) = [allanimals.(condition) nan(length(time),1)];
        end
        headers{i} = strcat(condition,'_', ratID);
    end

    data = allanimals.(condition);

    %Make an array with values
    condition4export = [headers; num2cell(data)];
    data4export = [data4export condition4export];

    tmp = [condition; num2cell(mean(data,2,'omitnan'))];
    avgpercond4export = [avgpercond4export tmp];

    % Get the mean, sdev, n, sem
    for le = 1:length(data)
        mean_data(le) = mean(data(le,:), 'omitnan');
        sdev(le) = nanstd(data(le,:));
        n(le) = sum(~isnan(data(le,:)));
        sem(le) = sdev(le)/(sqrt(n(le)));
    end

    meansemn_all.(condition) = [time; mean_data; sem'; n]; % get the means, sem and n of each trial, and put into another struct
    data = meansemn_all.(condition);

    if ~suppressplot

        plot_settings(data, colours, 1, time, 'nogo', true);
    end
    textoutput = strcat('n=', num2str(max(n)));

end