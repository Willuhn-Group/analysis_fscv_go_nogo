function figureSettings(recording, lines, region, varargin)


% Create an inputParser object
p = inputParser;

% Add optional 'sel_nogo' parameter
addParameter(p, 'textinput', [], @(x) ischar(x) || isempty(x)); % Default is empty, expect a cell if passed
addParameter(p, 'alignment', 'sm_moveAcue', @(x) ischar(x) || isempty(x));
addParameter(p, 'rewardtype', [], @(x) ischar(x) || isempty(x));
addParameter(p, 'once', 1, @(x) isnumeric(x));
addParameter(p, 'ylimits', 0, @(x) isnumeric(x));

% Parse the input arguments, including varargin
parse(p, varargin{:});

% Extract the 'sel_nogo' parameter from the parsed results
textinput = p.Results.textinput;
alignment = p.Results.alignment;
rewardtype = p.Results.rewardtype;
once = p.Results.once;
ylimits = p.Results.ylimits;

if once > 1
    return
end

x1 = -3;    % x lim for plot avg
x2 = 8;    % x lim for plot avg


if (ylimits == 1)

    if strcmp(alignment, 'sm_moveAcue')
        if strcmp(region, 'VMS')
                ylim([-5 25])
        elseif strcmp(region, 'DMS')
            ylim([-10 10])
        elseif strcmp(region, 'DLS')
            ylim([-10 10])
        end
    else
        if (strcmp(recording, '_selfGNGFD') && strcmp(alignment, 'sm_nphold')) || (strcmp(recording, '_cueGNG') && strcmp(alignment, 'sm_nphold')) || (strcmp(recording, '_selfGNG') && strcmp(alignment, 'sm_nphold'))
            ylim([-10 20])
        elseif (strcmp(recording, '_selfGNG') && strcmp(alignment, 'sm_magreach'))
            ylim([-20 10])
        else
            ylim([-15 15])
        end

    end
elseif (ylimits == 0)
    ylim([-5 25])
else
    ymin = ylimits(1);
    ymax = ylimits(2);
    ylim([ymin ymax]);
end





line1 = 0;

xline([line1 line1], 'Color', hex2rgb('#808080'), 'Linewidth', 1.5, 'HandleVisibility', 'off', 'Alpha',0.8);

set(gca, ...
    'XTick', [-2 -1 0 1 2 3 4 5 6], ...
    'XTickLabel', {'-2','-1','0','1','2','3','4','5','6'}, ...
    'TickLength', [0.015 0.01], ...
    'TickDir', 'both', ...
    'XAxisLocation', 'bottom', ...
    'Box', 'off');  % This removes the top and right border lines (and their ticks)
xtickangle(0);

ax = gca; % Get the current axes
hold(ax, 'on'); % Ensure new elements are added to the same plot
ax.XRuler.TickLabelGapOffset = -5;
if (lines == "yes")  && (alignment == "sm_moveAcue")                    % Y/N? plot lines at 180 and 200?
    xline([-0.5 -0.5], 'Color', 'black', 'Linewidth', 2.5, 'Linestyle', ':', 'HandleVisibility', 'off', 'Alpha', 0.8);

    if strcmp(recording, 'GNG_free_delay\') || strcmp(recording, 'GNG_free_delay_noNP\') || strcmp(recording, 'GNG_delay\')
        line2 = 3;
        xline([line2 line2], 'Color', hex2rgb('#808080'), 'Linewidth', 1.5, 'HandleVisibility', 'off', 'Alpha',0.8);

        % Draw a grey box behind for auditory cue
        x_rect = [0, 3, 3, 0];
        y_rect = [-20, -20, 40, 40];
        grey = hex2rgb('#cacaca'); % Convert hex to RGB
        h_fill = fill(ax, x_rect, y_rect, grey, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');

        % xline([-1.458358086 -1.458358086], 'Color', 'black', 'Linewidth', 1, 'Linestyle', ':', 'HandleVisibility', 'off', 'Alpha', 0.8);
        % ------------ GNG free delay yellow boxes ------------
        if strcmp(recording, '_cueGNGFD')

            % draw a rectangle
            x_rect1 = [-1.444999, 0, 0, -1.444999];
            y_rect1 = [-20, -20, 40, 40];
            yellow = [1.0000, 1.0000, 0.7725]; % Convert hex to RGB
            h_fill1 = fill(ax, x_rect1, y_rect1, yellow, ...
                'FaceAlpha', 0.7, 'EdgeColor', 'none', 'HandleVisibility', 'off');

            x_rect2 = [3, 5, 5, 3];
            y_rect2 = [-20, -20, 40, 40];
            h_fill2 = fill(ax, x_rect2, y_rect2, yellow, ...
                'FaceAlpha', 0.7, 'EdgeColor', 'none', 'HandleVisibility', 'off');

            % move the rectangles to the bottom of the stack
            uistack(h_fill1, 'bottom');
            uistack(h_fill2, 'bottom');
        end
        uistack(h_fill, 'bottom');


    else
        line2 = 2;
        xline([line2 line2], 'Color', hex2rgb('#808080'), 'Linewidth', 1.5, 'HandleVisibility', 'off', 'Alpha',0.8);

        % Draw a grey box behind for auditory cue
        x_rect = [0, 2, 2, 0];
        y_rect = [-20, -20, 40, 40];

        grey = hex2rgb('#cacaca'); % Convert hex to RGB
        h_fill= fill(ax, x_rect, y_rect, grey, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');

        if strcmp(recording, 'Syed2\')
            x_rect = [-2.175668, 0, 0, -2.175668];
            y_rect = [-20, -20, 40, 40];

            yellow = [1.0000, 1.0000, 0.7725]; % Convert hex to RGB
            h_fill1 = fill(ax, x_rect, y_rect, yellow, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
            % xline([-2.170608081 -2.170608081], 'Color', 'black', 'Linewidth', 1, 'Linestyle', ':', 'HandleVisibility', 'off', 'Alpha', 0.8);
            uistack(h_fill1, 'bottom');

        end
        uistack(h_fill, 'bottom');
    end
else
    set(gca, 'xtick', -2:1:6)
    xtickangle(0)
end

if lines == "yes"
    if (lines == "yes") && (alignment == "sm_moveAcue")
    end
    xline([line1 line1], 'Color', 'black', 'Linewidth', 1, 'Linestyle', ':', 'HandleVisibility', 'off', 'Alpha', 0.8);
    xline([line2 line2], 'Color', 'black', 'Linewidth', 1, 'Linestyle', ':', 'HandleVisibility', 'off', 'Alpha', 0.8);
end

xlim([x1 x2])
% xlabel('Time (s)', 'FontSize', 20)
ylabel('Δ Dopamine (nM)', 'FontSize', 20)

if ~isempty(textinput)
    text(max(xlim) + 0.25, min(ylim), textinput, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
end
set(gca, 'layer', 'top')

end

