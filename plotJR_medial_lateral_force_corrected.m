function [] = plotJR_medial_lateral_force_corrected(file_path,in_leg,subj_weight,subj_num_ID)
%% function for correcting the medial lateral force sign and for 
% creating JCF plots and saving them as png files

load('...\xray_data.mat');

% Selected the correct subject id first
MIRAKOS_ID = find(MIRAKOS_xray.subj_id == subj_num_ID);

if isempty(MIRAKOS_ID)
    load(['...\ID' num2str(subj_num_ID) '\Subj_details.mat'])
    Height = Subj_details.Height/10;
    if Height < 100
        Height = Height*10;
    end

    ICD_R = 0.3856*Height-14.67; % Based on regression determined from x-ray data
    ICD_L = 0.3856*Height-14.67; % Based on regression determined from x-ray data
    Tibial_width_R = 0.5637*Height-19.68; % Based on regression determined from x-ray data
    Tibial_width_L = 0.5637*Height-19.68; % Based on regression determined from x-ray data

else

    % Determine which one is right or left
    if MIRAKOS_xray.target_knee(MIRAKOS_ID(1,1)) == 1
        MIRAKOS_leg_r = MIRAKOS_ID(1,1);
    else
        MIRAKOS_leg_l = MIRAKOS_ID(1,1);
    end
    if MIRAKOS_xray.target_knee(MIRAKOS_ID(2,1)) == 1
        MIRAKOS_leg_r = MIRAKOS_ID(2,1);
    else
        MIRAKOS_leg_l = MIRAKOS_ID(2,1);
    end

    ICD_R = MIRAKOS_xray.Femoral_Condyle_Med_toCen_dx_mm(MIRAKOS_leg_r)+MIRAKOS_xray.Femoral_Condyle_Lat_toCen_dx_mm(MIRAKOS_leg_r);
    Tibial_width_R = MIRAKOS_xray.Tibial_width_mm(MIRAKOS_leg_r);
    ICD_L = MIRAKOS_xray.Femoral_Condyle_Med_toCen_dx_mm(MIRAKOS_leg_l)+MIRAKOS_xray.Femoral_Condyle_Lat_toCen_dx_mm(MIRAKOS_leg_l);
    Tibial_width_L = MIRAKOS_xray.Tibial_width_mm(MIRAKOS_leg_l);
end

