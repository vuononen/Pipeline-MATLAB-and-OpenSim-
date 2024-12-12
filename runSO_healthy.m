function [] = runSO_healthy(file_path,genericSetupForSO,modelFilePath,cutoff,in_leg)

import org.opensim.modeling.*
path='C:\OpenSim 4.1\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);

prefXmlRead.Str2Num = 'never';
prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem = false;

% Get IK folder
IK_data_folder = fullfile(file_path,'IK');

% Initialize Analyze tool
analyzeTool = AnalyzeTool(genericSetupForSO);

% Load the healthy model and initialize
modelFile = dir([modelFilePath '\*_healthy_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Get the trials of healthy leg walking
trials = dir(fullfile(file_path,'\IK\gang*healthy.mot'));

% Make other folders
mkdir(fullfile(file_path,'\SO','Setup'));
mkdir(fullfile(file_path,'\SO','Log'));
results_folder = fullfile(file_path,'\SO');

% Loop through walking trials
for m = 1:length(trials)

    cd(IK_data_folder)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:6) '.mat']);

    % Get the name of the file for this trial
    IKFile = trials(m).name;

    % Create name of trial
    name = regexprep(IKFile,'_IK_healthy.mot','_healthy');
    fullpath = fullfile(IK_data_folder,IKFile);

    % Setup the analyzeTool for this trial
    analyzeTool.setModel(model);
    analyzeTool.setName(name);
    analyzeTool.setModelFilename(modelFile.name)
    analyzeTool.setCoordinatesFileName(fullpath);

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

    if in_leg == LEG_FP1 %right = 1, left = 2
        analyzeTool.setInitialTime(event.stance_start_FP2);
        analyzeTool.setFinalTime(event.stance_end_FP2);
    else
        analyzeTool.setInitialTime(event.stance_start_FP1);
        analyzeTool.setFinalTime(event.stance_end_FP1);
    end

    analyzeTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:6) '_grf.xml']));
    analyzeTool.setResultsDir(results_folder);
    analyzeTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_SO_' name '_check_model.xml'];
    analyzeTool.print(fullfile(file_path,'\SO','Setup',outfile));

    % Modify setup file
    StaticOptTree = xml_read(fullfile(file_path,'\SO','Setup',outfile),prefXmlRead);
    StaticOptTree.AnalyzeTool.ATTRIBUTE.name = name;
    StaticOptTree.AnalyzeTool.model_file = fullfile(modelFilePath, modelFile.name);

    if in_leg == LEG_FP1 %right = 1, left = 2
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.start_time = num2str(event.stance_start_FP2);
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.end_time = num2str(event.stance_end_FP2);
    else
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.start_time = num2str(event.stance_start_FP1);
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.end_time = num2str(event.stance_end_FP1);
    end

    % Print final SO setup
    outfile2 = ['Setup_SO_' name '.xml'];
    xml_write(fullfile(file_path,'\SO','Setup',outfile2), StaticOptTree, 'OpenSimDocument',prefXmlWrite);

    disp(['Performing SO on ' trials(m).name(1:end-4)]);

    % Run SO
    analyzeTool = AnalyzeTool(fullfile(file_path,'\SO','Setup',outfile2));
    cd(fullfile(file_path,'\SO'))
    analyzeTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

% Get the trials of healthy leg
if in_leg == 1 %if injured is is right, healthy is left
    trials = dir(fullfile(file_path,'\IK\lungeV*healthy.mot'));
else
    trials = dir(fullfile(file_path,'\IK\lungeH*healthy.mot'));
end

% Loop through lunge trials
for m = 1:length(trials)

    cd(IK_data_folder)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:8) '.mat']);

    % Get the name of the file for this trial
    IKFile = trials(m).name;

    % Create name of trial
    name = regexprep(IKFile,'_IK_healthy.mot','_healthy');
    fullpath = fullfile(IK_data_folder,IKFile);

    % Setup the analyzeTool for this trial
    analyzeTool.setModel(model);
    analyzeTool.setName(name);
    analyzeTool.setModelFilename(modelFile.name)
    analyzeTool.setCoordinatesFileName(fullpath);

    if event.end_FP1 > 0 %right = 1, left = 2
        analyzeTool.setInitialTime(event.start_FP1);
        analyzeTool.setFinalTime(event.end_FP1);
    else
        analyzeTool.setInitialTime(event.start_FP2);
        analyzeTool.setFinalTime(event.end_FP2);
    end

    analyzeTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:8) '_grf.xml']));
    analyzeTool.setResultsDir(results_folder);
    analyzeTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_SO_' name '_check_model.xml'];
    analyzeTool.print(fullfile(file_path,'\SO','Setup',outfile));

    % Modify setup file
    StaticOptTree = xml_read(fullfile(file_path,'\SO','Setup',outfile),prefXmlRead);
    StaticOptTree.AnalyzeTool.ATTRIBUTE.name = name;
    StaticOptTree.AnalyzeTool.model_file = fullfile(modelFilePath, modelFile.name);

    if event.end_FP1 > 0 %right = 1, left = 2
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.start_time = num2str(event.start_FP1);
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.end_time = num2str(event.end_FP1);
    else
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.start_time = num2str(event.start_FP2);
        StaticOptTree.AnalyzeTool.AnalysisSet.objects.StaticOptimization.end_time = num2str(event.end_FP2);
    end

    % Print final SO setup
    outfile2 = ['Setup_SO_' name '.xml'];
    xml_write(fullfile(file_path,'\SO','Setup',outfile2), StaticOptTree, 'OpenSimDocument',prefXmlWrite);

    disp(['Performing SO on ' trials(m).name(1:end-4)]);

    % Run SO
    analyzeTool = AnalyzeTool(fullfile(file_path,'\SO','Setup',outfile2));
    cd(fullfile(file_path,'\SO'))
    analyzeTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

end