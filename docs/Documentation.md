<a id="TMP_8b8e"></a>

# **EDS Classification**

**Documentation**

The examples in this documentation are available in `eds_demo.m`

<!-- Begin Toc -->

## Table of Contents
[**EDS Classification**](#TMP_8b8e)
 
[eds\_classification](#TMP_54ca)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_0778)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_46f9)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_5c38)
 
&#8195;&#8195;&#8195;[Name\-Value Arguments](#TMP_28ec)
 
&#8195;&#8195;&#8195;[Example 1](#TMP_463d)
 
&#8195;&#8195;&#8195;[Example 2](#TMP_4d13)
 
[eds\_read](#TMP_8af8)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_52ec)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_12da)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_809d)
 
&#8195;&#8195;&#8195;[Functions (Methods)](#TMP_93c7)
 
&#8195;&#8195;&#8195;[Example 1](#TMP_7032)
 
&#8195;&#8195;&#8195;[Example 2](#TMP_27af)
 
[get\_sem\_metadata](#TMP_2982)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_0746)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_2693)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_347d)
 
&#8195;&#8195;&#8195;[Example](#TMP_535f)
 
[msa\_classification](#TMP_7263)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_3eb8)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_12b1)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_8529)
 
&#8195;&#8195;&#8195;[Name\-Value Arguments](#TMP_266e)
 
&#8195;&#8195;&#8195;[Example](#TMP_85cb)
 
[Spectrum](#TMP_44f4)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_4465)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_2f53)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_475f)
 
&#8195;&#8195;&#8195;[Name\-Value Arguments](#TMP_2c88)
 
&#8195;&#8195;&#8195;[Functions (Methods)](#TMP_9765)
 
&#8195;&#8195;&#8195;[Example 1](#TMP_2337)
 
&#8195;&#8195;&#8195;[Example 2](#TMP_534a)
 
&#8195;&#8195;&#8195;[Example 3](#TMP_19b5)
 
[standard\_stoich\_quant](#TMP_274e)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_6b9f)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_3c5d)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_1371)
 
&#8195;&#8195;&#8195;[Example](#TMP_40f7)
 
[stoich\_quant](#TMP_4b2d)
 
&#8195;&#8195;&#8195;[Syntax](#TMP_2298)
 
&#8195;&#8195;&#8195;[Input Arguments](#TMP_6c09)
 
&#8195;&#8195;&#8195;[Output Arguments](#TMP_1855)
 
&#8195;&#8195;&#8195;[Example](#TMP_6ae6)
 
<!-- End Toc -->

<a id="TMP_54ca"></a>

# eds\_classification

EDS mineral classification

**Description**

Apply different mineral classification algorithms to EDS data sets. Different algorithms may produce different results, depending on what the algorithm is trained to recognize. Therefore, it is recommended that the user compares the results of multiple algorithms to ensure thorough mineral identification.

<a id="TMP_0778"></a>
### Syntax

`mineral = eds_classification(data)`

`mineral = eds_classification(data,'Algorithm',algorithm)`

<a id="TMP_46f9"></a>
### Input Arguments

`data        table` | EDS data set with columns for each mineral\-forming element. Different algorithms require different elements.

<a id="TMP_5c38"></a>
### Output Arguments

`mineral      struct` | Container with labels for each mineral (row) in the input table. Containers vary depending on the algorithm.

<a id="TMP_28ec"></a>
### Name\-Value Arguments

The `eds_classification` function can accept one **optional** name\-value pair.

|||||
| :-- | :-- | :-- | :-- |
| **Name**  | **Value**  | **Description**  | **Reference**   |
| `'Algorithm'`  | `'Weber'` (default)  | Machine learning classifier trained to recognize certain minerals commonly found in dust samples. The input `table` must contain columns for the following elements: Na, Mg, Al, Si, P, K, Ca, Ti, and Fe. The output `struct` will contain (1) a `categorical` list of mineral names, (2) a `categorical` list of mineral group names, and (3) a probability `table` for each mineral ID.  | \[1\]   |
| `'Algorithm'`  | `'Donarummo'`  | Sorting algorithm designed for the identification of aluminosilicate minerals in ice core samples. The input `table` must contain columns for the following elements: Na, Mg, Al, Si, K, Ca, and Fe. The output `struct` will contain a `categorical` list of mineral names.  | \[2\]   |
| `'Algorithm'`  | `'Kandler'`  | Comparative criteria algorithm for classifying the general chemistry of particles in dust samples. The input `table` must contain columns for the following elements: Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The output `struct` will contain (1) a `categorical` list of chemical classes, (2) a `categorical` list of generalized mineral groups, and (3) a list of refractive indexes.   | \[3\]   |
| `'Algorithm'`  | `'Kutuzov'`  | Comparative criteria algorithm originally designed for mineral identification with single particle ICP\-TOFMS, but it also works reasonably well with EDS data. The input `table` must contain columns for the following elements: Na, Mg, Al, Si, Ca, Ti, and Fe. The output `struct` will contain a `categorical` list of mineral names.  | \[4\]   |
| `'Algorithm'`  | `'Panta'`  | Comparative criteria algorithm used for the classification of dust particles in the Moroccan Sahara. The input `table` must contain columns for each of the following elements: F, Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The output `struct` will contain a `categorical` list of mineral names.  | \[5\]   |

**References**

1. Weber, A. M. (2025). *Journal of Open Source Software*, *10*. [https://doi.org/10.21105/joss.07533](https://doi.org/10.21105/joss.07533)
2. Donarummo et al. (2003). *Geophysical Research Letters*, *30*. [https://doi.org/10.1029/2002GL016641](https://doi.org/10.1029/2002GL016641)
3. Kandler et al. (2011). *Tellus B*, *63*. [https://doi.org/10.1111/j.1600\-0889.2011.00550.x](https://doi.org/10.1111/j.1600-0889.2011.00550.x)
4. Kutuzov et al. (2026). *Scientific Reports*, *16*. [https://doi.org/10.1038/s41598\-026\-45260\-3](https://doi.org/10.1038/s41598-026-45260-3)
5. Panta et al. (2023). *Atmospheric Chemistry and Physics*, *23*. [https://doi.org/10.5194/acp\-23\-3861\-2023](https://doi.org/10.5194/acp-23-3861-2023)

<a id="TMP_463d"></a>
### Example 1

Load a `table` into the Workspace and apply the default EDS mineral classification algorithm to the data in the table.

```matlab
load('eds_data.mat','data')
minerals = eds_classification(data);
```

<a id="TMP_4d13"></a>
### Example 2

Compare the outputs of the `Donarummo` and `Kutuzov` mineral classification algorithms.

```matlab
% Get mineral IDs
D_minerals = eds_classification(data, Algorithm='Donarummo');
K_minerals = eds_classification(data, Algorithm='Kutuzov');


% Construct a comparison table
D_vs_K = array2table([D_minerals.Mineral, K_minerals.Mineral], ...
  'VariableNames', {'Donarummo','Kutuzov'});


% Compare the first 4 rows
head(D_vs_K, 4)
```

<a id="TMP_8af8"></a>

# eds\_read

Create object from EDS spectral data file (.msa / .emsa)

<a id="TMP_52ec"></a>
### Syntax

`data = eds_read(filename)`

<a id="TMP_12da"></a>
### Input Arguments

`filename    char` | Specifies the name of an x\-ray energy file in either .msa or .emsa format.

<a id="TMP_809d"></a>
### Output Arguments

`data        eds_read` | A struct\-like object with the following properties:

||||
| :-- | :-- | :-- |
| **Property**  | **Class**  | **Description**   |
| FileName  | char  | Name of the .msa / .emsa file   |
| Metadata  | struct  | Metadata contained in the file   |
| Energy  | double  | X\-ray energy bins (keV)   |
| Counts  | double  | Number of counts per energy bin   |

<a id="TMP_93c7"></a>
### Functions (Methods)

 `plot_spectrum` Quick visualization of x\-ray counts versus energy.

<a id="TMP_7032"></a>
### Example 1

Read an x\-ray energy file and access its metadata.

```matlab
s = eds_read('.\data\phenom_osu.emsa');
md = s.Metadata
```

<a id="TMP_27af"></a>
### Example 2

Plot a quick visualization of an x\-ray energy spectrum.

```matlab
figure
s.plot_spectrum; % Equivalent to eds_read(filename).plot_spectrum();
```

**Note:** For a better method for visualizing EDS spectra, see the documentation entry for the **Spectrum** class.

<a id="TMP_2982"></a>

# get\_sem\_metadata

Extract metadata from SEM images (.tif)

**Description**

Can extract useful information from SEM micrographs, such as the collection date, acceleration voltage, spot size, horizontal field width, working distance, pixel width, and beam current. I have tested this function on two different types of images (backscatter electron, BSE; and secondary electron, SE) collected with two different SEMs. However, I cannot guarantee that it will work on  *any* SEM image.

<a id="TMP_0746"></a>
### Syntax

`metadata = get_sem_metadata(filename)`

<a id="TMP_2693"></a>
### Input Arguments

`filename      char` | Name of an SEM micrograph file (.tif format). 

<a id="TMP_347d"></a>
### Output Arguments

`metadata    struct` | Container of useful metadata

<a id="TMP_535f"></a>
### Example

```matlab
backscatter_image = 'micrograph_BSE.tif';
metadata = get_sem_metadata(backscatter_image)
```

<a id="TMP_7263"></a>

# msa\_classification

Mineral classification of .msa / .emsa files

**Description**

In cases where you do not have a predefined table of EDS net intensities or atom percent data, you can approximate the mineralogy of an EDS spectrum by passing the .msa / .emsa file directly into the `msa_classification` function. This function reads the spectral data from the file and applies a series of algorithms to the data that subtract the background Bremmstrahlung radiation, calculate the peak intensities of the characteristic x\-rays for each mineral forming element, compile the intensity data into the proper format for analysis, and then apply the `eds_classification` function to the data. This method is slightly inferior to using net intensity data acquired directly from the original EDS software, but it still works well in most cases. 

<a id="TMP_3eb8"></a>
### Syntax

`mineral = msa_classification(filename)`

`mineral = msa_classification(filename,varargin)`

<a id="TMP_12b1"></a>
### Input Arguments

`filename`        `char` | Name of the .msa or .emsa file.

<a id="TMP_8529"></a>
### Output Arguments

`mineral     struct` | Container that includes the mineral ID according to the chosen algorithm. See the entry for `eds_classification` for details.

<a id="TMP_266e"></a>
### Name\-Value Arguments

The following name\-value arguments are **optional**.

||||
| :-- | :-- | :-- |
| **Name**  | **Default Value**  | **Description**   |
| `'Algorithm'`  | `'Weber'`  | The name of the mineral classification algorithm. Options include: `'Donarummo'`, `'Kandler'`, `'Kutuzov'`, `'Panta'`, and `'Weber'`.   |
| `'Degree'`  | 10  | The degree of the polynomial fitting algorithm used to subtract the background Bremsstrahlung radiation. It is worth noting that the background subtraction algorithm is not simply a fit\-and\-subtract function. The algorithm first identifies local minima at the base of each characteristic x\-ray peak and then fits the polynomial model to those data points, not the spectrum itself.   |
| `'MinSeparation'`  | 0.13  | The minimum distance between peaks in the spectrum (in units of keV), used for constraining the background subtraction algorithm.   |
| `'SmoothingFactor'`  | 15  | A moving average filter that reduces noise in the EDS spectrum. If the spectrum is noisy (lots of small variations due to relatively low x\-ray counts), the algorithm that identifies local minima in the spectra can become overwhelmed, which ruins the polynomial fitting and ergo, the background subtraction method.   |

 **Note on the background subtraction algorithm:** 

I do not want this algorithm to feel like a black box to the user. If you would like a better understanding of what is happening in the backend, I encourage you to view the internal documentation for this algorithm by executing:

 `>>  help subtract_background` 

in the Command Window. Trying run this algorithm individually on a `.msa` file and assign a second output argument to a variable, for example:

`>> [~,h] = subtract_background('myspectrum.msa');`

The output variable `h` will return an figure handle that automatically opens a new figure that visualizes the background subtraction process for the input file. Vary the optional input arguments to see how it affects your spectrum. For example:

`>> [~,h2] = subtract_background('myspectrum.msa', 'Degree', 9, 'MinSeparation', 0.1, 'SmoothingFactor', 10);`

This is the process that I used to determine the optimal default values, but I recognize that these values are not always perfect for a given EDS spectrum. This is why I decided to include the name\-value pairs as optional input arguments, so that the user doesn't have to blindly trust hard\-coded parameterizations.

<a id="TMP_85cb"></a>
### Example

Identify the mineralogy of a sample directly from its `.msa` file.

```matlab
mineral = msa_classification('.\data\apreo_cemas.msa');
```

<a id="TMP_97f3"></a>
<a id="TMP_44f4"></a>

# Spectrum

EDS x\-ray energy spectrum plot

**Description**

This is the preferred method for visualizing EDS spectra because the plots are much easier to customize.

<a id="TMP_4465"></a>
### Syntax

`plt = Spectrum(x,y,varargin)`

<a id="TMP_2f53"></a>
### Input Arguments

`x          double` | X\-ray energy channels in units of keV.

`y          double` | X\-ray counts for each channel in `x`.

<a id="TMP_475f"></a>
### Output Arguments

`plt`                `Spectrum` | Handle to the Spectrum object.

<a id="TMP_2c88"></a>
### Name\-Value Arguments

The following name\-value arguments are **optional**. If you do not specify chart colors then the visualization will behave similarly to the base plotting function `area(x,y)`.

`LineWidth        double` | Width of the edge line. Default=`1`.

`FaceAlpha        double` | Opacity of the area chart. Default=`0.1`.

`FaceColor        RGB, hexcode, or color symbol` | Color of the area chart.

`EdgeColor        RGB, hexcode, or color symbol` | Color of the edge line.

<a id="TMP_9765"></a>
### Functions (Methods)

 `getSpectrumAxes()` The equivalent of `gca` for a Spectrum object.

`addSpectrum(x,y,varargin)`    Overlay a new spectrum onto the existing Spectrum object.

`normalizeSpectrum()`                Normalize y\-axis from 0 to 1. Please note that this action is not reversible.

`removeSpectrum(varargin)`      If no arguments are passed, this function deletes the most recent spectrum overlay. Alternatively, the user can specify which spectra to remove by passing a vector of positive integers as the sole input argument. For example, `removeSpectrum([1 2])` will delete the 1st and 2nd\-most recent spectra overlays. The user may also pass the character vector `'all'` as the sole input argument, which will delete all spectra overlays. The original Spectrum object cannot be deleted with this function.

`addXrayLabels(varargin)`        If no arguments are passed, this function will auto\-detect major peaks in the spectrum and label them according to the characteristic x\-ray energy for what (we hope) is the most likely element. I cannot guarantee that this function will correctly label each peak, but it does a decent job at prioritizing K\-lines when labeling. For instance, an oxygen Kα peak (usually) will not be mislabeled as the vanadium Lα line if the corresponding vanadium Kα lines are not present. Similarly, an iron Lα peak (usually) will not be mislabeled as the fluorene Kα line as long as the iron Kα lines are present. The optional name\-value arguments are given in the following table:

||||
| :-- | :-- | :-- |
| **Name**  | **Default Value**  | **Description**   |
| `'Prominence'`  | 90  | The minimum prominence of the major x\-ray peaks in the EDS spectrum, given as a percentile. Think of prominence as the sensitivity of the labeling algorithm. The higher the prominence, the intenser the peak must be for the algorithm to label it.   |
| `'Marker'`  | `'none'`  | Specifying will add makers to the spectrum along with the x\-ray labels. You can use any combination of a single character marker style and/or a single character color code. For example, `'s'` will plot square markers at each major peak while `'sr'` will plot red square markers at each major peak.   |
| `'MarkerSize'`  | 4  | Size of the markers.   |
| `'MarkerFaceColor'`  | `'none'`  | Specifies a fill color for your markers. All basic color options are accepted, including RGB triplets and hexadecimal codes.   |

 `removeXrayLabels()` Deletes all markers and x\-ray labels in the current Spectrum.

<a id="TMP_2337"></a>
### Example 1

Create a simple Spectrum object visualization.

```matlab
s = eds_read('.\data\phenom_osu.emsa');
figure
plt = Spectrum(s.Energy, s.Counts);
```

Note that Example 1 above is equivalent to the quick visualization method: `eds_read(filename).plot_spectrum();` 

<a id="TMP_534a"></a>
### Example 2

Overlay a second spectrum onto the original Spectrum, and normalize the y\-axes for better comparison.

```matlab
s1 = eds_read('.\data\phenom_osu.emsa');
s2 = eds_read('.\data\quattro_cemas.msa');
figure
plt2 = Spectrum(s1.Energy, s1.Counts);
plt2.addSpectrum(s2.Energy, s2.Counts);
plt2.normalizeSpectrum();
```

<a id="TMP_19b5"></a>
### Example 3

Add characteristic x\-ray labels to a Spectrum.

```matlab
s3 = eds_read('.\data\apreo_cemas.msa');
figure
plt3 = Spectrum(s3.Energy, s3.Counts);
plt3.addXrayLabels('prominence',94,'marker','sr');
```

<a id="TMP_274e"></a>

# standard\_stoich\_quant

Casting's approximation for stoichiometry based on a reference material

**Description**

This function quantifies the stoichiometric composition of a sample by means of Casting's approximation:

 $$ C_{i,sample} =\frac{I_{i,sample} }{I_{i,standard} }\times C_{i,standard} $$ 

where `C` is normalized weight percent and `i` represents an element of the sample or standard. This function should only be used when you acquire data for a reference material and a sample using the same instrument conditions (acceleration voltage, spot size, etc.).

<a id="TMP_6b9f"></a>
### Syntax

`quant = standard_stoich_quant(num_Oxygens, elements, ...`

 `norm_wt_pct_standard, net_counts_standard, net_counts_sample)` 

<a id="TMP_3c5d"></a>
### Input Arguments

`num_Oxygens           double` | Number of expected oxygens in chemical formula.

`elements                cell` | List of elements in the measured data. For example: `{'O','Mg','Al','Si'}.`

`norm_wt_pct_standard  double` | Numeric array of normalized weight percents corresponding to the elements in the reference material.

`net_counts_standard   double` | Numeric array of net intensity values corresponding to the elements in the reference material.

`net_counts_sample     double` | Numeric array of net intensity values corresponding to the elements in the sampled material.

<a id="TMP_1371"></a>
### Output Arguments

`quant                  table` | Table of elements and their corresponding stoichiometric coefficients.

<a id="TMP_40f7"></a>
### Example

Let's say that you collected net intensity data for a sample of plagioclase feldspar, and you want to make sure that its stoichiometry is consistent with what is expected for plagioclase. (If you aren't familiar, plagioclase is a solid solution series that runs from its Na end\-member albite \[NaAlSi3O8\] to its Ca end\-member anorthite \[CaAl2Si2O8\]). 

The formula for plagioclase contains 8 oxygens, and so the first input argument for `standard_stoich_quant` should be `8`. The second input argument, `elements`, is a list of the measured elements in your plagioclase standard and your plagioclase sample. In this case, `elements` might be `{'O','Na','Al','Si',Ca'}`. The order of the elements should match the order of the measured data in `norm_wt_pct_standard`, `net_counts_standard`, and `net_counts_sample`.

An example data set is stored in the binary file `plagioclase_quant.mat`:

```matlab
load('plagioclase_quant.mat','num_O','elements','std_wts','std_net','spl_net')
standard_quant = standard_stoich_quant(num_O, elements, std_wts, std_net, spl_net)
```

<a id="TMP_4b2d"></a>

# stoich\_quant

Standardless stoichiometric quantification

<a id="TMP_2298"></a>
### Syntax

`quant = stoich_quant(num_Oxygens, elements, norm_wt_pct)`

<a id="TMP_6c09"></a>
### Input Arguments

`num_Oxygens           double` | Number of expected oxygens in chemical formula.

`elements                cell` | List of elements in the measured data. For example: `{'O','Mg','Al','Si'}.`

`norm_wt_pct           double` | Numeric array of normalized weight percents corresponding to the elements in the sample.

<a id="TMP_1855"></a>
### Output Arguments

`quant                  table` | Table of elements and their corresponding stoichiometric coefficients.

<a id="TMP_6ae6"></a>
### Example

Let's say you have performed EDS on a mineral particle that you expect is plagioclase feldspar (NaAlSi3O8 \- CaAl2Si2O8), and you acquired the normalized weight percents for each of the following elements: O, Na, Al, Si, and Ca, which you saved in the variable `wt_pct`. You can then perform standardless stoichiometic quantification:

```matlab
num_O = 8; % Number of oxygens in the chemical formula for plagioclase
elements = {'O','Na','Al','Si','Ca'};
wt_pct = [49.1527; 4.1517; 13.6314; 27.2759; 7.3997];
standardless_quant = stoich_quant(num_O, elements, wt_pct)
```