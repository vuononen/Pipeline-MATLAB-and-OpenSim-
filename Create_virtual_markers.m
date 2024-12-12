function Create_virtual_markers(input_file_static,subjects_path,subj,subjects_for_analyses)

import org.opensim.modeling.*

% Use the Vec3 TimeSeriesTable to read the Vec3 type data file.
opensimTable = TimeSeriesTableVec3(input_file_static);

% Convert the OpenSim table into a Matlab Struct for easy use.
matlabStruct_markerData = osimTableToStruct(opensimTable);

for i = 1:length(matlabStruct_markerData.time(:,1))
    
    % Calculate the functional knee joint centers
    try
        KJC_R = Project_marker(matlabStruct_markerData.RFemur_RTibia_score(i,:),matlabStruct_markerData.RFemur_RTibia_sara(i,:)...
            ,matlabStruct_markerData.RKNE(i,:),matlabStruct_markerData.RKNM(i,:));

        KJC_L = Project_marker(matlabStruct_markerData.LFemur_LTibia_score(i,:),matlabStruct_markerData.LFemur_LTibia_sara(i,:)...
            ,matlabStruct_markerData.LKNE(i,:),matlabStruct_markerData.LKNM(i,:));
    catch
        KJC_R = Project_marker(matlabStruct_markerData.RFemur_RTibia_score(i,:),matlabStruct_markerData.RFemur_RTibia_sara(i,:)...
            ,matlabStruct_markerData.RKNE(i,:),matlabStruct_markerData.RKNM(i,:));

        KJC_L = Project_marker(matlabStruct_markerData.LFemur_LTibia_score(i,:),matlabStruct_markerData.LFemur_LTibia_sara(i,:)...
            ,matlabStruct_markerData.LKNE(i,:),matlabStruct_markerData.LKNM(i,:));
    end
    
    % Add the calculated joint centers and projected foot markers to the markerData structure
    matlabStruct_markerData.RKJC_FUN(i,:) = KJC_R;
    matlabStruct_markerData.LKJC_FUN(i,:) = KJC_L;
    matlabStruct_markerData.LHEE_2(i,:) = matlabStruct_markerData.LHEE(i,:); matlabStruct_markerData.LHEE_2(i,2) = 0;
    matlabStruct_markerData.LTOE_2(i,:) = matlabStruct_markerData.LTOE(i,:); matlabStruct_markerData.LTOE_2(i,2) = 0;
    matlabStruct_markerData.LFMH_2(i,:) = matlabStruct_markerData.LFMH(i,:); matlabStruct_markerData.LFMH_2(i,2) = 0;
    matlabStruct_markerData.LSMH_2(i,:) = matlabStruct_markerData.LSMH(i,:); matlabStruct_markerData.LSMH_2(i,2) = 0;
    matlabStruct_markerData.LVMH_2(i,:) = matlabStruct_markerData.LVMH(i,:); matlabStruct_markerData.LVMH_2(i,2) = 0;
    matlabStruct_markerData.RHEE_2(i,:) = matlabStruct_markerData.RHEE(i,:); matlabStruct_markerData.RHEE_2(i,2) = 0;
    matlabStruct_markerData.RTOE_2(i,:) = matlabStruct_markerData.RTOE(i,:); matlabStruct_markerData.RTOE_2(i,2) = 0;
    matlabStruct_markerData.RFMH_2(i,:) = matlabStruct_markerData.RFMH(i,:); matlabStruct_markerData.RFMH_2(i,2) = 0;
    matlabStruct_markerData.RSMH_2(i,:) = matlabStruct_markerData.RSMH(i,:); matlabStruct_markerData.RSMH_2(i,2) = 0;
    matlabStruct_markerData.RVMH_2(i,:) = matlabStruct_markerData.RVMH(i,:); matlabStruct_markerData.RVMH_2(i,2) = 0;
    
end

%% Write new trc-file with added virtual markers

% Create new TimeSeriesTableVec3
output_file = osimTableFromStruct(matlabStruct_markerData);

