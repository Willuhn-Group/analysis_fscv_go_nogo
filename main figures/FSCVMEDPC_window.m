function [window_avg, data_val, data_val_idx] = FSCVMEDPC_window(data, recording, varargin)
% data should include the timstamp in the first column
data = data(:, 2:end);
% parsing input
p = inputParser;

addRequired(p, 'data');
addRequired(p, 'recording');

addParameter(p, 'output', 'mean', @(x) any(validatestring(x,{'mean', 'max', 'min'})));
addParameter(p, 'timeafterevent', 0, @isnumeric) % if manually defining the window period after the event
addParameter(p, 'timebeforeevent', 0, @isnumeric) % if manually defining the window period after the event

parse(p, data, recording, varargin{:})

output = p.Results.output;
timeafterevent = p.Results.timeafterevent;
timebeforeevent = p.Results.timebeforeevent;

if timeafterevent == 0 && timebeforeevent == 0
    if strcmp(recording, '_selfGNG') || strcmp(recording, '_cueGNG') 
        windowstart = 100;
        windowend = 120;
    else
        windowstart = 150;
        windowend = 180;
    end
else
    if strcmp(recording, '_selfGNG') || strcmp(recording, '_cueGNG') 
        windowstart = 100;
        windowend = windowstart-timebeforeevent*10 + timeafterevent*10;
    else
        windowstart = 150;
        windowend = windowstart-timebeforeevent*10 + timeafterevent*10;
    end
end

if strcmp(output, 'mean')
    for i = 1:size(data,2)
        data_val(i) = mean(data(windowstart:windowend,i), 'omitnan');
    end
elseif strcmp(output, 'max')
    for i = 1:size(data,2)
        [data_val(i), data_val_idx(i)]  = max(data(windowstart:windowend,i));
    end
elseif strcmp(output, 'min')
    for i = 1:size(data,2)
        [data_val(i), data_val_idx(i)] = min(data(windowstart:windowend,i));
    end
end
window_avg = mean(data_val, 'omitnan');

end