% Copyright Austin M. Weber 2024
%% Clear
close all
clear,clc

%% Define paths
% Get current folder
currentFolder = pwd;
% Define path to data
dataPath = [currentFolder '/eds_data/'];
% Define path to functions
exStr = 'Examples';
functionPath = currentFolder(1:end-length(exStr));
addpath(functionPath)

%% Import data
filename = 'eds_mineral_data.xlsx';

% EDS net intensity data
net = readtable([dataPath filename],'FileType','spreadsheet',...
    'Sheet','Net_Intensity');
% Get true classes from EDS net intensity data
netTrueClass = categorical(net.ABBREVIATION);

% EDS atom percent data
atP = readtable([dataPath filename],'FileType','spreadsheet',...
    'Sheet','Atom_Percent');
% Get true classes from EDS atom percent data
atTrueClass = categorical(atP.ABBREVIATION);


%% ALGORITHMS FOR CLASSIFYING EDS NET INTENSITY DATA
%% The Weber algorithm
%{
    The Weber algorithm is capable of classifying 18 unique minerals and
    can also group the minerals into their corresponding mineral groups.
    
    Unique to the Weber algorithm is the ability to discriminate the clay
    mineral palygorskite (Plg), the iron-magnesium silicate spinel (Spl),
    and three minerals of the pyroxene mineral group (i.e., augite [Aug],
    enstatite [En], and pigeonite [Pgt]). 

    The Weber algorithm is also the only algorithm with the ability to
    provide probability scores for each mineral classification.

    If you just want to perform mineral classification, then both the
    weber_classification or eds_classification function will produce the
    same results. However, if you want to obtain mineral group information
    or the probability scores, then use weber_classification.
%}

    % Compare the results of eds_classifcation and weber_classification and
    % confirm that they are the same:
    eds_weber = eds_classification(net,Algorith="Weber");
    weber = weber_classification(net);
    condition = isequal(eds_weber,weber);
    if condition == true
        disp('The eds_* and weber_* classification algorithms SUCCESSFULLY produced the same result.')
    else
        disp('The eds_* and weber_* classification algorithms FAILED to produce the same result.')
    end

    % Use the weber_classification function to get the mineral group
    % classifications and probability scores for the results.
    [~,groups,scores] = weber_classification(net);

    % Visualize the results
    figure(1)
    subplot(3,1,1)
     histogram(netTrueClass), hold on, histogram(weber,'BarWidth',0.3), hold off
     title('Mineral Classifiation')
     legend('True class','Weber classification')
    subplot(3,1,2)
     histogram(groups), title('Group classification')
    subplot(3,1,3)
     imagesc(scores{:,:})
     xticks(gca,1:18), xticklabels(gca,scores.Properties.VariableNames)
     ylabel(gca,'Observation')
     clim(gca,[0 1]), colorbar
     title(gca,'Probability Scores')
    sgtitle('Weber algorithm results')

%% The Donarummo algorithm
%{
    The Donarummo algorithm is capable of classifying a few minerals that
    the other algorithms are not programmed to recognize. For example, the
    mineral hectorite (Htr) and a 70/30 mix of illite/smectite (Ilt/Sme).

    The Donarummo algorithm also groups minerals that do not fit the proper
    indexing conditions into organized "unknown" classes beginning with
    "U-". See the original source material for details.
%}

    % Compare the results of eds_classifcation and donarummo_classification
    % and confirm that they are the same:
    eds_donarummo = eds_classification(net,Algorith="Donarummo");
    donarummo = donarummo_classification(net);
    condition = isequal(eds_donarummo,donarummo);
    if condition == true
        disp('The eds_* and donarummo_* classification algorithms SUCCESSFULLY produced the same result.')
    else
        disp('The eds_* and donarummo_* classification algorithms FAILED to produce the same result.')
    end

    % Visualize the results
    figure(2)
    histogram(donarummo)
    title('Donarummo algorithm results')

    %{
        Note that the Donarummo algorithm cannot correctly identify the
        minerals in the net intensity data that the algorithm is not
        programmed to recognize. For instance, there are several "U-"
        classifications as well a few Htr classifications, despite there
        being no Htr in the net intensity data.

        This is the first example demonstrating the importance of comparing
        multiple classification algorithms before finalizing your results.
        Simply relying on a single algorithm runs a serious risk of leading
        the researcher to make spurious interpretations.
    %}

