function [] = runID(file_path,genericSetupPath,genericSetupForID,modelFilePath,cutoff,in_leg)

import org.opensim.modeling.*
path='C:\OpenSim 4.1\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);

% Get IK folder
IK_data_folder = fullfile(file_path,'IK');

% Initialize ID tool
idTool = InverseDynamicsTool([genericSetupPath genericSetupForID]);

% Make other folders
mkdir(fullfile(file_path,'\ID','Setup'));
mkdir(fullfile(file_path,'\ID','Log'));
results_folder = fullfile(file_path,'\ID');

%% Get the trials
trials = dir(fullfile(file_path,'\IK\gang*injured.mot'));

% Load the injured model and initialize
modelFile = dir([modelFilePath '\*_injured_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Loop through walking trials of injured leg
for m = 1:length(trials)
    cd(IK_data_folder)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:6) '.mat']);

    % Be sure which leg is the injured one
    try
        if event.leg_FP1{1,1} == 'Left' % right = 1, left = 2
            LEG_FP1 = 2;
            LEG_FP2 = 1;
        end
    catch
        if event.leg_FP1{1,1} == 'Right'
            LEG_FP1 = 1;
            LEG_FP2 = 2;
        end
    end

    % Get the IK name of the file for this trial
    IKFile = trials(m).name;
    fullpath = fullfile(IK_data_folder,IKFile);

    % Create name of trial
    name = regexprep(IKFile,'IK_injured.mot','ID_injured');
    
    % Setup the idTool for this trial
    idTool.setModel(model);
    idTool.setModelFileName(modelFile.name)
    idTool.setName(name);
    idTool.setCoordinatesFileName(fullpath);

    % Check which is the injured leg
    if in_leg == LEG_FP1 %right = 1, left = 2
        idTool.setStartTime(event.stance_start_FP1);
        idTool.setEndTime(event.stance_end_FP1);
    else
        idTool.setStartTime(event.stance_start_FP2);
        idTool.setEndTime(event.stance_end_FP2);
    end
    
    idTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:end-11) '_grf.xml']));
    idTool.setOutputGenForceFileName([name '.sto']);
    idTool.setResultsDir(results_folder);
    idTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_ID_' name '.xml'];
    idTool.print(fullfile(file_path,'\ID','Setup',outfile));

    disp(['Performing ID on ' trials(m).name(1:end-15)]);
    % Run ID
    cd(fullfile(file_path,'\ID'))
    idTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

%% Get the trials
trials = dir(fullfile(file_path,'\IK\gang*healthy.mot'));

% Load the healthy model and initialize
modelFile = dir([modelFilePath '\*_healthy_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Loop through walking trials of healthy leg
for m = 1:length(trials)
% load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:6) '.mat']);

    % Be sure which leg is the healthy one
    try
        if event.leg_FP1{1,1} == 'Left' % right = 1, left = 2
            LEG_FP1 = 2;
            LEG_FP2 = 1;
        end
    catch
        if event.leg_FP1{1,1} == 'Right'
            LEG_FP1 = 1;
            LEG_FP2 = 2;
        end
    end

    % Get the IK name of the file for this trial
    IKFile = trials(m).name;
    fullpath = fullfile(IK_data_folder,IKFile);

    % Create name of trial
    name = regexprep(IKFile,'IK_healthy.mot','ID_healthy');

    % Setup the idTool for this trial
    idTool.setModel(model);
    idTool.setModelFileName(modelFile.name)
    idTool.setName(name);
    idTool.setCoordinatesFileName(fullpath);

    % Check which is the healthy leg
    if in_leg == LEG_FP2 %right = 1, left = 2
        idTool.setStartTime(event.stance_start_FP1);
        idTool.setEndTime(event.stance_end_FP1);
    else
        idTool.setStartTime(event.stance_start_FP2);
        idTool.setEndTime(event.stance_end_FP2);
    end
    
    idTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:end-11) '_grf.xml']));
    idTool.setOutputGenForceFileName([name '.sto']);
    idTool.setResultsDir(results_folder);
    idTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_ID_' name '.xml'];
    idTool.print(fullfile(file_path,'\ID','Setup',outfile));
    
    disp(['Performing ID on ' trials(m).name(1:end-15)]);
    % Run ID
    cd(fullfile(file_path,'\ID'))
    idTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

%% Get the trials
trials = dir(fullfile(file_path,'\IK\lung*healthy.mot'));

% Load the injured model and initialize
modelFile = dir([modelFilePath '\*_healthy_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Loop through lunge trials of healthy leg
for m = 1:length(trials)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:8) '.mat']);

    % Get the IK name of the file for this trial
    IKFile = trials(m).name;
    fullpath = fullfile(IK_data_folder,IKFile);

    % Create name of trial
    name = regexprep(IKFile,'IK_healthy.mot','ID_healthy');

    % Setup the idTool for this trial
    idTool.setModel(model);
    idTool.setName(name);
    idTool.setModelFileName(modelFile.name)
    idTool.setCoordinatesFileName(fullpath);
    
    % Check which force plate is being used
    if event.end_FP2 > 0 %right = 1, left = 2
        idTool.setStartTime(event.start_FP2);
        idTool.setEndTime(event.end_FP2);
    else
        idTool.setStartTime(event.start_FP1);
        idTool.setEndTime(event.end_FP1);
    end

    idTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:end-11) '_grf.xml']));
    idTool.setOutputGenForceFileName([name '.sto']);
    idTool.setResultsDir(results_folder);
    idTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_ID_' name '.xml'];
    idTool.print(fullfile(file_path,'\ID','Setup',outfile));
    disp(['Performing ID on ' trials(m).name(1:end-15)]);

    % Run ID
    cd(fullfile(file_path,'\ID'))
    idTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

%% Get the trials
trials = dir(fullfile(file_path,'\IK\lung*injured.mot'));

% Load the injured model and initialize
modelFile = dir([modelFilePath '\*_injured_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Loop through lunge trials of injured leg
for m = 1:length(trials)
    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:8) '.mat']);

    % Get the IK name of the file for this trial
    IKFile = trials(m).name;
    fullpath = fullfile(IK_data_folder,IKFile);

    % Create name of trial
    name = regexprep(IKFile,'IK_injured.mot','ID_injured');

    % Setup the idTool for this trial
    idTool.setModel(model);
    idTool.setName(name);
    idTool.setModelFileName(modelFile.name)
    idTool.setCoordinatesFileName(fullpath);
    
    % Check which force plate is used
    if event.end_FP2 > 0 %right = 1, left = 2
        idTool.setStartTime(event.start_FP2);
        idTool.setEndTime(event.end_FP2);
    else
        idTool.setStartTime(event.start_FP1);
        idTool.setEndTime(event.end_FP1);
    end

    idTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:end-11) '_grf.xml']));
    idTool.setOutputGenForceFileName([name '.sto']);
    idTool.setResultsDir(results_folder);
    idTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_ID_' name '.xml'];
    idTool.print(fullfile(file_path,'\ID','Setup',outfile));
    disp(['Performing ID on ' trials(m).name(1:end-15)]);
    
    % Run ID
    cd(fullfile(file_path,'\ID'))
    idTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

end