function minerals = kutuzov_classification(data_table)
%Mineral classification scheme from Kutuzov et al. (2026)
%
%DESCRIPTION
% This function automates the mineral classification workflow published
% by Kutuzov et al. (2026, Table S5). Takes a table of element data and 
% assigns a mineralogy to each row. NOTE: While the Kutuzov algorithm was
% developed for element data collected with sp-ICP-TOF-MS, the function
% herein is suitable for EDS elemental peak intensity data.
%
%SYNTAX
% minerals = KUTUZOV_CLASSIFICATION(data_table) 
%
%INPUT
% data_table - Table containing a column for each of the following
%  elements: Na, Mg, Al, Si, Ca, Ti, and Fe. The name of each column
%  may be the full element name or its abbreviation. For instance, "Silicon"
%  and "Si" are valid table variable names. Both the American and British
%  spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is
%  not required, but spelling is paramount. The values in the table should
%  represent the relative abundance of each element, either as fractional
%  values or as EDS x-ray peak intensities.
%
%OUTPUT
% minerals - Categorical vector of mineral names corresponding to each row
%  in the input table.
%
%The possible mineral classifications are:
%  _____________________________________________________________________
%  MINERAL             | DESCRIPTION
%  =====================================================================
%  Phyllosilicate      | Clay minerals and mica
%  Augite              | Clinopyroxene (high Ca)
%  Diopside            | Clinopyroxene (low Fe)
%  Pigeonite           | Orthopyroxene (low Ca)
%  High-Fe Hornblende  | Amphibole
%  High-Mg Hornblende  | Amphibole
%  Chlorite            | Clay mineral
%  Kaolinite           | Clay mineral
%  Albite              | Feldspar (Na end member)
%  Anorthite           | Feldspar (Ca end member)
%  Hypersthene         | Orthopyroxene (a variety of enstatite; high Mg)
%  Quartz              | Quartz (SiO2)
%  Ca-dominant         | Calcite, Apatite, Fluorite, etc.
%  Fe-dominant         | Hematite, Goethite, Magnetite, etc.
%  Unknown             | does not match any of the known criteria
%
%
%LIMITATIONS
% This function will misclassify any mineral not present in the list above.
% For instance, element data for titanite will never be classified as
% titanite. To maximize the usefulness of this algorithm the user should
% also consult the results of additional classification methods.
%
%REFERENCES
% Kutuzov, S., Olesik, J. W., Lomax-Vogt, M. C., Carter, L. M., Lowry, G.
%  V., Bland, G. D., Wielinski, J., Sullivan, R. C., & Gabrielli, P. (2026).
%  Geochemical characterization of millions of individual atmospheric
%  particles entrapped in Antarctic ice across the last glacial-interglacial
%  transition. Scientific Reports, 16(1), 10556.
%  https://doi.org/10.1038/s41598-026-45260-3
%
%
%See also
% eds_classification, donarummo_classification, kandler_classification, weber_classification

%Updates
% 31/March/2026 - Created

% Function code ©2026 Austin M. Weber

%
% BEGIN FUNCTION BODY
%
% Perform intial function checks
if ~istable(data_table)
	error('Input must be a table.');
end
% Convert full-name table variables to abbreviations
element_names = lower({'Aluminum','Aluminium','Silicon','Iron','Sodium','Magnesium','Phosphorus','Sulfur',...
	'Chlorine','Potassium','Calcium','Titanium','Chromium','Manganese','Fluorine'});
varnames = data_table.Properties.VariableNames;
varnames_lower = lower(varnames);
element_abbreviations = {'Al','Al','Si','Fe','Na','Mg','P','S',...
	'Cl','K','Ca','Ti','Cr','Mn','F'};
for n = 1:numel(element_abbreviations)
	if any(contains(varnames_lower,element_names{n}))
		inx = contains(varnames_lower,element_names{n});
		varnames(inx) = element_abbreviations(n);
	end
end
data_table.Properties.VariableNames = varnames;
% Make sure all necessary elements are present
element_list = {'Al','Si','Fe','Na','Mg','Ca','Ti'};
vars = data_table.Properties.VariableNames;
if sum(ismember(vars,element_list)) ~= 7
	error('Input must be a table containing columns for the elements Na, Mg, Al, Si, K, Ca, Ti, and Fe');