trials = dir(fullfile(file_path,'\JR\*healthy*ReactionLoads.sto'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'JR'))

    figure('units','normalized','outerposition',[0 0 1 1],'visible','off')

    % Read contact force data from .sto file
    JR_data= importdata(trials(trial).name,'\t',12);

    if in_leg == 1
        indx_time=find(ismember(JR_data.colheaders(1,:),'time'));
        indx_total=find(ismember(JR_data.colheaders(1,:),'tibial_plat_weld_l_on_tibia_l_in_tibia_l_fy'));
        indx_medial=find(ismember(JR_data.colheaders(1,:),'med_cond_joint_l_on_med_cond_l_in_med_cond_l_fy'));
        indx_lateral=find(ismember(JR_data.colheaders(1,:),'lat_cond_joint_l_on_lat_cond_l_in_lat_cond_l_fy'));

        % Force sign correction
        total = -JR_data.data(:,indx_total)/subj_weight;
        medial = -JR_data.data(:,indx_medial)/subj_weight;
        lateral = -JR_data.data(:,indx_lateral)/subj_weight;

        for j = 1:length(total)
            if lateral(j) < 0
                F_lcl = -lateral(j)/(((Tibial_width_L-ICD_L)/2)+ICD_L);
                lateral(j) = 0;
                total(j) = total(j)+F_lcl;
                medial(j) = total(j);
            elseif medial(j) < 0
                F_mcl = -medial(j)/(((Tibial_width_L-ICD_L)/2)+ICD_L);
                medial(j) = 0;
                total(j) = total(j)+F_mcl;
                lateral(j) = total(j);
            end
        end

    else
        indx_time=find(ismember(JR_data.colheaders(1,:),'time'));
        indx_total=find(ismember(JR_data.colheaders(1,:),'tibial_plat_weld_r_on_tibia_r_in_tibia_r_fy'));
        indx_medial=find(ismember(JR_data.colheaders(1,:),'med_cond_joint_r_on_med_cond_r_in_med_cond_r_fy'));
        indx_lateral=find(ismember(JR_data.colheaders(1,:),'lat_cond_joint_r_on_lat_cond_r_in_lat_cond_r_fy'));

        % Force sign correction
        total = -JR_data.data(:,indx_total)/subj_weight;
        medial = -JR_data.data(:,indx_medial)/subj_weight;
        lateral = -JR_data.data(:,indx_lateral)/subj_weight;

        for j = 1:length(total)
            if lateral(j) < 0
                F_lcl = -lateral(j)/(((Tibial_width_R-ICD_R)/2)+ICD_R);
                lateral(j) = 0;
                total(j) = total(j)+F_lcl;
                medial(j) = total(j);
            elseif medial(j) < 0
                F_mcl = -medial(j)/(((Tibial_width_R-ICD_R)/2)+ICD_R);
                medial(j) = 0;
                total(j) = total(j)+F_mcl;
                lateral(j) = total(j);
            end
        end
    end


    % Plot
    labels(trial) = {trials(trial).name};

    subplot(1,3,1)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), total, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Total tibiofemoral')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), medial, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Medial tibiofemoral')

    subplot(1,3,3)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), lateral, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Lateral tibiofemoral')

    % Save figure
    saveas(gcf,fullfile(file_path,'Figures\JR_corrected\',trials(trial).name(1:end-4)),'png')
    close all
end

trials = dir(fullfile(file_path,'\JR\*injured*ReactionLoads.sto'));

for trial = 1:length(trials)
    cd(fullfile(file_path,'JR'))

    figure('units','normalized','outerposition',[0 0 1 1],'visible','off')

    % Read contact force data from .sto file
    JR_data= importdata(trials(trial).name,'\t',12);

    if in_leg == 2
        indx_time=find(ismember(JR_data.colheaders(1,:),'time'));
        indx_total=find(ismember(JR_data.colheaders(1,:),'tibial_plat_weld_l_on_tibia_l_in_tibia_l_fy'));
        indx_medial=find(ismember(JR_data.colheaders(1,:),'med_cond_joint_l_on_med_cond_l_in_med_cond_l_fy'));
        indx_lateral=find(ismember(JR_data.colheaders(1,:),'lat_cond_joint_l_on_lat_cond_l_in_lat_cond_l_fy'));

        % Force sign correction
        total = -JR_data.data(:,indx_total)/subj_weight;
        medial = -JR_data.data(:,indx_medial)/subj_weight;
        lateral = -JR_data.data(:,indx_lateral)/subj_weight;

        for j = 1:length(total)
            if lateral(j) < 0
                F_lcl = -lateral(j)/(((Tibial_width_L-ICD_L)/2)+ICD_L);
                lateral(j) = 0;
                total(j) = total(j)+F_lcl;
                medial(j) = total(j);
            elseif medial(j) < 0
                F_mcl = -medial(j)/(((Tibial_width_L-ICD_L)/2)+ICD_L);
                medial(j) = 0;
                total(j) = total(j)+F_mcl;
                lateral(j) = total(j);
            end
        end

    else

        % Force sign correction
        indx_time=find(ismember(JR_data.colheaders(1,:),'time'));
        indx_total=find(ismember(JR_data.colheaders(1,:),'tibial_plat_weld_r_on_tibia_r_in_tibia_r_fy'));
        indx_medial=find(ismember(JR_data.colheaders(1,:),'med_cond_joint_r_on_med_cond_r_in_med_cond_r_fy'));
        indx_lateral=find(ismember(JR_data.colheaders(1,:),'lat_cond_joint_r_on_lat_cond_r_in_lat_cond_r_fy'));

        total = -JR_data.data(:,indx_total)/subj_weight;
        medial = -JR_data.data(:,indx_medial)/subj_weight;
        lateral = -JR_data.data(:,indx_lateral)/subj_weight;

        for j = 1:length(total)
            if lateral(j) < 0
                F_lcl = -lateral(j)/(((Tibial_width_R-ICD_R)/2)+ICD_R);
                lateral(j) = 0;
                total(j) = total(j)+F_lcl;
                medial(j) = total(j);
            elseif medial(j) < 0
                F_mcl = -medial(j)/(((Tibial_width_R-ICD_R)/2)+ICD_R);
                medial(j) = 0;
                total(j) = total(j)+F_mcl;
                lateral(j) = total(j);
            end
        end
    end

    % Plot
    labels(trial) = {trials(trial).name};

    subplot(1,3,1)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), total, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Total tibiofemoral')

    subplot(1,3,2)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), medial, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Medial tibiofemoral')

    subplot(1,3,3)
    plot(0:100,interp1(linspace(0,1-1/100,length(total)), lateral, linspace(0,1-1/100,101)));
    hold on
    xlabel('% cycle')
    ylabel('Contact force (BW)')
    title('Lateral tibiofemoral')

    % Save figure
    saveas(gcf,fullfile(file_path,'Figures\JR_corrected\',trials(trial).name(1:end-4)),'png')
    close all
end

end