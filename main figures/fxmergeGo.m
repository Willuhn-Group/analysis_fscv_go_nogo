function [FSCVMEDPC, newcondition] = fxmergeGo(FSCVMEDPC, aa)

aa.conditions2 = aa.conditions; % for merging the GoL and GoR
alignments = aa.alignments; % get the name of the FSCV data and moved datasets

% Find the indices of elements 'GoL' and 'GoR'
aa.idx_GoL = strcmp(aa.conditions, 'GoL');
aa.idx_GoR = strcmp(aa.conditions, 'GoR');

% Combine indices for 'GoL' and 'GoR'
aa.idx_Go = aa.idx_GoL | aa.idx_GoR;

% Replace 'GoL' and 'GoR' with 'Go'
aa.conditions(aa.idx_Go) = {'Go'};

% Remove duplicate entries
newcondition = unique(aa.conditions, 'stable');

for i = 1:length(FSCVMEDPC)
    if ~isempty(FSCVMEDPC(i).raw_Acue)
        FSCVMEDPC(i).MEDPC.correctGo = [FSCVMEDPC(i).MEDPC.correctGoL FSCVMEDPC(i).MEDPC.correctGoR];

        % ------ to convert the columsn into cell arrays so that they can be concatenated ------
        % Get the tables you want to concatenate
        try
        tblL = FSCVMEDPC(i).DLC_outputs.correctGoL.neck;
        tblR = FSCVMEDPC(i).DLC_outputs.correctGoR.neck;

        % Ensure all columns that are cells in one are cells in both
        varNames = tblL.Properties.VariableNames;
        for v = 1:numel(varNames)
            colL = tblL.(varNames{v});
            colR = tblR.(varNames{v});

            % Convert double to cell if the other is already a cell
            if iscell(colL) && ~iscell(colR)
                tblR.(varNames{v}) = num2cell(colR);
            elseif iscell(colR) && ~iscell(colL)
                tblL.(varNames{v}) = num2cell(colL);
            end
        end

        FSCVMEDPC(i).DLC_outputs.correctGo.neck = vertcat(tblL, tblR);
        end
        for ii = 1:length(alignments)
            try
                alignment = alignments{ii};
                FSCVMEDPC(i).(alignment).Go = [FSCVMEDPC(i).(alignment).GoL FSCVMEDPC(i).(alignment).GoR(:,2:end)];
            catch
                continue;
            end
        end
    end


end
end