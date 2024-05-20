function minerals = panta_classification(data_table)
%minerals = panta_classification(data_table) 
% Performs mineral classification using the sorting scheme from Panta et
% al. (2023).
%
%Description
% The sorting scheme is derived from corrected atomic concentration (%)
% measurements acquired on mineral particles using a FEI ESEM Quanta 400
% FEG scanning electron microscope with an X-Max 150 Energy-Dispersive
% X-ray spectroscopy silicon drift X-ray detector. Data were collected
% using an acceleration voltage of 12.5 keV, a beam current of 18 nA, a
% spot size of 5.0, and a working distance of 10 mm.
%
%Using the function
% This function requires an input of class 'table' with columns for each of
% the following elements: Al, Si, Na, Mg, P, S, Cl, Fe, K, Ca, Ti, Cr, Mn,
% and F.
%
% The function output will be a categorical list of the most likely mineral
% classification for each row in the input table.
%
%Reference:
% A. Panta, et al. (2023). "Insights into the single-particle composition,
% size, mixing state, and aspect ratio of freshly emitted mineral dust from
% field measurements in the Moroccan Sahara using electron microscopy."
% Atmos. Chem. Phys. 23, 3861–3885. doi.org/10.5194/acp-23-3861-2023

%
% The transcription of the Panta et al. (2023) sorting scheme into MATLAB code
% was performed and is copyrighted by Austin M. Weber.
%

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
element_list = {'Al','Si','Fe','Na','Mg','P','S','Cl','K','Ca','Ti','Cr','Mn','F'};
vars = data_table.Properties.VariableNames;
if sum(ismember(vars,element_list)) ~= 14
	error('Input must be a table containing columns for the elements Al, Si, Na, Mg, P, S, Cl, Fe, K, Ca, Ti, Cr, Mn, and F');
end
% Evaluate mineralogies with local functions
minerals = categorical(mineralogy_classification(data_table)); % Calls numerous local functions; Optimized for speed.

%
% LOCAL FUNCTIONS
%
function minerals = mineralogy_classification(T)
%{ 
This function creates a n-by-1 cell array where n is the
number of rows in the input table, T. All values of the array are set
as 'Unknown' by default. The function then calls 23 other local 
functions, one by one. Each local function checks whether the rows in 
the table can be attributed to a particular mineralogy. The output of 
each of these functions is a logical vector of the same length as the 
cell array. The `mineralogy_classification` function then uses
the logical index from each local function to re-assign the 'Unknown'
classifications to the correct mineraological classification. In
addition, the `mineralogy_classification` function calls another local
function, `element_sums` that evaluates the sum of the Na, Mg, Al, Si, 
P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe columns for each row in the input
table. The output of this function is included as an input argument for
the 23 mineralogy-checking local functions (which all require the
calculation of those sums in order to evaluate the element index) in
order to save computational time (i.e., so that the sums do not have to
be calculated 23 times; rather, only the one time).
© Austin M. Weber 2023
%}
sums = element_sums(T); % Local function
minerals = repmat({'Unknown'},[size(T,1),1]); % Preallocate memory
% HEMATITE
	idx = check_hematite(T,sums);
	minerals(idx) = {'Hematite-like'};
% RUTILE 
	idx = check_rutile(T,sums);
	minerals(idx) = {'Rutile-like'};
% ILLMENITE
	idx = check_illmenite(T,sums);
	minerals(idx) = {'Illmenite-like'};
% QUARTZ
	idx = check_quartz(T,sums);
	minerals(idx) = {'Quartz-like'};
% COMPLEX QUARTZ
	idx = check_complex_quartz(T,sums);
	minerals(idx) = {'Complex quartz-like'};
% MICROCLINE
	idx = check_microcline(T,sums);
	minerals(idx) = {'Microcline-like'};
% ALBITE
	idx = check_albite(T,sums);
	minerals(idx) = {'Albite-like'};
% COMPLEX FELDSPAR
	idx = check_complex_feldspar(T,sums);
	minerals(idx) = {'Feldspar-like'};
% COMPLEX CLAY/FELDSAR MIXTURE
	idx = check_complex_clay_feldspar_mix(T,sums);
	minerals(idx) = {'Complex clay/feldspar mixture'};
% MICA
	idx = check_mica(T,sums);
	minerals(idx) = {'Mica-like'};
% COMPLEX CLAY
	idx = check_complex_clay(T,sums);
	minerals(idx) = {'Complex clay-mineral-like'};
