classdef Ground
    properties
        nestLocation
        foodSourceLocation
        pheromoneParticles
        ants
        landmarks
    end
    
    methods
        
        function inRangeParticles = getParticlesInRange(this,ant)
            % Allocate enough space far the particles that could be
            % in range. Then remove the space not used. This approach
            % allocates the array just 2 times instead of *the number of
            % particles in range*.
            inRangeParticles = PheromoneParticle([1 length(this.pheromoneParticles)]);
            j = 1;
            for i = 1 : length(this.pheromoneParticles)
                ph = this.pheromoneParticles(i);
                if norm(ph.location - ant.location) <= ...
                   ant.viewRange
                    inRangeParticles(j) = ph;
                    j = j+1;
                end
            end
            inRangeParticles = inRangeParticles(1:j-1);
        end
        
        function inRangeLandmarks = getLandmarksInRange(this,ant)
            % Allocate enough space far the landmarks that could be
            % in range. Then remove the space not used. This approach
            % allocates the array just 2 times instead of *the number of
            % landmarks in range*.
            inRangeLandmarks = zeros(size(this.landmarks));
            j = 1;
            for i = 1 : size(this.landmarks,2)
                lm = this.landmarks(:,i);
                if norm(lm - ant.location) <= ...
                   ant.viewRange
                    inRangeLandmarks(:,j) = lm;
                    j = j+1;
                end
            end
            inRangeLandmarks = inRangeLandmarks(:,1:j-1);
        end
        
        function [bool particle i] = hasPheromoneInLocation(this,locationPart)
            bool = false;
            particle = PheromoneParticle();
            particle.intensity = 0;
            for i = 1 : length(this.pheromoneParticles)
                ph = this.pheromoneParticles(i);
                if norm(ph.location - locationPart) == 0
                    bool = true;
                    particle = ph;
                    return
                end
            end
            i = 0;
        end
        
        function bool = isLocationAtNest(this,loc)
            if norm(this.nestLocation-loc) == 0
                bool = true;
            else
                bool = false;
            end
        end
        
        function bool = isLocationAtFoodSource(this,loc)
            bool = false;
            for i = 1 : size(this.foodSourceLocation,2)
                if norm(this.foodSourceLocation(:,i)-loc) == 0
                    bool = true;
                    return;
                end
            end
        end
    end
end