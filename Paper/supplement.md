# Supplemental Informtion for "Algorithms for SEM-EDS Mineral Dust Classification"
by Austin M. Weber<sup>1,2</sup>

<small><sup>
1 Byrd Polar and Climate Research Center, Columbus, Ohio | 2 School of Earth Sciences, The Ohio State Universtiy, Colubmus, Ohio 
</sup></small>

## The "Weber Algorithm": A novel machine learning classifier for categorizing minerals from EDS net intensity data
### Reference Minerals

A total of 20 mineral standards were prepared in order to collect EDS data for training a novel mineral classification model using supervised machine learning. The mineral specimens used in this study were obtained from the Smithsonian Institution Mineralogy Collections Management Unit at the National Museum of Natural History (henceforth "NMNH"). The acquired mineral specimens are listed in **Table S1** and are grouped alphabetically by general mineral groupings. **Table S1** also lists the abbreviations used for each mineral as defined by Whitney & Evans (2010) unless otherwise specified. These minerals represent the majority of the most common silicate and aluminosilicate minerals that have been previously identified in ice core studies. Quartz and its polymorphs were not included because the simplicity of their EDS spectra makes them very easy to identify without the aid of a classification algorithm. 

**Table S1**. Standard mineral specimens and their abbreviations. <sup>*a*</sup>Also belongs to the mica group. <sup>*b*</sup>Abbreviation defined for this study.

|Group|Mineral Name|Abbreviation|Catalog No.|
|---|---|---|---|
|Amphibole|Hornblende|Hbl|NMNH 117329-00
|Apatite|Apatite|Ap|NMNH 144954-03
|Clay|Chlorite|Chl|NMNH 121066-00
| |Muscovite (var. illite)|Ms <sup>*a*</sup>|NMNH 122946-01
| |Kaolinite|Kln|NMNH 95997-00
| |Montmorillonite|Mnt|NMNH 106247-00
| |Palygorskite|Plg|NMNH 95658-00
| |Vermiculite|Vrm|NMNH 120901-00
|Feldspar|Albite|Ab|NMNH C5390-00
| |Anorthite|An|NMNH 61539-00
| |Labradorite|Lab <sup>*b*</sup>|NMNH 135065-00
| |Microcline|Mc|NMNH 161151-00
| |Oligoclase|Olig <sup>*b*</sup>|NMNH 80165-01
|Mica|Biotite|Bt|NMNH 126237-00
|Pyroxene|Augite|Aug|NMNH B18392-00
| |Enstatite (var. bronzite)|En|NMNH B18239-00
| |Ferrosilite|Fs|NMNH 165108-00
| |Pigeonite|Pgt|NMNH B18247-00
|Spinel|Spinel|Spl|NMNH 174748-00
|Titanite|Sphene|Spn|NMNH 117609-00

A chip of each mineral standard was powderized using a pre-cleaned mortar and pestle. The resulting powders were then transfered to individual SEM pin mounts by sprinkling the particles onto carbon adhesive tabs. Any loose material was removed by blowing air across the sample surfaces under a fume hood.

Electron microscopy was performed at the Center for Electron Microscopy and Microanalysis (CEMAS) at The Ohio State University. To reduce charging effects during analysis, each sample was pre-coated with a 10 to 20-nm layer of conductive carbon with a Leica EM ACE600. SEM-EDS was performed using a Quattro Environmental SEM with an EDAX Octane Elect x-ray detector. Operating conditions included a 15 kV acceleration voltage, a spot size of 5.5 (11 nA), and a working distance of 12-mm. Spot EDS analyses were run on at least 40 random particles from each sample surface. The total live time for each EDS analysis totaled 10 seconds. EDS spectra with fewer than 40,000 counts per second were discarded. 

The Quattro SEM utilizes the EDAX APEX software for EDS analyses. This software was specifically used for calculating the elemental net intensity, weight percent, and atomic percent values for each of the following elements: Na, Mg, Al, Si, P, K, Ca, Ti, and Fe. The built-in eZAF quantification algorithm was used to generate these results, which were subsequently downloaded as CSV files for each individual EDS spectrum.

### Preprocessing the Mineral Standard Data

Because the minerals were powderized rather than polished, not every particle produced a clean EDS spectrum. This was by design, as opposed to polishing the samples, in order to train a machine learning algorithm capable of distinguishing mineral particles with non-ideal morphological features. However, some of the collected EDS data needed to be discarded due to poor signal detection that resulted from larger particles blocking x-rays from reaching the detector. Moreover, the chemical composition of the An mineral laregly overlapped with the other Ca-rich feldspars. Therefore, the An samples were discarded to avoid redundancy in the algorithm training. The Fs samples, likewise, were discarded but for a different reason. The elemental composition of the Fs samples did not match the expected compositon--either due to a misclassification of the hand sample or the presence of contaminants--and so the Fs data needed to be removed from algorithm training.

