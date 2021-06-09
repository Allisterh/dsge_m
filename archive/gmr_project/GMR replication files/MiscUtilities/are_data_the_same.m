function dataAreTheSame = are_data_the_same(data1,data2,tol)
% This helper compares two MATLAB data for equality.
% It can be used to check that data are identical (by setting the tolerance
% input to 0) or can be treated as identical if they are very similar (by 
% setting the tolerance input to a positive number). 
%
% INPUTS:   
%   -> data1: first MATLAB data input
%   -> data2: second MATLAB data input
%   -> tol: numeric scalar tolerance
%
% OUTPUTS:  
%   -> dataAreTheSame: logical true if the data are the same, false if not
%
% DETAILS:  
%   -> This helper works by iteratively comparing elements of the data
%      input on a hierarchical basis.
%   -> If the data are identical, then the test passes; if the data are not 
%      of the same class, dimensions or size then the test fails.
%      Otherwise, the test depends on the class of data input with each
%      class treated separately in a cell below (and unhandled classes are
%      thrown as errors).
%   -> If the data is numeric, the absolute difference between the two 
%      elements is compared to the tolerance. If the difference between the
%      elements exceeds it, then the test fails (and passes otherwise).
%   -> It the data input is a cell, structure or an object, then this 
%      function unpacks the elements, fields or properties and calls itself
%      to test for equality on each individual element.
%   -> If the data input is an exception, then this function compares the
%      identifiers in the exceptions (which should be unique) to allow for
%      the fact that the messages and stacks may be different (eg if more 
%      comments have beed added to a function or if MATLAB have added lines
%      to one of their own functions).
%   -> If only two inputs are provided, the tolerance is set to eps.
%
% NOTES:
%   -> This function is useful for regression testing which requires a
%      comparison of the output of a function against a previously
%      generated output (which is treated as the truth).
%   -> The tolerance is useful in instances where code is being run on 
%      different machines (eg. 32bit versus 64bit) or where small changes
%      to the way something is calculated lead to small, numerical changs
%      in the outcomes.
%   -> Note that this function will not compare two strings (i.e. treat
%      them as though they are the same) if both strings are in valid date
%      string formats. This is designed so that objects which include a
%      dynamically updated date are not treated as being different just
%      because they were created on two different days.
%   -> This function should be easy to extend for classes of data which are
%      not handled below. 
%   -> This function could be extended to include an additional output to
%      provide more information about the cause of any differences in
%      the data input.
%   -> There is an issue with comparison of function handles that is
%      explained in the relevant cell below.
%
% This version: 18/12/2013
% Author(s): Francesca Monti & Matt Waldron

%% CHECK INPUTS
% Check the number of inputs and check the tolerance input, which has a
% known type.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif nargin>2 && ~is_positive_real_numeric_scalar(tol)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK FOR CLASS AND DIMENSIONS OF DATA
% Similaraly, if the data input for comparison is not of the same class,
% doesn't have the same dimensions or isn't of the same size then it cannot
% be the same. Set the output to false and exit the function.
if ~strcmp(class(data1),class(data2))
    dataAreTheSame = false;
    return
elseif ndims(data1)~=ndims(data2)
    dataAreTheSame = false;
    return
elseif any(size(data1)~=size(data2))
    dataAreTheSame = false;
    return
end

%% CHECK FOR EQUALITY OF DATA
% If the MATLAB function isequal returns true, then there is no need to go
% on with further checks.
if isequal(data1,data2);
    dataAreTheSame = true;
    return
end

%% SET DEFAULT TOLERANCE
% Set the default tolerance to effective zero.
if nargin < 3
    tol = eps;
end

%% COMPARE EXCEPTIONS
% If the data input is of the exception class, check that the identifiers 
% are the same by calling this function (which will compare the strings - 
% see below). If that passes check any causes, which will result in another
% exception comparison.
if isa(data1,'MException')
    dataAreTheSame = are_data_the_same(...
        data1.identifier,data2.identifier,tol);
    if dataAreTheSame
        if ~isempty(data2.cause)
            dataAreTheSame = are_data_the_same(...
                data1.cause,data2.cause,tol);
        end
    end
    return
end

