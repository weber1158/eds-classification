function mineral = msa_classification(filename,varargin)
%Mineral classification of .msa / .emsa files
%
%SYNTAX
% mineral = MSA_CLASSIFICATION(filename)
% mineral = MSA_CLASSIFICATION(filename,varargin)
%
%INPUT
% filename {char} :: Name of .msa or .emsa file
% 
%OUTPUT
% mineral {struct}:: Mineral classification
%
%
%NAME-VALUE PAIRS
% _________________________________________________________________________
%  Name           Default Value   Description
% =========================================================================
%  'Algorithm'      'Weber'       EDS classification algorithm. Options
%                                 include 'Donarummo','Kandler','Kutuzov',
%                                 'Panta', and 'Weber'
%  'Degree'            10         Degree of polynomial used in fitting
%                                 algorithm. See subtract_bacgkround for
%                                 details.
%  'MinSeparation'    0.13        Minimum separation between peaks required
%                                 for the fitting algorithm. See the
%                                 function help for subtract_background for
%                                 details.
%  'SmoothingFactor'   15         Moving average filter required for
%                                 fitting algorithm. See the function help
%                                 for subtract_background for details.
% _________________________________________________________________________
%
%
%EXAMPLE
% mineral = MSA_CLASSIFICATION('quattro_cemas.msa');
%
%
%See also
% eds_classification, subtract_background, net_intensity, atom_percent
%

  % Input parsing
  p = inputParser();
  addRequired(p, 'filename' , @(x) ischar(x));
  addParameter(p,'Algorithm', 'Weber', @(x) ischar(x));
  addParameter(p,'Degree'   , 10,      @(x) isnumeric(x) && isscalar(x));
  addParameter(p,'MinSeparation',0.13, @(x) isnumeric(x) && isscalar(x));
  addParameter(p,'SmoothingFactor',15, @(x) isnumeric(x) && isscalar(x));
  parse(p, filename, varargin{:});
  algorithm = p.Results.Algorithm;
  degree = p.Results.Degree;
  minsep = p.Results.MinSeparation;
  smFact = p.Results.SmoothingFactor;

  % Read .msa file and subtract background radiation
  data = subtract_background(filename,...
                             'Degree',degree,...
                             'MinSeparation',minsep,...
                             'SmoothingFactor',smFact);

  % Identify the net intensity for each mineral-forming element
  intensities = peak_intensity(data);

  % Apply mineral classification to the data
  if contains('KandlerKutuzovPanta',algorithm)
    % Convert to atom percent before identifying mineralogy
    atomic_proporitions = atom_percent(intensities);
    mineral = eds_classification(atomic_proporitions,...
      'Algorithm',algorithm);
  else
    mineral = eds_classification(intensities,'Algorithm',algorithm);
  end
  

%=========================================================================
% END MAIN FUNCTION
end
%=========================================================================