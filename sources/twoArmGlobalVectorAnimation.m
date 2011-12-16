function twoArmGlobalVectorAnimation(alpha,lengthArm1,lengthArm2,dt,printFlag)
if nargin == 0
    alpha = deg2rad(60);
    lengthArm1 = 10;
    lengthArm2 = 5;
    dt = 1;
    printFlag = false;
end

nestLocation = [0;0];
nodeLocation = [0;lengthArm1];
foodSourceLocation = nodeLocation + [lengthArm2*sin(pi-alpha);-lengthArm2*cos(pi-alpha)];

ground = Ground;
ground.nestLocation = nestLocation;
nestPh = PheromoneParticle();
nestPh.location = nestLocation;
nestPh.intensity = 0;
nestPh = nestPh.setPrev(nestPh);
ground.pheromoneParticles = nestPh;
ground.foodSourceLocation = foodSourceLocation;
ant = Ant;
ant = ant.setUp(ground);
ant.velocityVector(1:2) = [0;1];
ground.ants = ant;

target = nodeLocation;
currentPrint = 1;
while(currentPrint ==1 || ant.location(1) >= 0)
    ant.velocityVector(1:2) = ant.velocityVector(1:2)./norm(ant.velocityVector(1:2));
    ant.pathDirection = ant.velocityVector(1:2);
    ground = ant.releasePheromone(ground);
    if ant.carryingFood
        target = (ant.globalVector./norm(ant.globalVector)).*ant.l;
        ant.carryingFood = false;
    elseif norm(ant.location-nodeLocation) == 0
        target = foodSourceLocation;
    end
    ant = ant.stepStraightTo(target,dt);
    if ground.isLocationAtFoodSource(ant.location)
        ant.carryingFood = 1;        
    end
    ant = ant.updateGlobalVector(dt);
    ground.ants(1) = ant;
    cla;
    hold on;
    minv = min([nestLocation foodSourceLocation nodeLocation]');
    maxv = max([nestLocation foodSourceLocation nodeLocation]');
    axis([minv(1)-2 maxv(1)+2 minv(2)-2 maxv(2)+2]);
    title('Path integration');
    xlabel('length [m]');
    ylabel('length [m]');
    plot(nodeLocation(1),nodeLocation(2),'bo');
    ground = updateGround(ground,currentPrint,dt,printFlag);
    drawnow;
    currentPrint = currentPrint+1;
    if currentPrint > 500
        break
    end
end
end

