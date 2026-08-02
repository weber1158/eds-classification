classdef test_Spectrum < matlab.unittest.TestCase

  properties
    msa_file (1,:) char
    emsa_file (1,:) char
    msa_data eds_read
    emsa_data eds_read
  end

  methods (TestMethodSetup)
    function setup(testCase)
      clc

      testCase.msa_file  = which('apreo_cemas.msa');
      testCase.emsa_file = which('phenom_osu.emsa');

      testCase.msa_data = eds_read(testCase.msa_file);
      testCase.emsa_data= eds_read(testCase.emsa_file);
    end
  end

  methods (Test)
    % Test whether .msa files are plotted successfully
    function test_msa_files(testCase)
      data = eds_read(testCase.msa_file);
      f = figure;
        plt = Spectrum(data.Energy, data.Counts);
        drawnow;
        ax = plt.getSpectrumAxes();
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

    % Test whether .emsa files are plotted successfully
    function test_emsa_files(testCase)
      data = eds_read(testCase.emsa_file);
      f = figure;
        plt = Spectrum(data.Energy, data.Counts);
        drawnow;
        ax = plt.getSpectrumAxes();
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

    % Test whether optional name-value arguments function as expected
    function test_optional_input_args(testCase)
      data = eds_read(testCase.msa_file);
      % Vary LineWidth, FaceColor, and FaceAlpha
      f = figure;
        plt = Spectrum(data.Energy, data.Counts,...
          'LineWidth', 3, 'FaceColor', [0.5 0.6 0.2], 'FaceAlpha', 0.2);
        drawnow;
        ax = plt.getSpectrumAxes();
        area_object = findobj(ax,'Type','Area');
        testCase.verifyEqual(area_object.LineWidth, 3);
        testCase.verifyEqual(area_object.FaceColor, [0.5 0.6 0.2]);
        testCase.verifyEqual(area_object.EdgeColor, [0.5 0.6 0.2]);
        testCase.verifyEqual(area_object.FaceAlpha, 0.2);
      close(f)
      % Vary the types of color data (RGB triplet vs. hexadecimal ...)
      f = figure;
        plt = Spectrum(data.Energy, data.Counts,...
          'FaceColor', 'r', 'EdgeColor', '#000000');
        drawnow;
        ax = plt.getSpectrumAxes();
        area_object = findobj(ax,'Type','Area');
        testCase.verifyEqual(area_object.FaceColor, [1 0 0]);
        testCase.verifyEqual(area_object.EdgeColor, [0 0 0]);
      close(f)
    end

    % Test whether addSpectrum successfully plots multiple spectra
    function test_addSpectrum(testCase)
      data1 = testCase.msa_data;
      data2 = testCase.emsa_data;
      f = figure;
        plt = Spectrum(data1.Energy, data1.Counts);
        plt.addSpectrum(data2.Energy, data2.Counts);
        drawnow;
        ax = plt.getSpectrumAxes();
        area_objects = findobj(ax,'Type','Area');
        testCase.verifyEqual(length(area_objects), 2);
      close(f)
    end

    % Test whether normalizeSpectrum successfully normalizes y-axis
    function test_normalizeSpectrum(testCase)
      data1 = testCase.msa_data;
      data2 = testCase.emsa_data;
      f = figure;
        plt = Spectrum(data1.Energy, data1.Counts);
        plt.addSpectrum(data2.Energy, data2.Counts);
        plt.normalizeSpectrum();
        drawnow;
        ax = plt.getSpectrumAxes();
        area_objects = findobj(ax,'Type','Area');
        area1 = area_objects(1);
        area2 = area_objects(2);
        area1_YRange = [min(area1.YData) max(area1.YData)];
        area2_YRange = [min(area2.YData) max(area2.YData)];
        expected = [0 1];
        testCase.verifyEqual(area1_YRange, expected);
        testCase.verifyEqual(area2_YRange, expected);
        testCase.verifyEqual(ax.YAxis.TickLabelFormat, '%g');
      close(f)
    end
    
    % Test whether removeSpectrum successfully removes spectra
    function test_removeSpectrum(testCase)
      data1 = testCase.msa_data;
      data2 = testCase.emsa_data;
      f = figure;
        plt = Spectrum(data1.Energy, data1.Counts);
        plt.addSpectrum(data2.Energy, data2.Counts);
        plt.removeSpectrum();
        drawnow;
        ax = plt.getSpectrumAxes();
        area_objects = findobj(ax,'Type','Area');
        num_area_objects = length(area_objects);
        expected = 1;
        testCase.verifyEqual(num_area_objects, expected);
      close(f)
    end

    % Test whether addXrayLabels successfully adds labels
    function test_addXrayLabels(testCase)
      data = testCase.msa_data;
      % No input arguments for addXrayLabels()
      f = figure;
        plt = Spectrum(data.Energy, data.Counts);
        plt.addXrayLabels();
        drawnow;
        ax = plt.getSpectrumAxes();
        text_objects = findobj(ax,'Type','Area');
        num_text_objects = length(text_objects);
        testCase.verifyGreaterThanOrEqual(num_text_objects, 1);
        marker_objects = findobj(ax,'Type','Line');
        num_marker_objects = length(marker_objects);
        testCase.verifyEqual(num_marker_objects, 0);
      close(f)
      % Including input arguments for addXrayLabels(varargin)
      f = figure;
        plt = Spectrum(data.Energy, data.Counts);
        plt.addXrayLabels('marker','sr','markersize',5,...
          'markerfacecolor','#0000FF');
        drawnow;
        ax = plt.getSpectrumAxes();
        marker_objects = findobj(ax,'Type','Line');
        num_marker_objects = length(marker_objects);
        testCase.verifyGreaterThanOrEqual(num_marker_objects, 1);
        first_marker = marker_objects(1);
        testCase.verifyEqual(first_marker.MarkerSize, 5);
        testCase.verifyEqual(first_marker.Marker, 'square');
        testCase.verifyEqual(first_marker.Color, [1 0 0]);
        testCase.verifyEqual(first_marker.MarkerFaceColor, [0 0 1]);
      close(f)
    end

    % Test whether removeXrayLabels successfully removes labels
    function test_removeXrayLabels(testCase)
      data = testCase.msa_data;
      f = figure;
        plt = Spectrum(data.Energy, data.Counts);
        plt.addXrayLabels('marker','sr','markersize',5,...
          'markerfacecolor','#0000FF');
        plt.removeXrayLabels();
        drawnow;
        ax = plt.getSpectrumAxes();
        marker_objects = findobj(ax,'Type','Line');
        num_marker_objects = length(marker_objects);
        testCase.verifyEqual(num_marker_objects, 0);
        text_objects = findobj(ax,'Type','Text');
        num_text_objects = length(text_objects);
        testCase.verifyEqual(num_text_objects, 0);
      close(f)
    end

  end

end