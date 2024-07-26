---
title: 'EDS Classification for MATLAB'
tags:
  - MATLAB
  - scanning electron microscopy
  - energy dispersive spectrometry
  - mineralogy
  - earth sciences
authors:
  - name: Austin M. Weber
    orcid: 0009-0008-0070-2869
    equal-contrib: true
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
affiliations:
 - name: Byrd Polar and Climate Research Center, Columbus, Ohio
   index: 1
 - name: School of Earth Sciences, The Ohio State University, Columbus, Ohio
   index: 2
date: 26 July 2024
bibliography: paper.bib
---

# Summary
`EDS Classification for MATLAB` provides a suite of useful functions for working with scanning electron microcope (SEM) and energy dispersive x-ray spectrometry (EDS) data in MATLAB. The primary objective of the software repository is to provide users with functions to quickly and accurately determine the mineral compositions of single particles from their EDS data. This includes a novel machine learning classifier and three additional sorting algorithms that have been transcribed from the peer-reviewed literature. The repository also provides functions for importing and visualizing x-ray energy spectra, as well as functions for extracting and working with hidden metadata in SEM images.

# Statement of need
The mineral classification of single particles (i.e., dust) has major implications for atmospheric and glaciological research. For instance, there is a great need for building mineral dust datasets that can be used to improve the predictive ability of climate models [@Elements2010]. Mineral dust observations are also severely limited in many glaciated mountain regions, meaning that the dust's radiative impact on glacier melt rates cannot be easily determined [@Gilardoni2022].

One of the most common methods for reconstructing the mineral dust history of a location or region has been the use of a scanning electron microscope (SEM) with an energy dispersive x-ray spectrometry (EDS) detector to analyze single particles extracted from ice cores [@Donarummo2003; @Wu2016; @Nagatsuka2021]. However, the process of classifying individual particles based on their EDS data is highly laborious and prone to error due to the complexity of certain minerals' elemental signatures. The adoption of numerous classification techniques is typically required to improve the certainty of the classifications before finalizing the results. Many have used the dichotomous key in @Severin2004 to compare EDS spectra to that of mineral standards, but this protocol requires access to a physical or digital copy of the book and cannot be automated. Others have used published sorting algorithms like the one by @Donarummo2003, but these algorithms are limited in the number of minerals that they can identify and, to the author's knowledge, each of these algorithms is only available in print and not as functional computer program. 

To satisfy the needs of earth and atmospheric scientists seeking to rapidly classify mineral particles from EDS data with a high degree of certainty, the `EDS Classification for MATLAB` software repository has been established. This library of functions provides users with the ability to work with SEM-EDS data in the MATLAB programming language without difficulty.

# Methods
## Mineral Classification

The function library introduces a novel machine learning-based mineral classification model (the "Weber algorithm") that has been trained with EDS data collected on 18 mineral standards and exhibits an overall accuracy exceeding 99% (see `supplement.bib` for details). The library also includes functions for three sorting algorithms that have been painstakingly transcribed from the literature into MATLAB code. This includes the aforementioned Donarummo algorithm [@Donarummo2003] which can be used to classify 16 unique aluminosilicate minerals based on EDS net intensity data, the Panta algorithm [@Panta2023] which can be used to classify 17 unique minerals and 6 mineral groups based on EDS atom percent data, and the Kanlder algorithm [@Kandler2011] which can be used to categorized EDS atom percent data into broad mineral groups, classes, and refractive indexes. 

The four mineral classification algorithms are available as individual functions (`weber_classification`, `donarummo_classifiation`,  `panta_classifiation`, and `kandler_classification`) as well as packaged together in a single function (`eds_classification`). Each function has clearly written documentation that can be viewed using the MATLAB `help` or `doc` commands. The general syntax, however, is very basic:

```matlab
minerals = eds_classifiation(data,Algorithm="Name")
```

where `data` is a table of EDS data and `"Name"` specifies the desired algorithm; i.e., `"Weber"` (default), `"Donarummo"`, `"Kandler"`, or `"Panta"`. The output `minerals` is a categorical vector containing the mineral assignments for each row in the input table.

## Visualizing X-ray Energy Data

For individuals who want to compare the x-ray spectra of their single particle measurements to the standard spectra in @Severin2004, it will be necessary to visualize each energy spectrum along with labels for the major characteristic x-rays. Most EDS software save x-ray energy data in the EMSA (`.msa`) file format which is compiled differently depending on the software and therefore makes it difficult to simply import the data using a base MATLAB function such as `readtable`. While methods for visualizing  EDS spectra are available for the Julia programming language [@Ritchie2022] and as a desktop Java application (see **[DTSA-II](https://www.cstl.nist.gov/div837/837.02/epq/dtsa2/index.html)**), there are currently no simple alternatives to perform these tasks in MATLAB. 

The `EDS Classification for MATLAB` software repository introduces straightforward functionality for importing `.msa` files into MATLAB and visualizing the EDS spectrum contained in a file. Just use the `xray_plot` function to view the spectrum and the `xray_peak_label` function to label the characteristic x-rays with the most likely element.

```matlab
plt = xray_plot('energy_spectrum.msa');
xray_peak_label(plt)
```

Users may also import x-ray energy directly into the MATLAB workspace along with file metadata using `read_msa`.

```matlab
[data,metadata] = read_msa('filename.msa');
```

## Extract metadata from SEM images

Images collected with SEM software are usually saved as 16-bit TIFs and contain valuable metadata regarding the image itself as well as the operating conditions of the instrument at the time the image was taken. But while MATLAB users with access to the **[Image Processing Toolbox](https://www.mathworks.com/products/image-processing.html)** can typically view image metadata with the `imfinfo` function, the metadata stored in an SEM image are not so easily accessed. This is because the image metadata become compressed into a single character vector that is nested within several structure objects. Many string operations or regular expressions are therefore needed to access the relevant metadata. To combat this, a function called `get_sem_metadata` has been written to automatically extract the useful information from a SEM image.

```matlab
md = get_sem_metadata('filename.tif');
```

# Acknowledgements

I thank Paul Pohwat and the Smithsonian Institution for contributing the mineral standards used in this project. Thanks are also extended to Lonnie Thompson, Dan Veghte, and Julie Sheets for their various contributions in both advising and teaching. The electron microscopy work used to train the Weber algorithm was performed at the Center for Electron Microcscopy and Analysis (CEMAS) in the College of Engineering at The Ohio State University. Additional electron microscopy was carried out at the Subsurface Energy Materials Characterization and Analysis Laboratory (SEMCAL) in the School of Earth Sciences at The Ohio State University.

# Copyrights

The software repository is made available under a MIT license, meaning that users are free to modify and distribute the software without restriction. However, the *intellectual copyrights* for the Donarummo, Kandler, and Panta algorithms belong to their original creators. If you use any of these algorithms in your research, please also cite the original references as appropriate.

# References