%% COMPARE STRUCTURES
% If the data input are structures, then extract the field names and
% compare those (again by calling this function). If the fieldnames are the
% same, compare the data that exists in each of those fields.
if isstruct(data1)
    fn1 = fieldnames(data1);
    fn2 = fieldnames(data2);
    dataAreTheSame = are_data_the_same(fn1,fn2,tol);
    if dataAreTheSame
        nfn = size(fn1,1);
        for ifn = 1:nfn
            d1 = data1.(fn1{ifn});
            d2 = data2.(fn2{ifn});
            dataAreTheSame = are_data_the_same(d1,d2,tol);
            if ~dataAreTheSame
                break
            end
        end
    end
    return    
end

%% COMPARE CELLS
% If the data input are cells, compare the contents of the cells by
% recalling this function for each element of the cells.
if iscell(data1)
    nElements = numel(data1);
    for iElement = 1:nElements
        d1 = data1{iElement};
        d2 = data2{iElement};
        dataAreTheSame = are_data_the_same(d1,d2,tol);
        if ~dataAreTheSame
            break
        end
    end
    return
end

%% COMPARE NUMERICS
% If the data input are numeric matrices (or scalars), find all differences 
% that exceed the tolerance. For each dimension of the data, check that all 
% of the elements are the same (adjusting for any elements of the data
% that are NaN in both datasets).
if isnumeric(data1)
    absDiff  = abs(data1-data2);
    dataAreTheSame = (absDiff<=tol);
    dataAreTheSame(isnan(data1)&isnan(data2)) = true;
    nDataDims = ndims(data1);
    for iDataDims = 1:nDataDims
        dataAreTheSame = all(dataAreTheSame);
    end
    return
end

%% COMPARE STRINGS
% If strings were input, then they must pass the equality test at the top
% of this function or they cannot be the same (there is no numeric
% tolerance issue with strings!), so set the output to false. There is one
% exception to that logic. If the first string input is a date string, then
% the fact that they are different is ignored.
if ischar(data1)
    try
        datenum(data1);
        datenum(data2);
        dataAreTheSame = true;
    catch DateE                                                             %#ok<NASGU>
        dataAreTheSame = false;
    end
    return
end

%% COMPARE LOGICALS
% The same logic covers logicals. There cannot be a tolerance, so if this
% cell in the code is exercised, it must be the case that the data input
% are not the same.
if islogical(data1)
    dataAreTheSame = false;
    return
end

%% COMPARE FUNCTION HANDLES
% Function handles retain information about when or where they were created
% and loaded. Therefore, an "isequal" test of function handles fails to 
% return true even if the handles are in fact the same. In most cases, 
% a comparison of the output of the MATLAB function "functions" reveals 
% whether or not the function handles are equivalent. However, if the 
% function handle is an anonymous handle with one or more fixed input
% arguments, then even this test fails. The offending information is stored
% as the second element of the workspace cell array and is removed in the
% code below. It is possible that this behaviour will change in future
% releases and it would be nice to  be able to remove this code.
if isa(data1,'function_handle')
    data1FuncInfo = functions(data1);
    data2FuncInfo = functions(data2);
    if isfield(data1FuncInfo,'workspace') && ...
            isfield(data2FuncInfo,'workspace') && ...
            size(data1FuncInfo.workspace,1)==2 && ...
            size(data2FuncInfo.workspace,1)==2
        data1FuncInfo.workspace(2) = [];
        data2FuncInfo.workspace(2) = [];
    end
    dataAreTheSame = isequal(data1FuncInfo,data2FuncInfo);
    return
end

%% COMPARE OBJECTS
% If the data input are objects, then compare the content of the (publicly
% available) properties in much the same way as the fields in a structure.
if isobject(data1)
    p1 = properties(data1);
    p2 = properties(data2);
    dataAreTheSame = are_data_the_same(p1,p2,tol);
    if dataAreTheSame
        np = size(p1,1);
        for ip = 1:np
            d1 = data1.(p1{ip});
            d2 = data2.(p2{ip});
            dataAreTheSame = are_data_the_same(d1,d2,tol);
            if ~dataAreTheSame
                break
            end
        end
    end
    return    
end

%% HANDLE UNHANDLED CLASSES
% If none of the cells of code above have been exercised, it must be the
% case that this function cannot handle the particular datatype. In that
% case, throw an error and consider upgrading this function to handle the
% new class.
unhandledClass = class(data1);
errId = ['MAPS:',mfilename,':UnhandledClass'];
generate_and_throw_MAPS_exception(errId,{unhandledClass});

end