The next step in preprocessing the mineral standard data was to calculate elemental ratios from the net intensity data measured on each mineral sample. Elemental ratios, as opposed to raw elemental net intensities, are strong predictors for discriminating between mineral species (Donarummo et al., 2003). A total of 23 elemental ratios were evaluated for each sample to be used as the predictor variables for training machine learning models (**Table S2**).

**Table S2**. EDS net intensity ratios used for training machine learning models. \|X\| represents the ratios of element X to the sum of the remaining elements.

|Predictor|Ratio|Reference|
|:---:|---|---|
|1|(Mg+Fe)/Al|Donarummo et al., 2003|
|2|(Mg+Fe)/Si||
|3|(Ca+Na)/Al||
|4|K/(K+Na+Ca)||
|5|K/(Al+Si)||
|6|Al/Si||
|7|Fe/Si||
|8|Ca/Si||
|9|K/Si||
|10|K/Al||
|11|Ca/Na||
|12|P/Ca|This study|
|13|Ti/Fe||
|14|Mg/Al||
|15-23|\|X\||Kandler et al., 2011; Panta et al., 2023


### Synthetic Minority Oversampling Technique (SMOTE)

Due to the discarding of some measured data, not all of the remaining mineral classes were represented an equal number of times. This can lead to unequal sensitivities when training a machine learning model, and therefore oversampling techniques such as SMOTE have been developed in order to correct for potentially harmful data imbalances (Chawla et al., 2002). A SMOTE algorithm was applied to the elemental ratio training data in order to increase the number of class representations for each mineral until they all had the same number of observations. The function used was inspired by an implementation of the SMOTE algorithm by Larsen (2024). 

### Model Training

The <small>`classificationLearner`</small> application from the MATLAB Statistics and Machine Learning Toolbox was used to train a wide variety of machine learning algorithms. All algorithms were trained using at least 20 cross-validation folds with 70% of the data set aside for training and the remaining 30% set aside for testing. The most successful classifier was found to be a **bagged tree ensemble** model programmed with 30 decision tree learners and a maximum of 300 training splits. The accuracy of the model was improved slightly by adjusting the cost matrix so that misclassifications between minerals of different types (e.g., a feldspar being misclassified as a pyroxene) would be more costly than misclassifications between minerals of the same type. The validation accuracy when resubstituting the training data into the model was 99.3% and the test accuracy (using the 30% of data set aside) was 98.8%. When the model was applied to the 731 original data (i.e., the measured data before correcting for imbalances) the accuracy was 99.5%. The final model was exported and incorporated into a function called <small>`weber_classification`</small> that takes a table of EDS net intensity data, converts the data into a table of elemental ratios, and then classifies the mineral composition of each row.

### Limitations
The Weber algorithm is only capable of identifying the 18 minerals used to train the algorithm. Comparing the results of the algorithm to the results of alternative methods is therefore recommended in order to verify the classifications. 

Furthermore, restricting the algorithm training to 18 mineral classes was necessary due to time and monetary limits. The process of performing microscopy analyses is both labor intensive and economically restrictive. The collection of EDS data for the original 20 mineral samples was carried out over a three month period and cost approximately $2000 USD to complete. 

For individuals seeking mineral classification for economic mineral reasearch and need an algorithm for identifying minerals from electron microprobe data, see da Silva et al. (2021). 

### Data Availability Statement

The EDS net intensity data and relevant functions used for training the Weber algorithm are available in the software repository on GitHub [(click here)](https://github.com/weber1158/eds-classification-for-matlab/tree/main/MATLAB/MachineLearningModel).

# References

* **Chawla, N. V.**, Bowyer, K. W., Hall, L. O., & Kegelmeyer, W. P. (2002). SMOTE: Synthetic Minority Over-sampling Technique. *Journal of Artificial Intelligence Research*, 16, 321–357. https://doi.org/10.1613/jair.953

* **da Silva, G. F.**, Ferreira, M. V., Costa, I. S. L., Bernardes, R. B., Mota, C. E. M., & Cuadros Jiménez, F. A. (2021). Qmin – A machine learning-based application for processing and analysis of mineral chemistry data. *Computers & Geosciences*, 157, 104949. https://doi.org/10.1016/j.cageo.2021.104949

* **Donarummo Jr., J.**, Ram, M., & Stoermer, E. F. (2003). Possible deposit of soil dust from the 1930’s U.S. dust bowl identified in Greenland ice. Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641


* **Larsen, B. S.** (2024). Synthetic Minority Over-sampling Technique (SMOTE). GitHub. https://github.com/dkbsl/matlab_smote/releases/tag/1.0

* **Whitney, D. L.**, & Evans, B. W. (2010). Abbreviations for names of rock-forming minerals. *American Mineralogist*, 95(1), 185–187. https://doi.org/10.2138/am.2010.3371