% ILLITE
	idx = check_illite(T,sums);
	minerals(idx) = {'Illite-like'};
% CHLORITE
	idx = check_chlorite(T,sums);
	minerals(idx) = {'Chlorite-like'};
% SMECTITE
	idx = check_smectite(T,sums);
	minerals(idx) = {'Smectite-like'};
% KAOLINITE
	idx = check_kaolinite(T,sums);
	minerals(idx) = {'Kaolinite-like'};
% CALCIUM SILICATE MIX
	idx = check_calcium_silicate_mix(T,sums);
	minerals(idx) = {'Ca-rich silicate/Ca-Si-mixture'};
% CALCITE
	idx = check_calcite(T,sums);
	minerals(idx) = {'Calcite-like'};
% DOLOMITE
	idx = check_dolomite(T,sums);
	minerals(idx) = {'Dolomite-like'};
% APATITE
	idx = check_apatite(T,sums);
	minerals(idx) = {'Apatite-like'};
% GYPSUM
	idx = check_gypsum(T,sums);
	minerals(idx) = {'Gypsum-like'};
% ALUNITE
	idx = check_alunite(T,sums);
	minerals(idx) = {'Alunite-like'};
% HALITE
	idx = check_halite(T,sums);
	minerals(idx) = {'Halite-like'};
% COMPLEX SULFATE 
	idx = check_complex_sulfate(T,sums);
	minerals(idx) = {'Complex sulfate'};
end

function index = check_hematite(T,sums)
	criteria1 = T.Fe ./ sums; 
	criteria2 = T.Cr ./ (T.Cr+T.Fe);
	criteria3 = T.Cl ./ (T.Cl+T.Fe);
	criteria4 = (T.F+T.Si) ./ (T.F + sums);
	criteria5 = T.Ti ./ T.Fe;
	index = ((criteria1 >= 0.5) & (criteria1 <= 0.98999))...
			& ((criteria2 >= 0) & (criteria2 <= 0.1))...
			& ((criteria3 >= 0) & (criteria3 <= 0.1))...
			& ((criteria4 >= 0) & (criteria4 <= 0.499))...
			& ((criteria5 >= 0) & (criteria5 <= 0.24999));
end

function index = check_rutile(T,sums)
	criteria1 = T.Ti ./ sums;
	criteria2 = T.Ca ./ (T.Ca+T.Ti);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.3));
end

function index = check_illmenite(T,sums)
	criteria1 = (T.Fe+T.Ti) ./ sums;
	criteria2 = T.Ti ./ T.Fe;
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.25) & (criteria2 <= 4));
end

function index = check_quartz(T,sums)
	criteria1 = T.Si ./ sums;
	criteria2 = (T.Na+T.Mg+T.K+T.Ca+T.Al) ./ T.Si;
	criteria3 = T.F ./ (T.F+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.2))...
			& ((criteria3 >= 0) & (criteria3 <= 0.499));
end

function index = check_complex_quartz(T,sums)
	criteria1 = (T.Al+T.Si+T.Na+T.Mg+T.K+T.Ca+T.Fe) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = (T.Na+T.K+T.Ca) ./ T.Si;
	criteria4 = T.Fe ./ T.Si;
	criteria5 = T.Ca ./ T.Si;
	criteria6 = T.K ./ T.Si;
	criteria7 = T.Mg ./ T.Si;
	criteria8 = T.Na ./ T.Si;
	criteria9 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.05) & (criteria2 <= 0.25))...
			& ((criteria3 >= 0) & (criteria3 <= 1))...
			& ((criteria4 >= 0) & (criteria4 <= 0.5))...
			& ((criteria5 >= 0) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0) & (criteria6 <= 0.5))...
			& ((criteria7 >= 0) & (criteria7 <= 0.5))...
			& ((criteria8 >= 0) & (criteria8 <= 0.5))...
			& ((criteria9 >= 0) & (criteria9 <= 0.25));
end

function index = check_microcline(T,sums)
	criteria1 = (T.K+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.K ./ T.Si;
	criteria4 = T.Ca ./ T.Si;
	criteria5 = T.Na ./ T.Si;
	criteria6 = (T.Cl+(2.*T.S)) ./ T.Na;
	criteria7 = (T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.2) & (criteria2 <= 0.45))...
			& ((criteria3 >= 0.15) & (criteria3 <= 0.5))...
			& ((criteria4 >= 0) & (criteria4 <= 0.1))...
			& ((criteria5 >= 0) & (criteria5 <= 0.1))...
			& ((criteria6 >= 0) & (criteria6 <= 0.3))...
			& ((criteria7 >= 0) & (criteria7 <= 0.125));
