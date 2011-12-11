function startTraining(nAnts,nestLocation,foodSourceLocation,dt,steps)
if nargin == 0
    nAnts = 1;
    nestLocation = zeros(2,1);
    foodSourceLocation = [7.5;7.5];
    dt = 0.1;
    steps = 40;
end

ground = Ground;
ground.nestLocation = nestLocation;
nestPh = PheromoneParticle();
nestPh.location = nestLocation;
nestPh.intensity = 0;
nestPh = nestPh.setPrev(nestPh);
ground.pheromoneParticles = nestPh;
ground.foodSourceLocation = foodSourceLocation;
ants = Ant(zeros(nAnts,1));
for i = 1 : length(ants)
    ant = Ant;
    ant = ant.setUp(ground);
    ants(i) = ant;
end
ground.ants = ants;
disp('Put landmarks!');
for i = 1 : steps
    for j = 1 : length(ground.ants)
        [a g] = ground.ants(j).performCompleteStep(ground);
        ground = g;
        ground.ants(j) = a;
    end
    ground.updateGround(i);
end