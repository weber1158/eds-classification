"""
Mineral classifcation scheme from Donarummo et al. (2003)

DESCRIPTION

This function automates the mineral classification workflow published by Donarummo et al. (2003). Takes a table of energy dispersive spectrometry (EDS) net intensity data and assigns a mineralogy to each row.

SYNTAX

minerals = donarummo_classification(df)

INPUT

"df" :: DataFrame containing a column for each of the following elements: Na, Mg, Al, Si, K, Ca, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required by spelling is paramount. The values in the table should represent the measured net intensity for each element.

OUTPUT

"minerals" :: Categorical vector of mineral names corresponding to each row in the input DataFrame.

LIST OF POSSIBLE MINERAL CLASSIFICATIONS

 1. Albite
 2. Anorthite
 3. Augite
 4. Biotite
 5. Chlorite
 6. Hornblende
 7. Hectorite
 8. Illite
 9. Illite/Smectite 70/30 mix
10. Kaolinite
11. Labradorite/Bytownite
12. Montmorillonite
13. Muscovite
14. Oligoclase/Andesine
15. Orthoclase
16. Vermiculite

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
    
        ###
        ### CREATE LOCAL FUNCTIONS
        ###
        function mineral_classification(DF)
            num_classifications = nrow(DF)
            minerals = fill("Unknown", num_classifications) # Preallocate memory
    
            # FIRST BRANCHING PATHWAY
                # HECTORITE
                    idx = check_hectorite(DF)
                    minerals[idx] .= ["Hectorite"]
                # AUGITE
                    idx = check_augite(DF)
                    minerals[idx] .= ["Augite"]
                # U-A
                    idx = check_UA(DF)
                    minerals[idx] .= ["U-A"]
                # HORNBLENDE
                    idx = check_hornblende(DF)
                    minerals[idx] .= ["Hornblende"]
            # SECOND BRANCHING PATHWAY - B
                # ALBITE
                    idx = check_albite(DF)
                    minerals[idx] .= ["Albite"]
                # OLIG/ANDESINE
                    idx = check_olig(DF)
                    minerals[idx] .= ["Olig/Andesine"]
                # LAB/BYTOWNITE
                    idx = check_lab(DF)
                    minerals[idx] .= ["Lab/Bytownite"]
                # U-B3
                    idx = check_UB3(DF)
                    minerals[idx] .= ["U-B3"]
                # U-B2
                    idx = check_UB2(DF)
                    minerals[idx] .= ["U-B2"]
                # Ca-MONTMORILLONITE
                    idx = check_montmorillonite(DF)
                    minerals[idx] .= ["Ca-Montmorillonite"]
                # U-B1
                    idx = check_UB1(DF)
                    minerals[idx] .= ["U-B1"]
                # U-C1
                    idx = check_UC1(DF)
                    minerals[idx] .= ["U-C1"]
            # SECOND BRANCHING PATHWAY - B
                # U-D2
                    idx = check_UD1(DF)
                    minerals[idx] .= ["U-D2"]
                # ORTHOCLASE
                    idx = check_orthoclase(DF)
                    minerals[idx] .= ["Orthoclase"]
                # U-D1
                    idx = check_UD1(DF)
                    minerals[idx] .= ["U-D1"]
                # U-D0 (Note: this class is NOT defined by Donarummo et al. (2003)
                    idx = check_UD0(DF)
                    minerals[idx] .= ["U-D0"]
                # U-D4
                    idx = check_UD4(DF)
                    minerals[idx] .= ["U-D4"]
                # I/S MIXED (70/30)
                    idx = check_ISmix(DF)
                    minerals[idx] .= ["I/S Mixed (70/30)"]
                # ILLITE
                    idx = check_illite(DF)
                    minerals[idx] .= ["Illite"]
                # U-D3
                    idx = check_UD3(DF)
                    minerals[idx] .= ["U-D3"]
                # U-C2
                    idx = check_UC2(DF)
                    minerals[idx] .= ["U-C2"]
                # U-D5
                    idx = check_UD5(DF)
                    minerals[idx] .= ["U-D5"]
                # BIOTITE
                    idx = check_biotite(DF)
                    minerals[idx] .= ["Biotite"]
                # K-VERMICULITE
                    idx = check_vermiculite(DF)
                    minerals[idx] .= ["K-Vermiculite"]
            # THIRD BRANCHING PATHWAY
                # CHLORITE
                    idx = check_chlorite(DF)
                    minerals[idx] .= ["Chlorite"]
                # U-E
                    idx = check_UE(DF)
                    minerals[idx] .= ["U-E"]
                # MUSCOVITE
                    idx = check_muscovite(DF)
                    minerals[idx] .= ["Muscovite"]
                # KAOLINITE
                    idx = check_kaolinite(DF)
                    minerals[idx] .= ["Kaolinite"]
                # U-F
                    idx = check_UF(DF)
                    minerals[idx] .= ["U-F"]
                # ANORTHITE
                    idx = check_anorthite(DF)
                    minerals[idx] .= ["Anorthite"]    
            return minerals
        end ### END mineral_classification() FUNCTION
    
        # FIRST BRANCHING PATHWAY
        function check_hectorite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:Fe] ./ T[:,:Si]
            index = (criteria1 .< 0.1) .& (criteria2 .< 0.02)
            return index
        end
        function check_augite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:Fe] ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Al]
            index = (criteria1 .< 0.1) .& (criteria2 .>= 0.02) .& (criteria3 .< 0.3)
            return index
        end
        function check_UA(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:Fe] ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Al]
            index = (criteria1 .< 0.1) .& (criteria2 .>= 0.02) .& (criteria3 .>= 0.3) .& (criteria3 .<= 0.49)
            return index
        end
        function check_hornblende(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:Fe] ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Al]
            index = (criteria1 .< 0.1) .& (criteria2 .>= 0.02) .& (criteria3 .> 0.49)
            return index
        end
    
        # SECOND BRACHING PATHWAY - A
        function check_albite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = (T[:,:Ca] .+ T[:,:Na]) ./ T[:,:Al]
            criteria5 = T[:,:Ca] ./ T[:,:Na]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .< 0.3)
                .& (criteria4 .>= 0.23)
                .& (criteria5 .< 0.2))
            return index
        end
        function check_olig(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = (T[:,:Ca] .+ T[:,:Na]) ./ T[:,:Al]
            criteria5 = T[:,:Ca] ./ T[:,:Na]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7)
                .& (criteria2 .< 0.35)
                .& (criteria3 .< 0.3)
                .& (criteria4 .>= 0.23)
                .& (criteria5 .>= 0.2) .& (criteria5 .< 1.0))
            return index
        end
        function check_lab(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = (T[:,:Ca] .+ T[:,:Na]) ./ T[:,:Al]
            criteria5 = T[:,:Ca] ./ T[:,:Na]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .< 0.3)
                .& (criteria4 .>= 0.23)
                .& (criteria5 .>= 1.0) .& (criteria5 .< 10.0))
            return index
        end
        function check_UB3(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = (T[:,:Ca] .+ T[:,:Na]) ./ T[:,:Al]
            criteria5 = T[:,:Ca] ./ T[:,:Na]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .< 0.3)
                .& (criteria4 .>= 0.23)
                .& (criteria5 .> 10.0))
            return index
        end
        function check_UB2(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = (T[:,:Ca] .+ T[:,:Na]) ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .< 0.3)
                .& (criteria4 .< 0.23))
            return index
        end
        function check_montmorillonite(T)
           criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .>= 0.3) .& (criteria3 .<= 0.5))
            return index
        end
        function check_UB1(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .> 0.5) .& (criteria3 .< 1.0))
            return index
        end
        function check_UC1(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .< 0.35)
                .& (criteria3 .>= 1.0))
            return index
        end
        
        # SECOND BRANCHING PATHWAY - B
        function check_UD2(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:Al] ./ T[:,:Si]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .>= 0.7)
                .& (criteria5 .< 0.25))
            return index
        end
        function check_orthoclase(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:Al] ./ T[:,:Si]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .>= 0.7)
                .& (criteria5 .>= 0.25) .& (criteria5 .< 0.35))
            return index
        end
        function check_UD1(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:Al] ./ T[:,:Si]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .>= 0.7)
                .& (criteria5 .> 0.35) .& (criteria5 .< 0.7))
            return index
        end
        function check_UD0(T)
            # Note: This class is NOT defined in Donarummo et al. (2003)!
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:Al] ./ T[:,:Si]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .>= 0.7)
                .& (criteria5 .>= 0.7))
            return index
        end
        function check_UD4(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:K] ./ (T[:,:Al] .+ T[:,:Si])
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .< 0.7)
                .& (criteria5 .<= 0.05))
            return index
        end
        function check_ISmix(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:K] ./ (T[:,:Al] .+ T[:,:Si])
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .< 0.7)
                .& (criteria5 .> 0.05) .& (criteria5 .<= 0.1))
            return index
        end
        function check_illite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:K] ./ (T[:,:Al] .+ T[:,:Si])
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .< 0.7)
                .& (criteria5 .> 0.1) .& (criteria5 .<= 0.25))
            return index
        end
        function check_UD3(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            criteria5 = T[:,:K] ./ (T[:,:Al] .+ T[:,:Si])
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .< 0.7)
                .& (criteria5 .> 0.25))
            return index
        end
        function check_UC2(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .<= 0.1))
            return index
        end
        function check_UD5(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .> 0.1) .& (criteria4 .< 1.0))
            return index
        end
        function check_biotite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .>= 1.0) .& (criteria4 .<= 2.0))
            return index
        end
        function check_vermiculite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = T[:,:K] ./ (T[:,:K] .+ T[:,:Na] .+ T[:,:Ca])
            criteria3 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Al]
            criteria4 = T[:,:K] ./ T[:,:Al]
            index = ((criteria1 .>= 0.1) .& (criteria1 .< 0.7) 
                .& (criteria2 .>= 0.35)
                .& (criteria3 .< 0.55)
                .& (criteria4 .> 2.0))
            return index
        end
    
        # THIRD BRANCHING PATHWAY
        function check_chlorite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            index = (criteria1 .>= 0.7) .& (criteria2 .>= 0.9)
            return index
        end
        function check_UE(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            index = (criteria1 .>= 0.7) .& (criteria2 .>= 0.3) .& (criteria2 .< 0.9) 
            return index
        end
        function check_muscovite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Si]
            index = (criteria1 .>= 0.7) .& (criteria2 .< 0.3) .& (criteria3 .>= 0.1) 
            return index
        end
        function check_kaolinite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Si]
            criteria4 = T[:,:Ca] ./ T[:,:Si]
            index = ((criteria1 .>= 0.7) 
                .& (criteria2 .< 0.3) 
                .& (criteria3 .< 0.1) 
                .& (criteria4 .< 0.05))
            return index
        end
        function check_UF(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Si]
            criteria4 = T[:,:Ca] ./ T[:,:Si]
            index = ((criteria1 .>= 0.7) 
                .& (criteria2 .< 0.3) 
                .& (criteria3 .< 0.1) 
                .& (criteria4 .>= 0.05) .& (criteria4 .< 0.25))
            return index
        end
        function check_anorthite(T)
            criteria1 = T[:,:Al] ./ T[:,:Si]
            criteria2 = (T[:,:Mg] .+ T[:,:Fe]) ./ T[:,:Si]
            criteria3 = T[:,:K] ./ T[:,:Si]
            criteria4 = T[:,:Ca] ./ T[:,:Si]
            index = ((criteria1 .>= 0.7) 
                .& (criteria2 .< 0.3) 
                .& (criteria3 .< 0.1) 
                .& (criteria4 .>= 0.25))
            return index
        end
        
        # Final step: Classify the mineralogy for each row of the input table
        minerals = DataFrame(Minerals = mineral_classification(df))
        
        return minerals
end