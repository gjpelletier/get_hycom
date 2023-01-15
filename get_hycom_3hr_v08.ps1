
# ----------
# get_hycom_3hr.ps1 
# 
# Microsoft Powershell script to extract 3-hr hycom model output
# This script is used to download hycom hindcast data from www.hycom.org 

# Original script by Amitava Guha
# Modified by Greg Pelletier (gjpelletier@gmail.com) 
# ----------

# - - -
# INSTRUCTIONS
#
# 1) In the user input section above the while loop, specify the following:
# 		- specify the list of variables to be extracted from any combination of $var_list = "surf_el,water_temp,salinity,water_u,water_v"
# 		- specify the $west, $east, $south, and $north extent of the bounding box to be extracted
#  		- specify the name of the $resultDirectory where the hycom data will be saved as output
# 		- specify the $date_start and $date_end of the period to be extracted, and the hycom code for the corresponding glb and expt
# 2) In the Windows search box, search for "Powershell" and open a Powershell window, 
#    and then copy and paste the entire contents of this script into the Powershell window to execute.
# 	 If you do not have Windows, you may use this script in the new cross-platform version of PowerShell 
# 	 that is available for MacOS and Linux at the following link from Microsoft: https://aka.ms/pscore6
# 3) During execution you sould see the progress of each 3-hour file that is extracted during the period of interest 
#    from beginning to end. Each nc file name has the format yyyyMMdd_HH.nc to indicate the datetime stamp in UTC
#
# Occasionaly there may be times when the hycom server is not responsive 
# and the script may try several times to download a particular 3-hour time.
# Each 3-hour time is saved in a separate netcdf file in the specified output folder. 
# Sometimes if the hycom data are missing there may appear to be an endless loop of trials to download the missing data.
# In those cases it may be necessary to stop the script and change the $date_start to a value that resumes with non-missing data
# and then re-run the script with that new start time.
#
# Sometimes problems with endless error loops may be fixed by re-initialize a new powershell session with the following
# two commands at the Powershell prompt before submitting the rest of the script in the powershell window:
Clear-Host 							
Get-PSSession | Remove-PSSession	

# - - -
# VERSION HISTORY
#
# v08 added input of glb and expt to build the url automatically for any year
# v06 added option for Parker's LiveOcean open boundary box
# v05 added option for $var_list in user inputs
# v04 $url choices for all of the experiments in the same script to allow use for any time period from 1994-present

# - - -
# This main functional parts of this script were obtained from the following link: 
# https://www.mathworks.com/matlabcentral/answers/542831-downloading-hycom-data-using-matlab-and-opendap
# by Amitava Guha on 04-Jan-2021
# modified by Greg Pelletier 10-Jan-2023

# - - -


# ----------

# ----------
# ----------
# USER INPUT SECTION

# NOTE: In addition to the user inputs in this section, the user also must select the appropriate url in the while loop 
# by commenting/uncommenting the appropriate $url lines of code as needed from the choices that are provided below

# - - -
# uncomment one of the following choices for $var_list, or input any other subset of variables:
$var_list = "surf_el,water_temp,salinity,water_u,water_v"
# $var_list = "water_temp,salinity,water_u,water_v"
# $var_list = "water_temp,salinity"
# $var_list = "water_u,water_v"

# - - -
# input the bounding box west, east, south, and north for region to extract
# to download single grid points, use $east-$west and $south-$north inputs that are tiny differences, like +/- .04 difference

# John Gala's bounding box for the Salish Sea Model open boundary
# $west = 360-129.52001953125			# 0 to 360 degE
# $east = 360-123.03997802734375		# 0 to 360 degE
# $south = 43							# -80 to 80 degN
# $north = 52							# -80 to 80 degN

# Parker MacCready's LiveOcean Model boundary hycom extraction box:
$west = 360-131				# 0 to 360 degE
$east = 360-121				# 0 to 360 degE
$south = 39					# -80 to 80 degN
$north = 53					# -80 to 80 degN

# - - -
# input the directory where the extracted nc files are saved
# $resultDirectory = $PSScriptRoot + "\data"
$resultDirectory = "c:\data\hycom\3hr\ps1\"

