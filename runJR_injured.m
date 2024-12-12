function [] = runJR_injured(file_path,genericSetupForJR,modelFilePath,cutoff,in_leg)

%% Function to calculate the joint reaction forces

import org.opensim.modeling.*
path='C:\OpenSim 4.1\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);

prefXmlRead.Str2Num = 'never';
prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem = false;

% Get IK folder
SO_data_folder = fullfile(file_path,'SO');

% Initialize Analyze tool
analyzeTool = AnalyzeTool(genericSetupForJR);

% Load the injured model and initialize
modelFile = dir([modelFilePath '\*_injured_strength_scaled.osim']);
model = Model(fullfile(modelFilePath, modelFile.name));
model.initSystem();

% Get the trials of injured leg walking
trials = dir(fullfile(file_path,'\SO\gang*injured_Static*force.sto'));

% Make other folders
mkdir(fullfile(file_path,'\JR','Setup'));
mkdir(fullfile(file_path,'\JR','Log'));
results_folder = fullfile(file_path,'\JR');

% Loop through walking trials
for m = 1:length(trials)

    cd(SO_data_folder)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:6) '.mat']);

    % Get the name of the file for this trial
    SOFile = trials(m).name;

    % Create name of trial
    name = regexprep(SOFile,'_StaticOptimization_force.sto','');
    fullpath = fullfile(SO_data_folder,SOFile);

    % Setup the analyzeTool for this trial
    analyzeTool.setModel(model);
    analyzeTool.setName(name);
    analyzeTool.setCoordinatesFileName(fullfile([SO_data_folder(1:end-2) 'IK\'],[SOFile(1:end-36) 'IK_injured.mot']));
    analyzeTool.setModelFilename(modelFile.name)

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
        analyzeTool.setInitialTime(event.stance_start_FP1);
        analyzeTool.setFinalTime(event.stance_end_FP1);
    else
        analyzeTool.setInitialTime(event.stance_start_FP2);
        analyzeTool.setFinalTime(event.stance_end_FP2);
    end

    analyzeTool.setExternalLoadsFileName(fullfile(file_path,'Experimental_data',[name(1:6) '_grf.xml']));
    analyzeTool.setResultsDir(results_folder);
    analyzeTool.setLowpassCutoffFrequency(cutoff);

    % Save the settings in a setup file
    outfile = ['Setup_JR_check_used_model_here_' name '.xml'];
    analyzeTool.print(fullfile(file_path,'\JR','Setup',outfile));

    % Modify setup file
    JCFTree = xml_read(fullfile(file_path,'\JR','Setup',outfile),prefXmlRead);
    JCFTree.AnalyzeTool.ATTRIBUTE.name = name;
    JCFTree.AnalyzeTool.model_file = fullfile(modelFilePath, modelFile.name);

    if in_leg == LEG_FP1 %right = 1, left = 2
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(event.stance_start_FP1);
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(event.stance_end_FP1);
    else
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(event.stance_start_FP2);
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(event.stance_end_FP2);
    end

    JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.forces_file = [file_path '\SO\' name '_StaticOptimization_force.sto'];

    outfile2 = ['Setup_JR_' name '.xml'];
    xml_write(fullfile(file_path,'\JR','Setup',outfile2), JCFTree, 'OpenSimDocument',prefXmlWrite);

    disp(['Performing JR on ' trials(m).name(1:14)]);

    % Run JR
    analyzeTool = AnalyzeTool(fullfile(file_path,'\JR','Setup',outfile2));
    cd(fullfile(file_path,'\JR'))
    analyzeTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

% Get the trials of injured leg
trials = dir(fullfile(file_path,'\SO\lunge*injured_Static*force.sto'));

% Loop through lunge trials
for m = 1:length(trials)

    cd(SO_data_folder)

    % Load start and stop times
    event = load([file_path '\Events\' trials(m).name(1:8) '.mat']);

    % Get the name of the file for this trial
    SOFile = trials(m).name;

    % Create name of trial
    name = regexprep(SOFile,'_StaticOptimization_force.sto','');
    fullpath = fullfile(SO_data_folder,SOFile);

    % Setup the analyzeTool for this trial
    analyzeTool.setModel(model);
    analyzeTool.setName(name);
    analyzeTool.setCoordinatesFileName(fullpath);
    analyzeTool.setModelFilename(modelFile.name)

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
    outfile = ['Setup_JR_check_used_model_here_' name '.xml'];
    analyzeTool.print(fullfile(file_path,'\JR','Setup',outfile));

    % Modify setup file
    JCFTree = xml_read(fullfile(file_path,'\JR','Setup',outfile),prefXmlRead);
    JCFTree.AnalyzeTool.ATTRIBUTE.name = name;
    JCFTree.AnalyzeTool.model_file = fullfile(modelFilePath, modelFile.name);

    if event.end_FP2 > 0 %right = 1, left = 2
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(event.start_FP2);
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(event.end_FP2);
    else
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.start_time = num2str(event.start_FP1);
        JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.end_time = num2str(event.end_FP1);
    end

    JCFTree.AnalyzeTool.AnalysisSet.objects.JointReaction.forces_file = [file_path '\SO\' name '_StaticOptimization_force.sto'];

    outfile2 = ['Setup_JR_' name '.xml'];
    xml_write(fullfile(file_path,'\JR','Setup',outfile2), JCFTree, 'OpenSimDocument',prefXmlWrite);

    disp(['Performing JR on ' trials(m).name(1:8)]);

    % Run JR
    analyzeTool = AnalyzeTool(fullfile(file_path,'\JR','Setup',outfile2));
    cd(fullfile(file_path,'\JR'))
    analyzeTool.run();

    disp(['Still ' num2str(length(trials)-m) ' trials to go']);
end

end