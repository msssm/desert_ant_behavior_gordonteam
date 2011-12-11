classdef Ground
    properties
        grid
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
        
        function updateGround(this,currentStep)
            close all;
            hold on;
            axis([-15 15 -15 15]);
            
            % Update the pheromone pixels
            for i = 1 : length(this.pheromoneParticles)
                phPart = this.pheromoneParticles(i);
                [r g b] = intensity2color(min(phPart.intensity,...
                                            phPart.prev.intensity));
                if ~isempty(this.pheromoneParticles(i).prev.location)
                    plot([phPart.prev.location(1) phPart.location(1)],...
                         [phPart.prev.location(2) phPart.location(2)],...
                         'color',[r g b]);
                end
            end
            
            % Update the ants pixels
            for i = 1 : length(this.ants)
                plot(this.ants(i).prevLocation(1),this.ants(i).prevLocation(2),'ko');
            end
            
            % Update the landmark pixels
            for i = 1 : length(this.landmarks)
                plot(this.landmarks(i).location(1),this.landmarks(i).location(2),'bo');
            end
            
            % Update the nest pixels
            plot(this.nestLocation(1),this.nestLocation(2),'ro');
            
            % Update the food source pixels
            plot(this.foodSourceLocation(1),this.foodSourceLocation(2),'go');
            
            print(strcat('trainingResults/currentResult/training_',...
                    int2str(currentStep),'.png'),...
                  '-dpng');
            
        end
    end
end