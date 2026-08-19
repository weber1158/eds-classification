# 🪨 Algorithms for SEM-EDS Mineral Dust Classification
[![License: MIT](https://img.shields.io/badge/License-MIT-FE4365.svg?style=flat-square)](LICENSE)
[![MATLAB R2026a](https://img.shields.io/badge/MATLAB-R2026a-FC9D9A.svg?style=flat-square)](https://www.mathworks.com/products/matlab.html)
[![Tests](https://img.shields.io/badge/Tests-Passing-F9CDAD.svg?style=flat-square)](tests)
[![Documentation](https://img.shields.io/badge/Documentation-Markdown-C8C8A9.svg?style=flat-square)](docs/Documentation.md)
[![Contributing](https://img.shields.io/badge/Contributions-Welcome-83AF9B.svg?style=flat-square)](CONTRIBUTING.md)

[![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771) 
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/fileexchange/v1?id=170771&file=Tests/matlab_test.mlx)
[![status](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2/status.svg)](https://joss.theoj.org/papers/c2564d4c44b4ee77c24ac32f7431a6b2)

[![GitHub Repo stars](https://img.shields.io/github/stars/weber1158/eds-classification)](https://img.shields.io/github/stars/weber1158/eds-classification)

## 💡 About
A repository of functions for working with SEM-EDS data, with an emphasis on identifying mineral particles.

### 🚨 NEW: Latest Release Series: `eds-classification v2`
**Click [here](https://github.com/weber1158/eds-classification/releases/tag/v2.0) to access the full release notes.**

<details>
<summary> Brief Summary </summary>
   
- See the updated [Documentation](https://github.com/weber1158/eds-classification/blob/main/docs/Documentation.md) (`/main/docs/`).
   
- Replacing `v1.5.2` and includes significant changes to the repository structure.
  
- New main functions (`/main/src/`):
   - `Spectrum`: A custom MATLAB class for EDS x-ray spectra visualization (replaces `xray_plot`).
   - `msa_classification`: A new method for mineral classification that allows you to process spectral data files (.msa / .emsa) directly.
   - `eds_read`: A custom MATLAB class for reading spectral data files (replacing `msa_read`).
   - `stoich_quant` & `standard_stoich_quant`: Provide methods for standardless quantification and standard quantification of mineral stoichiometries.
     
- New utility functions (`/main/utils/`). These functions are designed to work as part of the backend of the new function classes. The main repository functions are written so that the user does not have to learn the utility functions individually, but each function contains its own internal documentation just in case.
</details>

<details>
<summary> Depreciated Functions </summary>
   
   - `add_xray_plot`
     
   - `clear_xray_labels`
     
   - `convergence_angle`
     
   - `read_msa`
     
   - `sem_pixel_size`
     
   - `xray_peak_label`
     
   - `xray_plot`
</details>

<details>
<summary> Previous Updates </summary>
   
1. `v1.5` introduced an improved version of the supervised machine learning mineral classification model (`weber_classification.m`). For details on how the new model was trained, see the contents of the [`machine_learning_models`](https://github.com/weber1158/eds-classification/tree/main/machine_learning_models/weber_classification_training) folder. The training description provided in `/Paper/supplement.md` is no longer accurate.

2. For the convenience of Julia users, all Julia files have been migrated to [https://github.com/weber1158/eds-classification.jl](https://github.com/weber1158/eds-classification.jl).
  
</details>

## 📖 Documentation
See the online **[Documentation](https://github.com/weber1158/eds-classification/blob/main/docs/Documentation.md)** for details on each of the algorithms.

## ⬇️ Installation
You can download the repository from the MATLAB Central File Exchange [![View my project on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/170771), or open it directly in your browser [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/fileexchange/v1?id=170771&file=Tests/matlab_test.mlx) (recommended). 

To add the EDS Classification functions to the default search path:

1. Un-zip the downloaded folder. 

2. Execute the following command in the MATLAB Command Window:

```matlab
pathtool
```

3. A popup menu should open. Click `Add Folder with Subfolders` and select the un-zipped main repository folder. 

4. Finalize your chce by clicking `Save` or `Apply`.

## 🎓 How to cite
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
