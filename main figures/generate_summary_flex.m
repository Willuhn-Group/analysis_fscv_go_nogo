function summary = generate_summary_flex(FSCVMEDPC, aa, region, varargin)
% GENERATE_SUMMARY_FLEX - Flexible summary generator using alignment and header options
%
% Inputs:
%   FSCVMEDPC - Struct of animal data
%   aa        - Analysis parameters (includes .time, .conditions, etc.)
%   region    - String to match brain region
%   varargin  - Name-value pairs:
%              'alignment' (default: 'sm_moveAcue')
%              'headers'   (cellstr, e.g. {'orient','reward','lastinter'})
%
% Output:
%   summary   - Struct summarizing data with flexible event and header alignment

p = inputParser;
addParameter(p, 'alignment', [], @(x) ischar(x) || isempty(x));
addParameter(p, 'headers', {'reward','orient','speed2mag'}, @iscell);
parse(p, varargin{:});

alignment = p.Results.alignment;
headers = p.Results.headers;

summary = [];
index = false(1, size(FSCVMEDPC, 2));
conditions = aa.conditions;

for k = 1:length(conditions)
    condition = conditions{k};

    for i = 1:size(FSCVMEDPC, 2)
        if ~contains(FSCVMEDPC(i).region, region), continue; end
        summary(i).ratID = FSCVMEDPC(i).ratID;

        try
            data = getfield(FSCVMEDPC(i), alignment); %#ok<GFLD>

            % Case 1: 'Go' is requested, but only GoL/GoR exist
            if strcmp(condition, 'Go') && all(isfield(data, {'GoL', 'GoR'}))
                % Combine GoL and GoR
                datacomb = [data.GoL(:,2:end), data.GoR(:,2:end)];
                [dataOutput] = FSCVMEDPC_avgperanimal(datacomb, aa.time);
                if sum(dataOutput(:,4))/350 <= 1, continue; end
                summary(i).Go = dataOutput;
                [window_mean, ~] = FSCVMEDPC_window(data.(condition), aa.recording);
                summary(i).(['avgDA' condition]) = window_mean;

                % Combine realignment times
                rt = FSCVMEDPC(i).realignment_times;
                for h = 1:length(headers)
                    header = headers{h};
                    try
                        gl = rt.GoL.([alignment(4:end) '2' header]);
                        gr = rt.GoR.([alignment(4:end) '2' header]);
                        summary(i).([alignment(4:end) '2' header '_Go']) = ...
                            mean(cell2mat([gl; gr]), 'omitnan');
                    catch
                        summary(i).([alignment(4:end) '2' header '_Go']) = [];
                    end
                end
                continue
            end

            % Case 2: GoL, GoR, Nogo, Free etc individually
            if ~isfield(data, condition) || isempty(data.(condition)), continue; end

            [dataOutput] = FSCVMEDPC_avgperanimal(data.(condition), aa.time);
            if sum(dataOutput(:,4))/350 <= 1
                summary(i).(condition) = [];
                summary(i).(['avgDA' condition]) = [];
                continue;
            end

            summary(i).(condition) = dataOutput;
            [window_mean, ~] = FSCVMEDPC_window(data.(condition), aa.recording);
            summary(i).(['avgDA' condition]) = window_mean;

            % Add realignment headers if available
            rt = FSCVMEDPC(i).realignment_times;
            if isfield(rt, condition)
                for h = 1:length(headers)
                    header = headers{h};
                    try
                        times = rt.(condition).([alignment(4:end) '2' header]);
                        times = times(~cellfun(@isempty, times));

                        % Convert cell to numeric, handling 'missing' entries
                        numericTimes = cellfun(@(x) double(x), times, 'UniformOutput', true); % Converts 'missing' to NaN
                        summary(i).([alignment(4:end) '2' header '_' condition]) = ...
                            mean(numericTimes, 'omitnan');
                    catch
                        summary(i).([alignment(4:end) '2' header '_' condition]) = [];
                    end
                end
            end

            index(i) = true;

        catch ME
            fprintf('Error processing %s - %s: %s\n', FSCVMEDPC(i).ratID, condition, ME.message);
            continue;
        end
    end
end

end
