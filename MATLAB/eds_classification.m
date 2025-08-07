function classes = eds_classification(data,varargin)
%EDS mineral classification
%
%SYNTAX
% EDS_CLASSIFICATION(data)
% EDS_CLASSIFICATION(data,Name=Value)
% classes = EDS_CLASSIFICATION(...)
%
%
%DESCRIPTION
% Four algorithms for mineral classification in a single function. Simply pass a
% table of EDS data (either net intensity or atom percent, depending on the
% algorithm you want) as the first input argument and then use the
% Algorithm="Algorithm" name-value pair to choose your algorithm.
%
%
%INPUTS
% data - Table of EDS data with columns for each of the elements required
%        by the algorithm.
%
% "Algorithm" - (Optional) name-value pair to specify the desired mineral
%               classification algorithm. For example, Algorithm="Panta".
%               The default is Algorithm="Weber".
% 
%OUTPUT
% classes - Categorical vector/table of mineral classes corresponding to each
%           row in the input table.
%
%
%NAME-VALUE PAIRS
% NAME
% "Algorithm" or Algorithm=
%
% VALUE         DATA_TYPE       REQUIRED_ELEMENTS           REFERENCE
% "Weber"       Net intensity   Na,Mg,Al,Si,P,K,Ca,Ti,Fe    This study
% "Donarummo"   Net intensity   Na,Mg,Al,Si,K,Ca,Fe         [1] 
% "Kandler"     Atom percent    Na,Mg,Al,Si,P,S,Cl,K,Ca,    [2]
%                               Ti,Cr,Mn,Fe
% "Panta"       Atom percent    F,Na,Mg,Al,Si,P,S,Cl,K,     [3]
%                               Ca,Ti,Cr,Mn,Fe              
%
%EXAMPLES
% % Use a custom machine learning algorithm to classify the mineral
% % composition of each row in an EDS net intenstiy data table.
% load eds_mineral_net_intensities.mat
% weber = EDS_CLASSIFICATION(data);
%
% % Use the sorting scheme algorithm from Donarummo et al. [1] to classify
% % the same data.
% donarummo = EDS_CLASSIFICATION(data,Algorithm="Donarummo");
%
%
%LIMITATIONS
% The four mineral classification algorithms were programmed using
% different SEM-EDS instruments and software and were designed for
% different applications. In addition, the mineral classes used to
% develop the algorithms are not the same. For more details on an 
% individual algorithm, use the MATLAB help() function. E.g., type:
%
% >> help kandler_classification
%
% in the Command Window to view the help info for the Kandler algorithm.
%
% The best way to utilize the EDS_CLASSIFICATION function is to consider
% the results from multiple algorithms before making any final decisions
% regarding the mineral classifications for a dataset. It is also
% recommended that the user compares the x-ray spectrum for each EDS
% measurement to the standard spectra in Severin [4] as an additional check
% on the mineral classifications.
%
%
%REFERENCES
% [1] Donarummo, J., Ram, M., & Stoermer, E. F. (2003). Possible deposit of
%     soil dust from the 1930 s U.S. dust bowl identified in Greenland ice.
%     Geophysical Research Letters, 30(6). <a href="matlab:
%     web('https://doi.org/10.1029/2002GL016641')">DOI</a>.
%
% [2] Kandler, K., Lieke, K., Benker, N., Emmel, C., Küpper, M., Müller-Ebert,
%     D., Ebert, M., Scheuvens, D., Schladitz, A., Schütz, L., & Weinbruch, S.
%     (2011). Electron microscopy of particles collected at Praia, Cape Verde,
%     during the Saharan Mineral Dust Experiment: Particle chemistry, shape,
%     mixing state and complex refractive index. Tellus B, 63(4), 475–496. <a href="matlab: web('https://doi.org/10.1111/j.1600-0889.2011.00550.x')">DOI</a>.
%
% [3] Panta , et al. (2023). "Insights into the single-particle composition,
%     size, mixing state, and aspect ratio of freshly emitted mineral dust 
%     from field measurements in the Moroccan Sahara using electron micro-
%     scopy." Atmos. Chem. Phys. 23, 3861–3885. <a href="matlab: web('https://doi.org/10.5194/acp-23-3861-2023')">DOI</a>.
%
% [4] Severin, K. P. (2004). Energy Dispersive Spectrometry of Common Rock 
%     Forming Minerals. Kluwer Academic Publishers. <a href="matlab:
% web('https://doi.org/10.1007/978-1-4020-2841-0')">DOI</a>.
%
%See also
% weber_classification, donarummo_classification, kandler_classification, panta_classification

% Copyright 2025 Austin M. Weber

%
% Begin function body
%

% Default Algorthm= condition
algorithm_condition = 'Weber';

% Input parsing
inP = inputParser();
addRequired(inP,'data',@istable);
addParameter(inP,'Algorithm',algorithm_condition,@(x) ischar(x) || isstring(x));
parse(inP,data,varargin{:});
% Define variables
dataTable = inP.Results.data;
algorithm = inP.Results.Algorithm;

algorithm_lowercase = lower(algorithm);

if strcmp(algorithm_lowercase,'weber')
 classes = weber_classification(dataTable);

elseif strcmp(algorithm_lowercase,'donarummo')
 classes = donarummo_classification(dataTable);

elseif strcmp(algorithm_lowercase,'kandler')
 classes = kandler_classification(dataTable);

elseif strcmp(algorithm_lowercase,'panta')
 classes = panta_classification(dataTable);

else
 disp('Algorithm not supported. Try Algorithm=''Weber'', ''Donarummo'', ''Kandler'', or ''Panta''.')

end

end