# get_hycom
Scripts to download HYCOM hindcast data from 1994 to present

This script is used to download 3-hourly hindcast predictions of sea surface elevation, and water temperature, salinty, u-velocity, and v-velocity at various depth layers from anywhere in the world oceans predicted by the HYCOM model (www.hycom.org). The script is generalized to extract HYCOm data for any dates and times between 1994 to the present.

The script is written in the Microsoft Powershell language. Powershell is a cross-platform task-automation solution that runs in Windows, Linux, and MacOS

INSTRUCTIONS

1) In the user input section above the while loop, specify the following:
 		- specify the list of variables to be extracted from any combination of $var_list = "surf_el,water_temp,salinity,water_u,water_v"
 		- specify the $west, $east, $south, and $north extent of the bounding box to be extracted
 		- specify the name of the $resultDirectory where the hycom data will be saved as output
 		- specify the $date_start and $date_end of the period to be extracted
 2) In the user selection section within the while loop, select the appropriate $url for the time period and variables to be extracted
 3) In the Windows search box, search for "Powershell" and open a Powershell window, and then copy and paste the entire contents of this script into the Powershell window to execute.
 	 If you do not have Windows, you may use this script in the new cross-platform version of PowerShell that is available for MacOS and Linux at the following link from Microsoft: https://aka.ms/pscore6
 4) During execution you sould see the progress of each 3-hour file that is extracted during the period of interest from beginning to end. Each nc file name has the format yyyyMMdd_HH.nc to indicate the datetime stamp in UTC

