function twoArmGlobalVectorTest(maxAngle, minAngle, nMesurements)
if nargin == 0
    maxAngle = deg2rad(170);
    minAngle = deg2rad(60);
    nMesurements = 10;
end
assert(maxAngle > minAngle && nMesurements > 0);
lengthArm1 = 10;
lengthArm2 = 5;
nestLocation = [0;0];
nodeLocation = [0;lengthArm1];
displacement = (maxAngle-minAngle)/nMesurements;
xs = zeros(nMesurements,1);
ys = zeros(nMesurements,1);
ass = 1;
dt = 1;
for alpha = minAngle : displacement : maxAngle
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
    step = 1;
    while(true)
        ant.pathDirection = ant.location-ant.prevLocation;
        ground = ant.releasePheromone(ground);
        if ant.carryingFood
            break;
        elseif norm(ant.location-nodeLocation) == 0
            target = foodSourceLocation;
        end
        ant = ant.stepStraightTo(target,dt);
        if ground.isLocationAtFoodSource(ant.location)
            ant.carryingFood = 1;        
        end
        ant = ant.updateGlobalVector(dt);
        ground.ants(1) = ant;
        step = step+1;
    end
    xs(ass) = rad2deg(alpha);
    ys(ass) = rad2deg(abs(vector2angle(ant.globalVector)-vector2angle(nestLocation -foodSourceLocation)));
    ass = ass + 1;
end
plot(xs,ys,'b-o');
title('Error Against Angle');
xlabel('Angle In Degrees');
ylabel('Absolute Error in Degrees');
end