function aa = setConditions(aa, varargin)
% Sets:
%       - conditions: go, nogo, free
%       - times: timestamps
%       - lines: whether to plot them

p = inputParser;
addRequired(p, 'aa');
addParameter(p, 'alignment', [], @(x) ischar(x) || isempty(x));
parse(p, aa, varargin{:})

alignment = p.Results.alignment;

if strcmp(aa.recording, '_cueGNGFD') || strcmp(aa.recording, '_selfGNGFD')
    aa.conditions = {'Go', 'Nogo', 'Free'};
else
    aa.conditions = {'Go', 'Nogo'};
end

if strcmp(alignment, 'sm_moveAcue')
    aa.lines = 'yes'; % add lines to figure?
else
    aa.lines = 'no';
end

% to create correct time stamps for plotting
if strcmp(aa.recording, '_selfGNG') || strcmp(aa.recording,'_cueGNG')
    aa.time = -9.9:0.1:15 ;
    aa.realigned_time = 10;
    aa.window = ([2, 5]); %time [before] and [after] in s
else
    aa.time = -14.9:0.1:20 ;
    aa.realigned_time = 15;
    aa.window = ([2, 8]); %time [before] and [after] in s

end
end