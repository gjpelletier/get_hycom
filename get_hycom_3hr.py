
# ----------
# get_hycom_3hr.py 
# 
# Python script to extract 3-hr hycom model output
# This script is used to download hycom hindcast data from www.hycom.org 

# Adapted from a LiveOcean script by Parker MacCready (https://github.com/parkermac/LiveOcean)
# Modified by Greg Pelletier (gjpelletier@gmail.com) for standalone use (https://github.com/gjpelletier/get_hycom)
# ----------

# - - -
# INSTRUCTIONS
#
# 1) In the user input section, specify the following:
# 		- specify the list of variables to be extracted from any combination of var_list = 'surf_el,water_temp,salinity,water_u,water_v'
# 		- specify the west, east, south, and north extent of the bounding box to be extracted
#  		- specify the name of the resultDirectory where the hycom data will be saved as output
# 		- specify the date_start and number_of_days of the period to be extracted
# 2) Run this script in python or ipython
# 3) During execution you sould see the progress of each 3-hour file that is extracted during the period of interest 
#    from beginning to end. Each nc file name has the format yyyyMMdd_HH.nc to indicate the datetime stamp in UTC
#
# Occasionaly there may be times when the hycom server is not responsive 
# and the script may try several times to download a particular 3-hour time.
# Each 3-hour time is saved in a separate netcdf file in the specified output folder. 
# Sometimes if the hycom data are missing there may appear to be an endless loop of trials to download the missing data.
# In those cases it may be necessary to stop the script and change the $date_start to a value that resumes with non-missing data
# and then re-run the script with that new start time.

# - - -
# IMPORT REQUIRED PYTHON PACKAGES

import os
import sys
from datetime import *
import time
from urllib.request import urlretrieve
from urllib.error import URLError
from socket import timeout

# ----------

# ----------
# ----------
# USER INPUT SECTION

# - - -
# Edit the var_list as needed to download any subset of these available variables:
var_list = 'surf_el,water_temp,salinity,water_u,water_v'

# specify spatial limits (default below is Parker MacCready's HYCOM bounding box for the boundary of the LiveOcean model):
north = 53              # -80 to 80 degN          
south = 39              # -80 to 80 degN
west = -131 + 360       # 0 to 360 degE
east = -121 + 360       # 0 to 360 degE

# - - -
# specify the directory where the extracted nc files will be saved:
resultDirectory = '/mnt/c/data/hycom/3hr/'         # include the ending '/'

# -  
# Specify the glb, expt, date_start, and number_of_days up to one year at a time between 1994 to present
glb = 'GLBy0.08'                        # code for the HYCOM grid that was used to produce the data to be downloaded as described at www.hycom.org
expt = '93.0'                           # code for the HYCOM experiment that was used to generate the data to be downloaded as described at www.hycom.org
date_start = '2020-01-01 12:00:00'      # ISO formatted string for the starting datetime for the data to be downloaded (starting hour must be either 00, 03, 06, 09, 12, 15, 18, or 21, and must be 12 if the date_start is Jan 1 of the year or first day of the expt. The date_start must be within the range of dates for the glb and expt as described at www.hycom.org)
number_of_days  = 1                     # number of days of 3-hourly data to be downloaded (note: all downloaded days must fall within the range for the glb and expt as described at www.hycom.org)

# IMPORTANT: Note for selecting the correct glb and expt for the dates to be downloaded (more info on the glb and expt is available at www.hycom.org if needed):
# Use glb = 'GLBv0.08' and expt = '53.X' for dates between 1994-2015
# Use glb = 'GLBv0.08' and expt = '56.3' for dates between 1/1/2016 or 7/1/2014 to 4/30/2016
# Use glb = 'GLBv0.08' and expt = '57.2' for dates between 5/1/2016 to 1/31/2017
# Use glb = 'GLBv0.08' and expt = '92.8' for dates between 2/1/2017 to 5/31/2017
# Use glb = 'GLBv0.08' and expt = '57.7' for dates between 6/1/2017 to 9/30/2017
# Use glb = 'GLBv0.08' and expt = '92.9' for dates between 10/1/2017 to 12/31/2017
# Use glb = 'GLBv0.08' and expt = '93.0' for dates between 1/1/2018 to 12/31/2018 or 2/18/2020
# Use glb = 'GLBy0.08' and expt = '93.0' for dates between 12/4/2018 or 1/1/2019-present

