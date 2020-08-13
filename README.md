# COCOTIER-Models

MATLAB software to obtain the nominal SBAS error models for the COCOTIER project.

## Description

This software is a modification of the [MAAST tool](https://github.com/stanford-gps-lab/maast) v1.5.1 from Stanford.

The following plots can be obtained with this software
  * Maps of the **ionospheric** range error mean and STD for different elevation bins.
  * Maps of the **clock+ephemeris** range error mean and STD for different elevation bins.
  * Maps of the **ionospheric** position error mean and STD at a given percentile.
  * Maps of the **clock+ephemeris** position error mean and STD at a given percentile.
  * Maps of the **total** position error mean and STD at a given percentile.
  * Histograms and Q-Q plots of the **ionospheric** position error mean and STD.
  * Histograms and Q-Q plots of the **clock+ephemeris** position error mean and STD.
  * Histograms and Q-Q plots of the **total** position error mean and STD.

The input data has been obtained from a software developed by Quentin Tessier.

## Getting Started

### Dependencies

* Developed using MATLAB R2020a

### Installing

* Open project with MATLAB

### Executing program

* Run maast.m
* On the GUI select the desired configuration and press **RUN**
* To visualise previous results, select the desired outputs and press **PLOT**
* To change the positions of the error histograms, edit the desired file:
  * For the Ionospheric error: [iono_histogram_positions.txt](Data/NSE/iono_histogram_positions.txt)
  * For the Clock+ephemeris error: [clockeph_histogram_positions.txt](Data/NSE/clockeph_histogram_positions.txt)
  * For the Total error: [total_histogram_positions.txt](Data/NSE/total_histogram_positions.txt)
* To change the central ECAC area, edit the vertices of the area in [ECAC_central_area.txt](Data/NSE/ECAC_central_area.txt)

## Help for future development

The main functions are the following:
  * **[cocoguicbfun](GUI/cocoguicbfun.m):** This is the callback function called when an action in the GUI is carried
  * **[svmrun](SVM/svmrun.m):** Main function of the simulation. It loops over the defined time and finds all the LOS among others.
  * **[init_nsemodel](Init/init_nsemodel.m):** This function defines the input files
  * **[usrprocess](SVM/User-Processing/usrprocess.m):** This function finds all the information referred to the errors for each user at a given time.
  * **[compute_iono_error_nse](SVM/User-Processing/compute_iono_error_nse.m):** This function computes the ionospheric error statistics in the range domain.
  * **[compute_clkeph_error_nse](SVM/User-Processing/compute_clkeph_error_nse.m):** This function computes the clock+ephemeris error statistics in the range domain.
  * **[compute_user_stats](SVM/User-Processing/compute_user_stats.m):** This function computes the ionospheric, clock+ephemeris and total error statistics in the position domain.
  * **[outputprocess](Output/outputprocess.m):** This function plots the results.

The [MAAST User's Guide](http://web.stanford.edu/group/scpnt/gpslab/website_files/maast/userguide.pdf) and [MAAST Developer's Guide](http://web.stanford.edu/group/scpnt/gpslab/website_files/maast/MAAST_SDG_1_1.pdf) may also be helpful.

This functions are the ones used to obtain the input data:
 * **[PlotsIonoResultsECAC](InputData/PlotsIonoResultsECAC.m):** Function used to obtain the input data for the ionospheric error. It must be placed in Quentin's project, ***IONO_Range_Error/CODE***.
 * **[obtainClockEphStats](InputData/obtainClockEphStats.m):** Function used to obtain the input data for the clock+ephemeris error. It must be placed in Quentin's project, ***Tango/UDRE_IGS 1***.
 * **[COMP_ORBCLK_SBAS_IGS_vUSRhist_2](InputData/COMP_ORBCLK_SBAS_IGS_vUSRhist_2.m):** Function called by *obtainClockEphStats*. It must be placed in Quentin's project, ***Tango/UDRE_IGS 1***.
> :warning: **These functions must be run in their respective projects.**

## Author

[Arnau Ochoa Bañuelos](arnauochoa.96@gmail.com)

## Acknowledgments
* This project is possible thanks to the MAAST tool
* This project has been tutored by Carl Milner and Christophe Macabiau.
