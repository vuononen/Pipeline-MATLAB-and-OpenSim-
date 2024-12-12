function [] = runIK(file_path,genericSetupPath,genericSetupForIK,modelFilePath,modelFile,in_leg)

import org.opensim.modeling.*
path='C:\OpenSim 4.1\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);

% Get trc folder
trc_data_folder = fullfile(file_path,'\Experimental_data');

% Initialize IK tool
ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);

% Load the model and initialize the analysis
model = Model(fullfile(modelFilePath, modelFile));
model.initSystem();

% Specify where results will be printed.
mkdir(fullfile(file_path,'\IK'),'Setup');
mkdir(fullfile(file_path,'\IK'),'Log');
results_folder = fullfile(file_path,'\IK');

% Do the walking trials first
cd(trc_data_folder)
trials = dir('gang*.trc');

% Loop through the trials
for trial = 1:length(trials)

    % Load start and stop times
    try
        event = load([file_path '\Events\' trials(trial).name(1:end-4) '.mat']);
    catch
        disp('Start/End files was not found. Fix problem and try again.');
        return
    end

    % Get the name of the file for this trial
    markerFile = trials(trial).name;

    % Create name of trial from .trc file name
    name = regexprep(markerFile,'.trc','');
    fullpath = fullfile(trc_data_folder, markerFile);

    % Setup the ikTool for FP1 trial
    ikTool.setModel(model);
    ikTool.setName(name);
    ikTool.setMarkerDataFileName(fullpath);
    ikTool.setStartTime(event.stance_start_FP1);
    ikTool.setEndTime(event.stance_end_FP1);

    % Be sure which leg is the injured one to name IK trials correctly
    try
        if event.leg_FP1{1,1} == 'Left'
            LEG_FP1 = 2;
            LEG_FP2 = 1;
        end
    catch
        if event.leg_FP1{1,1} == 'Right'
            LEG_FP1 = 1;
            LEG_FP2 = 2;
        end
    end

    if in_leg == LEG_FP1 %right = 1, left = 2
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_injured.mot']));
        outfile = ['Setup_IK_' name '_injured.xml'];
    else
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_healthy.mot']));
        outfile = ['Setup_IK_' name '_healthy.xml'];
    end

    % Run IK
    ikTool.print(fullfile(file_path,'\IK\Setup',outfile));
    disp(['Performing IK on ' trials(trial).name(1:end-4)]);
    cd(fullfile(file_path,'\IK'))
    try
        ikTool.run();
    catch
        disp('exception running IK tool, relaxing weight on RFoot3')
        ikTasks = ikTool.getIKTaskSet();
        ikTasks.set(0.95,ikTasks.get("LSHO"))
        ikTasks.set(0.95,ikTasks.get("RSHO"))
        ikTool.run()
    end

    % Setup the ikTool for FP2 trial
    ikTool.setStartTime(event.stance_start_FP2);
    ikTool.setEndTime(event.stance_end_FP2);

    if in_leg == LEG_FP2 %right = 1, left = 2
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_injured.mot']));
        outfile = ['Setup_IK_' name '_injured.xml'];
    else
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_healthy.mot']));
        outfile = ['Setup_IK_' name '_healthy.xml'];
    end

    % Save the settings in a setup file
    ikTool.print(fullfile(file_path,'\IK\Setup',outfile));
    disp(['Performing IK on ' trials(trial).name(1:end-4)]);
    cd(fullfile(file_path,'\IK'))
    try
        ikTool.run();
    catch
        disp('exception running IK tool, relaxing weight on RFoot3')
        ikTasks = ikTool.getIKTaskSet();
        ikTasks.set(0.95,ikTasks.get("LSHO"))
        ikTasks.set(0.95,ikTasks.get("RSHO"))
        ikTool.run()
    end

end

% Do the right leg lunges first
cd(trc_data_folder)
trials = dir('LungeH*.trc');

% Loop through the trials
for trial = 1:length(trials)

    % load start and stop times
    try
        event = load([file_path '\Events\' trials(trial).name(1:end-4) '.mat']);
    catch
        disp('Start/End files was not found. Fix problem and try again.');
        return
    end

    % Get the name of the file for this trial
    markerFile = trials(trial).name;

    % Create name of trial from .trc file name
    name = regexprep(markerFile,'.trc','');
    fullpath = fullfile(trc_data_folder, markerFile);

    % Setup the ikTool for FP1 trial
    ikTool.setModel(model);
    ikTool.setName(name);
    ikTool.setMarkerDataFileName(fullpath);

    % Be sure which force plate is being used
    if event.end_FP1 > 0
        ikTool.setStartTime(event.start_FP1);
        ikTool.setEndTime(event.end_FP1);
    end
    if event.end_FP2 > 0
        ikTool.setStartTime(event.start_FP2);
        ikTool.setEndTime(event.end_FP2);
    end

    % Be sure which leg is the injured one
    if in_leg == 1 %right = 1, left = 2
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_injured.mot']));
        outfile = ['Setup_IK_' name '_injured.xml'];
    else
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_healthy.mot']));
        outfile = ['Setup_IK_' name '_healthy.xml'];
    end

    % Run IK
    ikTool.print(fullfile(file_path,'\IK\Setup',outfile));
    disp(['Performing IK on ' trials(trial).name(1:end-4)]);
    cd(fullfile(file_path,'\IK'))
    try
        ikTool.run();
    catch
        disp('exception running IK tool, relaxing weight on RFoot3')
        ikTasks = ikTool.getIKTaskSet();
        ikTasks.set(0.95,ikTasks.get("LSHO"))
        ikTasks.set(0.95,ikTasks.get("RSHO"))
        ikTool.run()
    end

end

% Do the left leg lunges
cd(trc_data_folder)
trials = dir('LungeV*.trc');

% Loop through the trials
for trial = 1:length(trials)

    % Load start and stop times
    try
        event = load([file_path '\Events\' trials(trial).name(1:end-4) '.mat']);
    catch
        disp('Start/End files was not found. Fix problem and try again.');
        return
    end

    % Get the name of the file for this trial
    markerFile = trials(trial).name;

    % Create name of trial from .trc file name
    name = regexprep(markerFile,'.trc','');
    fullpath = fullfile(trc_data_folder, markerFile);

    % Setup the ikTool for FP1 trial
    ikTool.setModel(model);
    ikTool.setName(name);
    ikTool.setMarkerDataFileName(fullpath);

    % Be sure which force plate is being used
    if event.end_FP1 > 0
        ikTool.setStartTime(event.start_FP1);
        ikTool.setEndTime(event.end_FP1);
    end
    if event.end_FP2 > 0
        ikTool.setStartTime(event.start_FP2);
        ikTool.setEndTime(event.end_FP2);
    end

    % Be sure which leg is the injured one
    if in_leg == 2 %right = 1, left = 2
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_injured.mot']));
        outfile = ['Setup_IK_' name '_injured.xml'];
    else
        ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_IK_healthy.mot']));
        outfile = ['Setup_IK_' name '_healthy.xml'];
    end

    % Run IK
    ikTool.print(fullfile(file_path,'\IK\Setup',outfile));
    disp(['Performing IK on ' trials(trial).name(1:end-4)]);
    cd(fullfile(file_path,'\IK'))
    try
        ikTool.run();
    catch
        disp('exception running IK tool, relaxing weight on RFoot3')
        ikTasks = ikTool.getIKTaskSet();
        ikTasks.set(0.95,ikTasks.get("LSHO"))
        ikTasks.set(0.95,ikTasks.get("RSHO"))
        ikTool.run()
    end

end
end