# - - -
# Specify the glb, expt, date_start, and number_of_days up to one year at a time between 1994 to present
$glb = 'GLBy0.08'                        # code for the HYCOM grid that was used to produce the data to be downloaded as described at www.hycom.org
$expt = '93.0'                           # code for the HYCOM experiment that was used to generate the data to be downloaded as described at www.hycom.org
$date_start = '01-Jan-2020 12:00:00'
$date_end = '31-Dec-2020 21:00:00'

# IMPORTANT: Note for selecting the correct glb and expt for the dates to be downloaded (more info on the glb and expt is available at www.hycom.org if needed):
# Use glb = 'GLBv0.08' and expt = '53.X' for dates between 1994-2015
# Use glb = 'GLBv0.08' and expt = '56.3' for dates between 1/1/2016 or 7/1/2014 to 4/30/2016
# Use glb = 'GLBv0.08' and expt = '57.2' for dates between 5/1/2016 to 1/31/2017
# Use glb = 'GLBv0.08' and expt = '92.8' for dates between 2/1/2017 to 5/31/2017
# Use glb = 'GLBv0.08' and expt = '57.7' for dates between 6/1/2017 to 9/30/2017
# Use glb = 'GLBv0.08' and expt = '92.9' for dates between 10/1/2017 to 12/31/2017
# Use glb = 'GLBv0.08' and expt = '93.0' for dates between 1/1/2018 to 12/31/2018 or 2/18/2020
# Use glb = 'GLBy0.08' and expt = '93.0' for dates between 2019-present

# END OF USER INPUTS
# ----------
# ----------

# ----------

# make a new directory to store the output results if it does not exist already
If (!(test-path $resultDirectory))
{
    md $resultDirectory
}

# - - -
# Converting dates to datetime
$startDate = [datetime]::ParseExact($date_start,'dd-MMM-yyyy HH:mm:ss',$null)
$endDate = [datetime]::ParseExact($date_end,'dd-MMM-yyyy HH:mm:ss',$null)
Write-Host "Downloading data from " $startDate.ToString('yyyy-MM-ddTHH:mm:ssZ') " to "  $endDate.ToString('yyyy-MM-ddTHH:mm:ssZ')

# - - -
# the following for loop does the extraction

for ($time = $startDate; $time -le $endDate; $time=$time.AddHours(3)){
$error_flag = 1
while ($error_flag -eq 1){

	if($expt -ne '53.X') {
		$url = "https://ncss.hycom.org/thredds/ncss/" + $glb + "/expt_" + $expt + "?var=" + $var_list + "&north=" + $north.ToString() + "&west=" + $west.ToString() + "&east=" + $east.ToString() + "&south=" + $south.ToString() + "&disableLLSubset=on&disableProjSubset=on&horizStride=1&time=" + $time.ToString('yyyy-MM-ddTHH:mm:ssZ') + "&accept=netcdf4"
	}else {
		$url = "http://ncss.hycom.org/thredds/ncss/" + $glb + "/expt_" + $expt + "/data/" + $time.ToString('yyyy') + "?var=" + $var_list + "&north=" + $north.ToString() + "&west=" + $west.ToString() + "&east=" + $east.ToString() + "&south=" + $south.ToString() + "&time=" + $time.ToString('yyyy-MM-ddTHH:mm:ssZ') + "&accept=netcdf4"
	}

	# Output file name
	$fileName = $time.ToString('yyyyMMdd_HH') + ".nc"
	$output = $resultDirectory + $fileName
	Try{

		# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

		# Creating a web client which has the download file functionality
		#WebProxy = New-Object System.Net.WebProxy("hoeprx01.na.xom.com:8080",$true)

		$WebClient = New-Object System.Net.WebClient
		#$WebClient.Proxy=$WebProxy
		$WebClient.DownloadFile($url,$output)

		Write-Host "Successfully downloaded:"  $fileName
		
		$error_flag = 0
	}
	Catch {
		Write-Host $_.Exception.Message`n
		$error_flag = 1
		Write-Host  "Retrying download of file:" $fileName " ...."
	}
}
}





