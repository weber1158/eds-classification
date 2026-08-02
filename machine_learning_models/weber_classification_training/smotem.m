function [new_data,new_labels] = smotem(data,labels,k)
%Synthetic Minority Oversampling TEchnique for Multiclass data (SMOTEM)
% [newData,newLabels] = SMOTEM(data,labels,k)
%  
%Inputs
% data : Data matrix where each row represents a sample
% labels : Categorical, cell, or string vector of corresponding classes
% k : Number of nearest neighbors (must be an integer > 1)
%
%Outputs
% newData : Data matrix containing original and synthetic data
% newLabels : Vector containing original and synthetic data labels
%
%Inspiration
% Inspired by a similar function from the MATLAB Central File Exchange
% published by Bjarke Skogstad Larsen (2024). The function by Larsen was
% written based on the work of Chawla et al. (2002). I have rewritten the
% algorithm along with the help of ChatGPT to make it easier to apply to
% the function to multiclass data. Hence, the algorithm is named smotem().
%
%References 
% Bjarke Skogstad Larsen (2024). Synthetic Minority Over-sampling Technique
% (SMOTE) (https://github.com/dkbsl/matlab_smote/releases/tag/1.0), GitHub.
% Retrieved July 18, 2024.
% 
% Chawla, N. V., Bowyer, K. W., Hall, L. O., & Kegelmeyer, W. P. (2002).
% SMOTE: Synthetic minority over-sampling technique. Journal of Artificial
% Intelligence Research, 16, 321-357. https://doi.org/10.1613/jair.953

% Copyright Austin M. Weber 2024

%%%
%%% Begin function body
%%%
    % Unique classes and their counts
    unique_classes = unique(labels);
    number_of_counts_per_class = histcounts(labels);
    max_number_of_counts = max(number_of_counts_per_class);
    
    % Initialize new data and labels
    new_data = data;
    new_labels = labels;
    
    % Iterate over each class
    for i = 1:length(unique_classes)
        class_name = unique_classes(i);
        class_data = data(labels == class_name, :);
        number_of_samples = number_of_counts_per_class(i);
        
        % If number_of_samples equals max_number_of_counts, continue
        if number_of_samples == max_number_of_counts
            continue;
        end
        
        % Find k-nearest neighbors for each sample in the class
        neighbors = knnsearch(class_data, class_data, 'K', k + 1);
        neighbors = neighbors(:, 2:end); % Remove self-neighbor
        
        % Number of synthetic samples needed
        number_of_synthetic_samples = max_number_of_counts - number_of_samples;
        
        % Generate synthetic samples
        synthetic_samples = [];
        new_label = unique_classes(i);
        for j = 1:number_of_samples
                number_of_neighbors = neighbors(j, randi(k));
                diff = class_data(number_of_neighbors, :) - class_data(j, :);
                synthetic_sample = class_data(j, :) + rand(1, size(data, 2)) .* diff;
                synthetic_samples = [synthetic_samples; synthetic_sample];
                
                new_labels = [new_labels; new_label];

                % Stop if we have generated enough samples
                if size(synthetic_samples, 1) >= number_of_synthetic_samples
                    break;
                end
        end
        % Append synthetic samples to the new data and labels
        new_data = [new_data; synthetic_samples]; 
    end

    % Because there may not be enough samples in number_of_samples to fully
    % bring up the total number of synthetic samples to match the
    % "majority" class, this function must call itself until the number of
    % observations in each class is equal to the number in the majority
    % class. That is, when the standard deviation of the number of samples
    % in each class is equal to zero.
    new_label_counts = histcounts(new_labels);
    if std(new_label_counts) ~= 0
        % Run the function again (recursive operation)
        [new_data,new_labels] = smotem(new_data, new_labels, k);
    else
        return
    end

end