%% ALGORITHMS FOR CLASSIFYING EDS ATOM PERCENT DATA
%% The Kandler algorithm
%{
    The Kandler algorithm does not explicitly divide EDS data into
    distinct mineral classes; rather, the algorithm identifies generalized
    mineral groups (e.g., "Sulfates"), generalized mineral classes (e.g.,
    "SiAlNa"), and refractive indexes. This algorithm is nonetheless very
    useful because it is trained to recognize ~40 different types of
    mineralogical samples.
    
    Unlike the previous two algorithms, the Kandler algorithm requires an
    input table of atom percents rather than net intensities. 

    Note that the output of the kandler_classification function is a table 
    with columns for the "group", "class", and "refractive_index".
%}

    % Compare the results of eds_classifcation and kandler_classification
    % and confirm that they are the same:
    eds_kandler = eds_classification(net,Algorith="Kandler");
    kandler = kandler_classification(net);
    condition = isequal(eds_kandler.class,kandler.class);
    if condition == true
        disp('The eds_* and kandler_* classification algorithms SUCCESSFULLY produced the same result.')
    else
        disp('The eds_* and kandler_* classification algorithms FAILED to produce the same result.')
    end

    % Visualize the results
    figure(3)
     subplot(3,1,1)
      histogram(kandler.group)
      title('Kandler groups')
     subplot(3,1,2)
      histogram(kandler.class)
      title('Kandler classes')
     subplot(3,1,3)
      histogram(kandler.refractive_index)
      title('Kandler refractive indexes')
     sgtitle('Kandler algorithm results')

     %{
        If you already know the general elemental compositions of the
        mineral, then the results for the Kandler classes are a great way
        to perform a secondary check on the results of other algorithms.
        In this example, there is one instance where the algorithm
        misclassified a mineral as quartz (Qz), but overall the results are
        consistent with what is expected given what we know about the
        relative abundance of each true mineral class.
     %}

%% The Panta algorithm
%{
    The Panta algorithm, like the Kandler algorithm, requires a table of
    atom percents rather than net intensities. The Panta algorithm is
    capable of classifying a few minerals that the other algorithms are not
    trained to recognize, including calcite (Cal), dolomite (Dol), gypsum
    (Gp), hematite (Hem), halite (Hl), ilmenite (Ilm), alunite (Alu), and
    rutile (Rt). It can also recognize quartz (Qz), complex Qz, complex
    sulfates, and other complex mixtures or solid solution serires. For
    instance, it can recognize feldspars; however, it is not capable of
    communicating the type of feldspar (e.g., K-, Na-, or Ca-bearing).
%}

    % Compare the results of eds_classifcation and panta_classification
    % and confirm that they are the same:
    eds_panta = eds_classification(net,Algorith="Panta");
    panta = panta_classification(net);
    condition = isequal(eds_panta,panta);
    if condition == true
        disp('The eds_* and panta_* classification algorithms SUCCESSFULLY produced the same result.')
    else
        disp('The eds_* and panta_* classification algorithms FAILED to produce the same result.')
    end

    % Visualize the results
    figure(4)
    histogram(panta)
    title('Panta algorithm results')

    %{
        Even though the Panta algorithm can recognize several unique
        minerals that the other algorithms cannot, it is nonetheless
        imperfect because it is not trained to identify certain minerals in
        the atom percent data (e.g., palygorskite, spinel, and the three
        pyroxene minerals). Because of this, the algorithm produces some
        erroneous classifications.

        These results, once again, demonstrate the necessity of processing
        EDS data with multiple algorithms and then comparing the results
        before making any final mineral classification assignments. 
    %}
%% Directly comparing the results of multiple agorithms
%{
    Directly comparing the results of multiple algorithms is easy. Simply
    save the results of each algorithm to a variable and then concatenate
    them into a table. Then, display the table and compare.
%}
results = [netTrueClass weber donarummo kandler.class panta];
results = array2table(results,'VariableNames',...
    {'True','Weber','Donarummo','Kandler','Panta'});
disp(results)