function [] = plotSO(file_path) 
%% function for creating SO plots and saving them as png files

trials = dir(fullfile(file_path,'\SO\*_StaticOptimization_activation.sto'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'SO'))
    SO_data = importdata(trials(trial).name,'\t',9);
    figure('units','normalized','outerposition',[0 0 1 1],'visible','off')
    % Plot
    labels = {trials(trial).name(1:end-4)};

    h = 1;
    for z = 2:41
        activation{1,h} = interp1(linspace(0,1-1/100,size(SO_data.data,1)), SO_data.data(:,z),linspace(0,1-1/100,101));
        h = h +1;
    end

    for g = 1:length(activation)
        plot(0:100,activation{1,g})
        hold on
    end

    xlabel('% cycle')
    ylabel('SO activation')
    title(labels{1,1})

    saveas(gcf,fullfile(file_path,'Figures\SO\',trials(trial).name(1:end-4)),'png')
    close all
end

end