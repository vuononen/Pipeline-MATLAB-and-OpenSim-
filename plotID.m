function [] = plotID(file_path,in_leg)
%% Function for creating ID plots and saving them as png files

% First the healthy ones
trials = dir(fullfile(file_path,'\ID\*healthy.sto'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'ID'))

    figure('units','normalized','outerposition',[0 0 1 1],'visible','off')

    if in_leg == 1
        % Identify the needed columns
        ID_data= importdata(trials(trial).name,'\t',7);
        indx_time=find(ismember([ID_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([ID_data.colheaders(1,:)],'hip_flexion_l_moment'));
        indx_knee=find(ismember([ID_data.colheaders(1,:)],'knee_angle_l_moment'));
        indx_ankle=find(ismember([ID_data.colheaders(1,:)],'ankle_angle_l_moment'));
        indx_knee_add=find(ismember([ID_data.colheaders(1,:)],'knee_add_l_moment'));
    else
        ID_data= importdata(trials(trial).name,'\t',7);
        indx_time=find(ismember([ID_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([ID_data.colheaders(1,:)],'hip_flexion_r_moment'));
        indx_knee=find(ismember([ID_data.colheaders(1,:)],'knee_angle_r_moment'));
        indx_ankle=find(ismember([ID_data.colheaders(1,:)],'ankle_angle_r_moment'));
        indx_knee_add=find(ismember([ID_data.colheaders(1,:)],'knee_add_r_moment'));
    end

    % Read moment data from .sto file
    time=ID_data.data(:,indx_time);
    hip=ID_data.data(:,indx_hip);
    knee=ID_data.data(:,indx_knee);
    ankle=ID_data.data(:,indx_ankle);
    knee_add=ID_data.data(:,indx_knee_add);

    % Plot
    labels(trial) = {trials(trial).name(1:end-4)};

    subplot(1,3,1)
    plot(0:100,-interp1(linspace(0,1-1/100,length(hip)), hip, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Hip extensor moment')
    title('Hip')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee, linspace(0,1-1/100,101)));
    hold on
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee_add, linspace(0,1-1/100,101)),'--');
    xlabel('% cycle')
    ylabel('Knee moments')
    title('Knee')
    legend('knee angle', 'knee add')

    subplot(1,3,3)
    plot(0:100,-interp1(linspace(0,1-1/100,length(ankle)), ankle, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Ankle plantarflexor moment')
    title('Ankle')

    saveas(gcf,fullfile(file_path,'Figures\ID\',trials(trial).name(1:end-4)),'png')
    close all
end

% Then the injured ones
trials = dir(fullfile(file_path,'\ID\*injured.sto'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'ID'))

    figure('units','normalized','outerposition',[0 0 1 1],'visible','off')

    if in_leg == 2
        % Identify columns
        ID_data= importdata(trials(trial).name,'\t',7);
        indx_time=find(ismember([ID_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([ID_data.colheaders(1,:)],'hip_flexion_l_moment'));
        indx_knee=find(ismember([ID_data.colheaders(1,:)],'knee_angle_l_moment'));
        indx_ankle=find(ismember([ID_data.colheaders(1,:)],'ankle_angle_l_moment'));
        indx_knee_add=find(ismember([ID_data.colheaders(1,:)],'knee_add_l_moment'));
    else
        ID_data= importdata(trials(trial).name,'\t',7);
        indx_time=find(ismember([ID_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([ID_data.colheaders(1,:)],'hip_flexion_r_moment'));
        indx_knee=find(ismember([ID_data.colheaders(1,:)],'knee_angle_r_moment'));
        indx_ankle=find(ismember([ID_data.colheaders(1,:)],'ankle_angle_r_moment'));
        indx_knee_add=find(ismember([ID_data.colheaders(1,:)],'knee_add_r_moment'));
    end

    % Read moment data from .sto file
    time=ID_data.data(:,indx_time);
    hip=ID_data.data(:,indx_hip);
    knee=ID_data.data(:,indx_knee);
    ankle=ID_data.data(:,indx_ankle);
    knee_add=ID_data.data(:,indx_knee_add);

    % Plot
    labels(trial) = {trials(trial).name(1:end-4)};

    subplot(1,3,1)
    plot(0:100,-interp1(linspace(0,1-1/100,length(hip)), hip, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Hip extensor moment')
    title('Hip')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee, linspace(0,1-1/100,101)));
    hold on
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee_add, linspace(0,1-1/100,101)),'--');
    xlabel('% cycle')
    ylabel('Knee moments')
    title('Knee')
    legend('knee angle', 'knee add')

    subplot(1,3,3)
    plot(0:100,-interp1(linspace(0,1-1/100,length(ankle)), ankle, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Ankle plantarflexor moment')
    title('Ankle')

    saveas(gcf,fullfile(file_path,'Figures\ID\',trials(trial).name(1:end-4)),'png')
    close all
end

end