end

function index = check_albite(T,sums)
	criteria1 = (T.Na+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.Na ./ T.Si;
	criteria4 = T.Ca ./ T.Si;
	criteria5 = T.K ./ T.Si;
	criteria6 = (T.Cl+(2.*T.S)) ./ T.Na;
	criteria7 = (T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.2) & (criteria2 <= 0.45))...
			& ((criteria3 >= 0.15) & (criteria3 <= 0.5))...
			& ((criteria4 >= 0) & (criteria4 <= 0.1))...
			& ((criteria5 >= 0) & (criteria5 <= 0.1))...
			& ((criteria6 >= 0) & (criteria6 <= 0.3))...
			& ((criteria7 >= 0) & (criteria7 <= 0.125));
end

function index = check_complex_feldspar(T,sums)
	criteria1 = (T.Al+T.Si+T.Na+T.Mg+T.K+T.Ca+T.Fe) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = (T.Na+T.K+T.Ca) ./ T.Si;
	criteria4 = T.Fe ./ T.Si;
	criteria5 = T.Ca ./ T.Si;
	criteria6 = T.K ./ T.Si;
	criteria7 = T.Mg ./ T.Si;
	criteria8 = T.Na ./ T.Si;
	criteria9 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.25) & (criteria2 <= 0.5))...
			& ((criteria3 >= 0.125) & (criteria3 <= 0.7))...
			& ((criteria4 >= 0) & (criteria4 <= 0.5))...
			& ((criteria5 >= 0) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0) & (criteria6 <= 0.5))...
			& ((criteria7 >= 0) & (criteria7 <= 0.5))...
			& ((criteria8 >= 0) & (criteria8 <= 0.5))...
			& ((criteria9 >= 0) & (criteria9 <= 0.25));
end

function index = check_complex_clay_feldspar_mix(T,sums)
	criteria1 = (T.Al+T.Si+T.Na+T.Mg+T.K+T.Ca+T.Fe) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = (T.Na+T.K+T.Ca) ./ T.Si;
	criteria4 = T.Fe ./ T.Si;
	criteria5 = T.Ca ./ T.Si;
	criteria6 = T.K ./ T.Si;
	criteria7 = T.Mg ./ T.Si;
	criteria8 = T.Na ./ T.Si;
	criteria9 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.25) & (criteria2 <= 0.5))...
			& ((criteria3 >= 0) & (criteria3 <= 0.125))...
			& ((criteria4 >= 0) & (criteria4 <= 0.5))...
			& ((criteria5 >= 0) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0) & (criteria6 <= 0.5))...
			& ((criteria7 >= 0) & (criteria7 <= 0.5))...
			& ((criteria8 >= 0) & (criteria8 <= 0.5))...
			& ((criteria9 >= 0) & (criteria9 <= 0.25));
end

function index = check_mica(T,sums)
	criteria1 = (T.Ca+T.Na+T.K+T.Fe+T.Mg+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = (T.Na+T.K+T.Ca+T.Mg+T.Fe) ./ T.Si;
	criteria4 = (T.Cl+(2.*T.S)) ./ T.Na;
	criteria5 = (T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.2) & (criteria2 <= 3))...
			& ((criteria3 >= 0.5) & (criteria3 <= 2.5))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3))...
			& ((criteria5 >= 0) & (criteria5 <= 0.125));
end

function index = check_complex_clay(T,sums)
	criteria1 = (T.Al+T.Si+T.Na+T.Mg+T.K+T.Ca+T.Fe) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = (T.Mg+T.Fe+T.K) ./ T.Si;
	criteria4 = T.Fe ./ T.Si;
	criteria5 = T.Ca ./ T.Si;
	criteria6 = T.K ./ T.Si;
	criteria7 = T.Mg ./ T.Si;
	criteria8 = T.Na ./ T.Si;
	criteria9 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.5) & (criteria2 <= 1.5))...
			& ((criteria3 >= 0.1) & (criteria3 <= 1.0))...
			& ((criteria4 >= 0) & (criteria4 <= 0.5))...
			& ((criteria5 >= 0) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0) & (criteria6 <= 0.5))...
			& ((criteria7 >= 0) & (criteria7 <= 0.5))...
			& ((criteria8 >= 0) & (criteria8 <= 0.5))...
			& ((criteria9 >= 0) & (criteria9 <= 0.25));
