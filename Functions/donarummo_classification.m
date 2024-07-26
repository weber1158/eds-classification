function minerals = donarummo_classification(peak_intensity_table)
%Mineral classification scheme from Donarummo et al. (2003)
%
%DESCRIPTION
% This function automates the mineral classification workflow published
% by Donarummo et al. (2003). Takes a table of energy dispersive spectro-
% metry (EDS) net intensity data and assigns a mineralogy to each row.
%
%SYNTAX
% minerals = DONARUMMO_CLASSIFICATION(peak_intensity_table)
%
%INPUT
% peak_intensity_table - Table containing a column for each of the
%  following elements: Na, Mg, Al, Si, K, Ca, and Fe. The name of each
%  column may be the full element name or its abbreviation. For instance,
%  "Silicon" and "Si" are valid table variable names. Both the American and
%  British spelling of "Aluminum" ("Aluminium") are also valid.
%  Capitalization is not required, but spelling is paramount. The values in
%  the table should represent the measured net intensity for each element.
%
%OUTPUT
% minerals - Categorical vector of mineral names corresponding to each row
%  in the input table. Mineral names are given as abbreviations using the
%  taxonomy proposed by Whitney and Evans (2010)*. Unknown mineral
%  classifications are given names beginning with "U-" as described by
%  Donarummo et al. (2003).
% 
%*The sixteen possible mineral classifications are:
%  ABBREVIATION     NAME
%  Ab               Albite
%  Afs              Alkali feldspar (orthoclase)
%  An               Anorthite
%  Aug              Augite
%  Bt               Biotite
%  Chl              Chlorite
%  Hbl              Hornblende
%  Htr**            Hectorite
%  Ilt              Illite
%  Ilt/Sme          Illite/Smectite 70/30 mix.
%  Kln              Kaolinite
%  Lab/Byt**        Labradorite/Bytownite
%  Mnt              Ca-Montmorillonite
%  Ms               Muscovite
%  Olig/Ans**       Oligoclase/Andesine
%  Vrm              Vermiculite
%
%**Abbreviation defined for this function.
%
%LIMITATIONS
% This function will misclassify any mineral not present in the list above.
% For instance, net intensity data for the mineral quartz will never be
% classified as quartz. To maximize the usefulness of this algorithm the
% user should also consult the results of additional classification
% methods.
%
%REFERENCES
% Donarummo, J., Ram, M., & Stoermer, E. F. (2003). Possible deposit of
%  soil dust from the 1930 s U.S. dust bowl identified in Greenland ice.
%  Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641
% Whitney, D. L., & Evans, B. W. (2010). Abbreviations for names of
%  rock-forming minerals. American Mineralogist, 95(1), 185–187.
%  https://doi.org/10.2138/am.2010.3371
%
%See also
% eds_classification, kandler_classification, panta_classification, weber_classification

%Updates
% 20/Jul/2024 - Changed mineral IDs from full names to abbreviations and
% added a local function to check that the variable names in the input
% table match the required elements. Additional documentation updates.

% Function code ©2024 Austin M. Weber

%
% BEGIN FUNCTION BODY
%
% Perform initial function checks
if ~istable(peak_intensity_table)
	error('Input must be a table.')
end

% Does the table contain the correct variable names?
peak_intensity_table = parseTableVariableNames(peak_intensity_table); % Local function, defined at bottom of file

% Classify the mineral for each row of the input table
num_classifications = size(peak_intensity_table,1); 
minerals = categorical([]);
for n = 1:num_classifications
	mineral = node1(peak_intensity_table(n,:)); % Begin classification at first node of the sorting scheme tree
	minerals(n) = mineral;
end
minerals = minerals'; % Convert to column vector
% That's it! (Of course, there are a LOT of local functions behind the magic)

%
% LOCAL FUNCTIONS
%
function val = node1(T)
	ratio1 = T.Al ./ T.Si;
	if ratio1 < 0.1
		val = node2A(T);
	elseif ratio1 >= 0.7
		val = node2C(T);
	else
		val = node2B(T);
	end
end

function val = node2A(T)
	ratio2A = T.Fe ./ T.Si;
	if ratio2A >= 0.02
		val = node3A(T);
	else
		val = categorical("Htr"); % Hectorite, does not have an abbreviation in Whitney & Evans 2010
	end
end

function val = node3A(T)
	ratio3A = T.K ./ T.Al;
	if ratio3A < 0.3
		val = categorical("Aug"); % Augite
	elseif ratio3A > 0.49
		val = categorical("Hbl"); % Horblende
	else
		val = categorical("U-A");
	end
end

function val = node2C(T)
	ratio2C = (T.Mg + T.Fe) ./ T.Si;
	if ratio2C >= 0.9
		val = categorical("Chl"); % Chlorite
	elseif ratio2C < 0.3
		val = node3C(T);
	else
		val = categorical("U-E");
	end
end

function val = node3C(T)
	ratio3C = T.K ./ T.Si;
	if ratio3C >= 0.1
		val = categorical("Ms"); % Muscovite
	else
		val = node4C(T);
	end
