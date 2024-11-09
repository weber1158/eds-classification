# SEM-EDS Mineral Dust Classification

[![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771) 
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/fileexchange/v1?id=170771&file=Tests/matlab_test.mlx)
[![status](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2/status.svg)](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2)

**Functions for working with SEM-EDS data in MATLAB, including different algorithms for performing mineral classification.**

This repository includes several functions designed to quickly identify common mineral species from data collected using a scanning electron microscope (SEM) with an energy dispersive spectrometry (EDS) detector. The <small>`eds_classification()`</small> function is encoded with four EDS mineral classification algorithms, including a novel machine learning classifier trained on 18 mineral standards with an accuracy ≅ 99%. Three additional sorting algorithms (that have been transcribed from the peer-reviewed literature) are also available for discriminating mineral classes from SEM-EDS data. See the online **[Documentation](https://github.com/weber1158/eds-classification-for-matlab/blob/main/MATLAB/docs/DOCUMENTATION.md)** for details on each of the algorithms.

Moreover, this repository includes MATLAB functions for importing EDS x-ray spectral data (<small>`read_msa()`</small>) and visualizing the data (<small>`xray_plot()`</small>). Users may also import the metadata from SEM micrographs with the <small>`get_sem_metadata()`</small> function, and more.

## Installation
You can download the repository from the MATLAB Central File Exchange [![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771), or open it directly in your browser [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/fileexchange/v1?id=170771&file=Tests/matlab_test.mlx) (recommended). 

The repository was developed in MATLAB Online, which uses the most up-to-date version of MATLAB. To ensure backwards compatability, it is recommended that users also utilize the functions in MATLAB Online.

To add the EDS Classification functions to the default search path:

1. Un-zip the downloaded folder. 

2. Execute the following command in the MATLAB Command Window:

```matlab
pathtool
```

3. A popup menu should open. Click `Add Folder with Subfolders` and select the un-zipped main repository folder. 

4. Finalize your choice by clicking `Save` or `Apply`.

## How to cite
Weber, Austin M. (2024) EDS Classification Version #.#.# [Software]. GitHub. https://github.com/weber1158/eds-classification

For BibLaTeX:
```tex
@software{weber2024eds
   author = {Weber, Austin M.}, 
   title = {{EDS} {Classification}}, 
   year = 2024, 
   publisher = {GitHub}, 
   version = {#.#.#}, 
   url = {https://github.com/weber1158/eds-classification} 
}
```
