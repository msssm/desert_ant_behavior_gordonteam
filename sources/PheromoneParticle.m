classdef PheromoneParticle
    properties
        intensity
        location
        disappearTime = 2;
        next
        prev
    end
    
    methods
        % Needed to preallocate an array of ants.
        function particleArr = PheromoneParticle(F)
            if nargin ~= 0 % Allow nargin == 0 syntax.
                m = size(F,1);
                n = size(F,2);
                particleArr(m,n) = PheromoneParticle; % Preallocate object array.
            end
        end
        
        function this = setPrev(this,prevPart)
            this.prev = prevPart;
        end
        
        function this = setNext(this,nextPart)
            this.next = nextPart;
        end
        
        function bool = isParticleInRange(this,ant)
            if isempty(this.location)
                bool = 0;
            elseif norm(this.location-ant.location) <= ant.viewRange && ...
                this.intensity >= ant.pheromoneIntensityToFollow
                bool = 1;
            else
                bool = 0;
            end
            bool = logical(bool);
        end
        
        % Tells if a particle is at the same location as the passed arg.
        function bool = isParticleAtSameLocation(this,particle)
            if isempty(this.location) || norm(this.location - particle.location) == 0
                bool = 0;
            else
                bool = 1;
            end
            bool = logical(bool);
        end
        
        % Merges 2 particles at same location.
        function [this particle] = mergeWhithParticle(this,particle)
            this.intensity = this.intensity + particle.intensity;
        end
        
        % The pheromone intensity has to decay. This method handle this
        % behaviour. tc is the decay constant: smaller it is, faster the
        % particles decay.
        function this = decay(this,dt)
            tc = -log(0.5)/20*this.decayTime*60;
            this.intensity = this.intensity*exp((log(1/2)/tc)*dt);
        end
    end
end