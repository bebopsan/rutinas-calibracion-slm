
function [phaseShifts, background, modulation] = AIAStep2(phase, phaseShifts,fringesVector)

nPhaseShifts = length(phaseShifts);
nPixels = size(fringesVector,1);
A = zeros(3,3);
B = zeros(nPhaseShifts,3);

A(1,1) = nPixels;
A(1,2) = sum(cos(phase));
A(1,3) = sum(sin(phase));
A(2,1) = A(1,2);
A(2,2) = sum(cos(phase) .^ 2);
A(2,3) = sum(cos(phase) .* sin(phase));
A(3,1) = A(1,3);
A(3,2) = A(2,3);
A(3,3) = sum(sin(phase) .^ 2);

B(:,1) = sum(fringesVector,1);
B(:,2) = sum(fringesVector .* repmat(cos(phase), [1 nPhaseShifts]),1);
B(:,3) = sum(fringesVector .* repmat(sin(phase), [1 nPhaseShifts]),1);

AI = inv(A);
B = B';

X = AI* B;

background = X(1,:);
bj = X(2,:);
cj = X(3,:);

%phaseShifts = (bj==0&(cj>=0)) .* (pi/2) + (bj==0&(cj<0)) .* (-pi/2) + (bj~=0) .* atan2(cj,bj);

phaseShifts = atan2(-cj, bj);
modulation = sqrt(bj .^ 2 + cj .^ 2);

end   
