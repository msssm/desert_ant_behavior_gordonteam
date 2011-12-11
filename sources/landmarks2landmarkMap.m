% LandmarkVector should be a 2xn vector
function landmarkMap = landmarks2landmarkMap(landmarksVector)
rows = landmarksVector(1,:);
cols = landmarksVector(2,:);
rMin = min(rows);
rMax = max(rows);
cMin = min(cols);
cMax = max(cols);
landmarkMap = zeros(rMax-rMin,cMax-cMin);
for i = 1 : size(landmarksVector,2)
    landmark = landmarksVector(i,:);
    % +1 since the matrix indices start from 1
    landmarkMap(landmark(1)-rMin+1,landmark(2)-cMin+1) = 1;
end
end