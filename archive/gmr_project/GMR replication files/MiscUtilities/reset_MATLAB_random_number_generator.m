function reset_MATLAB_random_number_generator()
% This function resets the MATLAB random number generator.
% 
% INPUTS:
%   -> none
%
% OUTPUTS:
%   ->  none (resets the MATLAB random number generator's state)
%
% DETAILS:
%   -> This function resets the MATLAB random number generator's state to
%      the original one (i.e. that which prevails on creation of a MATLAB
%      instance).
%
% NOTES:
%   -> This function is useful as a helper for any MAPS functions that
%      rely on random number generation (eg posterior simulation, sampling
%      from priors, stochastic sims etc).
%
% This version: 09/01/2014
% Author(s): Matt Waldron

%% RESET SEED
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);

end