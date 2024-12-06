"""
Mineral classifcation scheme from Donarummo et al. (2003)

DESCRIPTION

This function automates the mineral classification workflow published by Donarummo et al. (2003). Takes a table of energy dispersive spectrometry (EDS) net intensity data and assigns a mineralogy to each row.

SYNTAX

minerals = donarummo_classification(df)

INPUT

"df" :: DataFrame containing a column for each of the following elements: Na, Mg, Al, Si, K, Ca, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required by spelling is paramount. The values in the table should represent the measured net intensity for each element.

OUTPUT

"minerals" :: DataFrame of mineral names corresponding to each row in the input DataFrame.

LIST OF POSSIBLE MINERAL CLASSIFICATIONS

 1. Ab [Albite]
 2. An [Anorthite]
 3. Aug [Augite]
 4. Bt [Biotite]
 5. Chl [Chlorite]
 6. Hbl [Hornblende]
 7. Htr [Hectorite]
 8. Ilt [Illite]
 9. Ilt/Sme [Illite/Smectite 70/30 mix]
10. Kln [Kaolinite]
11. Lab/Byt [Labradorite/Bytownite]
12. Mnt [Montmorillonite]
13. Ms [Muscovite]
14. Olig/Ans [Oligoclase/Andesine]
15. Afs [Orthoclase = Alkali feldspar AKA Microcline, Mc]
16. Vrm [Vermiculite]

LIMITATIONS

This function will misclassify any mineral not present in the list above. For instance, net intensity data for the mineral quartz will never be classified as quartz. Some minerals may be classified as "U-" (i.e., an unknown class) if their elemental compositions do not satisify any of the indexing criteria. To maximize the usefulness of this algorithm the user should also consult the results of additional classification methods.

REFERENCE

Donarummo et al. (2003). Geophyiscal Research Letters 30(6), 1269. https://doi.org/10.1029/2002GL016641

COPYRIGHT

©2024 Austin M. Weber - function code

"""
function donarummo_classification(df)
    
        ###
        ### BEGIN FUNCTION BODY
        ###
        
        # Check that input is a DataFrame
        @assert typeof(df) == DataFrame "Input must be a DataFrame"
    
        # Convert full-name table variables to abbreviations
        element_names = ["Aluminum","Aluminium","Silicon","Iron","Sodium","Magnesium","Potassium","Calcium"] # Vector{String}
        element_names = map(lowercase,element_names)
        varnames = names(df)
        varnames_lower = map(lowercase,varnames) # Vector{String}
        element_abbreviations = ["Al","Al","Si","Fe","Na","Mg","K","Ca"]
        for (n, abbreviation) in enumerate(element_abbreviations)
            if any(x -> contains(x, element_names[n]), varnames_lower)
                idx = contains.(varnames_lower, element_names[n])
                varnames[idx] .= abbreviation
            end
        end
        rename!(df,varnames) # Replace variable names in DataFrame
    
        # Ensure that all 7 of the necessary columns exist
        if sum(in.(varnames, Ref(["Na","Mg","Al","Si","K","Ca","Fe"]))) != 7
            error("Input must be a DataFrame containing a column for Na, Mg, Al, Si, K, Ca, and Fe. Check the spellings of the column names. Only full element names and abbreviations are valid.")
        end
    
"""
The Donarummo algorithm is a sorting scheme with the following structure:

                                  [1]
        ___________________________|_____________________________
        |                          |                            |
       [2A]                       [2B]                         [2C]
        |                __________|___________                 |
        |               |                      |                |
       [3A]           [3B1]                  [3B2]             [3C]
                        |              ________|________        |
                        |              |               |        |
                     [4B1a]          [4B2a]          [4B2b]    [4C]
                        |        ______|______          
                        |        |           |         
                     [5B1a]   [5B2a1]      [5B2a2]

The nodes in schematic above (indicated with brackets []) are criteria checks. Each node has its own local function, defined below.

"""
function node1(T)
	ratio1 = T[:Al] ./ T[:Si];
	if ratio1 < 0.1
		node2A(T);
	elseif ratio1 >= 0.7
		node2C(T);
	else
		node2B(T);
	end
end

function node2A(T)
	ratio2A = T[:Fe] ./ T[:Si];
	if ratio2A >= 0.02
		node3A(T);
	else
		val = "Htr"; # Hectorite, does not have an abbreviation in Whitney & Evans 2010
        return val
	end
end

function node3A(T)
	ratio3A = T[:K] ./ T[:Al];
	if ratio3A < 0.3
		val = "Aug"; # Augite
        return val
	elseif ratio3A > 0.49
		val = "Hbl"; # Horblende
        return val
	else
		val = "U-A";
        return val
	end
