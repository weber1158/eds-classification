classdef test_msa_multiclassification < matlab.unittest.TestCase

  properties
    msa_file (1,:) char
    emsa_file (1,:) char
  end

  methods(TestMethodSetup)
    function setup(testCase)
      testCase.msa_file = which('chromium.msa');
      testCase.emsa_file= which('phenom_osu.emsa');
    end
  end

  methods (Test)
    % Test whether .msa files are read properly
    function test_msa_file_extension(testCase)
      warning off % Prevents warning message about bad polynomial fitting:
                  % this should be expected because "chromium.msa" is not a
                  % real spectrum collected with an EDS detector. It is a
                  % .msa file that I created by adding synthetic energies
                  % to the known x-ray channels for O and Cr. All other
                  % channels are zeros.
      actual = msa_multiclassification(testCase.msa_file);
      warning on
      expected = 'cell';
      testCase.verifyClass(actual, expected);
    end

    % Test whether .emsa files are read properly
    function test_emsa_file_extension(testCase)
      actual = msa_multiclassification(testCase.emsa_file);
      expected = 'cell';
      testCase.verifyClass(actual, expected);
    end

    % Test whether msa_multiclassification produces a table when a second
    % output argument is provided
    function test_second_output_argument(testCase)
      [~,actual] = msa_multiclassification(testCase.emsa_file);
      expected = 'table';
      testCase.verifyClass(actual,expected);
    end

    % Test whether msa_multiclassification correctly assigns "Non-
    % mineralogical" to a spectrum that clearly has no mineralogical
    % characteristics. In this example case, I am testing the function on a
    % custom .msa file called "chromium.msa" which only has x-ray peaks
    % for oxygen and chromium.
    function test_non_mineralogical_indexing(testCase)
      warning off % Prevents warning message about bad polynomial fitting:
                  % this should be expected because "chromium.msa" is not a
                  % real spectrum collected with an EDS detector. It is a
                  % .msa file that I created by adding synthetic energies
                  % to the known x-ray channels for O and Cr. All other
                  % channels are zeros. 
      [actual_ID, actual_table] = ...
        msa_multiclassification(testCase.msa_file);
      warning on
      % Test first output
      expected_ID = {'Non-mineralogical'};
      testCase.verifyEqual(actual_ID, expected_ID);
      
      % Test second output
      expected_table = array2table(categorical({'Non-mineralogical'}),...
        'VariableNames',{'Final'});
      expected_table.DonarummoMineral = 'N/A';
      expected_table.KandlerGroup = categorical({'other'});
      expected_table.KandlerClass = categorical({'other'});
      expected_table.KutuzovMineral = 'N/A';
      expected_table.PantaMineral = 'N/A';
      expected_table.WeberMineral = 'N/A';
      expected_table.WeberProbability = 'N/A';
      testCase.verifyEqual(actual_table, expected_table);
    end

    % Test whether msa_multiclassification correctly identifies feldspars
    function test_mineralogy_feldspar(testCase)
     % If this test passes and all of the tests for eds_multiclassification
     % pass then presumably msa_multiclassification works as expected
     % because both functions use the same indexing pathway.
      mineral = {'Albite','Microcline','Oligoclase'};
      for M = 1:numel(mineral)
        id = msa_multiclassification(which([lower(mineral{M}) '.msa']));
        actual = contains(id, 'Feldspar-like');
        testCase.verifyTrue(actual);
      end
    end

  end

end