% Set metadata to new TimeSeriesTableVec3
output_file.addTableMetaDataString('DataRate','100');
output_file.addTableMetaDataString('CameraRate','100');
output_file.addTableMetaDataString('Units','mm');

% Write the TimeSeriesTableVec3 to file
TRCFileAdapter().write(output_file,[input_file_static(1:end-4) '_added_markers.trc']);

%% Function to calculate functional knee joint center
    function KJC = Project_marker(A,B,P1,P2)
        
        % The function projects mid point of medial and lateral femoral epicondyle markers on to the
        % functional knee joint axis. The projection is perpendiculat to the functional joint axis.
        % The method is as per used in Boeth et at. 2013 Anterior Cruciate Ligament–Deficient
        % Patients With Passive Knee Joint Laxity Have a Decreased Range of Anterior-Posterior Motion During Active Movements
        % A = Score marker, B = Sara marker, P1 = Lateral epicondyle marker, P2 = Medial epicondyle marker
        
        P = mean([P1;P2],1);
        AP = P-A;
        AB = B-A;
        KJC = A + dot(AP,AB) / dot(AB,AB) * AB;
    end

%% Visualize functional knee joint
    % Calculate mid point between medial and lateral epiconduly of the femur
    mid_knee_R = mean([matlabStruct_markerData.RKNE(1,:);matlabStruct_markerData.RKNM(1,:)],1);
    mid_knee_L = mean([matlabStruct_markerData.LKNE(1,:);matlabStruct_markerData.LKNM(1,:)],1);
    
    % Calculate mid point between medial and lateral malleolus
    mid_ankle_R = mean([matlabStruct_markerData.RANK(1,:);matlabStruct_markerData.RMED(1,:)]);
    mid_ankle_L = mean([matlabStruct_markerData.LANK(1,:);matlabStruct_markerData.LMED(1,:)]);
    
    % plot lower limb and markers of interest
    hold on
    axis equal
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    view(0,90)
    
    % Femur epicondyles and the midpoint
    plot3(matlabStruct_markerData.RKNM(1,1),matlabStruct_markerData.RKNM(1,2),matlabStruct_markerData.RKNM(1,3),'bo')
    plot3(matlabStruct_markerData.RKNE(1,1),matlabStruct_markerData.RKNE(1,2),matlabStruct_markerData.RKNE(1,3),'bo')
    plot3([matlabStruct_markerData.RKNM(1,1) matlabStruct_markerData.RKNE(1,1)],[matlabStruct_markerData.RKNM(1,2) matlabStruct_markerData.RKNE(1,2)],[matlabStruct_markerData.RKNM(1,3) matlabStruct_markerData.RKNE(1,3)],'b--')
    plot3(mid_knee_R(1),mid_knee_R(2),mid_knee_R(3),'ro')
    
    plot3(matlabStruct_markerData.LKNM(1,1),matlabStruct_markerData.LKNM(1,2),matlabStruct_markerData.LKNM(1,3),'bo')
    plot3(matlabStruct_markerData.LKNE(1,1),matlabStruct_markerData.LKNE(1,2),matlabStruct_markerData.LKNE(1,3),'bo')
    plot3([matlabStruct_markerData.LKNM(1,1) matlabStruct_markerData.LKNE(1,1)],[matlabStruct_markerData.LKNM(1,2) matlabStruct_markerData.LKNE(1,2)],[matlabStruct_markerData.LKNM(1,3) matlabStruct_markerData.LKNE(1,3)],'b--')
    plot3(mid_knee_L(1),mid_knee_L(2),mid_knee_L(3),'ro')
    
    % Functional joint axis
    plot3(matlabStruct_markerData.RFemur_RTibia_score(1,1),matlabStruct_markerData.RFemur_RTibia_score(1,2),matlabStruct_markerData.RFemur_RTibia_score(1,3),'go')
    plot3(matlabStruct_markerData.RFemur_RTibia_sara(1,1),matlabStruct_markerData.RFemur_RTibia_sara(1,2),matlabStruct_markerData.RFemur_RTibia_sara(1,3),'go')
    plot3([matlabStruct_markerData.RFemur_RTibia_score(1,1) matlabStruct_markerData.RFemur_RTibia_sara(1,1)],[matlabStruct_markerData.RFemur_RTibia_score(1,2) matlabStruct_markerData.RFemur_RTibia_sara(1,2)],[matlabStruct_markerData.RFemur_RTibia_score(1,3) matlabStruct_markerData.RFemur_RTibia_sara(1,3)],'g--')
    
    plot3(matlabStruct_markerData.LFemur_LTibia_score(1,1),matlabStruct_markerData.LFemur_LTibia_score(1,2),matlabStruct_markerData.LFemur_LTibia_score(1,3),'go')
    plot3(matlabStruct_markerData.LFemur_LTibia_sara(1,1),matlabStruct_markerData.LFemur_LTibia_sara(1,2),matlabStruct_markerData.LFemur_LTibia_sara(1,3),'go')
    plot3([matlabStruct_markerData.LFemur_LTibia_score(1,1) matlabStruct_markerData.LFemur_LTibia_sara(1,1)],[matlabStruct_markerData.LFemur_LTibia_score(1,2) matlabStruct_markerData.LFemur_LTibia_sara(1,2)],[matlabStruct_markerData.LFemur_LTibia_score(1,3) matlabStruct_markerData.LFemur_LTibia_sara(1,3)],'g--')
    
    % Hip to knee
    plot3(matlabStruct_markerData.Pelvis_RFemur_score(1,1),matlabStruct_markerData.Pelvis_RFemur_score(1,2),matlabStruct_markerData.Pelvis_RFemur_score(1,3),'ko','MarkerFaceColor','k','MarkerSize',5)
    plot3(matlabStruct_markerData.Pelvis_LFemur_score(1,1),matlabStruct_markerData.Pelvis_LFemur_score(1,2),matlabStruct_markerData.Pelvis_LFemur_score(1,3),'ko','MarkerFaceColor','k','MarkerSize',5)
    plot3([matlabStruct_markerData.Pelvis_RFemur_score(1,1) mid_knee_R(1)],[matlabStruct_markerData.Pelvis_RFemur_score(1,2) mid_knee_R(2)],[matlabStruct_markerData.Pelvis_RFemur_score(1,3) mid_knee_R(3)],'k--')
    plot3([matlabStruct_markerData.Pelvis_LFemur_score(1,1) mid_knee_L(1)],[matlabStruct_markerData.Pelvis_LFemur_score(1,2) mid_knee_L(2)],[matlabStruct_markerData.Pelvis_LFemur_score(1,3) mid_knee_L(3)],'k--')
    
    % Knee to ankle
    plot3(mid_ankle_R(1),mid_ankle_R(2),mid_ankle_R(3),'ko','MarkerFaceColor','k','MarkerSize',5)
    plot3(mid_ankle_L(1),mid_ankle_L(2),mid_ankle_L(3),'ko','MarkerFaceColor','k','MarkerSize',5)
    plot3([mid_knee_R(1) mid_ankle_R(1)],[mid_knee_R(2) mid_ankle_R(2)],[mid_knee_R(3) mid_ankle_R(3)],'k--')
    plot3([mid_knee_L(1) mid_ankle_L(1)],[mid_knee_L(2) mid_ankle_L(2)],[mid_knee_L(3) mid_ankle_L(3)],'k--')
    
    % Funtional knee joint centers
    plot3(KJC_R(1),KJC_R(2),KJC_R(3),'ko','MarkerFaceColor','k','MarkerSize',5)
    plot3(KJC_L(1),KJC_L(2),KJC_L(3),'ko','MarkerFaceColor','k','MarkerSize',5)
    title(["The right leg is on the right side", "i.e. we see the subjects back"])
    
    % Save the figure
    filename = 'Functional_joint_center';
    saveas(gcf,[fullfile(subjects_path,subjects_for_analyses(subj).name,'\Figures\Functional_joint_center\',filename) '.png']);
    close all
end