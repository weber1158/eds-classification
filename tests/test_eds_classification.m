classdef test_eds_classification < matlab.unittest.TestCase

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
      data = net_intensity(subtract_background(testCase.msa_file));
      actual = eds_classification(data);
      expected = 'struct';
      testCase.verifyClass(actual, expected);
    end

    % Test whether .emsa files are read properly
    function test_emsa_file_extension(testCase)
      data = net_intensity(subtract_background(testCase.emsa_file));
      actual = eds_classification(data);
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
        data = net_intensity(subtract_background(file));
        results = eds_classification(data);
        id = char(results.Mineral); % Convert from categorical
        actual = contains(id, mineral{M});
        testCase.verifyTrue(actual);
      end
    end

    % Test whether msa_classification applies the non-default algorithms
    % successfully
    function test_alternate_algorithms(testCase)
      algorithm = {'Donarummo','Kandler','Kutuzov','Panta'};
      data = net_intensity(subtract_background(testCase.msa_file));
      for A = 1:length(algorithm)
        if strcmp(algorithm{A},'Kandler')
          data = atom_percent(data); % Re-write 'data' for remainder of
                                     % the for-loop so that the table is
                                     % in the proper atom percent format.
        end
        actual = eds_classification(data,'Algorithm',algorithm{A});
        expected = 'struct';
        testCase.verifyClass(actual,expected);
      end
    end

  end

end