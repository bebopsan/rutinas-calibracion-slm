%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate the wrapped phase using as image the fringesVector matrix,
% and a vector with the phase shift among images
%
% 
% INPUT PARAMETERS:
%   fringesVector = inteferograms set as a vector
%   initialGuess = First approximation to find the phase shift among images
%   max_iterations = maximun number of iterations
%   precision = convergence parameter

%
% OUTPUT PARAMETERS
%   wrapped_phase = Phase modulo 2Pi
%   phaseShiftVector = Vector with the phase shift amog images
%   backgroundImage = Global background of the images 
%   modulationImage = Global modulation of the images
%   backgroundVector = Mean intensity of each image expressed as a constant
%   modulationVector = Amplitude modulation of each image expressed as a constant
%   phaseShiftVectorHistory = phaseShiftVector iteration by iteration
%
% REFERENCES: 
%   [1] Wang, Z. Y., Han, B. T., "Advanced iterative algorithm for phase
%       extraction of randomly phase-shifted interferograms," 
%       Opt Letters 29(14), 1671-1673. (2004).
% 
%
%   Matlab version Rene Restrepo
%   Octave version Nestor Uribe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [wrappedPhase, phaseShiftVector, backgroundImage, modulationImage, backgroundVector, modulationVector, phaseShiftVectorHistory] = GetPhaseAdvancedIterativeAlgorithm(fringesVector, initialGuess, maxIterations, precision)
    
  nImages = size(fringesVector,2);
  disp(nImages)
  disp(size(initialGuess))
  phaseShiftVector = initialGuess;
  ep = precision;
  
  disp('Finding random phase shifts...')
  disp(sprintf('Error target: %e', ep))
  a = 1;
  
while (a <= maxIterations)
    disp(sprintf('Iteration %d', a))
    %    oldPhaseShiftsVector = phaseShiftVector(a - 1, :);
    a=a+1;
    [wrappedPhase, backgroundImage, modulationImage] = AIAStep1(phaseShiftVector(a - 1, :), fringesVector);
    [phaseShiftVector(a, :), backgroundVector, modulationVector] = AIAStep2(wrappedPhase, phaseShiftVector(a - 1, :), fringesVector);
    
    %   Calculates the error until a stopping criterion is satisfy or exceeded
    %   the number of iterations set
    
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
      disp(sprintf('Phase shift error: %e', phaseShiftError))
    end
    
end
  phaseShiftVectorHistory = phaseShiftVector;
  phaseShiftVectorHistory = mod(phaseShiftVectorHistory - phaseShiftVectorHistory(:, ones(nImages, 1)), 2 * pi); % Making final phase value of first image equal 0
  phaseShiftVector = phaseShiftVectorHistory(end, :);
  end