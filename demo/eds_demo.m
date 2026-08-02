%% EDS CLASSIFICATION DEMO

% The examples in this demo file are given in order of their appearance in
% the documentation (see Documentation.md)


%% ========================================================================
% eds_classification
%==========================================================================
% Example 1
load('eds_data.mat','data')
minerals = eds_classification(data);

% Example 2
% Get mineral IDs
D_minerals = eds_classification(data, Algorithm='Donarummo');
K_minerals = eds_classification(data, Algorithm='Kutuzov');

% Construct a comparison table
D_vs_K = array2table([D_minerals.Mineral, K_minerals.Mineral], ...
  'VariableNames', {'Donarummo','Kutuzov'});

% Compare the first 4 rows
head(D_vs_K, 4)

%% ========================================================================
% eds_read
%==========================================================================
% Example 1
s = eds_read('.\data\phenom_osu.emsa');
md = s.Metadata

% Example 2
figure
s.plot_spectrum; % Equivalent to eds_read(filename).plot_spectrum();

%% ========================================================================
% get_sem_metadata
%==========================================================================
% Example
backscatter_image = 'micrograph_BSE.tif';
metadata = get_sem_metadata(backscatter_image)

%% ========================================================================
% msa_classification
%==========================================================================
% Example
mineral = msa_classification(which('apreo_cemas.msa'));

%% ========================================================================
% Spectrum
%==========================================================================
% Example 1
s = eds_read(which('phenom_osu.emsa'));
figure
plt = Spectrum(s.Energy, s.Counts);

% Example 2
s1 = eds_read(which('phenom_osu.emsa'));
s2 = eds_read(which('quattro_cemas.msa'));
figure
plt2 = Spectrum(s1.Energy, s1.Counts);
plt2.addSpectrum(s2.Energy, s2.Counts);
plt2.normalizeSpectrum();

% Example 3
s3 = eds_read(which('apreo_cemas.msa'));
figure
plt3 = Spectrum(s3.Energy, s3.Counts);
plt3.addXrayLabels('prominence',94,'marker','sr');

%% ========================================================================
% standard_stoich_quant
%==========================================================================
% Example
load('plagioclase_quant.mat','num_O','elements','std_wts','std_net','spl_net')
standard_quant = standard_stoich_quant(num_O, elements, std_wts, std_net, spl_net)


%% ========================================================================
% stoich_quant
%==========================================================================
% Example
num_O = 8; % Number of oxygens in the chemical formula for plagioclase
elements = {'O','Na','Al','Si','Ca'};
wt_pct = [49.1527; 4.1517; 13.6314; 27.2759; 7.3997];
standardless_quant = stoich_quant(num_O, elements, wt_pct)