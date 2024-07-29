function md = get_sem_metadata(filename)
%Extracts useful image metadata from SEM-generated .tif
%images and stores them in a MATLAB struct object.
%
% SYNTAX
%  md = GET_SEM_METADATA(filename)
%
% DESCRIPTION
%  This function extracts the metadata stored in a SEM micrograph (either a
%  backscatter or secondary electron image) given that the file is stored
%  in .tif format.
%
%  The function output, md, is a MATLAB structure array containing useful
%  metadata pertaining to the input image. This function has been
%  calibrated on BSE and ETD images collected on the FEI Quattro ESEM at
%  the Center for Electron Microscropy and Analysis (CEMAS) and on the FEI
%  Quanta 250 at the Subsurface Energy Materials and Chemical Analysis
%  Laboratory (SEMCAL) at The Ohio State University in Columbus, OH, USA.
%  This function is not guaranteed to work on any SEM micrograph TIF images
%  collected on different instruments and/or with different softwares.
%
% EXAMPLES
%  md = get_sem_metadata('imBSE.tif');
%
%  % Get the acceleration voltage (in eV) used to acquire the image
%  av = md.AccelerationVoltage
%    av =
%     20000
%
%  % Get working distance used to acquire the image (in meters)
%  wd = md.WorkingDistance
%    wd = 
%     0.0093
%
% See also
%  sem_pixel_size convergence_angle

% Copyright ©Austin M. Weber 2024

%
% Main function starts here
%
Istruct = imfinfo(filename); % Get structure of image info
Imet = Istruct.UnknownTags.Value; % Extract metadata

% Assemble desired metadata into a struct array
	md.Date = extract_datetime(Imet);
	md.Location = extract_str(Imet,'UserText=','UserTextUnicode=');
	md.AccelerationVoltage = extract_num(Imet,'HV=','Spot=');
	md.SpotSize = extract_num(Imet,'Spot=','StigmatorX');
	md.HorizontalFieldWidth = extract_num(Imet,'HFW=','VFW=');
	% Extract after 'VFW=' because 'WD' occurs within another variable
	% before the one we want
		md.WorkingDistance = extract_num(extractAfter(Imet,'VFW='),'WD=','BeamCurrent=');
	md.BeamCurrent = extract_num(Imet,'BeamCurrent=','TiltCorrectionIsOn=');
	md.PixelWidth = extract_num(Imet,'PixelWidth=','PixelHeight=');
	md.ResolutionX = extract_num(Imet,'ResolutionX=','ResolutionY=');
	md.ResolutionY = extract_num(Imet,'ResolutionY=','DriftCorrected=');
	% Check whether SignalType exists, if yes, it is {'SE'}; if not, assign {'BSE'}
	signal_type = extract_str(Imet,'Signal=','Grid=');
	if ~isempty(signal_type)
		md.SignalType = signal_type;
	else
		md.SignalType = {'BSE'};
	end
end

%
% Location functions
%
function out = extract_datetime(char_array)
	out = datetime(extractBetween(char_array,'Date=','Time='),'InputFormat','MM/dd/uuuu');
end

function out = extract_str(char_array,start_pat,end_pat)
	out = erase(erase(extractBetween(char_array,start_pat,end_pat),newline),char(13));
end

function out = extract_num(char_array,start_pat,end_pat)
	input = extractBetween(char_array,start_pat,end_pat);
	if size(input,1) > 1
		input = input(1);
	end
	out = str2double(cell2mat(erase(erase(input,newline),char(13))));
end