# Horizontal-Vertical-Illusion

This repo contains raw data and code used in this [Journal of Vision publication on Horizontal-Vertical Illusion](https://jov.arvojournals.org/article.aspx?articleid=2607085)


### Data
Raw data from all 9 subjects are included under the `Data` folder, with each subject's data in its own folder titled by his/her initials. For each subject, data from all 5 experiment sessions and 1 practice session are included.

### Code
All experiment scripts and analysis scripts are included under the `Code` folder. Specifically,

  - `Experiment/HVI_experiment.m`: the main experiment script used in the paper
  - `Experiment/HVI_calibration.m`: for calibrating the experiment setup before each session
  - `Experiment/HVI_practice_trial.m`: for familiarizing subjects with the experiment before starting his/her first actual session
  - `Experiment/psybayes.m`: for choosing the length of the comparison lines after the 1st trial using Luigi Acerbi's implementation of the PSI method from Kontsevich and Tyler (1999). For more details, please check out Liugi's repo [here](https://github.com/lacerbi/psybayes)
  - `Analysis/plot_model_fits_across_subjects_2nd.m`: for fitting and plotting the psychometric curves shown in Figure 2 in the paper
  - `Analysis/plot_PSE_2_figures.m`: for plotting the estimated PSEs from Figure 3 in the paper
  - `Analysis/data_comparison_all_subject.m`: for fitting the multiplicative bias model and generating Figure 4A & Table1 in the paper
  - `Analysis/model_fit_PSE.m`: for plotting the multiplicative model fitted PSEs shown in Figure 4B in the paper 
  - `Analysis/data_comparison_2nd.m`: for recording data from previous papers and generating Figure 5 in the paper
  - `Analysis/significance_testing_older_papers.m`: for calculating similarity between our results with results from previous papers (Table 2 in the paper)
  - `Analysis/significance_testing_symmetric.m`: for negating an asymmetry effect from vertical 
  - `Analysis/tryprojection.m`: for generating the anistropy model shown in Figure 7 in the paper 
  
### References
Kontsevich, L. L., & Tyler, C. W. (1999). ["Bayesian adaptive estimation of psychometric slope and threshold"](https://www.sciencedirect.com/science/article/pii/S0042698998002855). Vision Research, 39(16), 2729-2737. 

