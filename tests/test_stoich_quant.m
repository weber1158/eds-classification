classdef test_stoich_quant < matlab.unittest.TestCase

  methods (Test)
    % Test whether stoich_quant runs successfully
    function test_standardless_stoichiometric_quantification(testCase)
      % Ilmenite [FeTiO3]
      num_O = 3;
      elements = {'O','Mg','Ti','Mn','Fe'};
      norm_wt_pct = [32.84; 0.14; 35.41; 3.7; 27.91];
      actual = stoich_quant(num_O, elements, norm_wt_pct);
      expected = 'table';
      testCase.verifyClass(actual,expected);
    end

    % Test whether stoich_quant successfully quantifies a specimen
    % of quartz [SiO2]
    function test_quartz(testCase)
      num_O = 2;
      elements = {'O','Si'};
      norm_wt_pct = [46.74; 53.26];
      results = stoich_quant(num_O, elements, norm_wt_pct);
      expected_O = 2;
      expected_Si = 1;
      expected = [expected_O; expected_Si];
      for element = 1:length(elements)
        idx = ismember(results.Element, elements{element});
        actual = round(results.StoichiometricCoeff(idx));
        testCase.verifyEqual(actual,expected(element));
      end
    end

    % Test whether stoich_quant successfully quantifies a specimen
    % of ilmenite [FeTiO3]
    function test_ilmenite(testCase)
      num_O = 3;
      elements = {'O','Mg','Ti','Mn','Fe'};
      norm_wt_pct = [32.84; 0.14; 35.41; 3.7; 27.91];
      results = stoich_quant(num_O, elements, norm_wt_pct);
      expected_O = 3;
      expected_Mg = 0;
      expected_Ti = 1;
      expected_Mn = 0;
      expected_Fe = 1;
      expected = [expected_O; expected_Mg; expected_Ti; expected_Mn;...
        expected_Fe];
      for element = 1:length(elements)
        idx = ismember(results.Element, elements{element});
        actual = round(results.StoichiometricCoeff(idx));
        testCase.verifyEqual(actual,expected(element));
      end
    end

    % Test whether stoich_quant successfully quantifies a specimen
    % of the alkali feldspar anorthoclase [(K,Ca)AlSi3O8]
    function test_anorthoclase(testCase)
      num_O = 8;
      elements = {'O','Na','Al','Si','K','Ca','Fe'};
      norm_wt_pct = [48.30; 6.96; 10.72; 31.28; 1.96; 0.63; 0.16];
      results = stoich_quant(num_O, elements, norm_wt_pct);
      expected_O = 8;
      expected_Al = 1;
      expected_Si = 3;
      expected_Ca = 0;
      expected_Fe = 0;
      expected = [expected_O;expected_Al;expected_Si;expected_Ca;...
        expected_Fe];
      element_order = {'O','Al','Si','Ca','Fe'};
      for element = 1:length(element_order)
        idx = ismember(results.Element, element_order{element});
        actual = round(results.StoichiometricCoeff(idx));
        testCase.verifyEqual(actual, expected(element));
      end
      expected_Na_plus_K = 1;
      idx = ismember(results.Element, {'Na','K'});
      actual = round(sum(results.StoichiometricCoeff(idx)));
      testCase.verifyEqual(actual, expected_Na_plus_K);
    end

  end
end