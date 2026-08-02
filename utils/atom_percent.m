function atpct = atom_percent(net)
%Atom percent for each element in a net intensity table
%
%DESCRIPTION
% This function is a simplified calculation that assumes that the intensity
% of each peak is proportional to the element's weight percent, which is
% generally incorrect. For a more accurate approximation of atomic
% proportions you should consult with your EDS data acquisition software.
%
%
%SYNTAX
% atpct = ATOM_PERCENT(net)
%
%INPUT
% net {table} :: Table of net intensities for common mineral-forming 
%                elements. The table must have the elements in the correct
%                order, as obtained using the net_intensity function.
%
%OUTPUT
% atpct {table} :: A table of atom percents
%
%
%EXAMPLE
% net = net_intensity(xray_energy_data_file);
% atpct = ATOM_PERCENT(net);
%
%See also
% net_intensity

arguments
  net (:,14) table
end

% Atomic weights for the elements IN ORDER: F, Na, Mg, Al, Si, P, S, Cl,
% K, Ca, Ti, Cr, Mn, and Fe
atomic_weights = [18.998, 22.99, 24.305, 26.982, 28.085, 30.974, 32.06, ...
  35.45, 39.098, 40.078, 47.867, 51.996, 54.938, 55.845];

% Get names of the elements in the input table
elements = net.Properties.VariableNames;

% Convert intensity table into a matrix
I = net{:,:};
I(isnan(I) | I < 0) = 0; % Refuse NaNs and negatives, just in case
if any(sum(I,2) == 0)
  error(['One or more rows have intensities that sum to zero... '...
         'Invalid for calculating composition!'])
end

% Normalize intensities to sum to 1
I_fraction = I ./ sum(I,2);

% Convert to atomic fraction using molar amounts, assuming that intensity
% is proportional to weight
m_amount = I_fraction ./ atomic_weights;
atom_fraction = m_amount ./ sum(m_amount,2);

% Normalize to 100%
atpct = atom_fraction .* 100;
atpct = array2table(atpct,'VariableNames',elements);

end