end

function val = node4C(T)
	ratio4C = T.Ca ./ T.Si;
	if ratio4C < 0.05
		val = categorical("Kln"); % Kaolinite
	elseif ratio4C >= 0.25
		val = categorical("An"); % Anorthite
	else
		val = categorical("U-F");
	end
end

function val = node2B(T)
	ratio2B = T.K ./ (T.K + T.Na + T.Ca);
	if ratio2B < 0.35
		val = node3B1(T);
	else
		val = node3B2(T);
	end
end

function val = node3B1(T)
	ratio3B1 = (T.Mg + T.Fe) ./ T.Al;
	if ratio3B1 < 0.3
		val = node4B1a(T);
	elseif ratio3B1 >= 1.0
		val = categorical("U-C1");
	elseif (ratio3B1 > 0.5) && (ratio3B1 < 1.0)
		val = categorical("U-B1");
	else
		val = categorical("Mnt"); % Ca-Montmorillonite
	end
end

function val = node4B1a(T)
	ratio4B1a = (T.Ca + T.Na) ./ T.Al;
	if ratio4B1a >= 0.23
		val = node5B1a1(T);
	else
		val = categorical("U-B2");
	end
end

function val = node5B1a1(T)
	ratio5B1a1 = T.Ca ./ T.Na;
	if ratio5B1a1 < 0.2
		val = categorical("Ab"); % Albite
	elseif ratio5B1a1 >= 10
		val = categorical("U-B3");
	elseif (ratio5B1a1 >= 0.2) && (ratio5B1a1 < 1)
		val = categorical("Olig/Ans"); % Oligoclase/Andesine; my own abbreviations
	else
		val = categorical("Lab/Byt"); % Labradorite/Bytownite; my own abbreviations
	end
end

function val = node3B2(T)
	ratio3B2 = (T.Mg + T.Fe) ./ T.Al;
	if ratio3B2 < 0.55
		val = node4B2a(T);
	else
		val = node4B2b(T);
	end
end

function val = node4B2b(T)
	ratio4B2b = T.K ./ T.Al;
	if ratio4B2b <= 0.1
		val = categorical("U-C2");
	elseif ratio4B2b > 2
		val = categorical("Vrm"); % K-vermiculite
	elseif (ratio4B2b > 0.1) && (ratio4B2b < 1)
		val = categorical("U-D5");
	else
		val = categorical("Bt"); % Biotite
	end
end

function val = node4B2a(T)
	ratio4B2a = T.K ./ T.Al;
	if ratio4B2a >= 0.7
		val = node5B2a1(T);
	else
		val= node5B2a2(T);
	end
end

function val = node5B2a1(T)
	ratio5B2a1 = T.Al ./ T.Si;
	if ratio5B2a1 < 0.25
		val = categorical("U-D2");
	elseif (ratio5B2a1 >= 0.25) && (ratio5B2a1 <= 0.35)
		val = categorical("Afs"); % Orthoclase == alkali feldspar
	elseif (ratio5B2a1 > 0.35) && (ratio5B2a1 < 0.7)
		val = categorical("U-D1");
	else
		val = categorical("U-D5"); % This is my own classification, since Donarummo's sorting scheme does not consider classifications for any values >0.7
	end
end

function val = node5B2a2(T)
	ratio5B2a2 = T.K ./ (T.Al + T.Si);
	if ratio5B2a2 <= 0.05
		val = categorical("U-D4");
	elseif ratio5B2a2 > 0.25
		val = categorical("U-D3");
	elseif (ratio5B2a2 > 0.05) && (ratio5B2a2 <= 0.1)
		val = categorical("Ilt/Sme"); % Illite/Smectite 70/30 mixed
	else
		val = categorical("Ilt"); % Illite
	end
end

function newTable = parseTableVariableNames(originalTable)
% Checks whether the table contains the correct variables and re-names
% variables accordingly.
% Convert full-name table variables to abbreviations
element_names = lower({'Aluminum','Aluminium','Silicon',...
    'Iron','Sodium','Magnesium','Potassium','Calcium'});
varnames = originalTable.Properties.VariableNames;
varnames_lower = lower(varnames);
element_abbreviations = {'Al','Al','Si','Fe','Na','Mg','K','Ca'};
    for i = 1:numel(element_abbreviations)
	    if any(contains(varnames_lower,element_names{i}))
		    inx = contains(varnames_lower,element_names{i});
		    varnames(inx) = element_abbreviations(i);
	    end
    end
originalTable.Properties.VariableNames = varnames;
% Make sure all necessary elements are present
element_list = {'Al','Si','Fe','Na','Mg','K','Ca'};
varis = originalTable.Properties.VariableNames;
    if sum(ismember(varis,element_list)) ~= 7
	    error('Input must be a table containing columns for the elements Na, Mg, Al, Si, K, Ca, and Fe');
    end
newTable = originalTable;
end

%
% END FUNCTION BODY
%
end