function [] = ScaleModels_function(subj_num_ID,subj_ID,Data_all_subjects,subjects_for_analyses,subj_number_from_subjects_for_analyses,subjects_path,SubjectMass)

% --------------------------------------------------------- %
%  _____           _       ___  ___          _      _       %
% /  ___|         | |      |  \/  |         | |    | |      %
% \ `--.  ___ __ _| | ___  | .  . | ___   __| | ___| |___   %
%  `--. \/ __/ _` | |/ _ \ | |\/| |/ _ \ / _` |/ _ \ / __|  %
% /\__/ / (_| (_| | |  __/ | |  | | (_) | (_| |  __/ \__ \  %
% \____/ \___\__,_|_|\___| \_|  |_/\___/ \__,_|\___|_|___/  %
%                                                           %
% --------------------------------------------------------- %

% A code to programmatically generate subject-specific musculoskeletal
% models based on marker data
import org.opensim.modeling.*

% Create model folder
mkdir(fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name),'Models');

% Go to correct path and get all files
cd(subjects_path)
cd(subjects_for_analyses(subj_number_from_subjects_for_analyses).name);
cd('Experimental_data');
times = dir;
times = times(3:end);

%% Identify the static trial
files = dir('*Static_added_markers.trc');

%% Identify time point in which all markers are available
markerData = TimeSeriesTableVec3(files(1).name); % here you get the static trial markers
markerData = osimTableToStruct(markerData);

% Get the markers used in scaling
used_markers = {'LANK'; 'RANK';'LKJC_FUN';'RKJC_FUN';'C7';'LSHO';'RSHO';'RMED';'LMED';'Pelvis_RFemur_score';'Pelvis_LFemur_score'; ...
    'LHEE_2';'RHEE_2';'LTOE_2';'RTOE_2';'LSMH_2';'RSMH_2';'LVMH_2';'RVMH_2';'RFMH_2';'LFMH_2'};

for marker_idx = 1:length(used_markers)
    ispresent(:,marker_idx) = ~isnan(eval(['markerData.' used_markers{marker_idx,1} '(:,1)']));
end

first_frame = find(sum(ispresent,2) == 21,1);
first_time = markerData.time(first_frame);

% Confirm that the next frame is also valid
if ~sum(ispresent(first_frame+1,:)) == 46
    disp(['Valid frames were not identified for ' subjects_for_analyses(subj_number_from_subjects_for_analyses).name ' at ' files(1).name])
    return
end

% Get marker file
MarkerFile = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Experimental_data',files(1).name);

%% Write the xml file
path='...\Final_dataset\OpenSim\Model\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);
prefXmlRead.Str2Num = 'never'; %Options: "always", "never", and "smart", Original was 'never'
prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem = false;

% Specify where results will be printed
results_folder = fullfile(subjects_path,subjects_for_analyses(subj_number_from_subjects_for_analyses).name,'Models');

%% Scale the injured model
% Select the correct leg for the injured model and its setup
if Data_all_subjects.target_kn_v2(subj_ID) == 1 %1 = right, 2 = left
    model = Model('...\Final_dataset\OpenSim\Model\MIRAKOS_unscaled_injured_R_v3.osim');
    genericSetupForScaleTool = '...\Final_dataset\Codes\Setup\Scale_setup_injured_R_v3.xml';
else
    model = Model('..\Final_dataset\OpenSim\Model\MIRAKOS_unscaled_injured_L_v3.osim');
    genericSetupForScaleTool = '...\Final_dataset\Codes\Setup\Scale_setup_injured_L_v3.xml';
end

model.initSystem();

%% Initialize Scale tool first for injured leg model
scaleTool = ScaleTool(genericSetupForScaleTool);
markerPlacer = scaleTool.getMarkerPlacer;
ModelScaler = scaleTool.getModelScaler;

% Set subject mass
scaleTool.setSubjectMass(SubjectMass);

% Set marker data
markerPlacer.setMarkerFileName(MarkerFile);
ModelScaler.setMarkerFileName(MarkerFile);

% Set model name
scaleTool.setName([subjects_for_analyses(subj_number_from_subjects_for_analyses).name]);

% Set start and stop times for marker data in static trial
TimeRange = ArrayDouble(0,2);
TimeRange.set(0,first_time);
TimeRange.set(1,first_time+0.01);
markerPlacer.setTimeRange(TimeRange);
ModelScaler.setTimeRange(TimeRange);

% Print unfinished scale setup file to double check information before
% proceeding
if Data_all_subjects.target_kn_v2(subj_ID) == 1 %1 = right, 2 = left
    outfile = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_injured.xml'];
    scaleTool.print(fullfile(results_folder,outfile));
else
    outfile = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_injured.xml'];
    scaleTool.print(fullfile(results_folder,outfile));
end

%% Calculate scale factors for the knee structures from x-ray data
load('...\xray_data.mat');

% Selecte the correct subject id first
MIRAKOS_ID = find(MIRAKOS_xray.subj_id == subj_num_ID);
if isempty(MIRAKOS_ID)
    load(['...\Matlab' num2str(subj_num_ID) '\Subj_details.mat'])
    Height = Subj_details.Height/10;
    if Height < 100
        Height = Height*10;
    end

    ICD = 0.3856*Height-14.67; % Based on regression determined from x-ray data
    ScaleFactor = (ICD/2)/20;
else

    % Determine which leg is right or left
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

    % The x in MIRAKOS_xray is the mediolateral direction, but in opensim is z
    % The y in MIRAKOS_xray is the up down direction, same as in opensim

    % Right leg
    ScaleFactor_med_cond_r_x = MIRAKOS_xray.Femoral_Condyle_Med_toCen_dx_mm(MIRAKOS_leg_r)/20;
    ScaleFactor_lat_cond_r_x = MIRAKOS_xray.Femoral_Condyle_Lat_toCen_dx_mm(MIRAKOS_leg_r)/20;
    ScaleFactor_r = (ScaleFactor_med_cond_r_x + ScaleFactor_lat_cond_r_x)/2;

    % Left leg
    ScaleFactor_med_cond_l_x = MIRAKOS_xray.Femoral_Condyle_Med_toCen_dx_mm(MIRAKOS_leg_l)/20;
    ScaleFactor_lat_cond_l_x = MIRAKOS_xray.Femoral_Condyle_Lat_toCen_dx_mm(MIRAKOS_leg_l)/20;
    ScaleFactor_l = (ScaleFactor_med_cond_l_x + ScaleFactor_lat_cond_l_x)/2;

    % Final scale factor:
    ScaleFactor = (ScaleFactor_r + ScaleFactor_l)/2;
end

% Read xml
xmlfile = xml_read(fullfile(results_folder,outfile));

% Set scale factors
for ii = 1:8
    xmlfile.ScaleTool.ModelScaler.ScaleSet.objects.Scale(ii).scales = [1,1,ScaleFactor];
end

%% Scaling
% Set output model file, output IK file and final scale setup
xmlfile.ScaleTool.ModelScaler.marker_file = MarkerFile;
xmlfile.ScaleTool.MarkerPlacer.marker_file = MarkerFile;
if Data_all_subjects.target_kn_v2(subj_ID) == 1 %1 = right, 2 = left
    xmlfile.ScaleTool.MarkerPlacer.output_model_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_injured.osim'];
    xmlfile.ScaleTool.MarkerPlacer.output_motion_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_static_R_injured.mot'];
    xmlfile.ScaleTool.ModelScaler.output_scale_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_ScaleFactors_R_injured.xml'];
    outfile2 = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_final_R_injured.xml'];
    xml_write(fullfile(results_folder,outfile2), xmlfile, 'OpenSimDocument',prefXmlWrite);
else
    xmlfile.ScaleTool.MarkerPlacer.output_model_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_injured.osim'];
    xmlfile.ScaleTool.MarkerPlacer.output_motion_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_static_L_injured.mot'];
    xmlfile.ScaleTool.ModelScaler.output_scale_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_ScaleFactors_L_injured.xml'];
    outfile2 = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_final_L_injured.xml'];
    xml_write(fullfile(results_folder,outfile2), xmlfile, 'OpenSimDocument',prefXmlWrite);
end

% Start scaling the model
cd(results_folder)
scaleTool = ScaleTool(outfile2);
scaleTool.run();

%% Scale the healthy model
% Load the healthy model and its setup: target knee = injured knee!
if Data_all_subjects.target_kn_v2(subj_ID) == 2 % 1 = injured right, 2 = injured left
    model = Model('...\unscaled_healthy_R_v3.osim');
    genericSetupForScaleTool = '...\Final_dataset\Codes\Setup\Scale_setup_healthy_R_v3.xml';
else
    model = Model('...\unscaled_healthy_L_v3.osim');
    genericSetupForScaleTool = '...\Final_dataset\Codes\Setup\Scale_setup_healthy_L_v3.xml';
end

model.initSystem();

scaleTool = ScaleTool(genericSetupForScaleTool);
markerPlacer = scaleTool.getMarkerPlacer;
ModelScaler = scaleTool.getModelScaler;

% Set subject mass
scaleTool.setSubjectMass(SubjectMass);

% Set marker data
markerPlacer.setMarkerFileName(MarkerFile);
ModelScaler.setMarkerFileName(MarkerFile);

% Set model name
scaleTool.setName([subjects_for_analyses(subj_number_from_subjects_for_analyses).name]);

% Set start and stop times for marker data in static trial
TimeRange = ArrayDouble(0,2);
TimeRange.set(0,first_time);
TimeRange.set(1,first_time+0.01);
markerPlacer.setTimeRange(TimeRange);
ModelScaler.setTimeRange(TimeRange);

% Print unfinished scale setup file to double check information
if Data_all_subjects.target_kn_v2(subj_ID) == 2 %1 = right, 2 = left
    outfile = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_healthy.xml'];
    scaleTool.print(fullfile(results_folder,outfile));
else
    outfile = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_healthy.xml'];
    scaleTool.print(fullfile(results_folder,outfile));
end

% Read xml
xmlfile = xml_read(fullfile(results_folder,outfile));

% Set scale factors
for ii = 1:8
    xmlfile.ScaleTool.ModelScaler.ScaleSet.objects.Scale(ii).scales = [1,1,ScaleFactor];
end

%% Scaling
% Set output model file, output IK file and final scale setup
xmlfile.ScaleTool.ModelScaler.marker_file = MarkerFile;
xmlfile.ScaleTool.MarkerPlacer.marker_file = MarkerFile;
if Data_all_subjects.target_kn_v2(subj_ID) == 2 %1 = right, 2 = left
    xmlfile.ScaleTool.MarkerPlacer.output_model_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_R_healthy.osim'];
    xmlfile.ScaleTool.MarkerPlacer.output_motion_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_static_R_healthy.mot'];
    xmlfile.ScaleTool.ModelScaler.output_scale_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_ScaleFactors_R_healthy.xml'];
    outfile2 = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_final_R_healthy.xml'];
    xml_write(fullfile(results_folder,outfile2), xmlfile, 'OpenSimDocument',prefXmlWrite);
else
    xmlfile.ScaleTool.MarkerPlacer.output_model_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_L_healthy.osim'];
    xmlfile.ScaleTool.MarkerPlacer.output_motion_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_static_L_healthy.mot'];
    xmlfile.ScaleTool.ModelScaler.output_scale_file = [subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_ScaleFactors_L_healthy.xml'];
    outfile2 = ['ScaleSetup_' subjects_for_analyses(subj_number_from_subjects_for_analyses).name '_final_L_healthy.xml'];
    xml_write(fullfile(results_folder,outfile2), xmlfile, 'OpenSimDocument',prefXmlWrite);
end

% scale the model
cd(results_folder)
scaleTool = ScaleTool(outfile2);
scaleTool.run();