function LSSmodelFileConfig = get_LSS_model_file_config 
% This configuration contains info about the MAPS linear model file format.
% It contains information about the layout of *.maps linear model files. In
% particular, it details the file keyword for each model component. In 
% addition, it details the file layout of information under each of the
% components. It also details whether the particular model component is
% compulsory and which of the components in the file layout are compulsory.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> LSSmodelFileConfig: a 4-column string cell array detailing the
%      configuration of MAPS linear model files
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The output cell array has as many rows as there are model file
%      components.
%   -> It has four columns containing the following information:
%       - model file keyword for the object (eg. METADATA)
%       - compulsory flag for that object ('compulsory', 'optional')
%       - structure of and MAPS names for the info under that object
%       - compulsory flags for each of those bits of info
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS linear 
%      model files.
%
% This version: 29/01/2013
% Author(s): Matt Waldron & Kate Reinold

%% LIST LINEAR MODEL FILE CONFIGURATION
% Define the configuration information about each compoenent of MAPS linear
% state space model files.
LSSmodelFileConfig = {
    'METADATA'                                      'compulsory'    'metadataFields:metadataDescriptors'            'compulsory:compulsory'
    'MODEL VARIABLES'                               'compulsory'    'xNames:xMnems'                                 'compulsory:compulsory'
    'SHOCKS'                                        'compulsory'    'zNames:zMnems'                                 'compulsory:compulsory'
    'MODEL OBSERVABLES'                             'optional'      'Ynames:Ymnems:YtildeTransformations'           'compulsory:compulsory:optional'
    'MEASUREMENT ERRORS'                            'optional'      'wNames:wMnems'                                 'compulsory:compulsory'
    'RAW OBSERVABLES'                               'optional'      'YtildeNames:YtildeMnems'                       'compulsory:compulsory'
    'TIME VARYING TRENDS'                           'optional'      'etatNames:etatMnems'                           'compulsory:compulsory'
    'PARAMETERS'                                    'compulsory'    'thetaNames:thetaMnems:theta'                   'compulsory:compulsory:compulsory'
    'MODEL EQUATIONS'                               'compulsory'    'xEqNames:xEqStrs'                              'compulsory:compulsory'
    'MEASUREMENT EQUATIONS'                         'optional'      'YeqNames:YeqStrs'                              'compulsory:compulsory'
    'STEADY STATES & PARAMETER TRANSFORMATIONS'     'optional'      'ssNames:ssMnems:ssDefs'                        'compulsory:compulsory:compulsory'
    };

end