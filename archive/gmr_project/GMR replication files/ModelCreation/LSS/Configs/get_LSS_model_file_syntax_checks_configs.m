function [metadataSyntaxChecksConfig,LSSmodelSyntaxChecksConfig] = ...
    get_LSS_model_file_syntax_checks_configs
% This config contains info about syntax checks for LSS model files.
% It details all checks and configurations for those checks on MAPS linear
% state space (LSS) model files.
%
% INPUTS:
%   -> none
%
% OUTPUTS:
%   -> metadataSyntaxChecksConfig: configuration for shared metadata syntax
%      checks
%   -> decompAddOnSyntaxChecksConfig: configuration for decomposition
%      add-on syntax checks
%
% CALLS:
%   -> none
%
% DETAILS:  
%   -> This configuration function is used by the linear state space model 
%      file syntax checking function to define what to check and exactly 
%      how to check it. 
%   -> The syntax checks are split into two parts: those that relate to
%      metadata syntax which apply to any model file (like all mnemonics 
%      must be unique etc) and those that relate specifically to LSS model 
%      files.
%   -> Both sets of check are controlled by a configurations defined below.
%
% NOTES:
%   -> See XXXXX for a description of MAPS linear state space model file
%      syntax checking.
%
% This version: 06/06/2011
% Author(s): Matt Waldron

%% DEFINE MNEMONIC FIELDS
% These fields are checked against standard metadata rules (like mnemonics
% must be unique).
mnemFields = {'xMnems';'zMnems';'Ymnems';'wMnems';'YtildeMnems';
    'etatMnems';'ssMnems';'thetaMnems'};

%% DEFINE MNEMONIC FIELDS THAT MIGHT BE PUIBLISHED THROUGH EASE
% These are fields for variables that could be published to FAME through
% EASE & DALI.
mnemFieldsForPublishing = {'xMnems';'zMnems';'Ymnems';'wMnems';
    'YtildeMnems';'etatMnems'};

%% DEFINE EQUATION FIELDS
% These are checked against standard equation syntax rules.
eqFields = {'xEqStrs';'YeqStrs';'YtildeTransformations';'ssDefs'};

%% NAME FIELDS
% Define all name fields to check against standard syntax rules.
nameFields = {'xNames';'zNames';'Ynames';'wNames';'YtildeNames';
    'etatNames';'ssNames';'thetaNames';'xEqNames';'yEqNames'};

%% DEFINE EXPECTED METADATA FIELDS
modelMetadataFields = {'Name';'Description';'Author'};

%% DEFINE PERMITTED CONTENT FOR MODEL EQUATIONS
% Formatted as: field name of variable/parameter type allowed; expected
% time subscript; expected side of the equation (in this case either is
% fine). Note the use of regexp expression syntax on the time subscript.
xEqPermittedContent = {
    'xMnems'        '{t((+|-)1)?}'  ''
    'zMnems'        '{t}'           ''
    'thetaMnems'    ''              ''
    'ssMnems'       ''              ''
    };

%% DEFINE PERMITTED CONTENT FOR MEASUREMENT EQUATIONS
YeqPermittedContent = {
    'Ymnems'        '{t}'           'LHS'
    'xMnems'        '{t}'           'RHS'
    'wMnems'        '{t}'           'RHS'
    'thetaMnems'    ''              'RHS'
    'ssMnems'       ''              'RHS'
    };

%% DEFINE PERMITTED CONTENT FOR DATA TRANSFORMATIONS
YtildeTransPermittedContent = {
    'YtildeMnems'   ''              ''
    'etatMnems'     ''              ''
    };

%% DEFINE PERMITTED CONTENT FOR STEADY STATE & PARAMETER TRANSFORMATIONS
ssDefPermittedContent = {
    'ssMnems'       ''              ''
    'thetaMnems'    ''              ''
    };

