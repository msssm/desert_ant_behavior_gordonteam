function twoArmGlobalVectorAnimation(alpha,lengthArm1,lengthArm2,dt,printFlag)
if nargin == 0
    alpha = deg2rad(-45);
    lengthArm1 = 5;
    lengthArm2 = 3;
    dt = 5;
    printFlag = false;
end

nestLocation = [0;0];
nodeLocation = [0;lengthArm1];
foodSourceLocation = nodeLocation + [lengthArm2*cos(alpha);lenghtArm2*sin(alpha)];

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
ground.ants = ant;

while(ground.ants(1).phi ~= 0 || ground.ants(1).l ~= 0)

end