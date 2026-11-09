function plot_settings(data, colours, i, time, varargin)

% Create an inputParser object
p = inputParser;

% Add optional 'nogo' or 'go' parameter
addParameter(p, 'nogo', false, @(x) islogical(x)); % Default is false, expect a logical (true/false)
addParameter(p, 'go', false, @(x) islogical(x)); % Default is false, expect a logical (true/false)
addParameter(p, 'free', false, @(x) islogical(x)); % Default is false, expect a logical (true/false)


% Parse the input arguments, including varargin
parse(p, varargin{:});

% Extract the 'nogo' parameter from the parsed results
nogo = p.Results.nogo;
go = p.Results.go;
free = p.Results.free;


% Plotting data
x = time; % time
y = data(2,:); % mean [DA] values
sem = data(3,:); % SEM
curve1 = y + sem;
curve2 = y;
x2 = [time, fliplr(time)];
inBetween = [curve1, fliplr(curve2)];

% If 'nogo' is passed and is true, run the nogo-specific plotting
if nogo
    if i ~= 1
        % Plot with fill and regular line
        fill(x2, inBetween, colours(i,:), 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off');
        hold on
        h = plot(x, y, 'Color', colours(i,:), 'LineWidth', 2);
    else
        % Special style for i == 1
        h = plot(x, y, 'Color', colours(i,:), 'LineWidth', 2, 'LineStyle', '--');
        hold on
    end

elseif go || free
    if i ~= 1
        % Plot with fill and regular line
        fill(x2, inBetween, colours(i,:), 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off');
        hold on
        h = plot(x, y, 'Color', colours(i,:), 'LineWidth', 2);
    else
        % Special style for i == 1
        h = plot(x, y, 'Color', colours(i,:), 'LineWidth', 2, 'LineStyle', '--');
        hold on
    end
    
else
    % If 'nogo' is not passed or false, default behavior
    fill(x2, inBetween, colours(i,:), 'FaceAlpha', 0.3, 'LineStyle', 'none', 'HandleVisibility', 'off');
    hold on
    h = plot(x, y, 'Color', colours(i,:), 'LineWidth', 2);
end
end
