function angle = vector2angle(v)
angle = atan(v(2)/v(1));
if v(1) < 0
    angle = angle+pi;
end
end