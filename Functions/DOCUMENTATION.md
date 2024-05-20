# Documentation
**Mineral Classification Algorithms for SEM-EDS Data**

---
---
### **`donarummo_classification`**

Mineral classification algorithm from Donarummo et al. (2003)

**Syntax:**
```matlab
minerals = donarummo_classifiation(eds_net_intensity_table)
```

**Inputs:**

`eds_net_intensity_table` - A table containing columns for each of the following seven elements: Na, Mg, Al, Si, K, Ca, and Fe. The data should represent the net intensities derived from SEM-EDS measurements.

**Outputs:**

`minerals` - A categorical vector containing the mineral classifications for each row in the input table.

---
---
### **`panta_classification`**

Mineral classification algorithm from Panta et al. (2023)

**Syntax:**
```matlab
minerals = panta_classifiation(eds_atom_percent_table)
```

**Inputs:**

`eds_atom_percent_table` - A table containing columns for each of the following fourteen elements: Al, Si, Na, Mg, P, S, Cl, Fe, K, Ca, Ti, Cr, Mn, and F. The data should represent the corrected atomic percentages derived from SEM-EDS measurements.

**Outputs:**

`minerals` - A categorical vector containing the mineral classifications for each row in the input table.

---
---
### **`kandler_classification`**
Semi-mineral classification algorithm from Kandler et al. (2011)

**Syntax:**
```matlab
minerals = kandler_classifiation(eds_atom_percent_table)
```

**Inputs:**

`eds_atom_percent_table` - A table containing columns for each of the following thirteen elements: Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe. The data should represent the corrected atomic percentages derived from SEM-EDS measurements.

**Outputs:**

`minerals` - A table with columns corresponding to three categorical variables: `class`, `group`, and `refractive index`. 

**Notes:**
This function is slower than the `donarummo_classification` and `panta_classification` algorithms because it contains many more internal sorting functions and because it classifies each row of the input table into three groupings. The `class` grouping is a general mineral class (e.g., "silicates" or "oxides"); the `group` grouping identifies the dominant elemental species (e.g., "AlSiK" or "mixtures Cl+S"); the `refractive index` grouping shows the pure compounds based on which the refractive index was calculated by volume weighted averaging: sulf = ammonium sulfate, soot = flame soot, calc = calcium carbonate, hem = hematite, sil = modified kaolinite , nchl = sodium chloride, kchl = potassium chloride, rut = titanium dioxide, qtz = quartz. A "–" means that particles were neglected for refractive index calculation.

---
---

