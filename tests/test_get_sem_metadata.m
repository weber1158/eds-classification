classdef test_get_sem_metadata < matlab.unittest.TestCase

  properties
    bse_file (1,:) char
    etd_file (1,:) char
    bse_data struct
    etd_data struct
  end

  methods (TestMethodSetup)
    function setup(testCase)
      testCase.bse_file  = which('micrograph_BSE.tif');
      testCase.etd_file = which('micrograph_SE.tif');
    end
  end

  methods (Test)
    % Test whether .tif files are read properly
    function test_backscatter_electron_micrograph(testCase)
      actual = get_sem_metadata(testCase.bse_file);
      expected = 'struct';
      testCase.verifyClass(actual,expected);
    end
    function test_secondary_electron_micrograph(testCase)
      actual = get_sem_metadata(testCase.etd_file);
      expected = 'struct';
      testCase.verifyClass(actual,expected);
    end

    % Test whether get_sem_metdata stores metadata as expected
    function test_working_distance(testCase)
      %Backscatter electron image
        testCase.bse_data = get_sem_metadata(testCase.bse_file);
        actual = testCase.bse_data.WorkingDistance;
        expected = 9.3 / 1000; % mm to m
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
      %Secondary electron image
        testCase.etd_data = get_sem_metadata(testCase.etd_file);
        actual = testCase.etd_data.WorkingDistance;
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
    end
    function test_beam_current(testCase)
      %Backscatter electron image
        testCase.bse_data = get_sem_metadata(testCase.bse_file);
        actual = testCase.bse_data.BeamCurrent;
        expected = 13 / 1000000000; % nA to A
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
      %Secondary electron image
        testCase.etd_data = get_sem_metadata(testCase.etd_file);
        actual = testCase.etd_data.BeamCurrent;
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
    end
    function test_acceleration_voltage(testCase)
      %Backscatter electron image
        testCase.bse_data = get_sem_metadata(testCase.bse_file);
        actual = testCase.bse_data.AccelerationVoltage;
        expected = 20 * 1000; % V to kV
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
      %Secondary electron image
        testCase.etd_data = get_sem_metadata(testCase.etd_file);
        actual = testCase.etd_data.AccelerationVoltage;
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
    end
    function test_horizontal_field_width(testCase)
      %Backscatter electron image
        testCase.bse_data = get_sem_metadata(testCase.bse_file);
        actual = testCase.bse_data.HorizontalFieldWidth;
        expected = 104 / 1000000; % microns to meters
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
      %Secondary electron image
        testCase.etd_data = get_sem_metadata(testCase.etd_file);
        actual = testCase.etd_data.HorizontalFieldWidth;
        testCase.verifyEqual(actual,expected,'AbsTol',1e-4);
    end

  end

end