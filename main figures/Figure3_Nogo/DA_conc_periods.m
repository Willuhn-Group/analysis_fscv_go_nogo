
% get the DA concentration values for 1) trial-signal period, 2) tone, 3) correct trial

function [out_meansindiv] = DA_conc_periods(structs, sel_indexes, recording)
% sel_indexes = logical array;

if strcmp(recording, 'Syed2\') || strcmp(recording, 'Syed3\')
   times = [7.5 10 12 18];
elseif strcmp(recording, 'GNG_free_delay_noNP\') 
    times = [14 15 18 22];
else
    times = [12.5 15 18 22];
end

times = times*10;
trace = structs.filtered_meanDAsignal; % the selected traces with matrix_cond.final applied
ID = structs.filtered_ratID; % the selected ratIDs with matrix_cond.final applied

% split into [ratID | trialsignal | AcueON | correct]
trace_trialsignal = trace(:, times(1): times(2)-1);
trace_AcueON = trace(:, times(2): times(3)-1);
trace_correct = trace(:, times(3): times(4)-1);

max_trialsignal = max(trace_trialsignal, [], 2, 'omitnan'); % get MAX
mean_AcueON = mean(trace_AcueON, 2, 'omitnan'); % get MEAN
max_correct = max(trace_correct, [], 2, 'omitnan'); % get MAX

out_meansindiv = [ID max_trialsignal mean_AcueON max_correct];

end

