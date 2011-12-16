function [r g b] = intensity2color(intensity)
intensity = 255*5-min(intensity,255*5);
if intensity <= 255
    r = 255;
    g = 0;
    b = 0;
elseif intensity <= 255*2
    r = 255;
    g = intensity-255;
    b = 0;
elseif intensity <= 255*3
    r = 255-(intensity-255*2);
    g = 255;
    b = 0;
elseif intensity <= 255*4
    r = 0;
    g = 255;
    b = intensity-255*3;
else
    r = 0;
    g = 255-(intensity-255*4);
    b = 255;
end
r = r/255;
g = g/255;
b = b/255;
end