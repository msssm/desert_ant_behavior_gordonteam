function randomWalkTest
start = [0;0];
xs = zeros(100,1);
ys = xs;
for i = 1 : 100
    v = rand(2,1);
    location = [0;0];
    maxNorm = 0;
    for j = 1 : 10+i*20
        nd = start-location;
        if norm(nd)>maxNorm
            maxNorm = norm(nd);
        end
        d = norm(nd)/i;
        weightedVector = v./(d+0.00001)+nd.*d;
        weightedVector = weightedVector./norm(weightedVector);
        weightedAngle = vector2angle(weightedVector);
        angle = normrnd(weightedAngle,0.5); % choose an angle, with normal distr.
        yPart = sin(angle);
        xPart = cos(angle);
        v = [xPart;yPart];
        location = location + [xPart;yPart];
    end
    xs(i) = i;
    ys(i) = maxNorm;
end
plot(xs,ys);
title('Constant agains distance from nest');
xlabel('constant');
ylabel('distance [m]');
end