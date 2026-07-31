function quant = standard_stoich_quant(num_Oxygens, elements, ...
  norm_wt_pct_standard, net_counts_standard, net_counts_sample)
%Casting's approximation for stoichiometry based on a reference material
%
%DESCRIPTION
% This function quantifies the stoichiometric composition of a sample by
% means of Casting's approximation:
%   C(i,sample) = [I(i,sample)/I(i,standard)] * C(i,standard)
% where C is normalized weight percent and i represents an element of the
% sample or standard. This function should only be used when you acquire
% data for a reference material and a sample using the same instrument
% conditions (acceleration voltage, spot size, etc.).
%
%SYNTAX
% quant = STANDARD_STOICH_QUANT(num_Oxygens, elements,...
%   norm_wt_pct_standard, net_counts_standard, net_counts_sample)
%
%INPUTS
% num_Oxygens {double} :: Number of expected oxygens in chemical formula
% elements {cell}      :: List of elements in the measured data. For
%                         example, for a forsterite [Mg2(SiO4)] sample you
%                         would need to set elements as {'Mg','Si','O'}
%                         with the elements in the same order that they are
%                         given in the data.
% norm_wt_pct_standard :: Numeric array of normalized weight percents
%                         corresponding to the elements in the reference
%                         material.
% net_counts_standard  :: Numeric array of the integrated net intensity
%                         values for each element in the reference material
% net_counts_sample    :: Numeric array of the integrated net intensity
%                         values for each element in the sampled material
%
%OUTPUTS
% quant {table}        :: Table of elements and their corresponding
%                         stoichiometric coefficients.
%
%
%EXAMPLE
% Let's say that you collected net intensity data for a plagioclase sample
% and want to make sure that its stoichiometry is consistent with what is
% expected for plagioclase. (If you aren't familiar, plagioclase is the
% feldspar solid solution series that runs from its Na end-member albite
% [NaAlSi3O8] to its Ca end-member anorthite [CaAl2Si2O8]). 
%
% Now let's say you collected EDS data on a plagioclase reference mineral
% and a plagioclase sample with an unknown composition. Say the normalized
% weight percents for the plagioclase reference material are stored as:
% 
% standard_weights
%  5x2 table
%    Element      NormWtPct
%    =======      =========
%          O         47.390
%         Na          3.200
%         Al         15.490
%         Si         25.060   
%         Ca          8.860    
%
% while the net number of counts for each element in the plagioclase
% reference are stored in a similar variable called standard_counts and the
% net counts for the plagioclase sample are in sample_counts.
%
% Evaluating the stoichiometric composition of the sample is therefore:
%
% num_O = 8;
% elements = standard_weights.Element;
% std_wts = standard_weights.NormWtPct;
% std_net = standard_counts.Net;
% spl_net = sample_counts.Net;
% stoich_coeffs = STANDARD_STOICH_QUANT(num_O, elements, ...
%                                       std_wts, std_net, spl_net)
%
% stoich_coeffs = 
%   5x2 table
%    Element      StoichiometricCoeff
%    =======      ===================
%          O               8.0000
%         Na               0.4703
%         Al               1.3155
%         Si               2.5290
%         Ca               0.4808
%
% As you can see, the Casting's approximation suggests that the plagioclase
% sample has a formula of Na0.5 Ca0.5 Al1.3 Si2.5 O8, which is somewhere
% in-between the albite and anorthite endmembers of the plagioclase
% feldspar solid solution series.
%
%
%See also
% stoich_quant

arguments
  num_Oxygens (1,1) double
  elements (1,:) cell
  norm_wt_pct_standard (:,1) double
  net_counts_standard (:,1) double
  net_counts_sample (:,1) double
end

% Ensure column vectors
norm_wt_pct_standard = norm_wt_pct_standard(:);
net_counts_standard = net_counts_standard(:);
net_counts_sample = net_counts_sample(:);

% Calculate normalized weight percents for the sample
% using Casting's approximation
norm_wt_pct_sample = (net_counts_sample ./ net_counts_standard) ...
                     .* norm_wt_pct_standard;

% Evaluate stoichiometric coefficients
quant = stoich_quant(num_Oxygens, elements, norm_wt_pct_sample);

end