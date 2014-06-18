
function [phase, background, modulation] = AIAStep1(phaseShifts, fringesVector)

nPhaseShifts = length(phaseShifts);
nPixels = size(fringesVector,1);
A = zeros(3,3);
B = [zeros(nPixels,1) zeros(nPixels,1) zeros(nPixels,1)];

A(1,1) = nPhaseShifts;
A(1,2) = sum(cos(phaseShifts));
A(1,3) = sum(sin(phaseShifts));
A(2,1) = A(1,2);
A(2,2) = sum(cos(phaseShifts) .^ 2);
A(2,3) = sum(cos(phaseShifts) .* sin(phaseShifts));
A(3,1) = A(1,3);
A(3,2) = A(2,3);
A(3,3) = sum(sin(phaseShifts) .^ 2);

B(:,1) = sum(fringesVector,2);
B(:,2) = sum(fringesVector .* repmat(cos(phaseShifts), [nPixels 1]),2);
B(:,3) = sum(fringesVector .* repmat(sin(phaseShifts), [nPixels 1]),2);

AI = inv(A);

% We ommit transposing B because we do the matrix multiplication by hand
background = AI(1,1) * B(:,1)+AI(1,2) * B(:,2)+AI(1,3) * B(:,3);
bj = AI(2,1) * B(:,1)+AI(2,2) * B(:,2)+AI(2,3) * B(:,3);
cj = AI(3,1) * B(:,1)+AI(3,2) * B(:,2)+AI(3,3) * B(:,3);


%phase = (bj == 0 &(cj >= 0)) .* (pi/2)+(bj == 0&(cj<0)) .* (-pi/2)+(bj ~= 0) .* atan2(cj,bj);

phase = atan2(-cj, bj);
modulation = sqrt(bj .^ 2 + cj .^ 2);

end
