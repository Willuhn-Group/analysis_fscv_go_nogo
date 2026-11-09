% Get the latencies to the max dopamine for the different trialtypes
function summary = getmaxDAdetails(summary, aa, varargin)
p = inputParser;
addRequired(p, 'summary');
addRequired(p, 'aa');

addParameter(p, 'nphold', 0, @isnumeric);

parse(p, summary, aa, varargin{:})
nphold = p.Results.nphold;


for i = 1:length(summary)
    ratID = summary(i).ratID;
    try
        for cd = 1:length(aa.conditions)
            condition = aa.conditions{cd};

            if strcmp(aa.recordingname, 'GNG_free_delay') || strcmp(aa.recordingname, 'GNG_free_delay_noNP')
                MIDDLE = 150;                              
            elseif strcmp(aa.recordingname, 'Syed3_noNP') || strcmp(aa.recordingname, 'Syed2')
                MIDDLE = 100;
            end

            if nphold == 1
                MAGREACH = round(summary(i).(['nphold2magreach_' condition])*10,0) + MIDDLE;
                START_IDX = MAGREACH-20;
                END_IDX = MAGREACH + 20;
            else % for magreach data
                START_IDX = MIDDLE - 20; %2s before
                END_IDX = MIDDLE + 20; %2s later
            end

            [DAmax, tmp_idx] = max(summary(i).(condition)(START_IDX:END_IDX,2));
            DAmax_index = tmp_idx + START_IDX - MIDDLE;
            summary(i).(['latency' condition]) = DAmax_index/10;
            summary(i).(['maxDA' condition]) = DAmax;
        end
    catch
        continue
    end
end

end