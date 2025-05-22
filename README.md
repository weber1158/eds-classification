# SEM-EDS Mineral Dust Classification
[![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771) [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/fileexchange/v1?id=170771&file=Tests/matlab_test.mlx)

[![status](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2/status.svg)](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2)

# 🚨 **ATTENTION**
#### THE MATHWORKS SERVERS ARE CURRENTLY DOWN. YOU WILL NEED TO DOWNLOAD THIS REPOSITORY THROUGH GITHUB UNTIL FURTHER NOTICE. MATLAB DESKTOP MAY OR MAY NOT BE FUNCTIONING FOR YOU. I AM NOT A MATHWORKS EMPLOYEE, SO I CANNOT SPEAK ON WHEN THE SERVERS WILL BE BACK ONLINE, BUT SO FAR THEY HAVE BEEN DOWN FOR AT LEAST THREE DAYS (AS OF 22 MAY 2025). 

## About

**A repository of functions for identifying mineral species in SEM-EDS data**

This repository includes several functions designed to quickly identify common mineral species from energy dispersive spectrometry (EDS) data. The <small>`eds_classification()`</small> function is encoded with four EDS mineral classification algorithms, including a machine learning classifier trained on 18 mineral standards with an accuracy ≅ 99%. Three additional sorting algorithms (that have been transcribed from the peer-reviewed literature) are also available for discriminating mineral classes from EDS data. 

## Documentation
See the online **[Documentation](https://github.com/weber1158/eds-classification-for-matlab/blob/main/MATLAB/docs/DOCUMENTATION.md)** for details on each of the algorithms.

The docs also include MATLAB functions for importing EDS x-ray spectral data (<small>`read_msa()`</small>) and visualizing the data (<small>`xray_plot()`</small> and <small>`xray_peak_label()`</small>). Users may also import the metadata from scanning electron microscope (SEM) images with the <small>`get_sem_metadata()`</small> function, and more.

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

## Test Examples
View the test script by clicking [![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771) and navigating to the Examples tab, or download and run the `matlab_test.mlx` file [(here)](https://github.com/weber1158/eds-classification/tree/beac5acc06f7136acb9bb8a34be5c818cbd539f2/MATLAB/Tests) in MATLAB. 

## How to cite
<a href="https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2">
  <img src="https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2/status.svg" width="200" height="26" alt="status">
</a>

This repository has been peer-reviewed and published in _Journal of Open Source Software_. Please use the information below for citing the software:


#### APA-like
Weber, Austin M., (2025). Algorithms for SEM-EDS mineral dust classification. _Journal of Open Source Software_, *10*(107), 7533, https://doi.org/10.21105/joss.07533

#### `BibTeX`:
```tex
@article{weber2025,
    author = {Weber, Austin M.},
    title = {Algorithms for {SEM-EDS} mineral dust classification},
    journal = {Journal of Open Source Software},
    volume = {10},
    number = {107},
    pages = {7533},
    year = {2025},
    DOI = {10.21105/joss.07533}
}
```
