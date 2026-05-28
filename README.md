# Nirsevimab India-Specific mPBPK-QSSA-TMDD Model

**First India-specific pharmacometric model for nirsevimab in Indian infants using real IAP 2015 LMS growth charts.**

I developed this project during my 5th year PharmD to address a real clinical gap: current nirsevimab dosing recommendations are based on Western data, but Indian infants — especially low-birth-weight babies — follow different growth patterns described in the Indian Academy of Pediatrics (IAP) 2015 LMS standards. 

This model integrates real IAP 2015 LMS growth parameters with Z-score variability, dynamic allometric scaling, weight-banded dosing, QSSA-TMDD, and time-dependent viral escape dynamics. It also includes a fully functional interactive Shiny dosing simulator for practical clinical use.

## Key Results
- Achieved **100% Probability of Target Attainment** (PTA > 0.1 mg/L at Day 150) with standard weight-banded dosing (50 mg if birth weight < 5 kg, 100 mg otherwise) across 5,000 virtual Indian infants.
- Exactly reproduced the clinical terminal half-life of 71 days (apparent CL = 0.00836 L/day).
- Generated realistic dynamic growth trajectories matching IAP 2015 LMS standards with Z-score variability.
- Built and validated an interactive Shiny simulator for real-time concentration-time profiling and PTA prediction.
- Performed bootstrap validation (n = 1,000) with Wilson score confidence intervals.
- Included time-dependent viral escape dynamics (declining efficacy factor reaching 0.883 at Day 150).

## Features
- Real IAP 2015 LMS growth function with Z-score variability and floor guard (prevents unrealistic negative weights).
- Dynamic allometric scaling (CL ∝ WT^0.75, Vc/Vp ∝ WT^1.0).
- Full dynamic Monte Carlo simulation (n = 5,000) with inter-individual variability on CL and Vc.
- Professional interactive Shiny dosing simulator.
- Complete validation suite (half-life verification, bootstrap, Sobol sensitivity analysis).
- Fully reproducible environment using renv.lock.

## How to Run the Shiny Simulator
1. Clone or download the repository.
2. Open the project folder in RStudio.
3. Source the file `08_shiny_dosing_simulator_real.R`.
4. The app will launch automatically in your browser.

## Repository Contents
- `02_real_iap_lms_growth.R` – Full IAP 2015 LMS growth function  
- `04_real_qssa_tmdd_fixed.R` – Core QSSA-TMDD ODE model  
- `05_fixed_pta_montecarlo_iiv.R` – Full dynamic Monte Carlo PTA simulation  
- `08_shiny_dosing_simulator_real.R` – Interactive Shiny dosing simulator  
- `09_half_life_verification.R` – Terminal half-life verification  
- `10_full_validation_suite.R` – Bootstrap and Sobol validation  
- `11_viral_escape_dynamics.R` – Viral escape implementation  
- `Supplementary_Material.pdf` – Full model equations and sensitivity analysis  
- `Nirsevimab_India_mPBPK_Manuscript_Final_v36.docx` – Final manuscript  

## Author
**Jyotheeshwar Akshay RaviKumar**  
PharmD Candidate (5th Year), Specialization in Infectious Disease Immunopharmacology, India  

## License
MIT License — feel free to use, modify, and build upon this work.

## Data Availability & Citation
All code, data, plots, and supplementary material are openly available in this repository.  
If you use this work, please cite the GitHub repository and the manuscript (bioRxiv upload coming soon).

GitHub: https://github.com/jyotheeshwarakshay-ux/Nirsevimab-India-mPBPK
