% -----------------------------------------------------------------------------------------
%    ____                    _____ _                                  _           _
%   / __ \                  / ____(_)               /\               | |         (_)
%  | |  | |_ __   ___ _ __ | (___  _ _ __ ___      /  \   _ __   __ _| |_   _ ___ _ ___
%  | |  | | '_ \ / _ \ '_ \ \___ \| | '_ ` _ \    / /\ \ | '_ \ / _` | | | | / __| / __|
%  | |__| | |_) |  __/ | | |____) | | | | | | |  / ____ \| | | | (_| | | |_| \__ \ \__ \
%   \____/| .__/ \___|_| |_|_____/|_|_| |_| |_| /_/    \_\_| |_|\__,_|_|\__, |___/_|___/
%         | |                                                            __/ |
%   _____ |_|          _ _              __  __       _          _____   |___/  _
%  |  __ (_)          | (_)            |  \/  |     (_)        / ____|        | |
%  | |__) | _ __   ___| |_ _ __   ___  | \  / | __ _ _ _ __   | |     ___   __| | ___
%  |  ___/ | '_ \ / _ \ | | '_ \ / _ \ | |\/| |/ _` | | '_ \  | |    / _ \ / _` |/ _ \
%  | |   | | |_) |  __/ | | | | |  __/ | |  | | (_| | | | | | | |___| (_) | (_| |  __/
%  |_|   |_| .__/ \___|_|_|_| |_|\___| |_|  |_|\__,_|_|_| |_|  \_____\___/ \__,_|\___|
%          | |
%          |_|
% ----------------------------------------------------------------------------------------

% Script for batch analysis of over 120 participants who had an anterior 
% cruciate ligament reconstruction: you can choose which of the analyses 
% will be executed and for which subjects.

% Created by Lauri Stenroth and Will Bosch-Vuononen

close all
clear 
clc

%% Load relevant files and determine required paths

% The path to the folder containing all subjets
subjects_path = 'C:\Users\...\Subjects';

% Load all subjects' info
load('C:\Users\...\Data_all_subjects.mat');

% Get the generic setup files to work from
genericSetupPath = 'C:\Users\...\Setup';

% Get the subject details path for each subject
Subj_detailsPath = 'C:\Users\...';

%% Choose which parts of the code will be used

% Do you want to modify the ground reaction force xml file path? If yes, opt = 1.
modify_xml = 0;
% Do you need to create a new trc file for model scaling? If yes, opt = 1.
opt_newtrc = 0;
% Do you want to scale the musculoskeletal model? If yes, opt = 1.
opt_Scale = 0;
% Do you want to run inverse kinematics (IK) analysis? If yes, opt = 1.
opt_IK = 1;
% Do you want to plot IK figures? If yes, opt = 1.
opt_IK_figure = 1;
% Do you want to scale muscle strength? If yes, opt = 1.
opt_MuscleSt = 0;
% Do you want to run inverse dynamics (ID) analysis? If yes, opt = 1.
opt_ID = 1;
% Do you want to plot ID figures? If yes, opt = 1.
opt_ID_figure = 1;
% Do you want to run static optimization (SO) analysis? If yes, opt = 1.
opt_SO = 1;
% Do you want to plot SO? If yes, opt = 1.
opt_SO_figure = 1;
% Do you want to run joint reaction (JR) analysis? If yes, opt = 1.
opt_JR = 1;
% Do you want to plot JR? If yes, opt = 1.
opt_JR_figure = 1;

%% Choose which subjects will be analyzed

cd(subjects_path)
subjects = dir;
subjects = subjects(3:end);
for i = 1:length(subjects)
    subj_names{i} = subjects(i).name;
end
[indx,tf] = listdlg('PromptString',{'Select subjects you', 'want to process:'},...
    'SelectionMode','multi','ListString',subj_names);
subjects_for_analyses = subjects(indx);

clear tf i indx subj_names

% Get the setups for IK and ID, if you are doing these analyses
if opt_IK == 1
    genericSetupForIK = 'IK_setup.xml';
end

if opt_ID == 1
    genericSetupForID = 'ID_setup.xml';
end

%% Main code

for subj_number_from_subjects_for_analyses = 1:length(subjects_for_analyses)
    file_path = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name); %subject file path
    cd(fullfile(Subj_detailsPath, subjects_for_analyses(subj_number_from_subjects_for_analyses).name))
    load('Subj_details.mat')
    SubjectMass = Subj_details.Bodymass;

    % Be sure that all subjects' height is in the same unit
    if Subj_details.Height < 1000
        Subj_details.New_Height = Subj_details.Height*10;
    else
        Subj_details.New_Height = Subj_details.Height;
    end
    save('Subj_details.mat', 'Subj_details')

    clear Subj_details

    cd(file_path) % changes the path to subject's specific folder

    % Be sure that all subjects' id number are following the same style
    % First just get the number part of the subject ID and convert into number
    if length(subjects_for_analyses(subj_number_from_subjects_for_analyses).name) == 4
        if subjects_for_analyses(subj_number_from_subjects_for_analyses).name(3) == 0
            subj_num_ID = str2num(subjects_for_analyses(subj_number_from_subjects_for_analyses).name(4));
        else
            subj_num_ID = str2num(subjects_for_analyses(subj_number_from_subjects_for_analyses).name(3:4));
        end
    else %i.e. name length = 5, so over 100 number
        subj_num_ID = str2num(subjects_for_analyses(subj_number_from_subjects_for_analyses).name(3:5));
    end

    % Find the index of the same id of the subject in the data_all_subjects
    subj_ID = find(Data_all_subjects.record_id == subj_num_ID);

    % Determine which leg is the injured leg
    if Data_all_subjects.target_kn_v2(subj_ID) == 1 %right = 1, left = 2
        in_leg = 1;
    else
        in_leg = 2;
    end

    % Get the model file path
    modelFilePath = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models');

    % Filter frequency
    cutoff = 6;

    %% Modify the xml file of the ground reaction force
    if modify_xml == 1

        prefXmlRead.Str2Num = 'never';
        prefXmlWrite.StructItem = false;
        prefXmlWrite.CellItem = false;

        xml_file = dir(fullfile([file_path,'\Experimental_data\','*_grf.xml']));

        for jj = 1:length(xml_file)
            xml_tree = xml_read(fullfile(xml_file(jj).folder,xml_file(jj).name));
            xml_tree.ExternalLoads.datafile = fullfile(xml_file(jj).folder,[xml_file(jj).name(1:end-8) '.mot']);
            xml_write(fullfile(xml_file(jj).folder,xml_file(jj).name), xml_tree, 'OpenSimDocument',prefXmlWrite);
            clear xml_tree
        end
    end

    %% Modify the trc file of the static trial to include virtual markers
    if opt_newtrc == 1
        input_file_static = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'\Experimental_data\Static.trc');
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'\Figures\Functional_joint_center\');
        Create_virtual_markers(input_file_static,subjects_path,subj_number_from_subjects_for_analyses,subjects_for_analyses)
    end

    %% Scale the musculoskeletal model by using marker data
    if opt_Scale == 1
        ScaleModels_function(subj_num_ID,subj_ID,Data_all_subjects,subjects_for_analyses,subj_number_from_subjects_for_analyses,subjects_path,SubjectMass)
    end

    %% IK
    cd([subjects_path '\' subjects_for_analyses(subj_number_from_subjects_for_analyses).name]) % changes the path to subject's specific folder
    if opt_IK == 1
        modelFile = dir([modelFilePath '\*_healthy.osim']);
        modelFile = modelFile.name;

        % create output folder
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'IK');
        runIK(file_path,genericSetupPath,genericSetupForIK,modelFilePath,modelFile,in_leg)
    end
    if opt_IK_figure == 1
        % create folders and plot data
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Figures'),'IK');
        cd(fullfile(file_path,'IK'))
        plotIK(file_path,in_leg)
    end

    %% Muscle strength scaling
    if opt_MuscleSt == 1

        % Get scale factors: injured divided by healthy
        model_scale_factor_quad = 494.1845/493.9745;
        model_scale_factor_flex = 252.651/258.553;

        if in_leg == 2
            experimental_scale_factor_quad = Data_all_subjects.isokin_60_grader_quad_left_nm(subj_ID)/Data_all_subjects.isokin_60_grader_quad_right_nm(subj_ID);
            experimental_scale_factor_flex = Data_all_subjects.isokin_60_grader_hams_left_nm(subj_ID)/Data_all_subjects.isokin_60_grader_hams_right_nm(subj_ID);
            quad_scalar = experimental_scale_factor_quad/model_scale_factor_quad;
            flex_scalar = experimental_scale_factor_flex/model_scale_factor_flex;
        else
            experimental_scale_factor_quad = Data_all_subjects.isokin_60_grader_quad_right_nm(subj_ID)/Data_all_subjects.isokin_60_grader_quad_left_nm(subj_ID);
            experimental_scale_factor_flex = Data_all_subjects.isokin_60_grader_hams_right_nm(subj_ID)/Data_all_subjects.isokin_60_grader_hams_left_nm(subj_ID);
            quad_scalar = experimental_scale_factor_quad/model_scale_factor_quad;
            flex_scalar = experimental_scale_factor_flex/model_scale_factor_flex;
        end

        muscle_scale_factor = 1.5*(SubjectMass/75.3370003)^(2/3);

        if in_leg == 1 % Right leg is the injured one
            % Get the healthy model
            model_name = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_healthy.osim'];
            Model_In = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models\',model_name);
            Model_Out = [Model_In(1:end-5) '_strength_scaled.osim'];
            strengthScaler_L_healthy(muscle_scale_factor,Model_In,Model_Out);
            % get the Injured model
            model_name = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_injured.osim'];
            Model_In = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models\',model_name);
            Model_Out = [Model_In(1:end-5) '_strength_scaled.osim'];
            strengthScaler_R_injured(muscle_scale_factor,quad_scalar,flex_scalar,Model_In,Model_Out);
        else % left leg is the injured
            % get the healthy model
            model_name = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_healthy.osim'];
            Model_In = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models\',model_name);
            Model_Out = [Model_In(1:end-5) '_strength_scaled.osim'];
            strengthScaler_R_healthy(muscle_scale_factor,Model_In,Model_Out);
            % get the injured model
            model_name = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_injured.osim'];
            Model_In = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models\',model_name);
            Model_Out = [Model_In(1:end-5) '_strength_scaled.osim'];
            strengthScaler_L_injured(muscle_scale_factor,quad_scalar,flex_scalar,Model_In,Model_Out);
        end
    end

    %% ID ----------------------------------------------------------------
    if opt_ID == 1
        % Create output folders
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'ID');
        runID(file_path,genericSetupPath,genericSetupForID,modelFilePath,cutoff,in_leg)
    end

    if opt_ID_figure == 1
        % Create figure folders and plot data
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Figures'),'ID');
        cd(fullfile(file_path,'ID'))
        plotID(file_path,in_leg)
    end

    %% SO
    if opt_SO == 1
        % Create output folders
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'SO');
        genericSetupForSO = fullfile(genericSetupPath,'\SO_setup.xml');

        % Firstly for the healthy model
        runSO_healthy(file_path,genericSetupForSO,modelFilePath,cutoff,in_leg)

        % Then the injured model
        runSO_injured(file_path,genericSetupForSO,modelFilePath,cutoff,in_leg)
    end

    %% SO plotting
    if opt_SO_figure == 1
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Figures'),'SO');
        cd(fullfile(file_path,'SO'))
        plotSO(file_path)
    end

    %% JR
    if opt_JR == 1
        % create output folders
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'JR');
        genericSetupForJR = fullfile(genericSetupPath,'\JR_setup.xml');

        % Firstly for the healthy model
        runJR_healthy(file_path,genericSetupForJR,modelFilePath,cutoff,in_leg)

        % Then the injured model
        runJR_injured(file_path,genericSetupForJR,modelFilePath,cutoff,in_leg)
    end

    %% JR plotting
    if opt_JR_figure == 1
        mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Figures'),'JR_corrected');
        cd(fullfile(file_path,'JR'))
        subj_weight = SubjectMass*9.81;
        plotJR_medial_lateral_force_corrected(file_path,in_leg,subj_weight,subj_num_ID)
    end
end
disp(['All was processed for ' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '!'])
close all

%% end of script
disp('All subjects processed!')
close all
