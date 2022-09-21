# Towards a standardized evaluation of imputation routines

This repository is dedicated to the manuscript 'Towards a standardized evaluation of imputation routines', written by Hanne Oberman and Gerko Vink.

## Contents

The manuscript can be found in the `Manuscript` folder. The reporting guidelines formulated in the manuscript can be found in the `Checklist` folder. Both are also available from [www.gerkovink.com/evaluation](https://www.gerkovink.com/evaluation/).

## Data

The manuscript relies on simulated data only, which is used to illustrate different missing data mechanisms. The data was generated in `R` (v4.1.2) using `MASS` (v7.3) and `mice` (v3.14), and can be found in the subfolder `plots` inside the `Manuscript` folder. To recreate the data and figure, see the `R` scripts `1. Simulate_MCARvMAR.R` and `2. Createplot.R` (respectively). The function `renv::restore()` can be used to restore the state of the project upon manuscript submission (21-09-2022).

## Contribution

We invite others for discussion and to contribute to our proposed checklist for the evaluation of imputation routines.