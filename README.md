# EDS Classification for MATLAB
**Functions for working with SEM-EDS data in MATLAB, including different algorithms for performing mineral classification.**

This repository includes several functions designed to quickly identify common mineral species from data collected using a scanning electron microscope (SEM) with an energy dispersive spectrometry (EDS) detector. The <small>`eds_classification()`</small> function is encoded with four EDS mineral classification algorithms, including a novel machine learning classifier trained on 18 mineral standards with an accuracy ≅ 99%. Three additional sorting algorithms (that have been transcribed from the peer-reviewed literature) are also available for discriminating mineral classes from SEM-EDS data. See the online **[Documentation](https://github.com/weber1158/eds-classification-for-matlab/blob/main/MATLAB/docs/DOCUMENTATION.md)** for details on each of the algorithms.

Moreover, this repository includes MATLAB functions for importing EDS x-ray spectral data (<small>`read_msa()`</small>) and visualizing the data (<small>`xray_plot()`</small>). Users may also import the metadata from SEM micrographs with the <small>`get_sem_metadata()`</small> function, and more.

## How to cite
Weber, Austin M. (2024) EDS Classification for MATLAB Version 1.0.0 [Software]. GitHub. https://github.com/weber1158/eds-classification-for-matlab

For BibTeX:
```tex
@software{weber2024eds
   author = {Weber, Austin M.}, 
   title = {{EDS} {Classification} for {MATLAB}}, 
   year = 2024, 
   publisher = {GitHub}, 
   version = {1.0.0}, 
   url = {https://github.com/weber1158/eds-classification-for-matlab} 
}
```