end

function index = check_illite(T,sums)
	criteria1 = (T.K+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.Mg ./ (T.Al+T.Si);
	criteria4 = T.Fe ./ (T.Al+T.Si);
	criteria5 = (T.Na+T.Ca) ./ (T.Al+T.Si);
	criteria6 = T.K ./ T.Si;
	criteria7 = (T.Na+T.Cl+2.*T.S) ./ (T.Al+T.Si);
	index = ((criteria1 > 0.7) & (criteria1 < 1.01))...
			& ((criteria2 > 0.45) & (criteria2 < 1.5))...
			& ((criteria3 > 0) & (criteria3 < 0.2))...
			& ((criteria4 > 0) & (criteria4 < 0.2))...
			& ((criteria5 > 0) & (criteria5 < 0.2))...
			& ((criteria6 > 0.1) & (criteria6 < 1.01))...
			& ((criteria7 > 0) & (criteria7 < 0.25));
end

function index = check_chlorite(T,sums)
	criteria1 = (T.Mg+T.Fe+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.Fe ./ (T.Al+T.Si);
	criteria4 = T.Ca ./ (T.Al+T.Si);
	criteria5 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.5) & (criteria2 <= 1.5))...
			& ((criteria3 >= 0.2) & (criteria3 <= 1.01))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3))...
			& ((criteria5 >= 0) & (criteria5 <= 0.25));
end

function index = check_smectite(T,sums)
	criteria1 = (T.Mg+T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.Fe ./ (T.Al+T.Si);
	criteria4 = T.Mg ./ (T.Al+T.Si);
	criteria5 = T.Ca ./ (T.Al+T.Si);
	criteria6 = T.Na ./ (T.Al+T.Si);
	criteria7 = T.K ./ T.Si;
	criteria8 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.5) & (criteria2 <= 1.5))...
			& ((criteria3 >= 0) & (criteria3 <= 0.2))...
			& ((criteria4 >= 0.2) & (criteria4 <= 1.01))...
			& ((criteria5 >= 0) & (criteria5 <= 0.2))...
			& ((criteria6 >= 0) & (criteria6 <= 0.2))...
			& ((criteria7 >= 0) & (criteria7 <= 0.1))...
			& ((criteria8 >= 0) & (criteria8 <= 0.25));
end

function index = check_kaolinite(T,sums)
	criteria1 = (T.Al+T.Si) ./ sums;
	criteria2 = T.Al ./ T.Si;
	criteria3 = T.Fe ./ (T.Al+T.Si);
	criteria4 = T.Mg ./ (T.Al+T.Si);
	criteria5 = T.Ca ./ (T.Al+T.Si);
	criteria6 = T.Na ./ (T.Al+T.Si);
	criteria7 = T.K ./ T.Si;
	criteria8 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.5) & (criteria2 <= 1.5))...
			& ((criteria3 >= 0) & (criteria3 <= 0.2))...
			& ((criteria4 >= 0) & (criteria4 <= 0.2))...
			& ((criteria5 >= 0) & (criteria5 <= 0.2))...
			& ((criteria6 >= 0) & (criteria6 <= 0.15))...
			& ((criteria7 >= 0) & (criteria7 <= 0.1))...
			& ((criteria8 >= 0) & (criteria8 <= 0.25));
end

function index = check_calcium_silicate_mix(T,sums)
	criteria1 = (T.Ca+T.Al+T.Si) ./ sums;
	criteria2 = T.Ca ./ (T.Al+T.Si);
	criteria3 = (T.Na+T.Cl+(2.*T.S)) ./ (T.Al+T.Si);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.3) & (criteria2 <= 3.333))...
			& ((criteria3 >= 0) & (criteria3 <= 0.25));
end

function index = check_calcite(T,sums)
	criteria1 = T.Ca ./ sums;
	criteria2 = (T.Al+T.Si) ./ T.Ca;
	criteria3 = T.Mg ./ T.Ca;
	criteria4 = T.S ./ T.Ca;
	criteria5 = T.Cl ./ T.Ca;
	criteria6 = T.P ./ (T.Ca+T.P);
	criteria7 = T.S ./ (T.Ca+T.S);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.3))...
			& ((criteria3 >= 0) & (criteria3 <= 0.3))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3))...
			& ((criteria5 >= 0) & (criteria5 <= 0.3))...
			& ((criteria6 >= 0) & (criteria6 <= 0.19))...
			& ((criteria7 >= 0) & (criteria7 <= 0.19));
