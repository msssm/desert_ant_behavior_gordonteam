function pheromoneAnimation(nAnts,nestLocation,foodSourceLocation,dt,steps,printFlag)
if nargin == 0
    nAnts = 4;
    nestLocation = zeros(2,1);
    foodSourceLocation = [7;7];
    dt = 5;
    steps = 500;
    printFlag = true;
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
for i = 1 : steps
    for j = 1 : length(ground.ants)
        [a g] = ground.ants(j).performCompleteStep(ground,dt);
        ground = g;
        ground.ants(j) = a;
    end
    cla;
    hold on;
    axis([-15 15 -15 15]);
    title('Pheromone-based orientation');
    xlabel('length [m]');
    ylabel('length [m]');
    ground = updateGround(ground,i,dt,printFlag);
    
    drawnow;
end