# END OF USER INPUTS
# ----------
# ----------

# ----------
 
# - - -
# make function to create a directory if it does not already exist
def ensure_dir(file_path):
    # create a folder if it does not already exist
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

# - - -
# make function to extract the hycom data during the loop through all datetimes
def get_extraction(dt, out_fn, var_list):
    dstr0 = dt.strftime('%Y-%m-%d-T%H:00:00Z')
    print(dstr0)
    if expt == '53.X':
        url = ('http://ncss.hycom.org/thredds/ncss/' + glb + '/expt_' + expt + '/data/' + dt.strftime('%Y') + 
            '?var='+var_list +
            '&north='+str(north)+'&south='+str(south)+'&west='+str(west)+'&east='+str(east) +
            '&disableProjSubset=on&horizStride=1' +
            '&time_start='+dstr0+'&time_end='+dstr0+'&timeStride=8' +
            '&vertCoord=&addLatLon=true&accept=netcdf4')
    else:
        url = ('http://ncss.hycom.org/thredds/ncss/' + glb + '/expt_' + expt + 
            '?var='+var_list +
            '&north='+str(north)+'&south='+str(south)+'&west='+str(west)+'&east='+str(east) +
            '&disableProjSubset=on&horizStride=1' +
            '&time_start='+dstr0+'&time_end='+dstr0+'&timeStride=8' +
            '&vertCoord=&addLatLon=true&accept=netcdf4')
    # get the data and save as a netcdf file
    counter = 1
    got_file = False
    while (counter <= 10) and (got_file == False):
        print('  Attempting to get data, counter = ' + str(counter))
        tt0 = time.time()
        try:
            (a,b) = urlretrieve(url, out_fn)
            # a is the output file name
            # b is a message you can see with b.as_string()
        except URLError as ee:
            if hasattr(ee, 'reason'):
                print('  *We failed to reach a server.')
                print('  -Reason: ', ee.reason)
            elif hasattr(ee, 'code'):
                print('  *The server could not fulfill the request.')
                print('  -Error code: ', ee.code)
        except timeout:
            print('  *Socket timed out')
        else:
            got_file = True
            print('  Downloaded data')
        print('  Time elapsed: %0.1f seconds' % (time.time() - tt0))
        counter += 1
    if got_file:
        result = 'success'
    else:
        result = 'fail'
    return result

# - - -
# make 3-hourly dt_list to extract from hycom
base = datetime.fromisoformat(date_start)
if base.strftime('%H') == '12' and number_of_days >= 365:
    ndt = number_of_days * 8 - 4
else:
    ndt = number_of_days * 8
dt_list = []
dt_list = [base + timedelta(hours=3*x) for x in range(ndt)]

# - - -
# loop over all datetimes in dt_list
out_dir = resultDirectory                   # specify output directory adding the ending '/'
ensure_dir(out_dir)                         # make sure the output directory exists, make one if not
f = open(out_dir + 'log.txt', 'w+')         # open log of successful downloads
print('\n** Working on ' + glb + '/expt_' + expt + ' **')
f.write('\n\n** Working on ' + glb + '/expt_' + expt + ' **')
tt1 = time.time()                           # tic for total elapsed time
force_overwrite = True                      # overwrite any already existing nc files in the output folder that have the same names
for dt in dt_list:
    out_fn = out_dir + datetime.strftime(dt, '%Y%m%d_%H') + '.nc'
    print(out_fn)
    if os.path.isfile(out_fn):
        if force_overwrite:
            os.remove(out_fn)
    if not os.path.isfile(out_fn):
        result = get_extraction(dt, out_fn, var_list)
        f.write('\n ' + datetime.strftime(dt, '%Y%m%d_%H') + ' ' + result)
            
# - - -
# final message
totmin = (time.time() - tt1)/60             # total time elapsed for loop over all datetimes in minutes
print('')
print('All downloads are completed.')
print('Total time elapsed: %0.1f minutes' % totmin)
f.close()       # close log of successful downloads


