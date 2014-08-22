function [wrappedPhase, phaseShiftVector, backgroundImage, modulationImage, backgroundVector, modulationVector, phaseShiftVectorHistory] = GetPhaseAIA_fromShifts(fringesVector, initialGuess, maxIterations, precision)
  %% Calculate the wrapped phase using as image the fringesVector matrix.
  
  nImages = size(fringesVector,2);
  disp(nImages)
  disp(size(initialGuess))
  phaseShiftVector = initialGuess;
  ep = precision;
  
  disp('Finding random phase shifts...')
  disp(sprintf('Error target: %e', ep))
  a = 1;
  
while (a <= maxIterations)
    %disp(sprintf('Iteration %d', a))
    %%    oldPhaseShiftsVector = phaseShiftVector(a - 1, :);
    a=a+1;
    [wrappedPhase, backgroundImage, modulationImage] = AIAStep1(phaseShiftVector(a - 1, :), fringesVector);
    [phaseShiftVector(a, :), backgroundVector, modulationVector] = AIAStep2(wrappedPhase, phaseShiftVector(a - 1, :), fringesVector);
    
    if and(a ~= 1,a < maxIterations)
            for l = 2:nImages
            phaseShiftError(l) = ...
            abs(mod(phaseShiftVector(a, l) - phaseShiftVector(a, 1), 2 * pi) -...
            mod(phaseShiftVector(a - 1, l) - phaseShiftVector(a - 1, 1), 2 * pi));
                 if(mean(phaseShiftError) < ep)
                    a=maxIterations+1;
                    break
                 end
             end 
      %disp(sprintf('Phase shift error: %e', phaseShiftError))
    end
    
end
  phaseShiftVectorHistory = phaseShiftVector;
  phaseShiftVectorHistory = mod(phaseShiftVectorHistory - phaseShiftVectorHistory(:, ones(nImages, 1)), 2 * pi); % Making final phase value of first image equal 0
  phaseShiftVector = phaseShiftVectorHistory(end, :);
  end