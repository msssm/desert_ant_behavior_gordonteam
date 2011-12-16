%-- Projects a point on a line passing in p0 and p1 --%
%-----------------------------------------------------%
function p = projectPointOnLine(q,p0,p1)
A = double([p1(1)-p0(1) p1(2)-p0(2);
     p0(2)-p1(2) p1(1)-p0(1)]);
b = double([q(1)*(p1(1)-p0(1))+q(2)*(p1(2)-p0(2));
     p0(2)*(p1(1)-p0(1))-p0(1)*(p1(2)-p0(2))]);
p = A\b;
end