classdef test_msa_classification < matlab.unittest.TestCase

  properties
    msa_file (1,:) char
    emsa_file (1,:) char
  end

  methods (TestMethodSetup)
    function setup(testCase)
      testCase.msa_file  = which('apreo_cemas.msa');
      testCase.emsa_file = which('phenom_osu.emsa');
    end
  end

  methods (Test)
    % Test whether .msa files are read properly
    function test_msa_file_extension(testCase)
      actual = msa_classification(testCase.msa_file);
      expected = 'struct';
      testCase.verifyClass(actual, expected);
    end

    % Test whether .emsa files are read properly
    function test_emsa_file_extension(testCase)
      actual = msa_classification(testCase.emsa_file);
      expected = 'struct';
      testCase.verifyClass(actual, expected);
    end

    % Test whether msa_classification correctly identifies 20 reference
    % minerals using the default algorithm
    function test_default_algorithm(testCase)
      mineral = {'Albite','Apatite','Augite','Biotite','Chlorite',...
        'Enstatite','Hornblende','Illite','Kaolinite','Labradorite',...
        'Microcline','Montmorillonite','Oligoclase','Palygorskite',...
        'Pigeonite','Spinel','Titanite','Vermiculite'};
      for M = 1:length(mineral)
        file = which([lower(mineral{M}) '.msa']);
        results = msa_classification(file);
        id = char(results.Mineral); % Convert from categorical
        actual = contains(id, mineral{M});
        testCase.verifyTrue(actual);
      end
    end

    % Test whether msa_classification applies the non-default algorithms
    % successfully
    function test_alternate_algorithms(testCase)
      algorithm = {'Donarummo','Kandler','Kutuzov','Panta'};
      for A = 1:length(algorithm)
        actual = msa_classification(testCase.msa_file,...
                                    'Algorithm',algorithm{A});
        expected = 'struct';
        testCase.verifyClass(actual,expected);
      end
    end

    % Test whether msa_classification applies the 'Degree' argument
    % successfully
    function test_alternate_degrees(testCase)
      degree = [3 5 8];
      for D = 1:length(degree)
        actual = msa_classification(testCase.msa_file,...
          'Degree',degree(D));
        expected = 'struct';
        testCase.verifyClass(actual,expected);
      end
    end

    % Test whether msa_classification applies the 'MinSeparation' argument
    % successfully
    function test_alternate_min_separations(testCase)
      min_sep = [0.1 0.5 1.0];
      for MS = 1:length(min_sep)
        actual = msa_classification(testCase.msa_file,...
          'MinSeparation',min_sep(MS));
        expected = 'struct';
        testCase.verifyClass(actual,expected);
      end
    end

    % Test whether msa_classification applies the 'SmoothingFactor'
    % argument successfully
    function test_alternate_smoothing_factors(testCase)
      smooth_factors = [3 5 10 12];
      for SF = 1:length(smooth_factors)
        actual = msa_classification(testCase.msa_file,...
          'SmoothingFactor',smooth_factors(SF));
        expected = 'struct';
        testCase.verifyClass(actual,expected);
      end
    end

  end

end