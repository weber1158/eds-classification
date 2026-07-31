classdef test_eds_read < matlab.unittest.TestCase

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
      actual = eds_read(testCase.msa_file);
      expected = 'eds_read';
      testCase.verifyClass(actual, expected);
    end

    % Test whether .emsa files are read properly
    function test_emsa_file_extension(testCase)
      actual = eds_read(testCase.emsa_file);
      expected = 'eds_read';
      testCase.verifyClass(actual, expected);
    end

    % Test whether Energy property is a double
    function test_Energy_class(testCase)
      actual = eds_read(testCase.msa_file).Energy;
      expected = 'double';
      testCase.verifyClass(actual, expected);
    end

    % Test whether Counts property is a double
    function test_Counts_class(testCase)
      actual = eds_read(testCase.msa_file).Counts;
      expected = 'double';
      testCase.verifyClass(actual, expected);
    end

    % Test whether FileName property is a char vector
    function test_FileName_class(testCase)
      actual = eds_read(testCase.msa_file).FileName;
      expected = 'char';
      testCase.verifyClass(actual, expected);
    end

    % Test whether Metadata property is a struct
    function test_Metadata_class(testCase)
      actual = eds_read(testCase.msa_file).Metadata;
      expected = 'struct';
      testCase.verifyClass(actual,expected);
    end

    % Test whether Energy and Counts properties are same length
    function test_Energy_Counts_length(testCase)
      data = eds_read(testCase.msa_file);
      len_Energy = length(data.Energy);
      len_Counts = length(data.Counts);
      testCase.verifyEqual(len_Energy, len_Counts);
    end

    % Test whether the plot_spectrum() method executes successfully
    function test_plot_spectrum_method(testCase)
      data = eds_read(testCase.msa_file);
      f = figure;
      data.plot_spectrum();
      ax = gca;
      area_object = findobj(ax,'Type','Area');
      testCase.verifyEqual(area_object.XData, data.Energy);
      testCase.verifyEqual(area_object.YData, data.Counts);
      testCase.verifyEqual(ax.XLabel.String, 'Energy (keV)');
      testCase.verifyEqual(ax.YLabel.String, 'Counts');
      testCase.verifyEqual(ax.XLim, [0 10]);
      testCase.verifyEqual(ax.YAxis.Exponent, int32(0));
      testCase.verifyEqual(ax.YAxis.TickLabelFormat, '%g');
      close(f)
    end
    
  end

end