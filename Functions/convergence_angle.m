function angle = convergence_angle(aperature_diameter_um,working_distance_m)
%Calculates the convergence angle, α (in milliradians), given the SEM
%aperature diameter (in microns) and the working distance (in m).
%
% SYNTAX
%  angle = CONVERGENCE_ANGLE(aperature_diameter_um,working_distance_m)
% 
% DESCRIPTION
%  The convergence angle, α, is illustrated as follows:
%
%	======== <- Diameter -> ======== Aperature (µm)
%	          \     |     /  |
%	           \    |    /   |
%	            \   |(α)/    | Working distance (m)
%	             \  |  /     |
%	              \ | /      V
%	================================ Sample surface
%
%	α = arctan( 0.5*diameter / working distance)
%
%  Note: The working distance is taken in units of meters because of the
%  way metadata are stored in .tif images.
%
% EXAMPLE
%  % Import tif metadata
%  meta = get_sem_metadata('imETD.tif');
%  % Extract working distance
%  wd = meta.WorkingDistance;
%  % Calculate α given a 30 micron aperature
%  a = convergence_angle(30,wd);
%
% See also
%  get_sem_metadata

% Copyright ©Austin M. Weber 2024

%
% FUNCTION BODY BEGINS HERE
%
% Convert working distance to mm
conversion_factor = 1000;
working_distance_m = working_distance_m * conversion_factor; % m to mm
% Calculate 1/2 of the aperature diameter
aperature_radius = aperature_diameter_um * 0.5;
% Convert radius to mm
aperature_radius = aperature_radius/conversion_factor; % um to mm
% Calculate the inverse tangent of α
angle = atan(aperature_radius/working_distance_m);
% Convert to milliradians
angle = angle * conversion_factor; % rad to mrad

end