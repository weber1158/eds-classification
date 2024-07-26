function ratioTable = netIntensityRatios(dataTable,label)
%ratioTable = NETINTENSITYRATIOS(dataTable)
%
% Convert a table of EDS net intensity data to a table of net intensity
% ratios.
%
%Input
% dataTable - NxM table containing columns for the following elements:
%  Na, Mg, Al, Si, P, K, Ca, Ti, and Fe
% label - (Optional, must be a string or char) Adds a column of categorical
%  labels to the output table.
%
%Output
% ratioTable - Table containing columns for the following ratios:
%  (Mg+Fe) / Al
%  (Mg+Fe) / Si
%  (Ca+Na) / Al
%        K / (K+Na+Ca)
%        K / (Al+Si)
%       Al / Si
%       Fe / Si
%       Ca / Si
%        K / Si
%        K / Al
%       Ca / Na
%        P / Ca
%       Ti / Fe
%       Mg / Al
%         |X|
%
% where |X| represents the ratio of element X to the sum of all elements.
% There is a |X| precidtor for Na, Mg, Al, Si, P, K, Ca, Ti, and Fe.
% Most of the elemental ratios are based on those detailed by Donarummo et
% al. 2003. The |X| ratios are based on the work of Kandler et al. 2011 and
% Panta et al. 2023.

% (C) Austin M. Weber 2024

varnames = {'(Mg+Fe)/Al','(Mg+Fe)/Si','(Ca+Na)/Al','K/(K+Na+Ca)',...
    'K/(Al+Si)','Al/Si','Fe/Si','Ca/Si','K/Si','K/Al','Ca/Na',...
    'P/Ca','Ti/Fe','Mg/Al','|Na|','|Mg|','|Al|','|Si|','|P|',...
    '|K|','|Ca|','|Ti|','|Fe|'};

% Extract individual variables
MgFe = dataTable.Mg + dataTable.Fe;
CaNa = dataTable.Ca + dataTable.Na;
KNaCa = dataTable.K + dataTable.Na + dataTable.Ca;
AlSi = dataTable.Al + dataTable.Si;
Na = dataTable.Na;
Mg = dataTable.Mg;
Al = dataTable.Al;
Si = dataTable.Si;
P = dataTable.P;
K = dataTable.K;
Ca = dataTable.Ca;
Ti = dataTable.Ti;
Fe = dataTable.Fe;
element_sums = Na+Mg+Al+Si+P+K+Ca+Ti+Fe;

% CALCULATE RATIOS
% (Mg+Fe)/Al
 c01 = MgFe ./ Al;
% (Mg+Fe)/Si
 c02 = MgFe ./ Si;
% (Ca+Na)/Al
 c03 = CaNa ./ Al;
% K/(K+Na+Ca)
 c04 = K ./ KNaCa;
% K/(Al+Si)
 c05 = K ./ AlSi;
% Al/Si
 c06 = Al ./ Si;
% Fe/Si
 c07 = Fe ./ Si;
% Ca/Si
 c08 = Ca ./ Si;
% K/Si
 c09 = K ./ Si;
% K/Al
 c10 = K ./ Al;
% Ca/Na
 c11 = Ca ./ Na;
% P/Ca
 c12 = P ./ Ca;
% Ti/Fe
 c13 = Ti ./ Fe;
% Mg/Al
 c14 = Mg ./ Al;
% |Na|
 c15 = Na ./ element_sums;
% |Mg|
 c16 = Mg ./ element_sums;
% |Al|
 c17 = Al ./ element_sums;
% |Si|
 c18 = Si ./ element_sums;
% |P|
 c19 = P ./ element_sums;
% |K|
 c20 = K ./ element_sums;
% |Ca|
 c21 = Ca ./ element_sums;
% |Ti|
 c22 = Ti ./ element_sums;
% |Fe|
 c23 = Fe ./ element_sums;

% Create output table
ratios = [c01 c02 c03 c04 c05 c06 c07 c08 c09 c10 c11 c12 c13 c14 c15 c16 c17 c18 c19 c20 c21 c22 c23];
ratioTable = array2table(ratios,'VariableNames',varnames);

% Check if second input was specified
    if nargin == 2
     % Check if variable is a "string".
     if isstring(label)
        label = char(label); % Convert to char
     end
     % Ensure that label is of type char; if not produce an error.
     if ~ischar(label)
        error("Second input must be of type String or Char.")
     end
    % Create a categorical vector of the label
     number_of_rows = size(ratioTable,1);
     number_of_cols = 1;
     replabel = cellstr(repelem(label, number_of_rows, number_of_cols));
     replabelcat = categorical(replabel);
    % Add categorical data to the table
     ratioTable.Mineral = replabelcat;
     ratioTable = movevars(ratioTable,'Mineral','Before','(Mg+Fe)/Al');
    end

end