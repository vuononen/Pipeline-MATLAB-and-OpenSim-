function strengthScaler_L_healthy(muscle_scale_factor,Model_In,Model_Out)

import org.opensim.modeling.*

filepath = Model_In;
fileoutpath = Model_Out;

% Create the Original OpenSim model from a .osim file
Model1 = Model(filepath);
Model1.initSystem;

% Create a copy of the original OpenSim model for the Modified Model
Model2 = Model(Model1);
Model2.initSystem;

% Rename the modified Model so that it comes up with a different name in
% the GUI navigator
Model2.setName('modelModified');

% Get the set of muscles that are in the original model
Muscles1 = Model1.getMuscles(); 

% Count the muscles
nMuscles = Muscles1.getSize();

disp(['Number of muscles in original model: ' num2str(nMuscles)]);

Muscles2 = Model2.getMuscles();

for i = 0:39
    currentMuscle = Muscles1.get(i);
    
    % Define the muscle in the modified model for changing
    newMuscle = Muscles2.get(i);

    % Define the new muscle force by multiplying current muscle max
    %force by the scale factor
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*muscle_scale_factor);

end

% Save the updated model
Model2.print(fileoutpath)
disp(['The new model has been saved at ' fileoutpath]);

end
