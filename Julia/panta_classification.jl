"""
Mineral classifcation scheme from Panta et al. (2023)

DESCRIPTION

This function automates the mineral classification workflow published by Panta et al. (2023). Takes a table of energy dispersive spectrometry (EDS) atomic percentage data and assigns a mineralogy to each row.

SYNTAX

minerals = panta_classification(df)

INPUT

"df" :: DataFrame containing a column for each of the following elements: F, Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required by spelling is paramount. The values in the table should represent the measured net intensity for each element.

OUTPUT

"minerals" :: DataFrame of general mineral classes corresponding to each row in the input DataFrame.


LIST OF POSSIBLE MINERAL CLASSIFICATIONS

 1. Albite
 2. Alunite
 3. Apatite
 4. Calcite
 5. Chlorite
 6. Dolomite
 7. Feldspar
 8. Gypsum
 9. Halite
10. Hematite
11. Ilmenite
12. Illite
13. Kaolinite
14. Mica
15. Microcline
16. Quartz
17. Rutile
18. Smectite

The algorithm also has classifications for:
- Ca-rich silicate/Ca-Si-mix
- Complex clay
- Complex feldspar
- Complex quartz
- Complex sulfate

LIMITATIONS

This function will misclassify any mineral not present in the list above. For instance, atom percent data for a mineral in pyroxene family will not be classified as a pyroxene because the original algorithm was not written to recognize pyroxenes. To maximize the usefulness of this algorithm the user should also consult the results of additional classification methods.

REFERENCE

Panta et al. (2023). Atmospheric Chemistry and Physics 23, 3861-3885. https://doi.org/10.5194/acp-23-3861-2023

COPYRIGHT

©2024 Austin M. Weber - function code

"""
function panta_classification(df)
    # Check that input is a DataFrame
        @assert typeof(df) == DataFrame "Input must be a DataFrame"
    
        # Convert full-name table variables to abbreviations
        element_names = ["Aluminum","Aluminium","Silicon","Iron","Sodium",
        "Magnesium","Potassium","Calcium","Phosphorus",
        "Sulfur","Chlorine","Titanium","Chromium","Manganese","Fluorine"] # Vector{String}
        element_names = map(lowercase,element_names)
        varnames = names(df)
        varnames_lower = map(lowercase,varnames) # Vector{String}
        element_abbreviations = ["Al","Al","Si","Fe","Na","Mg","K","Ca","P","S","Cl","Ti","Cr","Mn","F"]
        for (n, abbreviation) in enumerate(element_abbreviations)
            if any(x -> contains(x, element_names[n]), varnames_lower)
                idx = contains.(varnames_lower, element_names[n])
                varnames[idx] .= abbreviation
            end
        end
        rename!(df,varnames) # Replace variable names in DataFrame
    
        # Ensure that all 14 of the necessary columns exist
        if sum(in.(varnames, Ref(["F","Na","Mg","Al","Si","P","S","Cl","K","Ca","Ti","Cr","Mn","Fe"]))) != 14
            error("Input must be a DataFrame containing a column for F, Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. Check the spellings of the column names. Only full element names and abbreviations are valid.")
        end

    # Define local functions
    function element_sums(DF)
    # CALCULATE THE SUM OF ALL ELEMENTS IN A DATAFRAME
        sums = DF[:,:Na] .+ DF[:,:Mg] .+ DF[:,:Al] .+ DF[:,:Si] .+ DF[:,:P] 
        .+ DF[:,:S] .+ DF[:,:Cl] .+ DF[:,:K] .+ DF[:,:Ca] .+ DF[:,:Ti] .+ DF[:,:Cr] .+ DF[:,:Mn] .+ DF[:,:Fe]
        return sums
    end
    
    function mineral_classification(DF)
    # CALL MINERAL CLASSIFICATION INDEX FUNCTIONS AND ASSIGN VALUES TO THE OUTPUT
        num_classifications = nrow(DF)
        classifications = fill("Unknown", num_classifications) # Preallocate memory
        sums = element_sums(DF)

        # BEGIN CALLING INDEXES
        #01 HEMATITE
         idx = check_hematite(DF,sums,classifications)
         classifications[idx] .= ["Hematite-like"]
        #02 RUTILE
         idx = check_rutile(DF,sums,classifications)
         classifications[idx] .= ["Rutile-like"]
        #03 ILMENITE
         idx = check_ilmenite(DF,sums,classifications)
         classifications[idx] .= ["Ilmenite-like"]
        #04 QUARTZ
         idx = check_quartz(DF,sums,classifications)
         classifications[idx] .= ["Quartz-like"]
        #05 COMPLEX QUARTZ
         idx = check_complex_quartz(DF,sums,classifications)
         classifications[idx] .= ["Complex quartz-like"]
        #06 MICROCLINE
         idx = check_microcline(DF,sums,classifications)
         classifications[idx] .= ["Microcline-like"]
        #07 ALBITE
         idx = check_albite(DF,sums,classifications)
         classifications[idx] .= ["Albite-like"]
        #08 COMPLEX FELDSPAR
         idx = check_complex_feldspar(DF,sums,classifications)
         classifications[idx] .= ["Complex feldspar-like"]
        #09 COMPLEX CLAY/FELDSPAR MIXTURE
         idx = check_complex_clay_feldspar(DF,sums,classifications)
         classifications[idx] .= ["Complex Clay/Feldspar mix"]
        #10 MICA
         idx = check_mica(DF,sums,classifications)
         classifications[idx] .= ["Mica-like"]
        #11 COMPLEX CLAY
         idx = check_complex_clay(DF,sums,classifications)
         classifications[idx] .= ["Complex clay-like"]
        #12 ILLITE
         idx = check_illite(DF,sums,classifications)
         classifications[idx] .= ["Illite-like"]
        #13 CHLORITE
         idx = check_chlorite(DF,sums,classifications)
         classifications[idx] .= ["Chlorite-like"]
        #14 SMECTITE
         idx = check_smectite(DF,sums,classifications)
         classifications[idx] .= ["Smectite-like"]
        #15 KAOLINITE
         idx = check_kaolinite(DF,sums,classifications)
         classifications[idx] .= ["Kaolinite-like"]
        #16 CALCIUM SILICATE MIX
         idx = check_calcium_silicate_mix(DF,sums,classifications)
         classifications[idx] .= ["Ca-rich silicate/Ca-Si-mix"]
        #17 CALCITE
         idx = check_calcite(DF,sums,classifications)
         classifications[idx] .= ["Calcite-like"]
        #18 DOLOMITE
         idx = check_dolomite(DF,sums,classifications)
         classifications[idx] .= ["Dolomite-like"]
        #19 APATITE
         idx = check_apatite(DF,sums,classifications)
         classifications[idx] .= ["Apatite-like"]
        #20 GYPSUM
         idx = check_gypsum(DF,sums,classifications)
         classifications[idx] .= ["Gypsum-like"]
        #21 ALUNITE
         idx = check_alunite(DF,sums,classifications)
         classifications[idx] .= ["Alunite-like"]
        #22 HALITE
         idx = check_halite(DF,sums,classifications)
         classifications[idx] .= ["Halite-like"]
        #23 COMPLEX SULFATE
         idx = check_complex_sulfate(DF,sums,classifications)
         classifications[idx] .= ["Complex sulfate-like"]

        return classifications
    end # End mineral_classification function

    #
    # BEGIN DEFINING MINERAL INDEX FUNCTIONS
    #
    function check_hematite(T, sums, classification_array)
        # Extract columns from DataFrame
        Fe = T[:, :Fe]
        Cr = T[:, :Cr]
        Cl = T[:, :Cl]
        F = T[:, :F]
        Si = T[:, :Si]
        Ti = T[:, :Ti]
        # Compute criteria
        criteria1 = Fe ./ sums
        criteria2 = Cr ./ (Cr .+ Fe)
        criteria3 = Cl ./ (Cl .+ Fe)
        criteria4 = (F .+ Si) ./ (F .+ sums)
        criteria5 = Ti ./ Fe
        # Logical conditions
        condition1 = (0.5 .<= criteria1) .& (criteria1 .<= 0.98999)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.1)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.1)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.499)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.24999)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5
        return index
    end

    function check_rutile(T, sums, classification_array)
        # Extract columns from DataFrame
        Ti = T[:, :Ti]
        Ca = T[:, :Ca]
        # Compute criteria
        criteria1 = Ti ./ sums
        criteria2 = Ca ./ (Ca .+ Ti)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.3)
        # Combine all conditions
        index = condition1 .& condition2
        return index
    end

    function check_ilmenite(T, sums, classification_array)
        # Extract columns from DataFrame
        Fe = T[:, :Fe]
        Ti = T[:, :Ti]
        #Compute criteria
        criteria1 = (Fe .+ Ti) ./ sums
        criteria2 = Ti ./ Fe
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.25 .<= criteria2) .& (criteria2 .<= 4)
        # Combine all conditions
        index = condition1 .& condition2
        return index
    end

    function check_quartz(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        F = T[:, :F]
        # Compute criteria
        criteria1 = Si ./ sums
        criteria2 = (Na .+ Mg .+ K .+ Ca .+ Al) ./ Si
        criteria3 = F ./ (F .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.2)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.499)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3
        return index
    end

    function check_complex_quartz(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Fe = T[:, :Fe]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Al .+ Si .+ Na .+ Mg .+ K .+ Ca .+ Fe) ./ sums
        criteria2 = Al ./ Si
        criteria3 = (Na .+ K .+ Ca) ./ Si
        criteria4 = Fe ./ Si
        criteria5 = Ca ./ Si
        criteria6 = K ./ Si
        criteria7 = Mg ./ Si
        criteria8 = Na ./ Si
        criteria9 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.05 .<= criteria2) .& (criteria2 .<= 0.25)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 1.0)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.5)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.5)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.5)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.5)
        condition9 = (0.0 .<= criteria9) .& (criteria9 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8 .& condition9
        return index
    end

    function check_microcline(T, sums, classification_array)
        # Extract columns from DataFrame
        K = T[:, :K]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (K .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = K ./ Si
        criteria4 = Ca ./ Si
        criteria5 = Na ./ Si
        criteria6 = (Cl .+ (2 .* S)) ./ Na
        criteria7 = (Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.2 .<= criteria2) .& (criteria2 .<= 0.45)
        condition3 = (0.15 .<= criteria3) .& (criteria3 .<= 0.5)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.1)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.1)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.3)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.125)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7
        return index
    end

    function check_albite(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        K = T[:, :K]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Na .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = Na ./ Si
        criteria4 = Ca ./ Si
        criteria5 = K ./ Si
        criteria6 = (Cl .+ (2 .* S)) ./ Na
        criteria7 = (Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.2 .<= criteria2) .& (criteria2 .<= 0.45)
        condition3 = (0.15 .<= criteria3) .& (criteria3 .<= 0.5)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.1)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.1)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.3)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.125)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7
        return index
    end

    function check_complex_feldspar(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Fe = T[:, :Fe]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Al .+ Si .+ Na .+ Mg .+ K .+ Ca .+ Fe) ./ sums
        criteria2 = Al ./ Si
        criteria3 = (Na .+ K .+ Ca) ./ Si
        criteria4 = Fe ./ Si
        criteria5 = Ca ./ Si
        criteria6 = K ./ Si
        criteria7 = Mg ./ Si
        criteria8 = Na ./ Si
        criteria9 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.25 .<= criteria2) .& (criteria2 .<= 0.5)
        condition3 = (0.125 .<= criteria3) .& (criteria3 .<= 0.7)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.5)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.5)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.5)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.5)
        condition9 = (0.0 .<= criteria9) .& (criteria9 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8 .& condition9
        return index
    end

    function check_complex_clay_feldspar(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Fe = T[:, :Fe]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Al .+ Si .+ Na .+ Mg .+ K .+ Ca .+ Fe) ./ sums
        criteria2 = Al ./ Si
        criteria3 = (Na .+ K .+ Ca) ./ Si
        criteria4 = Fe ./ Si
        criteria5 = Ca ./ Si
        criteria6 = K ./ Si
        criteria7 = Mg ./ Si
        criteria8 = Na ./ Si
        criteria9 = (Na .+ Cl .+ (2. * S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.25 .<= criteria2) .& (criteria2 .<= 0.5)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.125)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.5)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.5)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.5)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.5)
        condition9 = (0.0 .<= criteria9) .& (criteria9 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8 .& condition9
        return index
    end

    function check_mica(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        K = T[:, :K]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Ca .+ Na .+ K .+ Fe .+ Mg .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = (Na .+ K .+ Ca .+ Mg .+ Fe) ./ Si
        criteria4 = (Cl .+ (2 .* S)) ./ Na
        criteria5 = (Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.2 .<= criteria2) .& (criteria2 .<= 3.0)
        condition3 = (0.5 .<= criteria3) .& (criteria3 .<= 2.5)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.125)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5
        return index
    end

    function check_complex_clay(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Fe = T[:, :Fe]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Al .+ Si .+ Na .+ Mg .+ K .+ Ca .+ Fe) ./ sums
        criteria2 = Al ./ Si
        criteria3 = (Mg .+ Fe .+ K) ./ Si
        criteria4 = Fe ./ Si
        criteria5 = Ca ./ Si
        criteria6 = K ./ Si
        criteria7 = Mg ./ Si
        criteria8 = Na ./ Si
        criteria9 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.5 .<= criteria2) .& (criteria2 .<= 1.5)
        condition3 = (0.1 .<= criteria3) .& (criteria3 .<= 1.0)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.5)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.5)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.5)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.5)
        condition9 = (0.0 .<= criteria9) .& (criteria9 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8 .& condition9
        return index
    end

    function check_illite(T, sums, classification_array)
        # Extract column from DataFrame
        K = T[:, :K]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Mg = T[:, :Mg]
        Fe = T[:, :Fe]
        Na = T[:, :Na]
        Ca = T[:, :Ca]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (K .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = Mg ./ (Al .+ Si)
        criteria4 = Fe ./ (Al .+ Si)
        criteria5 = (Na .+ Ca) ./ (Al .+ Si)
        criteria6 = K ./ Si
        criteria7 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .< criteria1) .& (criteria1 .< 1.01)
        condition2 = (0.45 .< criteria2) .& (criteria2 .< 1.5)
        condition3 = (0.0 .< criteria3) .& (criteria3 .< 0.2)
        condition4 = (0.0 .< criteria4) .& (criteria4 .< 0.2)
        condition5 = (0.0 .< criteria5) .& (criteria5 .< 0.2)
        condition6 = (0.1 .< criteria6) .& (criteria6 .< 1.01)
        condition7 = (0.0 .< criteria7) .& (criteria7 .< 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7
        return index
    end

    function check_chlorite(T, sums, classification_array)
        # Extract columns from DataFrame
        Mg = T[:, :Mg]
        Fe = T[:, :Fe]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Mg .+ Fe .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = Fe ./ (Al .+ Si)
        criteria4 = Ca ./ (Al .+ Si)
        criteria5 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.5 .<= criteria2) .& (criteria2 .<= 1.5)
        condition3 = (0.2 .<= criteria3) .& (criteria3 .<= 1.01)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5
        return index
    end

    function check_smectite(T, sums, classification_array)
        # Extract columns from DataFrame
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Fe = T[:, :Fe]
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        K = T[:, :K]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Mg .+ Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = Fe ./ (Al .+ Si)
        criteria4 = Mg ./ (Al .+ Si)
        criteria5 = Ca ./ (Al .+ Si)
        criteria6 = Na ./ (Al .+ Si)
        criteria7 = K ./ Si
        criteria8 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.5 .<= criteria2) .& (criteria2 .<= 1.5)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.2)
        condition4 = (0.2 .<= criteria4) .& (criteria4 .<= 1.01)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.2)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.2)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.1)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8
        return index
    end

    function check_kaolinite(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        K = T[:, :K]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Al .+ Si) ./ sums
        criteria2 = Al ./ Si
        criteria3 = Fe ./ (Al .+ Si)
        criteria4 = Mg ./ (Al .+ Si)
        criteria5 = Ca ./ (Al .+ Si)
        criteria6 = Na ./ (Al .+ Si)
        criteria7 = K ./ Si
        criteria8 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.5 .<= criteria2) .& (criteria2 .<= 1.5)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.2)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.2)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.2)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.15)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.1)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .&
                condition4 .& condition5 .& condition6 .&
                condition7 .& condition8
        return index
    end

    function check_calcium_silicate_mix(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        S = T[:, :S]
        # Compute criteria
        criteria1 = (Ca .+ Al .+ Si) ./ sums
        criteria2 = Ca ./ (Al .+ Si)
        criteria3 = (Na .+ Cl .+ (2 .* S)) ./ (Al .+ Si)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.3 .<= criteria2) .& (criteria2 .<= 3.333)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3
        return index
    end

    function check_calcite(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Mg = T[:, :Mg]
        S = T[:, :S]
        Cl = T[:, :Cl]
        P = T[:, :P]
        # Compute criteria
        criteria1 = Ca ./ sums
        criteria2 = (Al .+ Si) ./ Ca
        criteria3 = Mg ./ Ca
        criteria4 = S ./ Ca
        criteria5 = Cl ./ Ca
        criteria6 = P ./ (Ca .+ P)
        criteria7 = S ./ (Ca .+ S)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.3)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.3)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.3)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.19)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.19)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& condition7
        return index
    end

    function check_dolomite(T, sums, classification_array)
        # Extract columns from DataFrame
        Mg = T[:, :Mg]
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Si = T[:, :Si]
        S = T[:, :S]
        Cl = T[:, :Cl]
        # Compute criteria
        criteria1 = (Mg .+ Ca) ./ sums
        criteria2 = Mg ./ Ca
        criteria3 = S ./ Ca
        criteria4 = Cl ./ Ca
        criteria5 = (Al .+ Si) ./ Ca
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.3 .<= criteria2) .& (criteria2 .<= 3.0)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.3)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.3)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5
        return index
    end

    function check_apatite(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        P = T[:, :P]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Cl = T[:, :Cl]
        # Compute criteria
        criteria1 = (Ca .+ P) ./ sums
        criteria2 = Mg ./ Ca
        criteria3 = P ./ (Ca .+ P)
        criteria4 = Cl ./ Ca
        criteria5 = (Al .+ Si) ./ (P .+ Ca)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.3)
        condition3 = (0.2 .<= criteria3) .& (criteria3 .<= 0.8)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5
        return index
    end

    function check_gypsum(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        S = T[:, :S]
        Cl = T[:, :Cl]
        # Compute criteria
        criteria1 = (Ca .+ S) ./ sums
        criteria2 = Ca ./ (Ca .+ S)
        criteria3 = Mg ./ Ca
        criteria4 = Cl ./ Ca
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.2 .<= criteria2) .& (criteria2 .<= 0.8)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.3)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.3)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4
        return index
    end

    function check_alunite(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        K = T[:, :K]
        S = T[:, :S]
        Ca = T[:, :Ca]
        Si = T[:, :Si]
        # Compute criteria
        criteria1 = (Al .+ K .+ S) ./ sums
        criteria2 = Ca ./ (Ca .+ Al .+ K .+ S)
        criteria3 = Si ./ (Si .+ Al .+ K .+ S)
        criteria4 = K ./ (Al .+ K .+ S)
        criteria5 = S ./ (Al .+ K .+ S)
        criteria6 = Al ./ (Al .+ K .+ S)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.05)
        condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.1)
        condition4 = (0.05 .<= criteria4) .& (criteria4 .<= 3.0)
        condition5 = (0.15 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.3 .<= criteria6) .& (criteria6 .<= 0.8)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6
        return index
    end

    function check_halite(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        S = T[:, :S]
        Al = T[:, :Al]
        Si = T[:, :Si]
        # Compute criteria
        criteria1 = (Na .+ Mg .+ Cl) ./ sums
        criteria2 = Cl ./ (Na .+ (0.5 .* Mg))
        criteria3 = Cl ./ (Cl .+ S)
        criteria4 = S ./ (Na .+ (0.5 .* Mg))
        criteria5 = K ./ Na
        criteria6 = Ca ./ Na
        criteria7 = Mg ./ Na
        criteria8 = (Al .+ Si) ./ (Na .+ Cl .+ S)
        # Logical conditions
        condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
        condition2 = (0.5 .<= criteria2) .& (criteria2 .<= 2.0)
        condition3 = (0.7 .<= criteria3) .& (criteria3 .<= 1.01)
        condition4 = (0.0 .<= criteria4) .& (criteria4 .<= 0.2)
        condition5 = (0.0 .<= criteria5) .& (criteria5 .<= 0.5)
        condition6 = (0.0 .<= criteria6) .& (criteria6 .<= 0.5)
        condition7 = (0.0 .<= criteria7) .& (criteria7 .<= 0.5)
        condition8 = (0.0 .<= criteria8) .& (criteria8 .<= 0.25)
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .&
                condition5 .& condition6 .& condition7 .& condition8
        return index
    end

    function check_complex_sulfate(T, sums, classification_array)
    # Extract columns from DataFrame
    Na = T[:, :Na]
    Mg = T[:, :Mg]
    K = T[:, :K]
    Ca = T[:, :Ca]
    S = T[:, :S]
    Cl = T[:, :Cl]
    Al = T[:, :Al]
    Si = T[:, :Si]
    # Compute criteria
    criteria1 = (Na .+ Mg .+ K .+ Ca .+ S .+ Cl) ./ sums
    criteria2 = (Al .+ Si) ./ S
    criteria3 = Cl ./ (Cl .+ S)
    # Logical conditions
    condition1 = (0.7 .<= criteria1) .& (criteria1 .<= 1.01)
    condition2 = (0.0 .<= criteria2) .& (criteria2 .<= 0.25)
    condition3 = (0.0 .<= criteria3) .& (criteria3 .<= 0.3)
    # Combine all conditions
    index = condition1 .& condition2 .& condition3
        return index
    end

# Final step: Classify the mineralogy for each row of the input table
minerals = DataFrame(Minerals = mineral_classification(df))
return minerals
end