function fourLandmarksAnimation(nestLocation,landmarksLocation,landmarksRotation,foodSourceLocation,tPhase1,tPhase2,tPhase3,dt,printFlag)
if nargin == 0
    nestLocation = [0;0];
    landmarksLocation = [-3;0];
    landmarksRotation = deg2rad(0);
    foodSourceLocation = [0;-4];
    tPhase1 = 2*60;
    tPhase2 = 2*60;
    tPhase3 = 2*60;
    dt = 1;
    printFlag = true;
end



ground = Ground;
ground.nestLocation = [inf;inf];
ground.foodSourceLocation = [inf,inf];
landmarks = [cos(landmarksRotation) -sin(landmarksRotation);
             sin(landmarksRotation) cos(landmarksRotation)]*...
            [-0.5 +0.5 ...
             -0.5 +0.5;...
             -0.5 -0.5 ...
             +0.5 +0.5]+...
             repmat(landmarksLocation,1,4);
% Ant training
ant = Ant;
ant = ant.setUp(ground);
ant.goingToNestDirectly = true;
ant.lookingFor = 'nest';
ant.location = foodSourceLocation;
ant.globalVector = nestLocation-foodSourceLocation;
ant.velocityVector(1:2) = ant.globalVector;
ht = Hashtable;
ht = ht.put('2',[0 0.3 20]);
ht = ht.put('4',[0 0 40]);
ant.storedLandmarksMap = ht;
% end training
ground.ants = ant;

t = 0;
cla;
currentStep = 1;
while (t <= tPhase1+tPhase2+tPhase3)
    ant.pathDirection = ant.location-ant.prevLocation;
    if ~isempty(ant.lookingFor)
        ant = ant.lookForSomething(ground,dt);
    else
        disp('Something went wrong. The ant can t find the nest!!');
    end
    ant = ant.updateGlobalVector(dt);
    ground.ants(1) = ant;
    
    hold on;
    axis([nestLocation(1)-5 nestLocation(1)+5 nestLocation(2)-5 nestLocation(2)+5]);
    title('Landmarks-based orientation');
    xlabel('length [m]');
    ylabel('length [m]');
    plot(landmarks(1,:),landmarks(2,:),'ko','MarkerSize',5);
    plot(nestLocation(1),nestLocation(2),'bo','MarkerSize',5);
    plot(foodSourceLocation(1),foodSourceLocation(2),'ro','MarkerSize',5);
    if t <= tPhase1
        color = [1 0.5 0]; % orange
    elseif t <= tPhase1 + tPhase2
        plot(landmarks(1,:),landmarks(2,:),'ko','MarkerSize',5,'MarkerFaceColor','k');
        ground.landmarks = landmarks;
        color = [139/255 0 0]; % dark red
    elseif t <= tPhase1 + tPhase2 + tPhase3
        plot(landmarks(1,:),landmarks(2,:),'ko','MarkerSize',5,'MarkerFaceColor','w');
        ground.landmarks = [];
        color = [0 20/255 100/255]; % readable blue
    end
    plot([ant.location(1) ant.prevLocation(1)],...
         [ant.location(2) ant.prevLocation(2)],...
         '-','color',color,'LineWidth',1);
    drawnow;
    if printFlag
         % It assures that the up to 9999 frames
        % the images are saved in the right order
        zeroStr = '000';
        if currentStep > 999
            zeroStr = '';
        elseif currentStep > 99
            zeroStr = '0';
        elseif currentStep > 9
            zeroStr = '00';
        end
        print(strcat('results/currentResult/snap_',...
                zeroStr,int2str(currentStep),'.png'),...
              '-dpng');
    end
    t = t+dt;
    currentStep = currentStep + 1;
end
end