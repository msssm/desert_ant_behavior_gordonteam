function ground = updateGround(ground,currentStep,dt,printFlag)
cla;
hold on;
axis([-15 15 -15 15]);
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
    if ground.pheromoneParticles(i).intensity < 30
        removeList(i) = i;
    end
end

removeList(removeList == 0) = [];
ground.pheromoneParticles(removeList) = [];

% Update the ants pixels
for i = 1 : length(ground.ants)
    text(ground.ants(i).prevLocation(1),ground.ants(i).prevLocation(2)+1,...
         strcat('Ant #',int2str(i)),...
         'BackgroundColor',[.78 .89 1],...
         'FontSize',10,...
         'HorizontalAlignment','center');
    plot(ground.ants(i).prevLocation(1),ground.ants(i).prevLocation(2),'ko');
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
    print(strcat('trainingResults/currentResult/training_',...
            int2str(currentStep),'.png'),...
          '-dpng');
end
drawnow;
end