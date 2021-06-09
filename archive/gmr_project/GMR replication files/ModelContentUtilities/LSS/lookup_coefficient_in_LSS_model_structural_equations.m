function coeff = lookup_coefficient_in_LSS_model_structural_equations(...
    Model,xEqName,xMnem,lagLeadIndicator)
% TODO



%% CHECK INPUTS
% todo

%% HANFLE OPTIONAL INPUT
if nargin < 4
    lagLeadIndicator = 0;
end

%% UNPACK COMPONENTS OF THE MODEL REQUIRED
[xEqNames,xMnems,HB,HC,HF] = unpack_model(...
    Model,{'xEqNames','xMnems','HB','HC','HF'});

%% LOOKUP EQUATION & VARIABLE INDEX NUMBERS
eqInd = lookup_model_index_numbers(xEqNames,xEqName);
varInd = lookup_model_index_numbers(xMnems,xMnem);

%% GET COEFFICIENT
if lagLeadIndicator == 1
    coeff = HF(eqInd,varInd);
elseif lagLeadIndicator == -1
    coeff = HB(eqInd,varInd);
else
    coeff = HC(eqInd,varInd);
end

end