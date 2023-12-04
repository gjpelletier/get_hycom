
% ----------
% merge_nc_files.m

% Example script to merge all data for a HYCOM model variable from separate nc files 
% that were previously downloaded with get_hycom.m into a single nc file.
% This script is run after the separate nc files are downloaded for each datetime stamp using the get_hycom.m script.
% This script reads the nc files that were downloaded by get_hycom.m and merges them all together into a single nc file.
% This script is an example merging a single variable, in this case salinity.
% Edit this script as needed to merge any other variables or additional variables.
%

% Greg Pelletier (gjpelletier@gmail.com) (https://github.com/gjpelletier/get_hycom)
% ----------

ncpath = 'c:\data\hycom\bhavana\' ;				% change this to whatever folder name contains your nc files downloaded by get_hycom
fout = 'c:\data\hycom\test\merged_data.nc';		% change this to whatever folder name and output file name that you want to use for the merged file

% - - -
% Process the files one by one
ncfiles = dir([ncpath,'*.nc']) ;				% list of all the separate nc files that are to be merged together
for fr = 1:length(ncfiles)
	file = [ncpath,ncfiles(fr,1).name] ;
	disp(['now reading >>>  ',file])
	if fr == 1

		time_long_name = ncreadatt(file,"time","long_name");
		time_units = ncreadatt(file,"time","units");
		time_origin = ncreadatt(file,"time","time_origin");
		time_calendar = ncreadatt(file,"time","calendar");
		NT = length(ncfiles);

		lon_long_name = ncreadatt(file,"lon","long_name");
		lon_standard_name = ncreadatt(file,"lon","standard_name");
		lon_units = ncreadatt(file,"lon","units");
		lon = ncread(file,"lon");
		NX = size(lon,1);
	
		lat_long_name = ncreadatt(file,"lat","long_name");
		lat_standard_name = ncreadatt(file,"lat","standard_name");
		lat_units = ncreadatt(file,"lat","units");
		lat = ncread(file,"lat");
		NY = size(lat,1);

		depth_long_name = ncreadatt(file,"depth","long_name");
		depth_standard_name = ncreadatt(file,"depth","standard_name");
		depth_units = ncreadatt(file,"depth","units");
		depth_positive = ncreadatt(file,"depth","positive");
		depth = ncread(file,"depth");
		NZ = size(depth,1);

		% initialize the datetime array for the merged data
		t = nan(NT,1);

		% initialize the arrays to merge for whichever variables are being merged
		% add as many variables as needed here, e.g. add more lines for var2, var3, etc
		var1 = nan(NX,NY,NZ,NT);

		% read the attributes for the variable being merged, in this example the variable is salinity
		% edit as needed to merge a different variable
		% add as many more variables as needed here, e.g. add ncreadatt statements for var2, var3, etc.
		var1_long_name = ncreadatt(file,"salinity","long_name");
		var1_standard_name = ncreadatt(file,"salinity","standard_name");
		var1_units = ncreadatt(file,"salinity","units");
	
	end

	% - - -
	% read the data from each nc file and add it to the merged data arrays for t, var1, var2, var3, etc

	t(fr,1) = ncread(file,"time");

	% read the data for the variable that is being merged, in this example salinity
	% edit as needed to merge a different variable
	% add as many more variables as needed here, e.g. add ncread statements for var2, var3, etc.
	var1(:,:,:,fr) = squeeze(ncread(file,"salinity"));
	
end

% write the nc file for the merged HYCOM data
if exist(fout)
	delete(fout);
end
%
% create nc variables
% vectors
nccreate(fout,'lon','Dimensions',{'lon',NX},'Format','netcdf4','FillValue',NaN,'DataType','single');   % create nc file with variables with needed dimensions
nccreate(fout,'lat','Dimensions',{'lat',NY},'Format','netcdf4','FillValue',NaN,'DataType','single');   % create nc file with variables with needed dimensions
nccreate(fout,'depth','Dimensions',{'depth',NZ},'Format','netcdf4','FillValue',NaN,'DataType','single');   % create nc file with variables with needed dimensions
nccreate(fout,'time','Dimensions',{'time',NT},'Format','netcdf4','FillValue',NaN,'DataType','int32');   % create nc file with variables with needed dimensions
% 4d arrays (lon x lat x dep x time)

% - - -
% create the nc variable for the HYCOM variable that is being merged, in this example salinity
% edit as needed to merge a different variable
% add as many more HYCOM variables as needed here, e.g. add nccreate statements for var2, var3, etc.
nccreate(fout,'salinity','Dimensions',{'lon',NX,'lat',NY,'depth',NZ,'time',NT},'Format','netcdf4','FillValue',NaN,'DataType','single');   % create nc file with variables with needed dimensions
% - - -

%
% write data into the nc variables
% vectors
ncwrite(fout,'lon',lon);   
ncwrite(fout,'lat',lat);   
ncwrite(fout,'depth',depth);   
ncwrite(fout,'time',t);   

% 4d arrays (lon x lat x dep x time)

% - - -
% write the merged nc data for the HYCOM variable that is being merged, in this example salinity
% edit as needed to merge a different variable
% add as many more HYCOM variables as needed here, e.g. add nccreate statements for var2, var3, etc.
ncwrite(fout,'salinity',var1);  

%
% write attributes of each variable
% vectors
ncwriteatt(fout,'lon','long_name',lon_long_name)
ncwriteatt(fout,'lon','standard_name',lon_standard_name)
ncwriteatt(fout,'lon','units',lon_units)
ncwriteatt(fout,'lat','long_name',lat_long_name)
ncwriteatt(fout,'lat','standard_name',lat_standard_name)
ncwriteatt(fout,'lat','units',lat_units)

ncwriteatt(fout,'depth','long_name',depth_long_name)
ncwriteatt(fout,'depth','standard_name',depth_standard_name)
ncwriteatt(fout,'depth','units',depth_units)
ncwriteatt(fout,'depth','positive',depth_positive)

ncwriteatt(fout,'time','long_name',time_long_name)
ncwriteatt(fout,'time','units',time_units)
ncwriteatt(fout,'time','origin',time_origin)
ncwriteatt(fout,'time','calendar',time_calendar)

% 4d arrays (lon x lat x dep x time)

% - - -
% write the attributes of the merged nc data for the HYCOM variable that is being merged, in this example salinity
% edit as needed to merge a different variable
% add as many more HYCOM variables as needed here, e.g. add ncwriteatt statements for var2, var3, etc.
ncwriteatt(fout,'salinity','long_name',var1_long_name)
ncwriteatt(fout,'salinity','standard_name',var1_standard_name)
ncwriteatt(fout,'salinity','units',var1_units)
% - - -

%
% write global attributes
ncwriteatt(fout,'/','title','Merged nc data previously downloaded from HYCOM using get_hycom.m')
ncwriteatt(fout,'/','title2','and merged using merge_nc_files.m')











