# EDS Classification for MATLAB
**Functions for working with SEM-EDS data in MATLAB, including different algorithms for performing mineral classification.**

This repository includes several functions designed to quickly classify minerals from data collected using a scanning electron microscope (SEM) with an energy dispersive spectrometry (EDS) detector. The <small>`weber_classification()`</small> algorithm is a novel machine learning classifier trained on 18 mineral standards with an validation accuracy exceeding 99%. In addition, three alternative classification algorithms have been trasncribed into viable MATLAB code from the literature to compare and help finalize the results. (See the **[online documentation](https://github.com/weber1158/eds-classification-for-matlab/blob/main/MATLAB/docs/DOCUMENTATION.md)** for the <small>`donarummo_classification()`</small> [1], <small>`kandler_classification()`</small> [2], and <small>`panta_classification()`</small> [3] functions for details). The Donarummo, Kandler, and Panta algorithms have also been transcribed into Julia code for those without a MATLAB license.

Moreover, this repository includes MATLAB functions for importing EDS x-ray spectral data (<small>`read_msa()`</small>) and visualizing the data (<small>`xray_plot()`</small>). Users may also import the metadata from SEM micrographs with the <small>`get_sem_metadata()`</small> function, and much more.

## Citation
Weber, Austin M. (2024) EDS Classification for MATLAB. V1.2.0 [Software]. Github. https://github.com/weber1158/eds-classification-for-matlab

For BibTeX:
```tex
@software{weber2024eds
   author = {Weber, Austin M.}, 
   title = {EDS Classification for MATLAB}, 
   year = 2024, 
   publisher = {GitHub}, 
   version = {1.2.0}, 
   url = {https://github.com/weber1158/eds-classification-for-matlab} 
}
```

## References
**[1]** Donarummo, J., Ram, M., & Stoermer, E. F. (2003). Possible deposit of soil dust from the 1930’s U.S. dust bowl identified in Greenland ice. Geophysical Research Letters, 30(6). https://doi.org/10.1029/2002GL016641

**[2]** Kandler, K., Lieke, K., Benker, N., Emmel, C., Küpper, M., Müller-Ebert, D., Ebert, M., Scheuvens, D., Schladitz, A., Schütz, L., & Weinbruch, S. (2011). Electron microscopy of particles collected at Praia, Cape Verde, during the Saharan Mineral Dust Experiment: Particle chemistry, shape, mixing state and complex refractive index. Tellus B, 63(4), 475–496. https://doi.org/10.1111/j.1600-0889.2011.00550.x

**[3]**  Panta, A., Kandler, K., Alastuey, A., González-Flórez, C., 
González-Romero, A., Klose, M., Querol, X., Reche, C., Yus-Díez, J., & Pérez García-Pando, C. (2023). Insights into the single-particle composition, size, mixing state, and aspect ratio of freshly emitted mineral dust from field measurements in the Moroccan Sahara using electron microscopy. Atmospheric Chemistry and Physics, 23(6), 3861–3885. https://doi.org/10.5194/acp-23-3861-2023

