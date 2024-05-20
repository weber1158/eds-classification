function minerals = donarummo_classification(peak_intensity_table)
% minerals = donarummo_classification(peak_intensity_table) 
% Performs a simple mineral classification on a table of elemental intensity data.
%
% The sorting scheme from Figure 2 in Donarummo et al. (2003) is used to identify the
% mineralogy of a sample given an input table of peak intensities as measured by
% energy-dispersive xray spectrometry (EDS) on an electron microscope.
% 
% The table must contain a column for each of the following elements: Al, Si, Fe, Ca,
% Na, K, and Mg. The name for each of these columns must match the shorthand notation 
% for the element (e.g. "Al" not "Aluminium"). 
% 
% The function returns the evaluated mineral name as a 1-by-1 categorical.
% Mineral names are given as abbreviations using the taxonmy proposed by
% Whitney and Evans (2010) unless otherwise stated. Unknown mineral
% classifications are given names beginning with "U-" as proposed by
% Donarummo et al. (2003).
% 
% Example:
% 	% Generate a table of elemental intensities using random integers
% 		sz = [1000,1];
% 		Al = randi(12000,sz);
% 		Si = randi(30000,sz);
% 		Fe = randi(6000,sz);
% 		Ca = randi(4000,sz);
% 		Na = randi(4000,sz);
% 		K  = randi(2000,sz);
% 		Mg = randi(1000,sz);
% 		elements = [Al,Si,Fe,Ca,Na,K,Mg];
% 		myTable = array2table(elements,'VariableNames',{'Al','Si','Fe','Ca','Na','K','Mg'});
% 	% Classify the mineralogy of each row
% 		minerals = donarummo_classification(myTable);
%

% References:
% Donarummo, J., Ram, M., & Stoermer, E. F. (2003). Possible deposit of soil dust from the 1930 s U.S. dust bowl identified in Greenland ice. Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641
% Whitney, D. L., & Evans, B. W. (2010). Abbreviations for names of rock-forming minerals. American Mineralogist, 95(1), 185–187. https://doi.org/10.2138/am.2010.3371

% Function code ©2023 Austin M. Weber

%
% BEGIN FUNCTION BODY
%
% Perform initial function checks
if ~istable(peak_intensity_table)
	error('Input must be a table.')
end
vars = peak_intensity_table.Properties.VariableNames;
if sum(ismember(vars,{'Al','Si','Fe','Ca','Na','K','Mg'})) ~= 7
	error('Input must be a table containing columns for Al, Si, Fe, Ca, Na, K, and Mg.')
end
% Classify the mineral for each row of the input table
num_classifications = size(peak_intensity_table,1); 
minerals = categorical([]);
for n = 1:num_classifications
	mineral = node1(peak_intensity_table(n,:)); 
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
		val = categorical("Hectorite"); % Htr
	end
end

function val = node3A(T)
	ratio3A = T.K ./ T.Al;
	if ratio3A < 0.3
		val = categorical("Augite"); % Aug
	elseif ratio3A > 0.49
		val = categorical("Hornblende"); % Hbl
	else
		val = categorical("U-A");
	end
end

function val = node2C(T)
	ratio2C = (T.Mg + T.Fe) ./ T.Si;
	if ratio2C >= 0.9
		val = categorical("Chlorite"); % Chl
	elseif ratio2C < 0.3
		val = node3C(T);
	else
		val = categorical("U-E");
	end
end

function val = node3C(T)
	ratio3C = T.K ./ T.Si;
	if ratio3C >= 0.1
		val = categorical("Muscovite"); % Ms
	else
		val = node4C(T);
	end
end

function val = node4C(T)
	ratio4C = T.Ca ./ T.Si;
	if ratio4C < 0.05
		val = categorical("Kaolinite"); % Kln
	elseif ratio4C >= 0.25
		val = categorical("Anorthite"); % An
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
		val = categorical("Ca-Montmorillonite"); % Ca-Montmorillonite (Mnt)
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
		val = categorical("Albite"); % Ab
	elseif ratio5B1a1 >= 10
		val = categorical("U-B3");
	elseif (ratio5B1a1 >= 0.2) && (ratio5B1a1 < 1)
		val = categorical("Olig/Andesine"); % Olg/Ans; my own abbreviations
	else
		val = categorical("Lab/Bytownite"); % Lab/Byt; my own abbreviations
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
		val = categorical("Vermiculite"); % K-vermiculite (Vrm)
	elseif (ratio4B2b > 0.1) && (ratio4B2b < 1)
		val = categorical("U-D5");
	else
		val = categorical("Biotite"); % Bt
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
		val = categorical("Orthoclase"); % Or
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
		val = categorical("I/S mixed"); % Ilt/Sme mixed
	else
		val = categorical("Illite"); % Ilt
	end
end

%
% END FUNCTION BODY
%
end