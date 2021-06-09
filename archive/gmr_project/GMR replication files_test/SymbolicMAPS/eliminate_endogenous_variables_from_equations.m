function eqReducedStrs = eliminate_endogenous_variables_from_equations(...
    eqStrs,endogVarMnems)
% This helper reduces a system of equations through substitution.
% It uses the elimination method to successively substitute out endogneous
% variables from a system of equations until it is reduced to the smallest
% system possible.
%
% INPUTS:
%   -> eqStrs: cell string array of equations
%   -> endogVarMnems: cell string array of endogenous variable mnemonics
%
% OUTPUTS:
%   -> eqReducedStrs: cell string array of reduced equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> extract_expressions_from_equations
%   -> lookup_model_index_numbers
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> compute_equations_incidence_matrix
%   -> substitute_variable_out_of_equation
%
% DETAILS:
%   -> This helper reduces a set of equations to the smallest system
%      possible by substituting out as many of the endogenous variables as
%      possible.
%   -> It searches for endogenous variables that can be expressed
%      numerically or as functions of variables that are exogneous to the
%      system and then substitutes out all instances of the variable found
%      in the other equations. It repeats this process until no analytical
%      expressions can be found. The resulting system would represent the
%      solution to a recursive system of equations.
%   -> For example, suppose the cell string array of equations input is
%      {'y1=x1*y2';'y2=x2'} and the vector of endogneous variables is
%      {'y1';'y2'} (with {'x1';'x2'} being exogenous variables. This
%      function would substitute out 'y2' from the first equation to
%      produce the following output: {'y1=x1*x2';'y2=x2'}.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> Each of the input endogenous variables must appear on the
%      left-hand-side of one and only one of the equations. And the
%      equations must be of a form where only one variable appears on the
%      left-hand-side. If not, it will throw an error.

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(endogVarMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);  
end

%% SPLIT THE EQUATIONS
% Extract the expressions either side of equality in the equations. Check
% that the expressions left of the equal sign are the endogenous variables 
% (i.e. they can be uniquely identified in the list of endogenous variables
% input).
[endogVarEqMnems,endogVarExprs] = extract_expressions_from_equations(...
    eqStrs);
try
    lookup_model_index_numbers(endogVarMnems,endogVarEqMnems);
catch LookupE
    errId = ['MAPS:',mfilename,':BadEqSpec'];
    generate_MAPS_exception_add_cause_and_throw(LookupE,errId);
end

%% COMPUTE THE INCIDENCE MATRIX OF THE SYSTEM
% Compute the incidence matrix of the right-hand-side of the equations with
% respect to the endogenous variables.
eqVarIncMat = compute_equations_incidence_matrix(...
    endogVarExprs,endogVarEqMnems);

%% REDUCE THE SYSTEM OF EQUATIONS
% Continue eliminating endogenous variables from the system by substituting
% them out for numerical expressions or those as functions of only 
% exogenous variables until there are no more expressions that can be
% substituted into. The loop first identifies the index numbers of
% expressions that can be substituted in (i.e. those that are not functions
% of any of the endogenous variables - the incidence matrix is a row of 
% zeros). Of those, it next identifies which of them appear in other
% expressions (i.e. those that can be substituted in). For each of those,
% it extracts the string expression to substitute in and the string
% endogenous variable to substitute out. Next, it finds the index numbers
% of the expressions to substitute into (i.e. those that are a function of 
% the variable to substitute out - the appropriate column of the incidence 
% matrix contains a 1). For each of those it calls the sub-function, before
% below to do the substitution, before updating the incidence matrix
% appropriately.
exprToSubsInFound = true;
while exprToSubsInFound
    exprsCanBeSubsInInds = find(sum(eqVarIncMat,2)==0);    
    exprsToSubsInInds = exprsCanBeSubsInInds(...
        sum(eqVarIncMat(:,exprsCanBeSubsInInds))>0);    
    nExprsToSubsIn = size(exprsToSubsInInds,1);
    for iExpr = 1:nExprsToSubsIn
        iExprToSubsInInd = exprsToSubsInInds(iExpr);        
        iExprToSubsIn = endogVarExprs{iExprToSubsInInd};
        iEndogVarToSubsOut = endogVarEqMnems{iExprToSubsInInd};
        iExprsToSubsIntoInds = find(eqVarIncMat(:,iExprToSubsInInd));
        niExprsToSubsInto = size(iExprsToSubsIntoInds,1);
        for iiExpr = 1:niExprsToSubsInto
            iiExprToSubsIntoInd = iExprsToSubsIntoInds(iiExpr);
            iiExprToSubsInto = endogVarExprs{iiExprToSubsIntoInd};
            iiExprSubsInto = substitute_variable_out_of_equation(...
                iiExprToSubsInto,iEndogVarToSubsOut,...
                iExprToSubsIn);
            endogVarExprs{iiExprToSubsIntoInd} = iiExprSubsInto;
            eqVarIncMat(iiExprToSubsIntoInd,iExprToSubsInInd) = false;
        end
    end
    if nExprsToSubsIn == 0
        exprToSubsInFound = false;
    end
end

%% PUT THE EQUATIONS BACK TOGETHER
% Recombine the endogenous variables mnemonics on the left-hand-sides with
% the reduced expressions on the right.
eqReducedStrs = strcat(endogVarEqMnems,{'='},endogVarExprs);

end

%% FUNCTION TO SUBSTITUTE A VARIABLE OUT FOR AN EXPRESSION
function eqSubsStr = substitute_variable_out_of_equation(...
    eqStr,varMnem,exprToSubsIn)
% This helper substitutes an expression into an equation for a variable.
% The expression to substitute in can be another variable or any valid
% mathematical string.
%
% INPUTS:
%   -> eqStr: equation string
%   -> varMnem: variable mnemonic string
%   -> exprToSubsIn: string expression to substitute in
%
% OUTPUTS:
%   -> eqSubsStr: equation with expression substituted for variable
%
% CALLS:
%   -> split_equation
%   -> reconstruct_equation

%% SPLIT EQUATION
% Call the split equation helper to split the equation into its constituent
% terms (with the delimiters returned seprately). Do not split out
% numerics, operators or time subscripts.
SplitOptions = struct('numerics',false,'operators',false,'timeSubs',false);
[eqStrSplit,eqStrDelims] = split_equation(eqStr,SplitOptions);

%% REPLACE VARIABLE INSTANCES WITH EXPRESSION
% Find the variable to replace in the split equation string (allowing for
% the fact that it could appear multiple times). Replace all instances with
% the expression to be substituted in (with parantheses around the 
% expression to guarantee that all elements of the expression are operated
% on in the correct way).
eqStrSubsTermLogicals = strcmp(varMnem,eqStrSplit);
eqStrSplit(eqStrSubsTermLogicals) = {['(',exprToSubsIn,')']};

%% RECONSTRUCT EQUATION
% Reconstruct the equation from the substtituted split terms and the
% delimiters.
eqSubsStr = reconstruct_equation(eqStrSplit,eqStrDelims);

end