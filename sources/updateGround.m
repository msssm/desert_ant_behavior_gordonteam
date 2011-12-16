function ground = updateGround(ground,currentStep,dt,printFlag)

removeList = zeros(length(ground.pheromoneParticles),1);

% Update the pheromone pixels
for i = 1 : length(ground.pheromoneParticles)
    phPart = ground.pheromoneParticles(i);
    [r g b] = intensity2color(max(phPart.intensity,...
                                phPart.prev.intensity));
    if ~isempty(ground.pheromoneParticles(i).prev.location)
        plot([phPart.prev.location(1) phPart.location(1)],...
             [phPart.prev.location(2) phPart.location(2)],...
             'color',[r g b]);
    end
    ground.pheromoneParticles(i) = phPart.decay(dt);
    if ground.pheromoneParticles(i).intensity < 20
        removeList(i) = i;
    end
end

removeList(removeList == 0) = [];
ground.pheromoneParticles(removeList) = [];

% Update the ants pixels
for i = 1 : length(ground.ants)
    text(ground.ants(i).prevLocation(1),ground.ants(i).prevLocation(2)+1,...
         strcat('#',int2str(i)),...
         'BackgroundColor',[.78 .89 1],...
         'FontSize',8,...
         'HorizontalAlignment','center');
    plot(ground.ants(i).prevLocation(1),ground.ants(i).prevLocation(2),'ko');
    
    %-- Used For Debug --%
    %--------------------%
    
%     % Plot the walk direction
%     plot([ground.ants(i).prevLocation(1) ground.ants(i).prevLocation(1)+ground.ants(i).pathDirection(1)], ...
%          [ground.ants(i).prevLocation(2) ground.ants(i).prevLocation(2)+ground.ants(i).pathDirection(2)],...
%          'r');
%     % Plot the next position
%     plot(ground.ants(i).location(1),ground.ants(i).location(2),'r*');
end

% Update the landmark pixels
for i = 1 : length(ground.landmarks)
    plot(ground.landmarks(i).location(1),ground.landmarks(i).location(2),'bo');
end

% Update the nest pixels
plot(ground.nestLocation(1),ground.nestLocation(2),'ro');

% Update the food source pixels
plot(ground.foodSourceLocation(1),ground.foodSourceLocation(2),'go');

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
end