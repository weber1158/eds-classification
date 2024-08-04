function [minerals,groups,scores] = weber_classification(data)
%Machine learning mineral classification model for EDS data
%
%SYNTAX
% WEBER_CLASSIFICATION(data)
% minerals = WEBER_CLASSIFICATION(data)
% [~,groups] = WEBER_CLASSIFICATION(data)
% [~,~,scores] = WEBER_CLASSIFICATION(data)
%
%
%DESCRIPTION
% This bagged tree ensemble model was trained using EDS net intensity data
% collected on 18 mineral standards at the Center for Electron Microscopy
% and Analysis (CEMAS) at The Ohio State Universtiy. The instrument that
% was used was a Quattro Environmental SEM with an EDAX Octane Elect Super
% EDS detector. Operating conditions included a 15 kV acceleration voltage,
% 11 nA beam current, and a 12 mm working distance.
%
% The purpose of this function is to assist in the mineral classification
% of complex EDS spectra, with emphasis on minerals that are often found in
% ice core dust studies. Minerals with simple chemistry, such as quartz,
% can be easily classified from their spectra alone and were therefore ex-
% cluded from model training. A complete list of the minerals used to train
% the algorithm is given at the bottom of the help/documentation.
%
%
%INPUT
% data : Table of EDS net intensity data containing variables (i.e. columns)
%        for the elements Na, Mg, Al, Si, P, K, Ca, Ti, and Fe.
%
%OUTPUTS
% minerals : Categorical vector of mineral classifications for each row in
%            the input table. All classifications are given using
%            standardized abbreviations (see the table below for details).
%
% groups   : (Optional) Categorical vector of generalized mineral groups
%            for each row in the input table. For example, if the mineral 
%            is classified as one of the four feldspars it will be given a 
%            group classification of 'Feldspar'.
%
% scores   : (Optional) Probability scores for each classification. That
%            is, a table showing the likelihood of each classification. 
%            The scores are given as fractions between 0 (0%) and 1 (100%).
%
%
%LIMITATIONS
% This algorithm can only classify the minerals listed in the table below.
% Any other mineral that may be represented by the data in the input table
% will be misclassified. The weber_classification() function is therefore
% best used in conjunction with additional classification techniques.
%
%
%See also
% eds_classification, donarummo_classification, kandler_classification, panta_classification
%
%
%LIST OF POSSIBLE MINERAL CLASSIFICATIONS:
%------------------------------------------
% GROUP     MINERAL         ABBREVIATION
%------------------------------------------
% Amphibole Hornblende      Hbl
%
% Apatite   Apatite         Ap
%
% Clay      Chlorite        Chl
%           Muscovite       Ms
%           (var. illite)
%           Kaolinite       Kln
%           Montmorillonite Mnt
%           Palygorskite    Plg
%           Vermiculite     Vrm
% 
% Feldspar  Albite          Ab
%           Labradorite     Lab
%           Microcline      Mc
%           Oligoclase      Olig
%
% Mica      Biotite         Bt
% 
% Pyroxene  Augite          Aug
%           Enstatite       En
%           (var. bronzite)
%           Pigeonite       Pgt
%
% Spinel    Spinel          Spl
%
% Titanite  Sphene          Spn
%------------------------------------------
%
%

% (C) Austin M. Weber 2024

% Import model
warning off
load weber_trained_model.mat
weber_classifier = trainedModel.predictFcn;

% Convert net intensities to ratios (i.e., the 23 model predictors)
predictors = netIntensityRatios(data);

% Make model predictions
[minerals,scores] = weber_classifier(predictors);

% Convert scores into a table
varnames = {'Ab','Ap','Aug','Bt','Chl','En',...
            'Hbl','Kln','Lab','Mc','Mnt','Ms','Olig',...
            'Pgt','Plg','Spl','Spn','Vrm'};
scores = array2table(scores,'VariableNames',varnames);

% Create model groups
if nargout >= 2
    % Preallocate memory
    groups = cellstr(minerals);

    % Define indecies for groups with multiple mineral species
    clay_idx = logical(sum([strcmp(groups,'Chl') strcmp(groups,'Kln') strcmp(groups,'Mnt') ...
        strcmp(groups,'Ms') strcmp(groups,'Plg') strcmp(groups,'Vrm')],2));
    feldspar_idx = logical(sum([strcmp(groups,'Ab') strcmp(groups,'An') ...
        strcmp(groups,'Mc') strcmp(groups,'Lab') strcmp(groups,'Olig')],2));
    pyroxene_idx = logical(sum([strcmp(groups,'Aug') strcmp(groups,'En') ...
        strcmp(groups,'Pgt')],2));

    % Rename the groups
    % Clays
     idx = find(clay_idx);
     groups = renamegroups(groups,idx,'Clay');
    % Feldspars
     idx = find(feldspar_idx);
     groups = renamegroups(groups,idx,'Feldspar');
    % Pyroxenes
     idx = find(pyroxene_idx);
     groups = renamegroups(groups,idx,'Pyroxene');
    
    % Apatite
     idx = find(strcmp(groups,'Ap'));
     groups = renamegroups(groups,idx,'Apatite');
    % Amphibole
     idx = find(strcmp(groups,'Hbl'));
     groups = renamegroups(groups,idx,'Amphibole');
    % Mica
     idx = find(strcmp(groups,'Bt'));
     groups = renamegroups(groups,idx,'Mica');
    % Spinel
     idx = find(strcmp(groups,'Spl'));
     groups = renamegroups(groups,idx,'Spinel');
    % Titanite
     idx = find(strcmp(groups,'Spn'));
     groups = renamegroups(groups,idx,'Titanite');

    % Convert to a categorical
    groups = categorical(groups);

end
warning on % Turns warning notifications back on
end

function groups = renamegroups(groups,index,group_name)
 for ii = 1:length(index)
  groups{index(ii)} = group_name;
 end
end