%% DEFINE CONTENT CONDITIONALITY CHECKS
% This should be read as: if this exists, then the other should exist too.
% For both fields a description is provided for any errors and for the 2nd
% field a keyword is provided as well.
contentConditionalityConfig = {
    {'Ymnems'                   'model observables'}        {'YeqStrs'                  'measurement equations' 'MEASUREMENT EQUATIONS'}
    {'YeqStrs'                  'measurement equations'}    {'Ymnems'                   'model observables'     'MODEL OBSERVABLES'}
    {'YtildeMnems'              'raw observables'}          {'YtildeTransformations'    'data transformations'  'MODEL OBSERVABLES'}
    {'YtildeTransformations'    'data transformations'}     {'YtildeMnems'              'raw observables'       'RAW OBSERVABLES'}
    {'YtildeMnems'              'raw observables'}          {'Ymnems'                   'model observables'     'MODEL OBSERVABLES'}
    {'wMnems'                   'measurement errors'}       {'YeqStrs'                  'measurement equations' 'MEASUREMENT EQUATIONS'}
    {'etatMnems'                'time-varying trends'}      {'YtildeTransformations'    'data transformations'  'MODEL OBSERVABLES'}  
    };

%% DEFINE NUMBERS CONDITIONALITY CHECKS
% These are checks of the number of each object relative to another object.
% Some ,ust be equal and some should not exceed.
numbersConditionalityConfig = {
    'equal'             {'xMnems'       'model variables'}          {'xEqStrs'              'model equations'}
    'equal'             {'Ymnems'       'model observables'}        {'YtildeMnems'          'raw observables'}  
    'equal'             {'Ymnems'       'model observables'}        {'YeqStrs'              'measurement equations'}
    'not exceed'        {'wMnems'       'measurement errors'}       {'Ymnems'               'model observables'}
    'not exceed'        {'Ymnems'       'model observables'}        {'xMnems'               'model variables'}
    };

%% DEFINE LSS MODEL METADATA SYNTAX CHECKS CONFIG
% Define all the shared, metadata syntax checks to carry out on LSS model 
% files. This is formatted as: function name of check; configuration
% for check.
metadataSyntaxChecksConfig = {
    'check_mnemonics_are_unique'                    mnemFields
    'check_mnemonics_are_used'                      {mnemFields eqFields}
    'check_mnemonics_are_continuous_expressions'    mnemFields
    'check_mnemonic_string_lengths'                 {mnemFieldsForPublishing 15}
    'check_mnemonics_are_not_banned'                mnemFields
    'check_mnemonics_do_not_contain_banned_content' mnemFields
    'check_names_are_unique_within_fields'          nameFields
    'check_names_are_non_overlapping_across_fields' {'xEqNames' 'YeqNames'}
    'check_name_string_lengths'                     {nameFields 100}
    'check_names_do_not_contain_banned_content'     nameFields
    'check_model_metadata_fields'                   {'metadataFields' modelMetadataFields}
    'check_parameter_values_are_valid'              {'theta'    'complete'}
};

%% DEFINE LSS MODEL (SPECIFIC) SYNTAX CHECKS CONFIG
% Define LSS specific content checks and their configuration. This includes
% information defined above plus: specifies that the "diff" operator can be 
% used in data transformations; defines that meaasurement equations should 
% not contain repetitions of model observables on their left-hand-sides or
% model variables on their right-hand-sides; defines that data
% transformations should not contain repetitions of raw observables on
% their right-hand-sides.
LSSmodelSyntaxChecksConfig = {
    'check_conditionality_of_file_content'          contentConditionalityConfig
    'check_conditionality_of_object_numbers'        numbersConditionalityConfig
    'check_model_equation_syntax'                   {'xEqStrs'               'explicit' xEqPermittedContent}       
    'check_measurement_equation_syntax'             {'YeqStrs'               {'explicit' YeqPermittedContent} {'Ymnems'   'LHS'} {'xMnems'  'RHS'}}
    'check_data_transformations_syntax'             {'YtildeTransformations' {'implicit' YtildeTransPermittedContent {'diff'}} {'YtildeMnems'   ''}}
    'check_steady_state_definitions_syntax'         {'ssDefs'                'implicit' ssDefPermittedContent}
    };

end