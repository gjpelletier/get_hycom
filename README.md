# get_hycom
Scripts to download 3-hourly HYCOM hindcast data from 1994 to present

These scripts are intended for use to download a consecutive series of 3-hourly hindcast predictions of sea surface elevation, and water temperature, salinity, u-velocity, and v-velocity at all depth layers from anywhere in the world oceans predicted by the HYCOM model (www.hycom.org). The scripts are generalized to extract HYCOM data for any dates and times between 1994 to the present. The output data extracted from hycom is saved to your drive in netcdf format for each 3-hourly datetime.

Three versions of the scripts are available as follows for use with different computing platforms:

- get_hycom_3hr.py is written in Python
- get_hycom_3hr.ipynb is a Jupyter notebook that is also set up as a Google Colab notebook to allow you to save hycom outputs in netcdf files directly to your Google drive
- get_hycom_3hr.ps1 is written in Microsoft Powershell. Powershell is a cross-platform task-automation solution that runs in Windows, Linux, and MacOS. This is a good option for people who do not use Python or Jupyter notebooks.

INSTRUCTIONS

1) In the user input section, specify the following:
 		- specify the list of variables to be extracted from any combination of var_list = "surf_el,water_temp,salinity,water_u,water_v"
 		- specify the west, east, south, and north extent of the bounding box to be extracted
 		- specify the name of the resultDirectory where the hycom data will be saved as output
 		- specify the date_start and number_of_days (or date_end in the Powershell version) of the period to be extracted, and the corresponding hycom codes for the model glb and expt
 2) Execute whichever version of the script you are using to generate the output nc files
 3) During execution you sould see the progress of each 3-hourly file that is extracted during the period of interest from beginning to end. Each nc file name has the format yyyyMMdd_HH.nc to indicate the datetime stamp in UTC

