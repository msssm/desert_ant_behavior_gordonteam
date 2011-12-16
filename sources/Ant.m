classdef Ant
    properties
        prevLocation % Needed to link pheromone particles
        location % Position in absolute coordinates.
        velocityVector % Vector composed from Vr Vc Vk.
        carryingFood % Bool
        followingPheromonePath % Bool
        goingToNestDirectly % Bool
        landmarkRecognized % Bool
        viewRange % How far an ants can "see"
        pheromoneIntensityToFollow % From which intensity value the ant
                                   % starts to follow a pheromone path
        limitSearchDistance % After what distance from a landmark pattern
                            % stop to search.
        pheromoneIntensity % How intense is the pheromone particle released
        problemEncountered % String containing the type of problem
                          % encountered. Empty string means
                          % no problem encountered.
        pointNearbyToSearch % Encountered a problem, try to solve it near
                            % the theoretical right position.
        timeToSpendInSearch % Encountered a problem, how much waste time
                            % focus the search near the theoretical right
                            % position.
        confidenceRegion % Encountered a problem, how much go far to search.
        globalVector % Vector pointing directly to the nest
        phi % Part to implement the "global vector" in a more
            % realistic way. phi represent an angle.
        l   % The second part needed for what is described above.
            % l represent the total length walked till now.
        pathDirection % Third part. This is the direction in which
                      % the ants was walking, in absolute coordinates.
        storedLandmarksMap % A map from a landmark pattern to a 
                           % local angle to follow.
        lookingFor % String witch says what the ant is looking for.
    end
    
    %-- NOTE: the non static methods requires always an argument.
    %-- This is because matlab passes secretely the istance on which
    %-- the method is called as an argument.
    %-- Thus the method looks like this: function my_method(this)
    %-- and the call to the method is: obj.my_method()
    methods
        
        % Needed to preallocate an array of ants.
        function antsArr = Ant(F)
            if nargin ~= 0 % Allow nargin == 0 syntax.
                m = size(F,1);
                n = size(F,2);
                antsArr(m,n) = Ant; % Preallocate object array.
            end
        end
        
        % Main behaviour, simply call this at each step.
        % It does all the things an ant should do automatically.
        function [this ground] = performCompleteStep(this,ground,dt)
            % normalize the velocity vector
            v = this.velocityVector(1:2);
            v = v./norm(v);
            this.velocityVector(1:2) = v;
            % end
            this.pathDirection = this.location-this.prevLocation;
            ground = this.releasePheromone(ground);
            if ~isempty(this.problemEncountered)
                this = this.problemHandler(ground,dt);
            elseif ~isempty(this.lookingFor)
                if norm(this.location-ground.nestLocation) == 0 && ...
                   strcmp(this.lookingFor,'nest')
                    this.lookingFor = '';
                    return;
                elseif norm(this.location-ground.foodSourceLocation) == 0 && ...
                       strcmp(this.lookingFor,'food')
                    this.lookingFor = '';
                    return;
                end
                this = this.lookForSomething(ground,dt);
            else
                if ground.isLocationAtNest(this.location)
                    this.carryingFood = 0;
                    this.followingPheromonePath = 1;
                    this = this.stepBack;
                elseif ground.isLocationAtFoodSource(this.location)
                    this.carryingFood = 1;
                    this.goingToNestDirectly = true;
                    this.lookingFor = 'nest';
                    this = this.backToNestDirectly(ground,dt);
                elseif this.followingPheromonePath
                    this = this.followPheromonePath(ground);
                end
            end
            this = this.updateGlobalVector(dt);     
        end
        
        % This method update the location of the ant using velocity vector
        % information
        function this = updateLocation(this,dt)
            v = this.velocityVector(1:2);
            theta = vector2angle(v);
            yPart = sin(theta)*this.velocityVector(3)*dt;
            xPart = cos(theta)*this.velocityVector(3)*dt;
            this.prevLocation = this.location;
            this.location = this.location + [xPart;yPart];
        end
        
        % This method performs a single step in the random walk of an ant.
        function this = randomWalkStep(this,ground,dt)
            v = this.velocityVector(1:2);
            nd = ground.nestLocation-this.location;
            d = norm(nd)/50;
            weightedVector = v./(d+0.00001)+nd.*d;
            weightedVector = weightedVector./norm(weightedVector);
            weightedAngle = vector2angle(weightedVector);
            angle = normrnd(weightedAngle,0.1*dt); % choose an angle, with normal distr.
            yPart = sin(angle);
            xPart = cos(angle);
            this.velocityVector(1:2) = [xPart;yPart];
            this = this.updateLocation(dt);
        end
        
        % This method makes the ant do a step directly straight to some
        % point. If the target is in range, it stops there.
        function this = stepStraightTo(this,point,dt)
            v = point - this.location;
            if norm(v) < this.velocityVector(3)*dt
                this.prevLocation = this.location;
                this.location = point;
            else
                this.velocityVector(1:2) = v;
                this = this.updateLocation(dt);
            end
        end
        
        function this = followPheromonePath(this,ground,dt)
            [bool particle] = ground.hasPheromoneInLocation(this.location);
            if bool
                if this.carryingFood
                    this.prevLocation = this.location;
                    this.location = particle.next.location;
                else
                    this.prevLocation = this.location;
                    this.location = particle.prev.location;
                end
            else
                this = this.randomWalkStep(ground,dt);
            end
        end
        
        % This method makes the ant go back to its previous position
        function this = stepBack(this)
            aux = this.location;
            this.location = this.prevLocation;
            this.prevLocation = aux;
        end
        
        % This method release pheromone on the ground, in the current and
        % position.
        function ground = releasePheromone(this,ground)
            pheromoneParticle = PheromoneParticle;
            pheromoneParticle.location = this.location;
            if this.carryingFood || this.followingPheromonePath
                pheromoneParticle.intensity = this.pheromoneIntensity+100;
            else
                pheromoneParticle.intensity = this.pheromoneIntensity;
            end
            arr = ground.pheromoneParticles; % arr just to abbreviate next line
            [bool prevParticle positionInArray] = ground.hasPheromoneInLocation(pheromoneParticle.location);
            if bool
                newPheromoneParticle = ...
                    arr(positionInArray).mergeWhithParticle(pheromoneParticle);
                clear pheromoneParticle;
                arr(positionInArray) = newPheromoneParticle;
                ground.pheromoneParticles = arr;
            else
                [bool prevParticle positionInArray] = ground.hasPheromoneInLocation(this.prevLocation);
                prevParticle = prevParticle.setNext(pheromoneParticle);
                pheromoneParticle = pheromoneParticle.setPrev(prevParticle);
                arr(positionInArray) = prevParticle;
                ground.pheromoneParticles = [arr;pheromoneParticle];
            end
        end
        
        % This method updates the global vector after the ant moved.
        function this = updateGlobalVector(this,dt)
            v = this.location-this.prevLocation;
            currentL = norm(v);
            % Implementation using the global vector variable
            %this.globalVector = this.globalVector-v; 
            
            % Implementation using a more realist model
            oldDir = this.pathDirection;
            % Needed by the first step
            if isnan(vector2angle(oldDir))
                delta = 0;
            else
                delta = vector2angle(v)-vector2angle(oldDir);
            end
            %this.phi = (this.l*this.phi+delta+this.phi*currentL)/(this.l+currentL);
            if this.l ~= 0
                this.phi = this.phi+4e-2*(pi+delta)*(pi-delta)*delta/this.l;
            end
            this.l = this.l + currentL - delta/pi*2*currentL;
            if ~this.goingToNestDirectly
                this.globalVector = -[cos(this.phi) -sin(this.phi);
                                 sin(this.phi) cos(this.phi)]*v;
            end
        end
        
        % This method tries to recognize a landmark, checking in the
        % lanmark array.
        function this = recognizeLandmark(this,landmarks,ground,dt)
            this.landmarkRecognized = true;
            if size(landmarks,2) < 2
                this = this.stepStraightTo(landmarks(:,1)+[0.2;0.2],dt);
            elseif size(landmarks,2) < 4
                if size(landmarks,2) == 3
                    candidate = 1;
                    if norm(this.location-landmarks(:,candidate)) < norm(this.location-landmarks(:,2))
                        candidate = 2;
                    end
                    if norm(this.location-landmarks(:,candidate)) < norm(this.location-landmarks(:,3))
                        candidate = 3;
                    end
                    landmarks(:,candidate) = [];
                end
                midPoint = sum(landmarks,2)./2;
                if norm(this.location-midPoint) < 0.3
                    [landmarkAngle length confidence] = this.storedLandmarksMap.get('2');
                    absoluteAngle = mod(vector2angle(landmarks(:,1)-landmarks(:,2)),pi)+pi/2+landmarkAngle;
                    vec = [cos(absoluteAngle);sin(absoluteAngle)].*length;
                    % Choose the direction to take passing through a landmark pattern
                    p = projectPointOnLine(this.location,landmarks(:,1),landmarks(:,2));
                    if p(2) < this.location(2)
                        if norm(this.location-(midPoint-vec)) <= this.viewRange && ...
                           norm((midPoint)-vec-ground.nestLocation) ~=0
                            this.problemEncountered = 'nestNotFound';
                            this.pointNearbyToSearch = (midPoint-vec);
                            this.timeToSpendInSearch = confidence;
                            this.confidenceRegion = sqrt(length);
                            this = this.problemHandler(ground,dt);
                            return;
                        end
                        this = this.stepStraightTo(midPoint-vec,dt);
                    else
                        if norm(this.location-(midPoint-vec)) <= this.viewRange && ...
                           norm((midPoint)-vec-ground.nestLocation) ~=0
                            this.problemEncountered = 'nestNotFound';
                            this.pointNearbyToSearch = (midPoint+vec);
                            this.timeToSpendInSearch = confidence;
                            this.confidenceRegion = sqrt(length);
                            this = this.problemHandler(ground,dt);
                            return;
                        end
                        this = this.stepStraightTo(midPoint+vec,dt);
                    end
                else
                    this = this.stepStraightTo(midPoint,dt);
                end 
            elseif size(landmarks,2) == 4
                midPoint = sum(landmarks(:,1:2),2)./2;
                midPoint = midPoint + sum(landmarks(:,3:4),2)./2;
                midPoint = midPoint./2;
                if norm(this.location-midPoint) < 0.5
                    [landmarkAngle length confidence] = this.storedLandmarksMap.get('4');
                    absoluteAngle = mod(vector2angle(landmarks(:,1)-landmarks(:,2)),pi)+pi/2+landmarkAngle;
                    vec = [cos(absoluteAngle);sin(absoluteAngle)].*length;
                    % Choose the direction to take passing through a landmark pattern
                    p = projectPointOnLine(this.location,landmarks(:,1),landmarks(:,2));
                    if p(2) < this.location(2)
                        if norm(this.location-(midPoint-vec)) <= this.viewRange && ...
                           norm((midPoint)-vec-ground.nestLocation) ~=0
                            this.problemEncountered = 'nestNotFound';
                            this.pointNearbyToSearch = (midPoint-vec);
                            this.timeToSpendInSearch = confidence;
                            this.confidenceRegion = sqrt(length);
                            this = this.problemHandler(ground,dt);
                            return;
                        end
                        this = this.stepStraightTo(midPoint-vec,dt);
                    else
                        if norm(this.location-(midPoint-vec)) <= this.viewRange && ...
                           norm((midPoint)-vec-ground.nestLocation) ~=0
                            this.problemEncountered = 'nestNotFound';
                            this.pointNearbyToSearch = (midPoint+vec);
                            this.timeToSpendInSearch = confidence;
                            this.confidenceRegion = sqrt(length);
                            this = this.problemHandler(ground,dt);
                            return;
                        end
                        this = this.stepStraightTo(midPoint+vec,dt);
                    end
                else
                    this = this.stepStraightTo(midPoint,dt);
                end
            end
        end
        
        % This method makes the ant go back to the nest directly using the
        % global vector.
        function this = backToNestDirectly(this,ground,dt)
            if norm(this.globalVector) < 1e-6 && ...
               norm(this.location-ground.nestLocation) > 1e-6
                this.goingToNestDirectly = false;
                this.problemEncountered = 'nestNotFound';
                this.pointNearbyToSearch = this.location;
                this.timeToSpendInSearch = inf;
                this.confidenceRegion = 5/dt;
                return;
            end
            if norm(this.globalVector) < this.velocityVector(3)*dt
                target = this.location+this.globalVector;
                this = this.stepStraightTo(target,dt);
            else
                this.velocityVector(1:2) = this.globalVector;
                this = this.updateLocation(dt);
            end
            
        end
        
        % This method look for something. What is looked for is stored in
        % the "lookingFor" variable. Basically it performs a randomWalkStep
        % if the ant can't see what is looking for, else it changes
        % behaviour of the ant. The three options are 'food' or 'nest'.
        function this = lookForSomething(this,ground,dt)
            if strcmp(this.lookingFor,'food')
                if norm(ground.foodSourceLocation-this.location) < this.viewRange
                    this = this.stepStraightTo(ground.foodSourceLocation,dt);
                else
                     % also if the ant can't see the food source, maybe
                     % the ant can see a strong pheromone path
                     auxParts = ground.getParticlesInRange(this);
                     for i = 1 : length(auxParts)
                        if norm(auxParts(i).location-ground.nestLocation)~=0 && ...
                           auxParts(i).intensity >= this.pheromoneIntensityToFollow
                            this = this.stepStraightTo(auxParts(i).location,dt);
                            return;
                        end
                     end
                     this = this.randomWalkStep(ground,dt);
                end
            elseif strcmp(this.lookingFor,'nest')
                if ground.isLocationAtNest(this.location)
                    this.lookingFor = '';
                    return;
                elseif norm(ground.nestLocation-this.location) < this.viewRange
                    this = this.stepStraightTo(ground.nestLocation,dt);
                elseif this.goingToNestDirectly
                    this = this.backToNestDirectly(ground,dt);
                else
                    % also if the ant can't see the nest, maybe
                    % the ant can see a familiar landmark pattern
                    auxLandmarks = ground.getLandmarksInRange(this);
                    if size(auxLandmarks,2) > 0
                        this.landmarkRecognized = true;
                        this = this.recognizeLandmark(auxLandmarks,ground,dt);
                        return;
                    else
                        this.landmarkRecognized = false;
                    end
                    if ~isempty(this.problemEncountered)
                        this = this.problemHandler(ground,dt);
                    else
                        this = this.randomWalkStep(ground,dt);
                    end
                end
            end
        end
        
        % This method is a problem handler. If one of the other methods
        % encounters a problem, it would pass the problem to this problem
        % handler.
        function this = problemHandler(this,ground,dt)
            if strcmp(this.problemEncountered,'nestNotFound')
                if norm(ground.nestLocation-this.location) <= this.viewRange || ...
                   this.timeToSpendInSearch <= 0
                    this.problemEncountered = '';
                    this.goingToNestDirectly = true;
                else
                    % Random walk with constraints
                    v = this.velocityVector(1:2);
                    nd = this.pointNearbyToSearch-this.location;
                    d = norm(nd)/(this.confidenceRegion+0.3);
                    weightedVector = v./(d+0.00001)+nd.*d;
                    weightedVector = weightedVector./norm(weightedVector);
                    weightedAngle = vector2angle(weightedVector);
                    angle = normrnd(weightedAngle,0.5); % choose an angle, with normal distr.
                    yPart = sin(angle);
                    xPart = cos(angle);
                    this.velocityVector(1:2) = [xPart;yPart];
                    this = this.updateLocation(dt);
                    % end random walk
                    this.timeToSpendInSearch = this.timeToSpendInSearch-dt;
                end
            end
        end
        
        % Build an ant
        function this = setUp(this,ground)
            v = ([rand;rand]).*2-1;
            v = v./norm(v);
            v = [v;0.125];
            this.velocityVector = v;
            this.carryingFood = 0;
            this.followingPheromonePath = 0;
            this.landmarkRecognized = false;
            this.viewRange = 2;
            this.pheromoneIntensity = 50;
            this.problemEncountered = '';
            this.globalVector = [0;0];
            this.storedLandmarksMap = [];
            this.lookingFor = 'food';
            this.prevLocation = nan;
            this.location = ground.nestLocation;
            this.pheromoneIntensityToFollow = 300;
            this.phi = 0;
            this.l = 0;
            this.pathDirection = [0;0];
            this.goingToNestDirectly = false;
            this.storedLandmarksMap = Hashtable;
        end
        
    end
end




