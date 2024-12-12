function strengthScaler_L_injured(muscle_scale_factor,quad_scalar,flex_scalar,Model_In,Model_Out)

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

disp(['Number of muscles in orginal model: ' num2str(nMuscles)]);

Muscles2 = Model2.getMuscles();

% Scale all muscles normally
for i = 0:39
    currentMuscle = Muscles1.get(i);
    
    %define the muscle in the modified model for changing
    newMuscle = Muscles2.get(i);

    %define the new muscle force by multiplying current muscle max
    %force by the scale factor
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*muscle_scale_factor);

end

% Knee flexer muscles
for i = [6 7 23 30 31 32]
    currentMuscle = Muscles2.get(i);
    
    %define the muscle in the modified model for changing
    newMuscle = Muscles2.get(i);
    
    %define the new muscle force by multiplying current muscle max
    %force by the scale factor
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*flex_scalar);
end

% Knee extensor muscles
for i = [29 37 38 39]
    currentMuscle = Muscles2.get(i);
    
    %define the muscle in the modified model for changing
    newMuscle = Muscles2.get(i);

    %define the new muscle force by multiplying current muscle max
    %force by the scale factor
    newMuscle.setMaxIsometricForce(currentMuscle.getMaxIsometricForce()*quad_scalar);
end
 
% save the updated model
Model2.print(fileoutpath)
disp(['The new model has been saved at ' fileoutpath]);

end
