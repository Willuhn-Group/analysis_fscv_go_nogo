function FSCVMEDPC_plotavgperanimal(summary, condition, time)
figure
myhexvalues = ['#6c3eb6' ;	'#52a8ce' ;	'#6fde89' ;	'#ddeb8f' ;	'#f5b7b2' ;	'#543fbe' ;	'#58c7d2' ;	'#75e177' ;	'#ede896' ;	'#4249c3' ;	'#5dd5c6' ;	'#91e47b' ;	'#f0d89d' ;	'#4869c7' ;	'#63d8b1' ;	'#ace782' ;	'#f1cba4' ;	'#4d89cb' ;	'#69db9c' ;	'#c5e988' ;	'#f3c0ab'];
colours = hex2rgb(myhexvalues);
legend_strings = {};
for i = 1:size(summary,2)
    ratID = summary(i).ratID;

    data = summary(i).(condition)';
    if ~isempty(data)
        plot_settings(data, colours, i, time);
        legend_strings = [legend_strings, ratID]; % add rat ID to legend_strings
        legend(legend_strings, 'Location', 'northeastoutside'); % Add the legend outside the subplots and include all the rats in each condition.
        hold on
    else
        continue;
    end
    
end
end