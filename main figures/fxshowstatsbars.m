function fxshowstatsbars(btsrp, aa)
thres = aa.thres;
p = aa.p;
if strcmp(aa.showstats, 'yes')
    % Colours for permutation tests
    aa.myhexvalues = ['#6B3920'; '#55BBA2'; '#6E3CBF'; '#E0D67E'; '#9B6FD2'; '#A5E8C1'];
    legend_strings = {};

    % Significance bars for permutation tests
    yl = ylim;
    ymin = yl(1);
    ymax = yl(2);
    distance_away = 2.8;
    try
        % Set vertical spacing parameters
        bar_spacing = 0.8;        % distance between bars
        thick_bar_offset = 1.2;   % extra space for first/thicker bar
        start_height = ymin + distance_away;

        aa.fn = fieldnames(btsrp); % only do this once outside loop

        for fn = 1:length(aa.fn)
            aa.colours = aa.myhexvalues(fn, :);
            aa.colour = hex2rgb(aa.colours);
            comparison = aa.fn{fn};
            data = btsrp.(comparison);

            tmp = find(data(1,:)<p);
            id = tmp(consec_idx(tmp, thres));

            % Determine vertical position
            if comparison == "Go_Nogo" && (length(aa.fn)==1)
                y_offset = start_height-thick_bar_offset;  % highest bar
                marker_size = 14;
            elseif comparison == "Go_Nogo"
                y_offset = start_height;  % highest bar
                marker_size = 14;
            else
                y_offset = start_height - thick_bar_offset - (fn-2)*bar_spacing;
                marker_size = 7;
            end

            if ~isempty(id)
                plot(aa.time(id), y_offset*ones(size(aa.time(id),2), 2), 's', ...
                    'MarkerSize', marker_size, ...
                    'MarkerFaceColor', aa.colour, ...
                    'Color',  aa.colour, ...
                    'HandleVisibility', 'off');
            end
        end
    end
end
end