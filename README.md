# get_hycom
Scripts to download a temporal series of HYCOM model output data at time frequency of 3-hourly (over all model depths) or 1-hourly (surface diagnostic)

These scripts are intended for use to download a consecutive temporal series of 3-hourly or 1-hourly HYCOM predictions. The available variables for 3-hourly HYCOM predictions include the sea surface elevation, and water temperature, salinity, u-velocity, and v-velocity at all model depth layers. The available variables for 1-hourly predictions include the surface diagnostic water_flux_into_ocean, ocean_mixed_layer_thickness, surface_downward_heat_flux_in_air, sea_surface_elevation, steric_ssh, surface_boundary_layer_thickness, u_barotropic_velocity, and v_barotropic_velocity. 

The 3-hourly scripts are generalized to extract HYCOM data for any dates and times between 1994 to the present from any selected location in the world oceans at all model depths. The 1-hourly scripts download sur/surface diagnostic data between 2019 to the present for any selected location. 

The output data extracted from hycom is saved to your drive in netcdf format for each datetime.

Three versions of the 3-hourly and 1-hourly scripts are available as follows for use with different computing platforms:

- get_hycom_3hr.py and get_hycom_1hr.py are written in Python
- get_hycom_3hr.ipynb and get_hycom_1hr.ipynb are Jupyter notebooks that are set up as Google Colab notebooks to save hycom outputs in netcdf files directly to your Google drive
- get_hycom_3hr.ps1 and get_hycom_1hr.ps1 are written in Microsoft Windows Powershell. Powershell is a part of the Windows OS, and it is also available to run in Linux or MacOS. This is a good option for people who do not use Python or Jupyter notebooks.

INSTRUCTIONS

1) In the user input section, specify the following:
 		- specify the list of variables to be extracted in any combination of the available variables
 		- specify the west, east, south, and north extent of the bounding box to be extracted
 		- specify the name of the resultDirectory where the hycom data will be saved as output
 		- specify the date_start and number_of_days (or date_end in the Powershell version) of the period to be extracted, and the corresponding hycom codes for the model glb and expt
 2) Execute whichever version of the script you are using to generate the output nc files
 3) During execution you should see the progress of each 3-hourly or 1-hourly file that is extracted during the period of interest from beginning to end. Each nc file name has the format yyyyMMdd_HH.nc to indicate the datetime stamp in UTC

