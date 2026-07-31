function quant = stoich_quant(num_Oxygens, elements, norm_wt_pct)
%Standardless stoichiometric quantification
%
%SYNTAX
% quant = STOICH_QUANT(num_Oxygens, elements, norm_wt_pct)
%
%INPUTS
% num_Oxygens (1,1) :: Number of expected oxygens in chemical formula
% elements    (1,:) :: Cell vector of element names (e.g. {'O','Mg',Al'})
% norm_wt_pct (:,1) :: Normalized weight percents for each element in the
%                      'elements' input argument.
%
%OUTPUT
% quant       (:,2) :: Table with two columns: (1) "Element" and (2)
%                      "StoichiometricCoeff"
%
%
%EXAMPLE
% num_O = 8;  % Assuming plagioclase composition (NaAlSi3O8 - CaAl2Si2O8)
% elements = {'O','Na','Al','Si','Ca'};
% wt_pct = [49.1527; 4.1517; 13.6314; 27.2759; 7.3997];
% quant = STOICH_QUANT(num_O, elements, wt_pct)
%
% quant =
%   5x2 table
%    Element      StoichiometricCoeff
%    =======      ===================
%          O               8.0000
%         Na               0.4703
%         Al               1.3155
%         Si               2.5289
%         Ca               0.4808
%
%
%See also
% standard_stoich_quant

arguments
  num_Oxygens (1,1) double
  elements (1,:) cell
  norm_wt_pct (:,1) double
end

% Ensure column vector
norm_wt_pct = norm_wt_pct(:);

% Get atomic weights for the elements in the input 'elements'
atomWts = readtable('atomic-weights.csv');
atomic_weights = zeros(size(elements));
for e = 1:numel(elements)
  e_name = elements{e};
  for w = 1:length(atomWts.Abbreviation)
    if strcmp(atomWts.Abbreviation{w}, e_name)
      e_idx = w;
      break;
    end
  end
  atomic_weights(e) = atomWts.Weight(e_idx);
end

% Calculate atomic proportions
atomic_proportions = norm_wt_pct ./ atomic_weights';

% Calculate oxygen factor
e_name = 'O';
for i = 1:length(elements)
  if strcmp(elements{i}, e_name)
    e_idx = i;
    break;
  end
end
oxygen_factor = num_Oxygens / atomic_proportions(e_idx);

% Calculate stoichiometries
stoichs = atomic_proportions * oxygen_factor;

% Generate output table
quant = table(elements', stoichs, ...
  'VariableNames',{'Element','StoichiometricCoeff'});

end