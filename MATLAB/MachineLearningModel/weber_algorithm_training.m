%% Weber Algorithm Training
% Training a supervised machine learning model to classify mineral species
% from EDS net intensity data.
%
% Copyright 2024 Austin M. Weber
%
%% Importing EDS net intensity data
% The following imports a table of EDS net intensity data collected on 18
% unique minerals (N=731). The table contains a column called ABBREVIATION
% that will be used as the target variable (i.e., the variable containing
% the true class information). The column is converted into a categorical
% data type. Although the table contains columns for 14 elements, only 9 of
% the columns will be used for generating the predictor variables that will
% be used to train the model (i.e., Na, Mg, Al, Si, P, K, Ca, Ti, and Fe).
net = readtable('eds_mineral_data.xlsx',...
    'FileType','spreadsheet');
net.ABBREVIATION = categorical(net.ABBREVIATION);

%% Create a table of predictor variables
% Rather than using the raw net intensity data for the 9 desired elements,
% the predictor variables will be 23 combinations of net intensity
% ratios. A table of predictors is produced with the user function:
% netIntensityRatios().
predictors = netIntensityRatios(net);

% Add a column for the known mineral class
targets = net.ABBREVIATION;
predictors.Mineral = targets;
predictors = movevars(predictors,'Mineral','Before','(Mg+Fe)/Al');

%% Apply SMOTE algorithm to the data
% The following employs the Synthetic Minority Oversampling TEchnique
% (SMOTE) in order to increase the number of observations in each
% "minority" class to match the number of observations in the "majority"
% class. In this case, the class with the most number of observations is Ab
% with 61, and so the smotem() function creates synthetic data for each of
% the remaining classes so that they also have a total of 61 observations.
% This raises the total number of observations from 731 to 1098.
[data_smote,labels_smote] = smotem(predictors{:,2:end},predictors.Mineral,5);

% The smotem() function produces a numerical matrix rather than a table, and
% so we need to convert data_smote into a table with the proper variable
% names in order to train the machine learning model. This table also
% needs to include a column for the target variable (which is stored in
% labels_smote).
varnames = predictors.Properties.VariableNames(2:end);
data_smote_table = array2table(data_smote,'VariableNames',varnames);
data_smote_table.Mineral = labels_smote;
data_smote_table = movevars(data_smote_table,'Mineral','Before','(Mg+Fe)/Al');

%% Train machine learning model
% The Classification Learner app is used to train supervised machine
% learning models. The process of training a model has already been
% completed and can be viewed by running the following:
classificationLearner("CLSession.mat")

% The bagged tree ensemble model is the one that has been saved and
% incorporated into the weber_classification() function. Note that the
% model uses a customized cost matrix and is fitted with the following
% hyperparameterizations:
%   HYPERPARAMETER          OPTION
%   Preset                  Bagged Trees
%   Ensemble method         Bag
%   Learner type            Decision tree
%   Max. # of splits        300
%   Number of learners      30
%   Number of predictors    Select All  
%
% The model was trained using 25 cross-validation folds and tested using
% 30% of the predictor data that was set aside before training. The 70/30
% training/testing split produced strong results.
%
% The calculated validation accuracy is 99.3% (N=769; i.e. 70% of 1098)
% The calculated test accuracy is 98.8% (N=329; i.e. 30% of 1098)