end
% Evaluate mineralogies with local functions
minerals = categorical(mineralogy_classification(data_table)); % Calls numerous local functions; Optimized for speed.

%
% LOCAL FUNCTIONS
%
function minerals = mineralogy_classification(T)
%{ 
Ths function creates a n-by-1 cell array where n is the number of rows in 
he input table, T. All values of the array are set as 'Unknown' by 
default. The function then calls remaining local functions, one by one. 
Each local function checks whether the rows in the table can be attributed 
to a particular mineralogy. The output of each of these functions is a 
logical vector of the same length as the cell array. The 
`mineralogy_classification` function then uses the logical index from each 
local function to re-assign the 'Unknown' classifications to the correct 
mineraological classification.
%}
minerals = repmat({'Unknown'},[size(T,1),1]); % Preallocate memory

% Re-write T so that each element is represented as a fraction
newT = [T.Na T.Mg T.Al T.Si T.Ca T.Ti T.Fe];
rowsSummed = sum(newT,2);
newT = newT./rowsSummed;
newT = array2table(newT,'VariableNames',{'Na','Mg','Al','Si','Ca','Ti','Fe'});

%01 PHYLLOSILICATE
	idx = check_phyllosilicate(newT);
	minerals(idx) = {'Phyllosilicate'};
%02 AUGITE
  idx = check_augite(newT);
  minerals(idx) = {'Augite'};
%03 DIOPSIDE 
	idx = check_diopside(newT);
	minerals(idx) = {'Diopside'};
%04 PIGEONITE
	idx = check_pigeonite(newT);
	minerals(idx) = {'Pigeonite'};
%05 HIGH FE HORNBLENDE
	idx = check_fe_hornblende(newT);
	minerals(idx) = {'High-Fe Hornblende'};
%06 HIGH MG HORNBLENDE
	idx = check_mg_hornblende(newT);
	minerals(idx) = {'High-Mg Hornblende'};
%07 CHLORITE
	idx = check_chlorite(newT);
	minerals(idx) = {'Chlorite'};
%08 KAOLINITE
	idx = check_kaolinite(newT);
	minerals(idx) = {'Kaolinite'};
%09 ALBITE
	idx = check_albite(newT);
	minerals(idx) = {'Albite'};
%10 ANORTHITE
	idx = check_anorthite(newT);
	minerals(idx) = {'Anorthite'};
%11 HYPERSTHENE
	idx = check_hypersthene(newT);
	minerals(idx) = {'Hypersthene'};
%12 QUARTZ
	idx = check_quartz(newT);
	minerals(idx) = {'Quartz'};
%13 Ca-DOMINANT
	idx = check_ca_dominant(newT);
	minerals(idx) = {'Ca-dominant'};
%14 Fe-DOMINANT
	idx = check_fe_dominant(newT);
	minerals(idx) = {'Fe-dominant'};
end

function index = check_phyllosilicate(T)
	criteria1 = T.Si > 0;
  criteria2 = T.Al > 0;
  criteria3 = (T.Mg > 0) | (T.Fe > 0);
  criteria4 = (((T.Al + T.Mg + T.Fe)./T.Si) > 0.7) & ...
              (((T.Al + T.Mg + T.Fe)./T.Si) < 4.0);
	index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_augite(T)
	criteria1 = (T.Ca>0) & (T.Mg>0) & (T.Fe>0) & (T.Si>0);
  expression2 = (T.Ca+T.Mg+T.Fe)./T.Si;
    criteria2 = (expression2>0.6) & (expression2<2.2);
  expression3 = (T.Mg+T.Fe)./T.Si;
    criteria3 = (expression3>0.275) & (expression3<1.6);
  expression4 = T.Ca ./ T.Si;
    criteria4 = (expression4>0.3) & (expression4<2.0);
	index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_diopside(T)
	criteria1 = (T.Ca>0) & (T.Mg>0) & (T.Si>0);
  expression2 = T.Ca ./ T.Si;
    criteria2 = (expression2>0.25) & (expression2<1.0);
  expression3 = T.Mg ./ T.Si;
    criteria3 = (expression3>0.25) & (expression3<1.0);
	index = criteria1 & criteria2 & criteria3;
end

