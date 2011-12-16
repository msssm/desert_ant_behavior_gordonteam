-- Ant.random_walk_step(dt)
random_walk_step(ground,dt)
	do
		-- velocity is the velocity vector of the current Ant
		-- ground is the ground the Ant is currently in
		distance_vector := ground.nestLocation-location
		-- See the implementation section for an
		-- explanation of the constant variable
		distance_norm = norm(distance_vector)/constant
		weighted_vector := velocity/(distance_norm) + distance_vector*distance_norm
		weighted_angle = vector2angle(weighted_vector)
		new_angle = normrnd(weighted_angle, 0.5)
		y_velocity = sin(angle)
		x_velocity = cos(angle)
		velocity := [x_velocity; y_velocity]
		-- Knowing the new velocity direction and
		-- the time step dt, update the Ant's location
		updateLocation(dt);
	end