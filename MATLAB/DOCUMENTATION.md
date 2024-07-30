## Table of Contents ##

- [Features](#features)
- [Documentation](#documentation)
  - [List of Functions](#list-of-functions)
- [Acknowledgements](#acknowledgements)
- [Copyrights](#copyrights)


## Features ##
<big>Key feature:</big>
- The main draw for this repository is that users with energy dispersive spectrometry (EDS) data can programmatically identify mineral species in their data from a choice of 3 peer-reviewed sorting scheme algorithms and a novel machine learning classifier.

<big>Users can also:</big>

- Import EDS spectral data from an EMSA (.msa) file as a MATLAB <small>`table`</small>.

- Quickly plot EDS spectra and identify the primary elements based on their characteristic x-ray wavelengths.

- Extract the metadata from SEM tagged image files (TIFs), including the x- and y-resolution, working distance, acceleration voltage, and more.

- Calculate the pixel size of an SEM tagged image file (TIF). 

- Calculate the convergence angle for an SEM image.



## **Documentation** ##

All of the functions in this software package have documentation hard-coded into their programming. Simply run the command `help` followed by the name of any of the following functions and it will print the documentation for that function in the command window. Alternatively, you can replace the `help` command with `doc` and it will open the documentation in a separate window. For example:

```matlab
% Print documentation 
help function

% Open documenation
doc function
```

### List of Functions ###

  - [`eds_classification()`](#eds_classification) - EDS mineral classification
  - [`weber_classification()`](#weber_classification) -  Machine learning mineral classification model for EDS data
  - [`donarummo_classification()`](#donarummo_classification) - Mineral classification scheme from Donarummo et al. (2003)
  - [`kandler_classification()`](#kandler_classification) - Mineral classification scheme from Kandler et al. (2011)
  - [`panta_classifiction()`](#panta_classification) - Mineral classification scheme from Panta et al. (2023)
  - [`read_msa()`](#read_msa) - Import EDS spectral data from EMSA (.msa) files
  - [`xray_plot()`](#xray_plot) - Plot EDS spectra
  - [`xray_peak_label()`](#xray_peak_label) - Identify characteristic x-ray peaks in spectra
  - [`get_sem_metadata()`](#get_tif_metadata) - Extract metadata from SEM images (.tif or .tiff)
  - [`sem_pixel_size()`](#sem_pixel_size) - Calculate pixel size in a SEM image
  - [`convergence_angle()`](#convergence_angle) - Calculate the convergence angle for an SEM image


## eds_classification ##
EDS mineral dust classification

<big>**Syntax**</big>

`eds_classification(data)`

`eds_classification(data,Name=Value)`

`classes = eds_classification(___)`

<big>**Description**</big>

Four algorithms for mineral classification in a single function. Simply pass a table of EDS data (either net intensity or atom percent, depending on the algorithm you want) as the first input argument and then use the `Algorithm="Name"` name-value pair to choose you algorithm.

<big>**Inputs**</big>

`data` - table of EDS data with columns for each of the elements required by the algorithm.

`"Algorithm"` - (Optional) name-value pair to specify the desired mineral classification algorithm. For example, `Algorithm="Panta"`. The default is `Algorithm="Weber"`.

<big>**Ouput**</big>

`classes` - Categorical vector or table containing mineral classifications corresponding to each row in the input `data`.

<big>**Name-Value Pairs**</big>

NAME

`"Algorithm"` or `Algorithm=`

| VALUE | DATA_TYPE | REQUIRED_ELEMENTS | [REFERENCE](#copyrights) |
| --- | --- | --- | :---: | 
|`"Weber"`|Net intensity|Na,Mg,Al,Si,P,K,Ca,Ti,Fe|[1]|
|`"Donarummo"`|Net intensity|Na,Mg,Al,Si,K,Ca,Fe|[2]|
|`"Kandler"`|Atom percent|Na,Mg,Al,Si,P,S,Cl,K,Ca,Ti,Cr,Mn,Fe|[3]|
|`"Panta"`|Atom percent|F,,Mg,Al,Si,P,S,Cl,K,Ca,Ti,Cr,Mn,Fe|[4]|


<big>**Examples**</big>

```matlab
% Use the machine learning algorithm by Weber [1] to classify the mineral composition of each row in an EDS net intensity data table.
load eds_mineral_standards.mat
weber = eds_classifiation(data);

% Use the sorting scheme algorithm from Donarummo et al. [2] to classify the same data.
donarummo = eds_classifiation(data,Algorithm="Donarummo");
```

**SEE ALSO** [`weber_classification()`](#weber_classification), [`donarummo_classification()`](#donarummo_classification), [`kandler_classification()`](#kandler_classification),  [`panta_classification()`](#panta_classification).

## weber_classification ##
Machine learning mineral classification model for EDS data

<big>**Syntax**</big>

`weber_classifiation(data)`

`minerals = weber_classification(data)`

`[~,groups] = weber_classification(data)`

`[~,~,scores] = weber_classification(data)`

<big>**Description**</big>

This **bagged tree ensemble** model was trained using EDS net intensity data collected on 18 mineral standards at the Center for Electron Microscopy and Analysis (CEMAS) at The Ohio State University. The instrument that was used was a Quattro Environmental SEM with an EDAX Octane Elect Super EDS detector. Operating conditions included a 15 kV acceleration voltage, 11 nA beam current, and 12 mm working distance.

The purpose of this function is to assist in the mineral classification of complex EDS spectra, with emphasis on minerals that are often found in ice core dust studies. Minerals with simple chemistry, such as quartz, can be easily identified from their spectra alone and were therefore excluded from the model training. 

<big>**Input**</big>

`data` - table of EDS net intensity data containing variables (i.e. columns) for the elements Na, Mg, Al, Si, P, K, Ca, Ti, and Fe.

<big>**Outputs**</big>

`minerals` - categorical vector of mineral classifications for each row in the input table. All classifications are given using standardized abbreviations (see the table below for details).

`groups` - (Optional) categorical vector of generalized mineral groups for each row in the input table. For example, if the mineral is classified as one of the five feldspars it will be given a group classification of "Feldspar".

`scores` - (Optional) Probability scores for each classification. That is, a table showing the likelihood of each classification. The scores are given as fractions between 0 (0%) and 1 (100%).

<big>**List of Possible Mineral Classifications**</big>

| Group | Mineral | Abbreviation |
| --- | --- | --- |
|Amphibole|Hornblende|Hbl|
|Apatite|Apatite|Ap|
|Clay|Chlorite|Chl|
| |Muscovite (var. illite)|Ms|
| |Kaolinite|Kln|
| |Montmorillonite|Mnt|
| |Palygorskite|Plg|
| |Vermiculite|Vrm|
|Feldspar|Albite|Ab|
| |Labradorite|Lab|
| |Microcline|Mc|
| |Oligoclase|Olig|
|Mica|Biotite|Bt|
|Pyroxene|Augite|Aug|
| |Enstatite (var. bronzite)|En|
| |Pigeonite|Pgt|
|Spinel|Spinel|Spl|
|Titanite|Sphene|Spn|

<big>**Limitations**</big>

The `weber_classification()` algorithm can only classify minerals listed in the table above. Any other mineral that may be represented by the data in the input table will be misclassified. This function is therefore best used in conjunction with additional classification techniques. See [`donarummo_classification()`](#donarummo_classification), [`kandler_classification()`](#kandler_classification), and [`panta_classification()`](#panta_classification).

## donarummo_classification ##
Mineral classification scheme from Donarummo et al. (2003)

<big>**Description**</big>

This function automates the mineral classification workflow published by Donarummo et al. (2003). Takes a table of energy dispersive spectrometry (EDS) net intensity data and assigns a mineralogy to each row.

<big>**Syntax**</big>

`minerals = donarummo_classification(data)`

<big>**Input**</big>

`data` - table of net intensity data containing a column for each of the following elements: Na, Mg, Al, Si, K, Ca, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required, but spelling is paramount.

<big>**Output**</big>

`minerals` - categorical vector of mineral names corresponding to each row in the input table. A list of possible mineral names is given in the table below. If the mineral classification is unknown it will be assigned an output of "U-" as described by Donarummo et al. (2003).

<big>**List of Possible Mineral Classifications**</big>

| Abbreviation | Mineral |
| --- | --- |
|Ab|Albite|
|Afs|Alkali feldspar (orthoclase)|
|An|Anorthite|
|Aug|Augite|
|Bt|Biotite|
|Chl|Chlorite|
|Hbl|Hornblende|
|Htr|Hectorite|
|Ilt|Illite|
|Ilt/Sme|Illite/Smectite 70/30 mix|
|Kln|Kaolinite|
|Lab/Byt|Labradorite/Bytownite|
|Mnt|Montmorillonite|
|Ms|Muscovite|
|Olig/Ans|Oligoclase/Andesine|
|Vrm|Vermiculite|

<big>**Limitations**</big>

The `donarummo_classifiation()` function will misclassify any mineral not present in the list above. For instance, net intensity data for the mineral quartz will never be classified as quartz. To maximize the usefulness of this algorithm the user should also consult the results of additional classification methods. See [`weber_classification()`](#weber_classification), [`kandler_classification()`](#kandler_classification), and [`panta_classification()`](#panta_classification).

<big>**References**</big>

Donarummo, J. Ram, M. & Soermer, E.F. (2003). Possible deposit of soil dust from the 1930s U.S. dust bowl identified in Greenland ice. Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641


## kandler_classification ##
EDS classification scheme from Kandler et al. (2011)

<big>**Description**</big>

This  function automates the classification workflow published by Kandler et al. (2011). Takes a table of energy dispersive spectrometry (EDS) atom percent data and categorizes each row into a broad mineral group, mineral class, and refractive index.

<big>**Syntax**</big>

`minerals = kandler_classification(data)`

<big>**Input**</big>

`data` - table of EDS atom percents containing a column for each of the following elements: Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required, but spelling is paramount.

<big>**Output**</big>

`minerals` - table containing three variables: `group`, `class`, and `refractive_index` where each row corresponds to the same row in the input table. The `group` variable describes the general mineral class (e.g., "sulfates"); the `class` variable describes the general mienral composition (e.g., "SiAlNaK"); and the `refractive_index` variable describes the related refractive index calculation defined by Kandler et al. (2011).

<big>**Limitations**</big>

The `kandler_classification()` algorithm does not distinctly classifiy any mineral species and is most useful for identifying generalized mineral classes. For mineral-specific classification algorithms see [`weber_classification()`](#weber_classification), [`donarummo_classification()`](#donarummo_classification), and [`panta_classification()`](#panta_classification).

<big>**References**</big>

Kandler, K., Lieke, K., Benker, N., Emmel, C., Küpper, M., Müller-Ebert, D., Ebert, M., Scheuvens, D., Scladitz, A., Schütz, L., & Weinbruch, S. (2011). Electron microscopy of particles collected at Praia, Cape Verde, during the Saharan Mineral Dust Experiment: Particle chemistry, shape, mixing state and complex refractive index. Tellus B, 63(4), 475-496. https://doi.org/10.1111/j.1600-0889.2011.00550.x


## panta_classification ##
Mineral classification scheme from Panta et al. (2023)

<big>**Description**</big>

This function automates the mineral classification workflow published by Panta et al. (2023). Takes a table of energy dispersive spectrometry (EDS) atom percent data and assigns a mineralogy to each row.

<big>**Syntax**</big>

`minerals = panta_classification(data)`

<big>**Input**</big>

`data` - table of EDS atom percent data containing columns for each of the following elements: F, Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The name of each column may be the full element name or its abbreviation. For instance, "Silicon" and "Si" are valid table variable names. Both the American and British spelling of "Aluminum" ("Aluminium") are also valid. Capitalization is not required, but spelling is paramount.

<big>**Output**</big>

`minerals` - categorical vector of mineral names corresponding to each row in the input table. Specific mineral names are given as abbreviations (see the list of mineral names below).

<big>**List of Possible Mineral Classifications**</big>

| Abbreviation | Mineral |
| --- | --- |
|Ab|Albite|
|Alu|Alunite|
|Ap|Apatite|
|Cal|Calcite|
|Dol|Dolomite|
|Fsp|Feldspar|
|Gp|Gypsum|
|Hl|Halite|
|Hem|Hematite|
|Ilm|Ilmenite|
|Ilt|Illite|
|Kln|Kaolinite|
|Mica|Mica|
|Mc|Microcline|
|Qz|Quartz|
|Rt|Rutile|
|Sme|Smectite|

The algorithm also has classifications for *Ca-rich silicate/Ca-Si-mix*, *Complex Clay*, *Complex Fsp*, *Complex Fsp/Clay mix*, *Complex Qz*, and *Complex Sulfate*.

<big>**Limitations**</big>

The `panta_classification()` function will misclassify any mineral not present in the list above. For instance, atom percent data for pyroxene will never be classified as pyroxene. To maximize the usefulness of this algorithm the user should also consult the results of additional classification methods. See [`weber_classification()`](#weber_classification), [`donarummo_classification()`](#donarummo_classification), and [`kandler_classification()`](#kandler_classification).

<big>**References**</big>

Panta, A. *et al.* (2023). Insights into the single-particle composition, size, mixing state, and aspect ratio of freshly emitted dust from field measurments in the Moroccan Sahara using electron microscopy. Atoms. Chem. Phys. 23, 3861-3885. https://doi.org/10.5194/acp-23-3861-2023


## read_msa ##
Read EMSA spectral data files (.msa)

<big>**Syntax**</big>

`read_msa(filename)`

`data = read_msa(filename)`

`[~,metadata] = read_msa(filename)`

<big>**Description**</big>

Depending on your EDS software, the x-ray spectral data is likely saved in the .msa file format. Reading the data into MATLAB with <small> `readtable()` </small> is not always possible because different EDS softwares compile .msa data differently. Hence, the `read_msa()` function is designed to import .msa data without the headache.

<big>**Input**</big>

`filename` - (String) Name of the file including the .msa extension. Note that the file must be located on the current search path.

<big>**Outputs**</big>

`data` - Nx2 table with variables `keV` and `Counts`

`metadata` - (Optional) Nx2 cell array containing file metadata

<big>**Examples**</big>

```matlab
% Read x-ray energy data
read_msa('file1.msa');

% View metadata for 'file2.msa'
[~,md] = read_msa('file2.msa');

% Note that the output of the 2nd command is equivalent to:
md = get_msa_metadata('file2.msa');
```

<big>**Limitations**</big>

I have tested and verified that this function works on .msa files generated using EDS analysis software from APEX™ and Bruker. However, I cannot guarantee that the function will work for .msa data collected using alternative sofware.


## xray_plot ##
Plot EDS spectra

<big>**Syntax**</big>

`axHandle = xray_plot(data)`

`axHandle = xray_plot(filename)`


<big>**Inputs**</big>

`data` - table produced by the `read_msa()` function

`filename` - (String) name of EMSA file including the .msa extension

<big>**Output**</big>

`axHandle` - Axes handle for editing the plot after compilation

<big>**Examples**</big>

```matlab
% One way to plot an EDS spectrum
data = read_msa('file1.msa');
plt = xray_plot(data);

% Alternative method (equivalent to the above syntax)
plt = xray_plot('file1.msa');

% Plot multiple spectra on the same plot with normalized units
f1 = read_msa('file1.msa');
f2 = read_msa('file2.msa');
f1.Counts = normalize(f1.Counts,'Range',[0 1]);
f2.Counts = normalize(f2.Counts,'Range',[0 1]);
figure
plt = xray_plot(f2);
hold on
  xray_plot(f1);
hold off
legend('F2','F1')
```

**SEE ALSO**: [`xray_peak_label()`](#xray_peak_label) [`read_msa()`](#read_msa)


## xray_peak_label ##
Label most prominent peaks in an `xray_plot`

<big>**Syntax**</big>

`xray_peak_label(axHandle)`

`xray_peak_label(axHandle,prominence)`

<big>**Inputs**</big>

`axHandle` - Axes handle to an open <small> `xray_plot()`</small> object.

`prominence` - (Optional, default=90) percentile between 0 and 100 that specifies the minimum prominence of the x-ray peaks to be labeled.

<big>**Examples**</big>

```matlab
data = read_msa('file1.msa');
plt = xray_plot(data);
xray_peak_label(plt)

% Label the peaks above the 95th percentile in height
xray_peak_label(plt,95)
```

**SEE ALSO** [`xray_plot()`](#xray_plot) [`read_msa()`](#read_msa)


## get_sem_metadata ##
Extract metadata from SEM images (.tif or .tiff)

<big>**Syntax**</big>

`md = get_sem_metadata(filename)`

<big>**Description**</big>

This function extracts the metadata stored in an SEM micrograph (either a backscatter or secondary electron image) given that the file is stored in the .tif or .tiff format. The input `filename` is the name of the image file including the file extension.

The function ouptut `md` is a MATLAB structure array containing useful metadata pertaining to the input image. The function has been calibrated on BSE and ETD images collected on a Quattro ESEM and an FEI Quanta 250 SEM at separate facilities (the Center for Electron Microscopy and Analysis & the Subsurface Energy Materials and Chemical Analysis Laboratory, both housed on The Ohio State University's Columbus, Ohio campus). This function is not guaranteed to work on SEM micrographs collected using different instruments and/or with different software.

<big>**Examples**</big>

```matlab
% Get metadata for a backscatter electron image
md = get_sem_metadata('imBSE.tif');

% Extract the acceleration voltage (in eV) used to acquire the image
av = md.AccelerationVoltage
  av = 
   20000

% Extract the working distance used to acquire the image (in meters)
wd = md.WorkingDistance
  wd = 
   0.0093
```

**SEE ALSO** [`sem_pixel_size()`](#sem_pixel_size), [`convergence_angle()`](#convergence_angle)



## sem_pixel_size ##
Evaluates the pixel size of an SEM-generated .tif image

<big>**Syntax**</big>

`pixWidth = sem_pixel_size(filename)`

<big>**Description**</big>

Computes the pixel size of a .tif image in units of microns/pixel. The result is printed in the Command Window as well as stored to a variable. This function is useful if you need to create a scale bar for the image.

Note that this function will only work on images taken using relevant SEM software. It will not work on general .tif image files.

<big>**Example**</big>

```matlab
img = 'imBSE.tif';
pw = sem_pixel_size(img)
  The pixel size of imBSE.tif is 0.0674 μm/pixel.
  pw = 
   0.0674
```

**SEE ALSO** [`get_sem_metadata()`](#get_sem_metadata), [`convergence_angle()`](#convergence_angle)

## convergence_angle ##
Convergence angle from an SEM image

<big>**Syntax**</big>
 
`angle = convergence_angle(aperature,workingDistance)`

<big>**Description**</big>

The convergence angle, **α**, is illustrated as follows:

```
%	======== <- Diameter -> ======== Aperature (µm)
%	          \     |     /  |
%	           \    |    /   |
%	            \   |(α)/    | Working distance (m)
%	             \  |  /     |
%	              \ | /      V
%	================================ Sample surface
%
%	α = arctan( 0.5*diameter / working distance)
```

<big>**Inputs**</big>

`aperature` - Known aperature diameter of the microscope (must be in given in units of microns)

`workingDistance` - Working distance (in meters) used to take an SEM image

<big>**Output**</big>

`angle` - Convergence angle, **α**, in milliradians.

<big>**Example**</big>

```matlab
% Import metadata for an SEM image
meta = get_sem_metadata('imETD.tif');
% Extract working distance
wd = meta.WorkingDistance;
% Calculate α given a 30 micron aperature
a = convergence_angle(30,wd);
```
**SEE ALSO** [`sem_pixel_size()`](#sem_pixel_size), [`get_sem_metadata()`](#get_sem_metadata)


## Acknowledgements ##
I thank Paul Pohwat and the Smithsonian Institution for contributing the mineral standards used in this project. I also thank Dan Veghte and the Center for Electron Microscopy and Analysis (CEMAS), as well as Julie Sheets and the Subsurface Energy Materials Characterization and Analysis Laboratory (SEMCAL) at The Ohio State University for their assistance with SEM-EDS analyses. Additionally, I thank my PhD advisor Lonnie Thompson for supporting me as a graduate student, and the Friends of Orton Hall for their generous financial contributions to the project.

## Copyrights ##

This software is made available under a MIT license meaning that users are free to modify and distribute the software without restriction. However, the intellectual copyrights for the Donarummo, Kandler, and Panta algorithms belong to their original creators. If you use any of these algorithms in your research, **please** also cite the appropriate reference(s) from the list below:

**[1]** Weber, Austin M. (2024) EDS Classification for MATLAB. [Software]. GitHub. https://github.com/weber1158/eds-classification-for-matlab

**[2]** Donarummo, J., Ram, M., & Stoermer, E. F. (2003). Possible deposit of soil dust from the 1930’s U.S. dust bowl identified in Greenland ice. Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641

**[3]** Kandler, K., Lieke, K., Benker, N., Emmel, C., Küpper, M., Müller-Ebert, D., Ebert, M., Scheuvens, D., Schladitz, A., Schütz, L., & Weinbruch, S. (2011). Electron microscopy of particles collected at Praia, Cape Verde, during the Saharan Mineral Dust Experiment: Particle chemistry, shape, mixing state and complex refractive index. Tellus B, 63(4), 475–496. https://doi.org/10.1111/j.1600-0889.2011.00550.x

**[4]** Panta, A., Kandler, K., Alastuey, A., González-Flórez, C., González-Romero, A., Klose, M., Querol, X., Reche, C., Yus-Díez, J., & Pérez García-Pando, C. (2023). Insights into the single-particle composition, size, mixing state, and aspect ratio of freshly emitted mineral dust from field measurements in the Moroccan Sahara using electron microscopy. Atmospheric Chemistry and Physics, 23(6), 3861–3885. https://doi.org/10.5194/acp-23-3861-2023
