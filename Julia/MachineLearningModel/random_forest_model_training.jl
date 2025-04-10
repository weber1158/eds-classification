# Programming a random forest model to identify minerals from SEM-EDS data
# (C) 2025 Austin M. Weber

## LOAD DEPENDENCIES
using CSV, DataFrames, DecisionTree, MLJ, CategoricalArrays, Statistics

## IMPORT TRAINING DATA
# The file model_training_data_balanced.csv contains 1098 rows of mineral observations. 
# The first column :Mineral is the target variable, and the remaining 23 columns are the 
# features (in this case, different elemental net intensity ratios). The dataset has been 
# balanced using the synthetic minority oversampling technique so that each target class 
# has an equal number of observations.
#
# Note: In order for this to work, "model_training_data_balanced.csv" must be a file in
# the current folder.
data = CSV.read("model_training_data_balanced.csv",DataFrame);
first(data,5)

## REMOVE ROWS WITH MISSING DATA
data_no_missing = dropmissing!(data);

## EXTRACT TARGET LABELS
labels = Int.(CategoricalArray(data_no_missing.Mineral).refs);
true_classes = data_no_missing[:,1];

## EXTRACT FEATURES
features = Matrix{Float64}(select(data_no_missing, Not(:Mineral)));
training_data = data_no_missing[:,2:end];

## PARTITION THE DATA INTO 70/30 TRAINING/TEST DATASETS USING A STRATIFIED SPLIT
(Xtrain1, Xtest1), (ytrain1, ytest1) = 
    partition((training_data, true_classes), 0.7, rng=10, multi=true);

## CONVERT INTO DATA TYPES THAT build_forest CAN INTERPRET (that is, from DataFrame
## to Float64 and Int)
Xtrain1_features = Matrix{Float64}(Xtrain1);
Xtest1_features = Matrix{Float64}(Xtest1);

ytrain1_targets = Int.(CategoricalArray(ytrain1).refs);
ytest1_targets = Int.(CategoricalArray(ytest1).refs);

## CONSTRUCT MACHINE LEARNING MODEL
model = build_forest(ytrain1_targets, Xtrain1_features)

## APPLY RANDOM FOREST MODEL TO THE TRAINING DATASET (Xtrain1_features) AND THE TEST
## DATASET (Xtest1_features)
validation_predictions = apply_forest(model, Xtrain1_features);
test_predictions = apply_forest(model, Xtest1_features);

## EVALUATE THE ACCURACY OF THE MODEL BY COMPARING THE PREDICTIONS TO THE TRUE LABELS 
## (i.e. targets)
# The model should have an accuracy of around 98-100%, depending on the RNG seed
validation_accuracy = mean(validation_predictions .== ytrain1_targets)
test_accuracy = mean(test_predictions .== ytest1_targets)
println("Validation accuracy: ", round(validation_accuracy * 100, digits=3), "%\n")
println("Test accuracy: ", round(test_accuracy * 100, digits=3), "%\n")

## VISUALIZE THE TEST CONFUSION MATRIX
DecisionTree.confusion_matrix(ytest1_targets, test_predictions)

## GET PROBABILITY SCORES FOR A PREDICTION
observation = 123; # i.e., the 123rd row in the training features data
 # The line below will print the possible classes in the lefthand column
 # and the probability of that class in the righthand column
[levels(true_classes) apply_forest_proba(model,Xtrain1_features[observation,:],levels(labels)).*100]