function index = check_pigeonite(T)
	criteria1 = (T.Ca>0) & (T.Mg>0) & (T.Fe>0) & (T.Si>0);
  expression2 = T.Ca ./ T.Si;
    criteria2 = (expression2>0.06) & (expression2<0.25);
  expression3 = T.Mg ./ T.Si;
    criteria3 = (expression3>0.22) & (expression3<0.88);
  expression4 = T.Fe ./ T.Si;
    criteria4 = (expression4>0.22) & (expression4<0.88);
  index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_fe_hornblende(T)
	criteria1 = (T.Ca>0) & (T.Al>0) & (T.Fe>0) & (T.Si>0);
  expression2 = (T.Fe + 2.*T.Ti + T.Al + T.Mg) ./ T.Si;
    criteria2 = (expression2>0.428) & (expression2<1.5);
  expression3 = (2.*T.Ca + T.Na) ./ T.Si;
    criteria3 = (expression3<1.0);
  criteria4 = (T.Mg ./ T.Si)<0.143;
  expression5 = (T.Al ./ T.Si);
    criteria5 = (expression5>0.143) & (expression5<0.571);
  criteria6 = (T.Fe + T.Al) > T.Mg;
  index = criteria1 & criteria2 & criteria3 & criteria4 & criteria5 & criteria6;
end

function index = check_mg_hornblende(T)
	criteria1 = (T.Ca>0) & (T.Al>0) & (T.Fe>0) & (T.Si>0) & (T.Mg>0);
  expression2 = (T.Fe + 2.*T.Ti + T.Al + T.Mg) ./ T.Si;
    criteria2 = (expression2>0.428) & (expression2<3.0);
  criteria3 = (T.Fe ./ T.Si) < 0.143;
  expression4 = (T.Al ./ T.Si);
    criteria4 = (expression4>0.143) & (expression4<0.571);
  criteria5 = (T.Mg + T.Al) > T.Fe;
  index = criteria1 & criteria2 & criteria3 & criteria4 & criteria5;
end

function index = check_chlorite(T)
  criteria1 = (T.Al>0) & (T.Fe>0) & (T.Si>0) & (T.Mg>0);
  expression2 = (T.Al + T.Fe + T.Mg) ./ T.Si;
    criteria2 = (expression2>0.95) & (expression2<3.6);
  index = criteria1 & criteria2;
end

function index = check_kaolinite(T)
  criteria1 = (T.Si>0) & (T.Al>0);
  expression2 = (T.Al ./ T.Si);
    criteria2 = (expression2>0.8) & (expression2<1.2);
  index = criteria1 & criteria2;
end

function index = check_albite(T)
  criteria1 = (T.Si>0) & (T.Al>0) & (T.Na>0);
  expression2 = (T.Na ./ T.Si);
    criteria2 = (expression2>0.2) & (expression2<0.66);
  expression3 = (T.Al ./ T.Si);
    criteria3 = (expression3>0.15) & (expression3<1.33);
  expression4 = (T.Ca ./ T.Si);
    criteria4 = (expression4<0.15);
  index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_anorthite(T)
  criteria1 = (T.Si>0) & (T.Al>0) & (T.Ca>0);
  expression2 = (T.Ca ./ T.Si);
    criteria2 = (expression2>0.25) & (expression2<1.0);
  expression3 = (T.Al ./ T.Si);
    criteria3 = (expression3>0.5) & (expression3<2.0);
  expression4 = (T.Na ./ T.Si);
    criteria4 = (expression4<0.2);
  index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_hypersthene(T)
  criteria1 = T.Si > 0;
  criteria2 = (T.Mg > 0) | (T.Fe>0);
  expression3 = (T.Mg + T.Fe)./ T.Si;
    criteria3 = (expression3>0.75) & (expression3<1.25);
  criteria4 = (T.Ca<0.1) & (T.Al<0.1) & (T.Na<0.1) & ((T.Ti ./ T.Si)<0.1);
  index = criteria1 & criteria2 & criteria3 & criteria4;
end

function index = check_quartz(T)
  criteria1 = T.Si > 0.9;
  index = criteria1;
end

function index = check_ca_dominant(T)
  criteria1 = T.Ca > 0.6;
  index = criteria1;
end

function index = check_fe_dominant(T)
  criteria1 = T.Fe > 0.6;
  index = criteria1;
end

%
% END FUNCTION
%
end