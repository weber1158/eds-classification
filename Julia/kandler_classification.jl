"""
Mineral classifcation scheme from Kandler et al. (2011)

DESCRIPTION

This function automates the mineral classification workflow published by Kandler et al. (2011). Takes a table of energy dispersive spectrometry (EDS) atomic percentage data and assigns a mineralogy to each row.

SYNTAX

minerals = kandler_classification(df)

INPUT

"df" :: DataFrame containing a column for each of the following elements: Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required by spelling is paramount. The values in the table should represent the measured net intensity for each element.

OUTPUT

"minerals" :: Categorical vector of general mineral classes corresponding to each row in the input DataFrame.


LIMITATIONS

This function does not classify specific minerals but rather generalized mineral classes (e.g., "Complex sulfates"). To maximize the usefulness of this algorithm the user should also consult the results of additional classification methods.

REFERENCE

Kandler et al. (2011). Tellus B 63(4), 475–496. https://doi.org/10.1111/j.1600-0889.2011.00550.x

COPYRIGHT

©2024 Austin M. Weber - function code

"""
function kandler_classification(df)
    # Check that input is a DataFrame
        @assert typeof(df) == DataFrame "Input must be a DataFrame"
    
        # Convert full-name table variables to abbreviations
        element_names = ["Aluminum","Aluminium","Silicon","Iron","Sodium",
        "Magnesium","Potassium","Calcium","Phosphorus",
        "Sulfur","Chlorine","Titanium","Chromium","Manganese"] # Vector{String}
        element_names = map(lowercase,element_names)
        varnames = names(df)
        varnames_lower = map(lowercase,varnames) # Vector{String}
        element_abbreviations = ["Al","Al","Si","Fe","Na","Mg","K","Ca","P","S","Cl","Ti","Cr","Mn"]
        for (n, abbreviation) in enumerate(element_abbreviations)
            if any(x -> contains(x, element_names[n]), varnames_lower)
                idx = contains.(varnames_lower, element_names[n])
                varnames[idx] .= abbreviation
            end
        end
        rename!(df,varnames) # Replace variable names in DataFrame
    
        # Ensure that all 13 of the necessary columns exist
        if sum(in.(varnames, Ref(["Na","Mg","Al","Si","P","S","Cl","K","Ca","Ti","Cr","Mn","Fe"]))) != 13
            error("Input must be a DataFrame containing a column for Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. Check the spellings of the column names. Only full element names and abbreviations are valid.")
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

        #01 BIOLOGICAL
         idx = check_biological(DF,sums,classifications)
         classifications[idx] .= ["biological"]
        #02 Na-rich
         idx = check_NaRich(DF,sums,classifications)
         classifications[idx] .= ["Na-rich"]
        #03 AMMONIUM SULFATE
         idx = check_NH4SO4(DF,sums,classifications)
         classifications[idx] .= ["ammonium sulfate"]
        #04 Na SULFATE
         idx = check_NaSO4(DF,sums,classifications)
         classifications[idx] .= ["Na sulfate"]
        #05 Ca Na SULFATE
         idx = check_CaNaSO4(DF,sums,classifications)
         classifications[idx] .= ["Ca Na sulfate"]
        #06 Ca SULFATE
         idx = check_CaSO4(DF,sums,classifications)
         classifications[idx] .= ["Ca sulfate"]
        #07 OTHER SULFATE
         idx = check_otherSO4(DF,sums,classifications)
         classifications[idx] .= ["other sulfate"]
        #08 Ca CARBONATE
         idx = check_CaCO3(DF,sums,classifications)
         classifications[idx] .= ["Ca carbonate"]
        #09 Ca Mg CARBONATE
         idx = check_CaMgCO3(DF,sums,classifications)
         classifications[idx] .= ["Ca Mg carbonate"]
        #10 PHOSPHATE
         idx = check_PO4(DF,sums,classifications)
         classifications[idx] .= ["phosphate"]
        #11 Na CHLORIDE
         idx = check_NaCl(DF,sums,classifications) 
         classifications[idx] .= ["Na chloride"]
        #12 K CHLORIDE
         idx = check_KCl(DF,sums,classifications)
         classifications[idx] .= ["K chloride"]
        #13 OTHER CHLORIDE
         idx = check_otherCl(DF,sums,classifications)
         classifications[idx] .= ["other chloride"]
        #14 Fe OXIDE
         idx = check_FeO(DF,sums,classifications)
         classifications[idx] .= ["Fe oxide"]
       #15 Ti OXIDE
         idx = check_TiO(DF,sums,classifications)
         classifications[idx] .= ["Ti oxide"]
       #16 Fe Ti OXIDE
         idx = check_FeTiO(DF,sums,classifications)
         classifications[idx] .= ["Fe Ti oxide"]
       #17 Al OXIDE
         idx = check_AlO(DF,sums,classifications)
         classifications[idx] .= ["Al oxide"]
       #18 QUARTZ
         idx = check_quartz(DF,sums,classifications)
         classifications[idx] .= ["quartz"]
       #19 ALUMINOSILICATE
         idx = check_SiAl(DF,sums,classifications)
         classifications[idx] .= ["SiAl"]
       #20 K-ALUMINOSILICATE
         idx = check_SiAlK(DF,sums,classifications)
         classifications[idx] .= ["SiAlK"]
       #21 Na-ALUMINOSILICATE
         idx = check_SiAlNa(DF,sums,classifications)
         classifications[idx] .= ["SiAlNa"]
       #22 Na-Ca ALUMINOSILICATE
        idx = check_SiAlNaCa(DF,sums,classifications)
        classifications[idx] .= ["SiAlNaCa"]
       #23 Na-K ALUMINOSILICATE
        idx = check_SiAlNaK(DF,sums,classifications)
        classifications[idx] .= ["SiAlNaK"]
       #24 Ca-Fe-Mg ALUMINOSILICATE
        idx = check_SiAlCaFeMg(DF,sums,classifications)
        classifications[idx] .= ["SiAlCaFeMg"]
       #25 K-Fe-Mg ALUMINOSILICATE
        idx = check_SiAlKFeMg(DF,sums,classifications)
        classifications[idx] .= ["SiAlKFeMg"]
       #26 Fe-Mg ALUMINOSILICATE
        idx = check_SiAlFeMg(DF,sums,classifications)
        classifications[idx] .= ["SiAlFeMg"]
       #27 Mg-Fe SILICATE
        idx = check_SiMgFe(DF,sums,classifications)
        classifications[idx] .= ["SiMgFe"]
       #28 Mg-SILICATE
        idx = check_SiMg(DF,sums,classifications)
        classifications[idx] .= ["SiMg"]
       #29 Ca-Ti SILICATE
        idx = check_SiCaTi(DF,sums,classifications)
        classifications[idx] .= ["SiCaTi"]
       #30 MIXTURES Si+S
        idx = check_mixSiS(DF,sums,classifications)
        classifications[idx] .= ["mixtures Si+S"]
       #31 MIXTURES SiAl+S
        idx = check_mixSiAlS(DF,sums,classifications)
        classifications[idx] .= ["mixtures SiAl+S"]
       #32 MIXTURES Cl+S
        idx = check_mixClS(DF,sums,classifications)
        classifications[idx] .= ["mixtures Cl+S"]
       #33 MIXTURES NaCl+SiAl
        idx = check_mixNaClSiAl(DF,sums,classifications)
        classifications[idx] .= ["mixtures NaCl+SiAl"]
       #34 MIXTURES Ca+Si
        idx = check_mixCaSi(DF,sums,classifications)
        classifications[idx] .= ["mixtures Ca+Si"]
       #35 MIXTURES Ca+SiAl
        idx = check_mixCaSiAl(DF,sums,classifications)
        classifications[idx] .= ["mixtures Ca+SiAl"]
       #36 MIXTURES OTHER Si-DOMINATED
        idx = check_mixOtherSi(DF,sums,classifications)
        classifications[idx] .= ["other Si-dominated"]
       #37 STEEL
        idx = check_steel(DF,sums,classifications)
        classifications[idx] .= ["steel"]
       #38 OTHER Mg-DOMINATED
        idx = check_otherMg(DF,sums,classifications)
        classifications[idx] .= ["other Mg-dominated"]
       #39 OTHER K-DOMINATED
        idx = check_otherK(DF,sums,classifications)
        classifications[idx] .= ["other K-dominated"]
       #40 OTHER Ca-DOMINATED
        idx = check_otherCa(DF,sums,classifications)
        classifications[idx] .= ["other Ca-dominated"]

      return classifications 
    end # END mineral_classification() LOCAL FUNCTION

    #
    # BEGIN MINERAL CLASSIFICATION INDEX FUNCTIONS
    #
    function check_biological(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        S = T[:, :S]
        P = T[:, :P]
        Ca = T[:, :Ca]
        K = T[:, :K]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        Cl = T[:, :Cl]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute mini sums
        minisums = Na .+ S .+ P .+ Ca
        # Compute criteria
        criteria1 = (K .+ Na .+ S .+ P .+ Ca) ./ sums
        criteria2 = P ./ sums
        criteria3 = Na ./ sums
        criteria4 = Ca ./ sums
        criteria5 = K ./ sums
        criteria6 = S ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.4) .& (criteria1 .<= 1.1)
        condition2 = (criteria2 .>= 0.05) .& (criteria2 .<= 0.8)
        condition3 = (criteria3 .>= 0.05) .& (criteria3 .<= 0.8)
        condition4 = (criteria4 .>= 0.05) .& (criteria4 .<= 1.1)
        condition5 = (criteria5 .>= 0.025) .& (criteria5 .<= 0.8)
        condition6 = (criteria6 .>= 0.025) .& (criteria6 .<= 0.8)
        condition7 = (Mg ./ minisums .< 0.1)
        condition8 = (Al ./ minisums .< 0.05)
        condition9 = (Si ./ minisums .< 0.1)
        condition10 = (Cl ./ minisums .< 0.05)
        condition11 = (Ti ./ minisums .< 0.05)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.1)
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .&
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .&
                condition13 .& condition14 .& condition15
        
        return index
    end

    function check_NaRich(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Na ./ sums
        condition1 = (criteria1 .>= 0.2) .& (criteria1 .<= 1.1)
        condition2 = (Cl ./ sums .< 0.002499)
        condition3 = (Mg ./ Na .< 1.1)
        condition4 = (Al ./ Na .< 0.75)
        condition5 = (Si ./ Na .< 0.25)
        condition6 = (P ./ Na .< 0.1)
        condition7 = (S ./ Na .< 0.1)
        condition8 = (Cl ./ Na .< 0.05)
        condition9 = (K ./ Na .< 0.5)
        condition10 = (Ca ./ Na .< 0.5)
        condition11 = (Ti ./ Na .< 0.05)
        condition12 = (Cr ./ Na .< 0.05)
        condition13 = (Mn ./ Na .< 0.1)
        condition14 = (Fe ./ Na .< 0.1)
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15
        return index
    end
    
    function check_NH4SO4(T, sums, classification_array)
            # Extract columns from DataFrame
        S = T[:, :S]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = S ./ sums
        condition1 = (criteria1 .>= 0.3) .& (criteria1 .<= 1.1)
        condition2 = (Na ./ S .< 0.1)
        condition3 = (Mg ./ S .< 0.1)
        condition4 = (Al ./ S .< 0.2)
        condition5 = (Si ./ S .< 0.25)
        condition6 = (P ./ S .< 0.1)
        condition7 = (Cl ./ S .< 0.1)
        condition8 = (K ./ S .< 0.1)
        condition9 = (Ca ./ S .< 0.1)
        condition10 = (Ti ./ S .< 0.05)
        condition11 = (Cr ./ S .< 0.05)
        condition12 = (Mn ./ S .< 0.05)
        condition13 = (Fe ./ S .< 0.1)
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_NaSO4(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        S = T[:, :S]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Na ./ S
        criteria2 = (Na .+ S) ./ sums
        criteria3 = Na ./ sums
        criteria4 = S ./ sums
        minisums = S .+ Na
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 10)
        condition2 = (criteria2 .>= 0.1) .& (criteria2 .<= 1.1)
        condition3 = (criteria3 .>= 0.025) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.025) .& (criteria4 .<= 1.1)
        condition5 = (Mg ./ minisums .< 0.5)
        condition6 = (Al ./ minisums .< 0.1)
        condition7 = (Si ./ minisums .< 0.15)
        condition8 = (P ./ minisums .< 0.5)
        condition9 = (Cl ./ minisums .< 0.1)
        condition10 = (K ./ minisums .< 0.1)
        condition11 = (Ca ./ minisums .< 0.05)
        condition12 = (Ti ./ minisums .< 0.05)
        condition13 = (Cr ./ minisums .< 0.05)
        condition14 = (Mn ./ minisums .< 0.5)
        condition15 = (Fe ./ minisums .< 0.1)
        condition16 = (classification_array .== "Unknown ")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15 .& condition16
        return index
    end

    function check_CaNaSO4(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        S = T[:, :S]
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = (Na .+ S .+ Ca) ./ sums
        criteria2 = Na ./ sums
        criteria3 = S ./ sums
        criteria4 = Ca ./ sums
        criteria5 = Na ./ Ca
        criteria16 = Ca ./ (S .+ Na)
        minisums = S .+ Na .+ Ca
        # Logical conditions
        condition1 = (criteria1 .>= 0.15) .& (criteria1 .<= 1.1)
        condition2 = (criteria2 .>= 0.025) .& (criteria2 .<= 1.1)
        condition3 = (criteria3 .>= 0.025) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.025) .& (criteria4 .<= 1.1)
        condition5 = (criteria5 .>= 0.100) .& (criteria5 .<= 10)
        condition6 = (Mg ./ minisums .< 0.5)
        condition7 = (Al ./ minisums .< 0.05)
        condition8 = (Si ./ minisums .< 0.05)
        condition9 = (P ./ minisums .< 0.2)
        condition10 = (Cl ./ minisums .< 0.1)
        condition11 = (K ./ minisums .< 0.1)
        condition12 = (Ti ./ minisums .< 0.05)
        condition13 = (Cr ./ minisums .< 0.1)
        condition14 = (Mn ./ minisums .< 0.5)
        condition15 = (Fe ./ minisums .< 0.1)
        condition16 = (criteria16 .>= 0.1001) .& (criteria16 .<= 10)
        condition17 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15 .& condition16 .& condition17
        return index
    end

    function check_CaSO4(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        S = T[:, :S]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Ca ./ S
        criteria2 = (Ca .+ S) ./ sums
        minisums = S .+ Ca
        # Logical conditions
        condition1 = (criteria1 .>= 0.20) .& (criteria1 .<= 10)
        condition2 = (criteria2 .>= 0.2) .& (criteria2 .<= 1.1)
        condition3 = (Na ./ minisums .< 0.1)
        condition4 = (Mg ./ minisums .< 0.35)
        condition5 = (Al ./ minisums .< 0.1)
        condition6 = (Si ./ minisums .< 0.1)
        condition7 = (P ./ minisums .< 0.1)
        condition8 = (Cl ./ minisums .< 0.1)
        condition9 = (K ./ minisums .< 0.1)
        condition10 = (Ti ./ minisums .< 0.05)
        condition11 = (Cr ./ minisums .< 0.05)
        condition12 = (Mn ./ minisums .< 0.5)
        condition13 = (Fe ./ minisums .< 0.1)
        condition14 = (classification_array .== "Unknown")
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_otherSO4(T, sums, classification_array)
        # Extract columns from DataFrame
        S = T[:, :S]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = S ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2) .& (criteria1 .<= 1.1)
        condition2 = (Na ./ S .< 2)
        condition3 = (Mg ./ S .< 2)
        condition4 = (Al ./ S .< 2.5)
        condition5 = (Si ./ S .< 0.25)
        condition6 = (P ./ S .< 0.2)
        condition7 = (Cl ./ S .< 0.2)
        condition8 = (K ./ S .< 10)
        condition9 = (Ca ./ S .< 2)
        condition10 = (Ti ./ S .< 0.5)
        condition11 = (Cr ./ S .< 0.5)
        condition12 = (Mn ./ S .< 2)
        condition13 = (Fe ./ S .< 2)
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
            return index
    end

    function check_CaCO3(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Ca ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2) .& (criteria1 .<= 1.1)
        condition2 = (Na ./ Ca .< 0.110)
        condition3 = (Mg ./ Ca .< 0.500)
        condition4 = (Al ./ Ca .< 0.151)
        condition5 = (Si ./ Ca .< 0.110)
        condition6 = (P ./ Ca .< 0.100)
        condition7 = (S ./ Ca .< 0.100)
        condition8 = (Cl ./ Ca .< 0.100)
        condition9 = (K ./ Ca .< 0.100)
        condition10 = (Ti ./ Ca .< 0.100)
        condition11 = (Cr ./ Ca .< 0.050)
        condition12 = (Mn ./ Ca .< 0.500)
        condition13 = (Fe ./ Ca .< 0.100)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_CaMgCO3(T, sums, classification_array)
        # Extract columns from DataFrame
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        Na = T[:, :Na]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = (Ca .+ Mg) ./ sums
        criteria2 = Mg ./ Ca
        minisums = Ca .+ Mg
        # Logical conditions
        condition1 = (criteria1 .>= 0.200) .& (criteria1 .<= 1.1)
        condition2 = (criteria2 .>= 0.501) .& (criteria2 .<= 2.0)
        condition3 = (Na ./ minisums .< 0.500)
        condition4 = (Al ./ minisums .< 0.100)
        condition5 = (Si ./ minisums .< 0.200)
        condition6 = (P ./ minisums .< 0.100)
        condition7 = (S ./ minisums .< 0.100)
        condition8 = (Cl ./ minisums .< 0.100)
        condition9 = (Ti ./ minisums .< 0.100)
        condition10 = (Cr ./ minisums .< 0.050)
        condition11 = (Fe ./ minisums .< 0.100)
        # Classification condition
        condition12 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12
        return index
    end

    function check_PO4(T, sums, classification_array)
        # Extract columns from DataFrame
        P = T[:, :P]
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Si = T[:, :Si]
        # Compute criteria
        criteria1 = P ./ sums
        minisums = Ca ./ P
        # Logical conditions
        condition1 = (criteria1 .>= 0.050) .& (criteria1 .<= 1.100)
        condition2 = (Al ./ minisums .< 0.200)
        condition3 = (Si ./ minisums .< 0.100)
        # Classification condition
        condition4 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4
        return index
    end

    function check_NaCl(T, sums, classification_array)
        # Extract columns from DataFrame
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        Si = T[:, :Si]
        Al = T[:, :Al]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = Na .+ Cl
        criteria1 = minisums ./ sums
        criteria2 = Na ./ sums
        criteria3 = Cl ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.250) .& (criteria1 .<= 1.100)
        condition2 = (criteria2 .>= 0.010) .& (criteria2 .<= 1.100)
        condition3 = (criteria3 .>= 0.010) .& (criteria3 .<= 1.100)
        condition4 = (Si ./ sums .< 0.0499)
        condition5 = (Al ./ sums .< 0.0299)
        condition6 = (Mg ./ minisums .< 2.00)
        condition7 = (P ./ minisums .< 0.20)
        condition8 = (S ./ minisums .< 0.25)
        condition9 = (K ./ minisums .< 0.15)
        condition10 = (Ti ./ minisums .< 0.25)
        condition11 = (Cr ./ minisums .< 0.25)
        condition12 = (Mn ./ minisums .< 2.00)
        condition13 = (Fe ./ minisums .< 0.25)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_KCl(T, sums, classification_array)
        # Extract columns from DataFrame
        K = T[:, :K]
        Cl = T[:, :Cl]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = K .+ Cl
        criteria1 = minisums ./ sums
        criteria2 = Na ./ sums
        criteria3 = Cl ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.300) .& (criteria1 .<= 1.100)
        condition2 = (criteria2 .>= 0.010) .& (criteria2 .<= 1.100)
        condition3 = (criteria3 .>= 0.010) .& (criteria3 .<= 1.100)
        condition4 = (Na ./ minisums .< 0.150)
        condition5 = (Mg ./ minisums .< 0.100)
        condition6 = (Al ./ minisums .< 0.200)
        condition7 = (Si ./ minisums .< 0.250)
        condition8 = (P ./ minisums .< 0.200)
        condition9 = (S ./ minisums .< 0.250)
        condition10 = (Ca ./ minisums .< 0.500)
        condition11 = (Ti ./ minisums .< 0.250)
        condition12 = (Cr ./ minisums .< 0.250)
        condition13 = (Mn ./ minisums .< 2.000)
        condition14 = (Fe ./ minisums .< 0.250)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15
        return index
    end

    function check_otherCl(T, sums, classification_array)
        # Extract columns from DataFrame
        Cl = T[:, :Cl]
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Cl ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 1.10)
        condition2 = (Si ./ sums .< 0.0699)
        condition3 = (Al ./ sums .< 0.0099)
        condition4 = (Na ./ Cl .< 2.0000)
        condition5 = (Mg ./ Cl .< 2.0000)
        condition6 = (P ./ Cl .< 0.1000)
        condition7 = (S ./ Cl .< 0.2000)
        condition8 = (K ./ Cl .< 2.0000)
        condition9 = (Ca ./ Cl .< 2.0000)
        condition10 = (Ti ./ Cl .< 0.1000)
        condition11 = (Cr ./ Cl .< 0.1000)
        condition12 = (Mn ./ Cl .< 2.0000)
        condition13 = (Fe ./ Cl .< 10.000)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_FeO(T, sums, classification_array)
        # Extract columns from DataFrame
        Fe = T[:, :Fe]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute criteria
        criteria1 = Fe ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 1.10)
        condition2 = (Na ./ Fe .< 0.10)
        condition3 = (Mg ./ Fe .< 0.25)
        condition4 = (Al ./ Fe .< 0.20)
        condition5 = (Si ./ Fe .< 0.25)
        condition6 = (P ./ Fe .< 0.20)
        condition7 = (S ./ Fe .< 0.20)
        condition8 = (Cl ./ Fe .< 0.10)
        condition9 = (K ./ Fe .< 0.10)
        condition10 = (Ca ./ Fe .< 0.10)
        condition11 = (Ti ./ Fe .< 0.25)
        condition12 = (Cr ./ Fe .< 0.05)
        condition13 = (Mn ./ Fe .< 1.00)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_TiO(T, sums, classification_array)
        # Extract columns from DataFrame
        Ti = T[:, :Ti]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Ti ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 1.10)
        condition2 = (Na ./ Ti .< 0.18)
        condition3 = (Mg ./ Ti .< 0.10)
        condition4 = (Al ./ Ti .< 0.20)
        condition5 = (Si ./ Ti .< 0.25)
        condition6 = (P ./ Ti .< 0.20)
        condition7 = (S ./ Ti .< 0.20)
        condition8 = (Cl ./ Ti .< 0.10)
        condition9 = (K ./ Ti .< 0.10)
        condition10 = (Ca ./ Ti .< 0.10)
        condition11 = (Cr ./ Ti .< 0.05)
        condition12 = (Mn ./ Ti .< 0.25)
        condition13 = (Fe ./ Ti .< 0.25)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_FeTiO(T, sums, classification_array)
        # Extract columns from DataFrame
        Ti = T[:, :Ti]
        Fe = T[:, :Fe]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute criteria
        minisums = Ti .+ Fe
        criteria1 = Ti ./ Fe
        criteria2 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2501) .& (criteria1 .<= 4.000)
        condition2 = (criteria2 .>= 0.2500) .& (criteria2 .<= 1.100)
        condition3 = (Na ./ minisums .< 0.20)
        condition4 = (Mg ./ minisums .< 0.10)
        condition5 = (Al ./ minisums .< 0.20)
        condition6 = (Si ./ minisums .< 0.25)
        condition7 = (P ./ minisums .< 0.20)
        condition8 = (S ./ minisums .< 0.20)
        condition9 = (Cl ./ minisums .< 0.10)
        condition10 = (K ./ minisums .< 0.10)
        condition11 = (Ca ./ minisums .< 0.10)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_AlO(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Si = T[:, :Si]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Al ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2) .& (criteria1 .<= 1.1)
        condition2 = (Na ./ Al .< 0.2)
        condition3 = (Mg ./ Al .< 0.1)
        condition4 = (Si ./ Al .< 0.2499)
        condition5 = (P ./ Al .< 0.2)
        condition6 = (S ./ Al .< 0.2)
        condition7 = (Cl ./ Al .< 0.1)
        condition8 = (K ./ Al .< 0.1)
        condition9 = (Ca ./ Al .< 0.1)
        condition10 = (Ti ./ Al .< 0.1)
        condition11 = (Fe ./ Al .< 1.0)
        # Classification condition
        condition12 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12
        return index
    end

    function check_quartz(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        criteria1 = Si ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.4) .& (criteria1 .<= 1.1)
        condition2 = (Al ./ Si .< 0.2)
        condition3 = (Na ./ Si .< 0.1)
        condition4 = (Mg ./ Si .< 0.1)
        condition5 = (P ./ Si .< 0.2)
        condition6 = (S ./ Si .< 0.2)
        condition7 = (Cl ./ Si .< 0.05)
        condition8 = (K ./ Si .< 0.1)
        condition9 = (Ca ./ Si .< 0.05)
        condition10 = (Ti ./ Si .< 0.1)
        condition11 = (Cr ./ Si .< 0.05)
        condition12 = (Mn ./ Si .< 0.25)
        condition13 = (Fe ./ Si .< 0.1)
        # Classification condition
        condition14 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14
        return index
    end

    function check_SiAl(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = Si .+ Al
        criteria1 = Al ./ Si
        criteria2 = minisums ./ sums
        criteria3 = Al ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.201) .& (criteria1 .<= 4.000)
        condition2 = (criteria2 .>= 0.400) .& (criteria2 .<= 1.100)
        condition3 = (criteria3 .>= 0.050) .& (criteria3 .<= 1.100)
        condition4 = (Na ./ minisums .< 0.05)
        condition5 = (Mg ./ minisums .< 0.05)
        condition6 = (P ./ minisums .< 0.20)
        condition7 = (S ./ minisums .< 0.20)
        condition8 = (Cl ./ minisums .< 0.10)
        condition9 = (K ./ minisums .< 0.05)
        condition10 = (Ca ./ minisums .< 0.05)
        condition11 = (Ti ./ minisums .< 0.10)
        condition12 = (Cr ./ minisums .< 0.10)
        condition13 = (Mn ./ minisums .< 0.50)
        condition14 = (Fe ./ minisums .< 0.10)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15
        return index
    end

    function check_SiAlK(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        K = T[:, :K]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = Si .+ Al .+ K
        criteria1 = K ./ (Si .+ Al)
        criteria2 = Al ./ Si
        criteria3 = minisums ./ sums
        criteria4 = K ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.00)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 2.00)
        condition3 = (criteria3 .>= 0.400) .& (criteria3 .<= 1.10)
        condition4 = (criteria4 .>= 0.0025) .& (criteria4 .<= 1.10)
        condition5 = (Na ./ minisums .< 0.05)
        condition6 = (Mg ./ minisums .< 0.08)
        condition7 = (P ./ minisums .< 0.20)
        condition8 = (S ./ minisums .< 0.10)
        condition9 = (Cl ./ minisums .< 0.10)
        condition10 = (Ca ./ minisums .< 0.10)
        condition11 = (Ti ./ minisums .< 0.05)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.05)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& condition6 .& 
                condition7 .& condition8 .& condition9 .& condition10 .& condition11 .& condition12 .& 
                condition13 .& condition14 .& condition15
        return index
    end

    function check_SiAlNa(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = Si .+ Al .+ Na
        criteria1 = Na ./ (Si .+ Al)
        criteria2 = Al ./ Si
        criteria4 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.00)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 2.00)
        condition3 = (Ca ./ Na .< 0.25)
        condition4 = (criteria4 .>= 0.400) .& (criteria4 .<= 1.10)
        condition5 = (Mg ./ minisums .< 0.15)
        condition6 = (P ./ minisums .< 0.20)
        condition7 = (S ./ minisums .< 0.10)
        condition8 = (Cl ./ minisums .< 0.05)
        condition9 = (K ./ minisums .< 0.05)
        condition10 = (Ca ./ minisums .< 0.05)
        condition11 = (Ti ./ minisums .< 0.05)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.15)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
        return index
    end

    function check_SiAlNaCa(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Ca = T[:, :Ca]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisum = Si .+ Al
        minisums = Si .+ Al .+ Na .+ Ca
        criteria1 = (Ca .+ Na) ./ minisum
        criteria2 = Ca ./ minisum
        criteria3 = Al ./ Si
        criteria4 = Ca ./ Na
        criteria5 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.00)
        condition2 = (criteria2 .>= 0.101) .& (criteria2 .<= 3.00)
        condition3 = (criteria3 .>= 0.200) .& (criteria3 .<= 2.00)
        condition4 = (criteria4 .>= 0.2501) .& (criteria4 .<= 5.50)
        condition5 = (criteria5 .>= 0.400) .& (criteria5 .<= 1.10)
        condition6 = (Mg ./ minisums .< 0.10)
        condition7 = (P ./ minisums .< 0.20)
        condition8 = (S ./ minisums .< 0.20)
        condition9 = (Cl ./ minisums .< 0.05)
        condition10 = (K ./ minisums .< 0.10)
        condition11 = (Ti ./ minisums .< 0.05)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.10)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
    
        return index
    end

    function check_SiAlNaK(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Na = T[:, :Na]
        K = T[:, :K]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute criteria
        minisums = Si .+ Al .+ Na .+ K
        criteria1 = (K .+ Na) ./ (Si .+ Al)
        criteria2 = Al ./ Si
        criteria3 = K ./ Na
        criteria4 = minisums ./ sums
        criteria5 = Na ./ sums
        criteria6 = K ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.000)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 2.000)
        condition3 = (criteria3 .>= 0.250) .& (criteria3 .<= 4.000)
        condition4 = (criteria4 .>= 0.400) .& (criteria4 .<= 1.100)
        condition5 = (criteria5 .>= 0.050) .& (criteria5 .<= 1.100)
        condition6 = (criteria6 .>= 0.050) .& (criteria6 .<= 1.100)
        condition7 = (Mg ./ minisums .< 0.05)
        condition8 = (P ./ minisums .< 0.20)
        condition9 = (S ./ minisums .< 0.20)
        condition10 = (Cl ./ minisums .< 0.05)
        condition11 = (Ca ./ minisums .< 0.10)
        condition12 = (Ti ./ minisums .< 0.05)
        condition13 = (Cr ./ minisums .< 0.05)
        condition14 = (Mn ./ minisums .< 0.05)
        condition15 = (Fe ./ minisums .< 0.05)
        # Classification condition
        condition16 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15 .& 
                condition16
        return index
    end

    function check_SiAlCaFeMg(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Ca = T[:, :Ca]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        Na = T[:, :Na]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute criteria
        minisums = Si .+ Al .+ Ca .+ Fe .+ Mg
        criteria1 = (Ca .+ Fe .+ Mg) ./ (Si .+ Al)
        criteria2 = Al ./ Si
        criteria3 = Ca ./ (Fe .+ Mg)
        criteria4 = minisums ./ sums
        criteria5 = Ca ./ sums
        criteria6 = Fe ./ sums
        criteria7 = Mg ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.000)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 2.000)
        condition3 = (criteria3 .>= 0.250) .& (criteria3 .<= 10.000)
        condition4 = (criteria4 .>= 0.400) .& (criteria4 .<= 1.100)
        condition5 = (criteria5 .>= 0.050) .& (criteria5 .<= 1.100)
        condition6 = (criteria6 .>= 0.025) .& (criteria6 .<= 1.100)
        condition7 = (criteria7 .>= 0.025) .& (criteria7 .<= 1.100)
        condition8 = (Ca ./ (Si .+ Al) .< 0.50)
        condition9 = (Na ./ minisums .< 0.05)
        condition10 = (P ./ minisums .< 0.20)
        condition11 = (S ./ minisums .< 0.20)
        condition12 = (Cl ./ minisums .< 0.10)
        condition13 = (K ./ minisums .< 0.05)
        condition14 = (Ti ./ minisums .< 0.05)
        condition15 = (Cr ./ minisums .< 0.05)
        condition16 = (Mn ./ minisums .< 0.05)
        # Classification condition
        condition17 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15 .& 
                condition16 .& condition17
        return index
    end

    function check_SiAlKFeMg(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Na = T[:, :Na]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute sums
        minisum1 = Si .+ Al
        minisum2 = Fe .+ Mg
        minisums = Si .+ Al .+ K .+ Fe .+ Mg
        # Compute criteria
        criteria1 = (K .+ Fe .+ Mg) ./ minisum1
        criteria2 = K ./ minisum1
        criteria3 = minisum2 ./ minisum1
        criteria4 = K ./ minisum2
        criteria5 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.101) .& (criteria1 .<= 3.00)
        condition2 = (criteria2 .>= 0.101) .& (criteria2 .<= 3.00)
        condition3 = (criteria3 .>= 0.101) .& (criteria3 .<= 3.00)
        condition4 = (criteria4 .>= 0.250) .& (criteria4 .<= 4.00)
        condition5 = (criteria5 .>= 0.400) .& (criteria5 .<= 1.10)
        condition6 = (Ca ./ sums .< 0.05)
        condition7 = (Na ./ minisums .< 0.10)
        condition8 = (P ./ minisums .< 0.20)
        condition9 = (S ./ minisums .< 0.20)
        condition10 = (Cl ./ minisums .< 0.10)
        condition11 = (Ca ./ minisums .< 0.05)
        condition12 = (Ti ./ minisums .< 0.05)
        condition13 = (Cr ./ minisums .< 0.05)
        condition14 = (Mn ./ minisums .< 0.05)
        # Classification condition
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
        return index
    end

    function check_SiAlFeMg(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Al = T[:, :Al]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        K = T[:, :K]
        Na = T[:, :Na]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute sums and criteria
        minisum = Si .+ Al
        minisums = Si .+ Al .+ Fe .+ Mg
        criteria1 = Al ./ sums
        criteria2 = Fe ./ sums
        criteria3 = Mg ./ sums
        criteria5 = (Mg .+ Fe) ./ minisum
        criteria6 = Al ./ Si
        criteria8 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.10) .& (criteria1 .<= 0.80)
        condition2 = (criteria2 .>= 0.05) .& (criteria2 .<= 0.80)
        condition3 = (criteria3 .>= 0.05) .& (criteria3 .<= 0.80)
        condition4 = (Ca ./ sums .< 0.05)
        condition5 = (criteria5 .>= 0.101) .& (criteria5 .<= 3.00)
        condition6 = (criteria6 .>= 0.201) .& (criteria6 .<= 2.00)
        condition7 = (K ./ minisum .< 0.10)
        condition8 = (criteria8 .>= 0.050) .& (criteria8 .<= 1.10)
        condition9 = (Na ./ minisums .< 0.05)
        condition10 = (P ./ minisums .< 0.20)
        condition11 = (S ./ minisums .< 0.20)
        condition12 = (Cl ./ minisums .< 0.05)
        condition13 = (K ./ minisums .< 0.10)
        condition14 = (Ca ./ minisums .< 0.10)
        condition15 = (Ti ./ minisums .< 0.05)
        condition16 = (Cr ./ minisums .< 0.05)
        condition17 = (Mn ./ minisums .< 0.05)
        # Classification condition
        condition18 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15 .& 
                condition16 .& condition17 .& condition18
        return index
    end

    function check_SiMgFe(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Fe = T[:, :Fe]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Na = T[:, :Na]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        # Compute sums and criteria
        minisums = Si .+ Fe .+ Mg
        criteria1 = Fe ./ (Si .+ Mg)
        criteria2 = (Mg .+ Fe) ./ Si
        criteria4 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.201) .& (criteria1 .<= 10.0)
        condition2 = (criteria2 .>= 0.250) .& (criteria2 .<= 4.0)
        condition3 = (Al ./ Si .< 0.2)
        condition4 = (criteria4 .>= 0.400) .& (criteria4 .<= 1.1)
        condition5 = (Na ./ minisums .< 0.10)
        condition6 = (Al ./ minisums .< 0.05)
        condition7 = (P ./ minisums .< 0.20)
        condition8 = (S ./ minisums .< 0.20)
        condition9 = (Cl ./ minisums .< 0.10)
        condition10 = (K ./ minisums .< 0.10)
        condition11 = (Ca ./ minisums .< 0.10)
        condition12 = (Ti ./ minisums .< 0.05)
        condition13 = (Cr ./ minisums .< 0.05)
        condition14 = (Mn ./ minisums .< 0.05)
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
        return index
    end

    function check_SiMg(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Na = T[:, :Na]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute sums and criteria
        minisums = Si .+ Mg
        criteria1 = Mg ./ Si
        criteria3 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 4.0)
        condition2 = (Al ./ Si .< 0.2)
        condition3 = (criteria3 .>= 0.40) .& (criteria3 .<= 1.1)
        condition4 = (Na ./ minisums .< 0.1)
        condition5 = (Al ./ minisums .< 0.1)
        condition6 = (P ./ minisums .< 0.2)
        condition7 = (S ./ minisums .< 0.2)
        condition8 = (Cl ./ minisums .< 0.1)
        condition9 = (K ./ minisums .< 0.1)
        condition10 = (Ca ./ minisums .< 0.1)
        condition11 = (Ti ./ minisums .< 0.05)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.20)
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
        return index
    end

    function check_SiCaTi(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute sums and criteria
        minisums = Si .+ Ca .+ Ti
        criteria1 = Ca ./ Ti
        criteria3 = minisums ./ sums
        criteria4 = Ca ./ Si
        criteria5 = Ti ./ Si
        # Logical conditions
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 4.0)
        condition2 = (Al ./ Si .< 0.2)
        condition3 = (criteria3 .>= 0.40) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.101) .& (criteria4 .<= 10.0)
        condition5 = (criteria5 .>= 0.101) .& (criteria5 .<= 10.0)
        condition6 = (Na ./ minisums .< 0.10)
        condition7 = (Mg ./ minisums .< 0.10)
        condition8 = (P ./ minisums .< 0.20)
        condition9 = (S ./ minisums .< 0.20)
        condition10 = (Cl ./ minisums .< 0.10)
        condition11 = (K ./ minisums .< 0.10)
        condition12 = (Cr ./ minisums .< 0.05)
        condition13 = (Mn ./ minisums .< 0.05)
        condition14 = (Fe ./ minisums .< 0.20)
        condition15 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15
        return index
    end

    function check_mixSiS(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        S = T[:, :S]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute sums and criteria
        minisums = Si .+ S
        criteria2 = S ./ sums
        criteria3 = S ./ Si
        criteria5 = minisums ./ sums
        # Logical conditions
        condition1 = (Al ./ sums .< 0.05)
        condition2 = (criteria2 .>= 0.05) .& (criteria2 .<= 0.90)
        condition3 = (criteria3 .>= 0.50) .& (criteria3 .<= 3.00)
        condition4 = (Al ./ Si .< 0.20)
        condition5 = (criteria5 .>= 0.30) .& (criteria5 .<= 1.10)
        condition6 = (Na ./ minisums .< 2.00)
        condition7 = (Mg ./ minisums .< 2.00)
        condition8 = (Al ./ minisums .< 0.20)
        condition9 = (P ./ minisums .< 0.20)
        condition10 = (Cl ./ minisums .< 0.05)
        condition11 = (K ./ minisums .< 2.00)
        condition12 = (Ca ./ minisums .< 2.00)
        condition13 = (Ti ./ minisums .< 0.20)
        condition14 = (Cr ./ minisums .< 0.10)
        condition15 = (Mn ./ minisums .< 0.05)
        condition16 = (Fe ./ minisums .< 0.20)
        condition17 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15 .& 
                condition16 .& condition17
        return index
    end

    function check_mixSiAlS(T, sums, classification_array)
        # Extract columns from DataFrame
        Al = T[:, :Al]
        Si = T[:, :Si]
        S = T[:, :S]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        Cl = T[:, :Cl]
        K = T[:, :K]
        Ca = T[:, :Ca]
        Ti = T[:, :Ti]
        Cr = T[:, :Cr]
        Mn = T[:, :Mn]
        Fe = T[:, :Fe]
        # Compute sums and criteria
        minisums = Al .+ Si .+ S
        criteria1 = Al ./ sums
        criteria2 = Si ./ sums
        criteria3 = S ./ sums
        criteria4 = S ./ Si
        criteria5 = Al ./ Si
        criteria6 = minisums ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.05) .& (criteria1 .<= 0.90)
        condition2 = (criteria2 .>= 0.10) .& (criteria2 .<= 0.90)
        condition3 = (criteria3 .>= 0.10) .& (criteria3 .<= 0.90)
        condition4 = (criteria4 .>= 0.50) .& (criteria4 .<= 10.00)
        condition5 = (criteria5 .>= 0.201) .& (criteria5 .<= 5.00)
        condition6 = (criteria6 .>= 0.30) .& (criteria6 .<= 1.10)
        condition7 = (Na ./ minisums .< 5.00)
        condition8 = (Mg ./ minisums .< 5.00)
        condition9 = (P ./ minisums .< 0.20)
        condition10 = (Cl ./ minisums .< 0.05)
        condition11 = (K ./ minisums .< 5.00)
        condition12 = (Ca ./ minisums .< 5.00)
        condition13 = (Ti ./ minisums .< 0.20)
        condition14 = (Cr ./ minisums .< 0.20)
        condition15 = (Mn ./ minisums .< 0.20)
        condition16 = (Fe ./ minisums .< 5.00)
        condition17 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13 .& condition14 .& condition15 .& 
                condition16 .& condition17
        return index
    end

    function check_mixClS(T, sums, classification_array)
       # Extract columns from DataFrame
        Cl = T[:, :Cl]
        S = T[:, :S]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        Al = T[:, :Al]
        Si = T[:, :Si]
        P = T[:, :P]
        K = T[:, :K]
        Fe = T[:, :Fe]
        # Compute sums and criteria
        minisums = S .+ Cl
        criteria1 = Cl ./ S
        criteria2 = minisums ./ sums
        criteria3 = Cl ./ sums
        criteria4 = S ./ sums
        criteria5 = S ./ (Na .+ Cl)
        # Logical conditions
        condition1 = (criteria1 .>= 0.201) .& (criteria1 .<= 10.00)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 1.10)
        condition3 = (criteria3 .>= 0.025) .& (criteria3 .<= 1.10)
        condition4 = (criteria4 .>= 0.025) .& (criteria4 .<= 1.10)
        condition5 = (criteria5 .>= 0.100) .& (criteria5 .<= 20.00)
        condition6 = (Na ./ minisums .< 3.00)
        condition7 = (Mg ./ minisums .< 3.00)
        condition8 = (Al ./ minisums .< 0.20)
        condition9 = (Si ./ minisums .< 0.25)
        condition10 = (P ./ minisums .< 0.25)
        condition11 = (K ./ minisums .< 3.00)
        condition12 = (Fe ./ minisums .< 2.00)
        condition13 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13
        return index
    end

    function check_mixNaClSi(T, sums, classification_array)
       # Extract columns from DataFrame
        Si = T[:, :Si]
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        Al = T[:, :Al]
        # Compute criteria
        criteria1 = Si ./ (Na .+ Cl)
        criteria2 = Al ./ Si
        criteria3 = (Si .+ Na .+ Cl) ./ sums
        criteria4 = Cl ./ sums
        criteria5 = Na ./ sums
        criteria6 = Si ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.05) .& (criteria1 .<= 100)
        condition2 = (criteria2 .< 0.2)
        condition3 = (criteria3 .>= 0.2) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.05) .& (criteria4 .<= 1.1)
        condition5 = (criteria5 .>= 0.05) .& (criteria5 .<= 1.1)
        condition6 = (criteria6 .>= 0.01) .& (criteria6 .<= 1.1)
        condition7 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7
        return index
    end

    function check_mixNaClSiAl(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Na = T[:, :Na]
        Cl = T[:, :Cl]
        Al = T[:, :Al]
        # Compute criteria
        criteria1 = (Si .+ Al) ./ (Na .+ Cl)
        criteria2 = Al ./ Si
        criteria3 = (Si .+ Na .+ Cl) ./ sums
        criteria4 = Cl ./ sums
        criteria5 = Na ./ sums
        criteria6 = Si ./ sums
        criteria7 = Al ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.075) .& (criteria1 .<= 100)
        condition2 = (criteria2 .>= 0.201) .& (criteria2 .<= 100)
        condition3 = (criteria3 .>= 0.200) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.050) .& (criteria4 .<= 1.1)
        condition5 = (criteria5 .>= 0.050) .& (criteria5 .<= 1.1)
        condition6 = (criteria6 .>= 0.025) .& (criteria6 .<= 1.1)
        condition7 = (criteria7 .>= 0.010) .& (criteria7 .<= 1.1)
        condition8 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8
        return index
    end

    function check_mixCaSi(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        # Compute criteria
        minisums = Si .+ Ca
        criteria1 = Si ./ Ca
        criteria2 = Al ./ Si
        criteria3 = minisums ./ sums
        criteria4 = Si ./ sums
        criteria5 = Ca ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2501) .& (criteria1 .<= 4.00)
        condition2 = (criteria2 .< 0.2)
        condition3 = (criteria3 .>= 0.2000) .& (criteria3 .<= 1.10)
        condition4 = (criteria4 .>= 0.0100) .& (criteria4 .<= 1.10)
        condition5 = (criteria5 .>= 0.0500) .& (criteria5 .<= 1.10)
        condition6 = (Mg ./ minisums .< 0.1)
        condition7 = (Al ./ minisums .< 0.2)
        condition8 = (P ./ minisums .< 0.2)
        condition9 = (S ./ minisums .< 0.2)
        condition10 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10
        return index
    end

    function check_mixCaSiAl(T, sums, classification_array)
        # Extract columns from DataFrame
        Si = T[:, :Si]
        Ca = T[:, :Ca]
        Al = T[:, :Al]
        Na = T[:, :Na]
        Mg = T[:, :Mg]
        P = T[:, :P]
        S = T[:, :S]
        Cl = T[:, :Cl]
        K = T[:, :K]
        # Compute criteria
        minisums = Si .+ Ca
        criteria1 = Al ./ Si
        criteria2 = (Ca .+ Si .+ Al) ./ sums
        criteria3 = Al ./ sums
        criteria4 = Si ./ sums
        criteria5 = Ca ./ sums
        criteria6 = Si ./ Ca
        # Logical conditions
        condition1 = (criteria1 .>= 0.201) .& (criteria1 .<= 20)
        condition2 = (criteria2 .>= 0.200) .& (criteria2 .<= 1.1)
        condition3 = (criteria3 .>= 0.010) .& (criteria3 .<= 1.1)
        condition4 = (criteria4 .>= 0.010) .& (criteria4 .<= 1.1)
        condition5 = (criteria5 .>= 0.050) .& (criteria5 .<= 1.1)
        condition6 = (criteria6 .>= 0.1001) .& (criteria6 .<= 100)
        condition7 = (Na ./ minisums .< 0.2)
        condition8 = (Mg ./ minisums .< 2.0)
        condition9 = (P ./ minisums .< 0.2)
        condition10 = (S ./ minisums .< 0.2)
        condition11 = (Cl ./ minisums .< 0.05)
        condition12 = (K ./ minisums .< 1.00)
        condition13 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3 .& condition4 .& condition5 .& 
                condition6 .& condition7 .& condition8 .& condition9 .& condition10 .& 
                condition11 .& condition12 .& condition13
        return index
    end

    function check_mixOtherSi(T, sums, classification_array)
       # Extract columns from DataFrame
        Si = T[:, :Si]
        # Compute criteria
        criteria1 = Si ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.1) .& (criteria1 .<= 1.1)
        condition2 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2
        return index
    end

    function check_steel(T, sums, classification_array)
        # Extract columns from DataFrame
        Fe = T[:, :Fe]
        Ti = T[:, :Ti]
        Mn = T[:, :Mn]
        Cr = T[:, :Cr]
        # Compute criteria
        criteria1 = Fe .+ Ti .+ Mn .+ Cr
        criteria2 = Fe ./ sums
        # Logical conditions
        condition1 = (criteria1 .>= 0.2) .& (criteria1 .<= 1.1)
        condition2 = (criteria2 .>= 0.2) .& (criteria2 .<= 1.1)
        condition3 = (classification_array .== "Unknown")
        # Combine all conditions
        index = condition1 .& condition2 .& condition3
        return index
    end

    function check_otherMg(T, sums, classification_array)
    # Extract columns from DataFrame
    Mg = T[:, :Mg]
    # Compute criteria
    criteria1 = Mg ./ sums
    # Logical conditions
    condition1 = (criteria1 .>= 0.35) .& (criteria1 .<= 1.1)
    condition2 = (classification_array .== "other")
    # Combine all conditions
    index = condition1 .& condition2
        return index
    end

    function check_otherK(T, sums, classification_array)
        K = T[:, :K]
        criteria1 = K ./ sums
        condition1 = (criteria1 .>= 0.25) .& (criteria1 .<= 1.1)
        condition2 = (classification_array[:, 1] .== "Unknown")
        index = condition1 .& condition2 
        return index
    end

    function check_otherCa(T, sums, classification_array)
        Ca = T[:, :Ca]
        criteria1 = Ca ./ sums
        condition1 = (criteria1 .>= 0.15) .& (criteria1 .<= 1.1)
        condition2 = (classification_array[:, 1] .== "Unknown")
        index =  condition1 .& condition2
        return index
    end

# Final step: Classify the mineralogy for each row of the input table
minerals = DataFrame(Minerals = mineral_classification(df))
return minerals
end