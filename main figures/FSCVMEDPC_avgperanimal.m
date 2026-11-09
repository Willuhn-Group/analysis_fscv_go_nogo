function [mean_data] = FSCVMEDPC_avgperanimal(data, time)
try
    for i = 1:size(data,1)
        mean_data(i) = mean(data(i,:), 'omitnan');
        sdev(i) = nanstd(data(i,:));
        n(i) = sum(~isnan(data(i,:)));
        sem(i) = sdev(i)/n(i)^0.5;
    end
    mean_data = [time', mean_data', sem', n'];
catch
    fprintf('Less than 3 trials so no SEM')
end
end