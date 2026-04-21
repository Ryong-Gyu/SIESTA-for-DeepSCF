# Custom SIESTA Extensions

This repository provides **custom code extensions** for the [SIESTA](https://departments.icmab.es/leem/siesta/) program, enabling efficient electronic structure calculations and *ab initio* molecular dynamics simulations of molecules and solids within the framework of **Density Functional Theory (DFT)**.

The original codebase is based on **SIESTA 4.1.5**, with several added functionalities described below.

## Features

### 1. DeepSCF

- Generates three-dimensional feature vectors in unformatted files.
- Supports reading of an initial guessed charge density (`.RHO`) for self-consistent field (SCF) calculations.

### 2. Modified Becke–Johnson (mBJ) Potential

- Implementation of the mBJ exchange potential for improved band gap predictions.

### 3. DFT-1/2

- Includes support for the DFT-1/2 method to correct self-interaction errors and improve electronic properties.

---

## Notes

- All modifications are intended to integrate seamlessly with the standard SIESTA workflow.
- For compilation and usage instructions, please refer to the individual module directories or the [SIESTA documentation](https://departments.icmab.es/leem/siesta/).

