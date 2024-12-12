function [] =  plotIK(file_path,in_leg)
%% Function for creating IK plots and saving them as png files

% First the trials for the healthy leg
trials = dir(fullfile(file_path,'\IK\*healthy.mot'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'IK'))

    figure('visible','off', 'units','normalized','outerposition',[0 0 1 1])

    if in_leg == 1
        IK_data = importdata(trials(trial).name,'\t',11);
        indx_time=find(ismember([IK_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([IK_data.colheaders(1,:)],'hip_flexion_l'));
        indx_knee=find(ismember([IK_data.colheaders(1,:)],'knee_angle_l'));
        indx_ankle=find(ismember([IK_data.colheaders(1,:)],'ankle_angle_l'));
        indx_pelvis_z=find(ismember([IK_data.colheaders(1,:)],'pelvis_tz'));
        indx_pelvis_y=find(ismember([IK_data.colheaders(1,:)],'pelvis_ty'));
        indx_pelvis_x=find(ismember([IK_data.colheaders(1,:)],'pelvis_tx'));
    else
        IK_data = importdata(trials(trial).name,'\t',11);
        indx_time=find(ismember([IK_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([IK_data.colheaders(1,:)],'hip_flexion_r'));
        indx_knee=find(ismember([IK_data.colheaders(1,:)],'knee_angle_r'));
        indx_ankle=find(ismember([IK_data.colheaders(1,:)],'ankle_angle_r'));
        indx_pelvis_z=find(ismember([IK_data.colheaders(1,:)],'pelvis_tz'));
        indx_pelvis_y=find(ismember([IK_data.colheaders(1,:)],'pelvis_ty'));
        indx_pelvis_x=find(ismember([IK_data.colheaders(1,:)],'pelvis_tx'));
    end

    % Read joint angles from .mot file
    time=IK_data.data(:,indx_time);
    hip=IK_data.data(:,indx_hip);
    knee=IK_data.data(:,indx_knee);
    ankle=IK_data.data(:,indx_ankle);

    % Plot
    labels(trial) = {trials(trial).name(1:end-4)};

    subplot(1,3,1)
    plot(0:100,interp1(linspace(0,1-1/100,length(hip)), hip, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Hip flexion angle')
    title('Hip')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Knee flexion angle')
    title('Knee')

    subplot(1,3,3)
    plot(0:100,interp1(linspace(0,1-1/100,length(ankle)), ankle, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Ankle dorsiflexion angle')
    title('Ankle')

    subplot(1,3,1)
    legend(labels(trial),'Location','northeast')

    subplot(1,3,2)
    legend(labels(trial),'Location','northwest')

    subplot(1,3,3)
    legend(labels(trial),'Location','southeast')

    saveas(gcf,fullfile(file_path,'Figures\IK\',trials(trial).name(1:end-4)),'png')
    close all
end

% Then the trials for the injured leg
trials = dir(fullfile(file_path,'\IK\*injured.mot'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'IK'))

figure('visible','off', 'units','normalized','outerposition',[0 0 1 1])

    if in_leg == 2
        IK_data = importdata(trials(trial).name,'\t',11);
        indx_time=find(ismember([IK_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([IK_data.colheaders(1,:)],'hip_flexion_l'));
        indx_knee=find(ismember([IK_data.colheaders(1,:)],'knee_angle_l'));
        indx_ankle=find(ismember([IK_data.colheaders(1,:)],'ankle_angle_l'));
        indx_pelvis_z=find(ismember([IK_data.colheaders(1,:)],'pelvis_tz'));
        indx_pelvis_y=find(ismember([IK_data.colheaders(1,:)],'pelvis_ty'));
        indx_pelvis_x=find(ismember([IK_data.colheaders(1,:)],'pelvis_tx'));
    else
        IK_data = importdata(trials(trial).name,'\t',11);
        indx_time=find(ismember([IK_data.colheaders(1,:)],'time'));
        indx_hip=find(ismember([IK_data.colheaders(1,:)],'hip_flexion_r'));
        indx_knee=find(ismember([IK_data.colheaders(1,:)],'knee_angle_r'));
        indx_ankle=find(ismember([IK_data.colheaders(1,:)],'ankle_angle_r'));
        indx_pelvis_z=find(ismember([IK_data.colheaders(1,:)],'pelvis_tz'));
        indx_pelvis_y=find(ismember([IK_data.colheaders(1,:)],'pelvis_ty'));
        indx_pelvis_x=find(ismember([IK_data.colheaders(1,:)],'pelvis_tx'));
    end

    % Read joint angles from .mot file
    time=IK_data.data(:,indx_time);
    hip=IK_data.data(:,indx_hip);
    knee=IK_data.data(:,indx_knee);
    ankle=IK_data.data(:,indx_ankle);

    % Plot
    labels(trial) = {trials(trial).name(1:end-4)};

    subplot(1,3,1)
    plot(0:100,interp1(linspace(0,1-1/100,length(hip)), hip, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Hip flexion angle')
    title('Hip')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(knee)), knee, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Knee flexion angle')
    title('Knee')

    subplot(1,3,3)
    plot(0:100,interp1(linspace(0,1-1/100,length(ankle)), ankle, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Ankle dorsiflexion angle')
    title('Ankle')

    subplot(1,3,1)
    legend(labels(trial),'Location','northeast')

    subplot(1,3,2)
    legend(labels(trial),'Location','northwest')

    subplot(1,3,3)
    legend(labels(trial),'Location','southeast')

    saveas(gcf,fullfile(file_path,'Figures\IK\',trials(trial).name(1:end-4)),'png')
    close all
end

end