end

function index = check_dolomite(T,sums)
	criteria1 = (T.Mg+T.Ca) ./ sums;
	criteria2 = T.Mg ./ T.Ca;
	criteria3 = T.S ./ T.Ca;
	criteria4 = T.Cl ./ T.Ca;
	criteria5 = (T.Al+T.Si) ./ T.Ca;
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.3) & (criteria2 <= 3.0))...
			& ((criteria3 >= 0) & (criteria3 <= 0.3))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3))...
			& ((criteria5 >= 0) & (criteria5 <= 0.3));
end

function index = check_apatite(T,sums)
	criteria1 = (T.Ca+T.P) ./ sums;
	criteria2 = T.Mg ./ T.Ca;
	criteria3 = T.P ./ (T.Ca+T.P);
	criteria4 = T.Cl ./ T.Ca;
	criteria5 = (T.Al+T.Si) ./ (T.P+T.Ca);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.3))...
			& ((criteria3 >= 0.2) & (criteria3 <= 0.8))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3))...
			& ((criteria5 >= 0) & (criteria5 <= 0.25));
end

function index = check_gypsum(T,sums)
	criteria1 = (T.Ca+T.S) ./ sums;
	criteria2 = T.Ca ./ (T.Ca+T.S);
	criteria3 = T.Mg ./ T.Ca;
	criteria4 = T.Cl ./ T.Ca;
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.2) & (criteria2 <= 0.8))...
			& ((criteria3 >= 0) & (criteria3 <= 0.3))...
			& ((criteria4 >= 0) & (criteria4 <= 0.3));
end

function index = check_alunite(T,sums)
	criteria1 = (T.Al+T.K+T.S) ./ sums;
	criteria2 = T.Ca ./ (T.Ca+T.Al+T.K+T.S);
	criteria3 = T.Si ./ (T.Si+T.Al+T.K+T.S);
	criteria4 = T. K ./ (T.Al+T.K+T.S);
	criteria5 = T.S ./ (T.Al+T.K+T.S);
	criteria6 = T.Al ./ (T.Al+T.K+T.S);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.05))...
			& ((criteria3 >= 0) & (criteria3 <= 0.1))...
			& ((criteria4 >= 0.05) & (criteria4 <= 3.0))...
			& ((criteria5 >= 0.15) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0.3) & (criteria6 <= 0.8));
end

function index = check_halite(T,sums)
	criteria1 = (T.Na+T.Mg+T.Cl) ./ sums;
	criteria2 = T.Cl ./ (T.Na+(0.5.*T.Mg));
	criteria3 = T.Cl ./ (T.Cl+T.S);
	criteria4 = T.S ./ (T.Na+(0.5.*T.Mg));
	criteria5 = T.K ./ T.Na;
	criteria6 = T.Ca ./ T.Na;
	criteria7 = T.Mg ./ T.Na;
	criteria8 = (T.Al+T.Si) ./ (T.Na+T.Cl+T.S);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0.5) & (criteria2 <= 2.0))...
			& ((criteria3 >= 0.7) & (criteria3 <= 1.01))...
			& ((criteria4 >= 0) & (criteria4 <= 0.2))...
			& ((criteria5 >= 0) & (criteria5 <= 0.5))...
			& ((criteria6 >= 0) & (criteria6 <= 0.5))...
			& ((criteria7 >= 0) & (criteria7 <= 0.5))...
			& ((criteria8 >= 0) & (criteria8 <= 0.25));
end

function index = check_complex_sulfate(T,sums)
	criteria1 = (T.Na+T.Mg+T.K+T.Ca+T.S+T.Cl) ./ sums;
	criteria2 = (T.Al+T.Si) ./ T.S;
	criteria3 = T.Cl ./ (T.Cl+T.S);
	index = ((criteria1 >= 0.7) & (criteria1 <= 1.01))...
			& ((criteria2 >= 0) & (criteria2 <= 0.25))...
			& ((criteria3 >= 0) & (criteria3 <= 0.3));
end

function sums = element_sums(T)
	sums = T.Na + ...
		T.Mg + ...
		T.Al + ...
		T.Si + ...
		T.P + ...
		T.S + ...
		T.Cl + ...
		T.K + ...
		T.Ca + ...
		T.Ti + ...
		T.Cr + ...
		T.Mn + ...
		T.Fe;
end
%
% END FUNCTION
%
end