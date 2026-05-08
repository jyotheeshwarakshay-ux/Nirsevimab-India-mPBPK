# India-Specific mPBPK-QSSA-TMDD Model of Nirsevimab

**Flagship PharmD Project**  
**Specialization: Infectious Disease Immunopharmacology**

This repository contains the complete computational implementation of an **India-specific minimal physiologically based pharmacokinetic (mPBPK) model coupled with Quasi-Steady-State Approximation (QSSA) of Target-Mediated Drug Disposition (TMDD)** for the monoclonal antibody nirsevimab.

### Key Features (as per mother document)
- Integrates **IAP 2015 LMS growth charts** for Indian low-birth-weight infants
- Includes dynamic allometric scaling and catch-up growth
- Incorporates viral escape dynamics with FoldX thermodynamic penalties (S190R mutation)
- Monte Carlo simulations (5000+ virtual Indian infants) for Probability of Target Attainment (PTA)
- Interactive **Shiny dosing simulator** for clinicians and public health officials

### Files
- `01_base_model.R` – Base two-compartment PopPK model
- `03_iap_growth.R` – IAP 2015 growth ontogeny
- `06_pta_montecarlo.R` – Monte Carlo PTA simulations
- `08_shiny_dosing_simulator.R` – Interactive web app

### Technologies
- R, rxode2, nlmixr2
- ggplot2, Shiny

**This project directly aligns with Model-Informed Drug Development (MIDD) and translational immunopharmacology goals for top pharmaceutical companies (Pfizer, Novartis, Roche) and institutes like MPIIB.**

**Author**: Jyotheeshwar Akshay Ravi Kumar (PharmD 5th year)  
**Goal**: Hybrid Clinical Development + Translational Medicine → CSO → WHO Director General

⭐ Star this repo if it helps your research!