end

function node2C(T)
	ratio2C = (T[:Mg] + T[:Fe]) ./ T[:Si];
	if ratio2C >= 0.9
		val = "Chl"; # Chlorite
        return val
	elseif ratio2C < 0.3
		node3C(T);
	else
		val = "U-E";
        return val
	end
end

function node3C(T)
	ratio3C = T[:K] ./ T[:Si];
	if ratio3C >= 0.1
		val = "Ms"; # Muscovite
        return val
	else
		node4C(T);
	end
end

function node4C(T)
	ratio4C = T[:Ca] ./ T[:Si];
	if ratio4C < 0.05
		val = "Kln"; # Kaolinite
        return val
	elseif ratio4C >= 0.25
		val = "An"; # Anorthite
        return val
	else
		val = "U-F";
        return val
	end
end

function node2B(T)
	ratio2B = T[:K] / (T[:K] + T[:Na] + T[:Ca]);
	if ratio2B < 0.35
		node3B1(T);
	else
		node3B2(T);
	end
end

function node3B1(T)
	ratio3B1 = (T[:Mg] .+ T[:Fe]) ./ T[:Al];
	if ratio3B1 < 0.3
		node4B1a(T);
	elseif ratio3B1 >= 1.0
		val = "U-C1";
        return val
	elseif (ratio3B1 > 0.5) && (ratio3B1 < 1.0)
		val = "U-B1";
        return val
	else
		val = "Mnt"; # Ca-Montmorillonite
        return val
	end
end

function node4B1a(T)
	ratio4B1a = (T[:Ca] .+ T[:Na]) ./ T[:Al];
	if ratio4B1a >= 0.23
		node5B1a1(T);
	else
		val = "U-B2";
        return val
	end
end

function node5B1a1(T)
	ratio5B1a1 = T[:Ca] ./ T[:Na];
	if ratio5B1a1 < 0.2
		val = "Ab"; # Albite
        return val
	elseif ratio5B1a1 >= 10
		val = "U-B3";
        return val
	elseif (ratio5B1a1 >= 0.2) && (ratio5B1a1 < 1)
		val = "Olig/Ans"; # Oligoclase/Andesine; my own abbreviations
        return val
	else
		val = "Lab/Byt"; # Labradorite/Bytownite; my own abbreviations
        return val
	end
end

function node3B2(T)
	ratio3B2 = (T[:Mg] .+ T[:Fe]) ./ T[:Al];
	if ratio3B2 < 0.55
		node4B2a(T);
	else
		node4B2b(T);
	end
end

function node4B2b(T)
	ratio4B2b = T[:K] ./ T[:Al];
	if ratio4B2b <= 0.1
		val = "U-C2";
        return val
	elseif ratio4B2b > 2
		val = "Vrm"; # K-vermiculite
        return val
	elseif (ratio4B2b > 0.1) && (ratio4B2b < 1)
		val = "U-D5";
        return val
	else
		val = "Bt"; # Biotite
        return val
	end
end

function node4B2a(T)
	ratio4B2a = T[:K] ./ T[:Al];
	if ratio4B2a >= 0.7
		node5B2a1(T);
	else
		node5B2a2(T);
	end
end

function node5B2a1(T)
	ratio5B2a1 = T[:Al] ./ T[:Si];
	if ratio5B2a1 < 0.25
		val = "U-D2";
        return val
	elseif (ratio5B2a1 >= 0.25) && (ratio5B2a1 <= 0.35)
		val = "Afs"; # Orthoclase == alkali feldspar
        return val
	elseif (ratio5B2a1 > 0.35) && (ratio5B2a1 < 0.7)
		val = "U-D1";
        return val
	end
end

function node5B2a2(T)
	ratio5B2a2 = T[:K] ./ (T[:Al] + T[:Si]);
	if ratio5B2a2 <= 0.05
		val = "U-D4";
        return val
	elseif ratio5B2a2 > 0.25
		val = "U-D3";
        return val
	elseif (ratio5B2a2 > 0.05) && (ratio5B2a2 <= 0.1)
		val = "Ilt/Sme"; # Illite/Smectite 70/30 mixed
        return val
	else
		val = "Ilt"; # Illite
        return val
	end
end
        
# Final step: Classify the mineralogy for each row of the input table
minerals = [] #fill("Unknown", num_classifications) # Preallocate memory
for row in eachrow(df)
	mineral = node1(row); # Begin classification at first node of the sorting scheme
    push!(minerals,mineral)
end
minerals = DataFrame(Minerals = map(string,minerals))   
return minerals
end