classdef test_standard_stoich_quant < matlab.unittest.TestCase

   methods (Test)
    % Test whether standard_stoich_quant runs successfully
    function test_standard_stoichiometric_quantification(testCase)
      % Plagioclase [NaAlSi3O8 - CaAl2Si2O8]
      num_O = 8;
      elements = {'O','Na','Al','Si','Ca','K','Fe'};
      std_wts = [47.09; 3.16; 15.49; 25.06; 8.71; 0.29; 0.33];
      std_net = [35569; 6943; 49988; 70467; 16236; 639; 212];
      spl_net = [36892; 9008; 43990; 76698; 13560; 594; 1187];
      actual = standard_stoich_quant(num_O,elements,...
        std_wts, std_net, spl_net);
      expected = 'table';
      testCase.verifyClass(actual, expected);
    end

    % Test whether standard_stoich_quant correctly evaluates the
    % stoichiometery of a plagioclase sample based on Casting's
    % approximation with a plagioclase standard
    function test_quantification_of_plagioclase_sample(testCase)
      % Plagioclase [NaAlSi3O8 - CaAl2Si2O8]
      num_O = 8;
      elements = {'O','Na','Al','Si','Ca','K','Fe'};
      std_wts = [47.09; 3.16; 15.49; 25.06; 8.71; 0.29; 0.33];
      std_net = [35569; 6943; 49988; 70467; 16236; 639; 212];
      spl_net = [36892; 9008; 43990; 76698; 13560; 594; 1187];
      results = standard_stoich_quant(num_O,elements,...
        std_wts, std_net, spl_net);
      rowNames = results.Element;
      results.Properties.RowNames = rowNames;
      colName = 'StoichiometricCoeff';
      expected_O = 8;
      expected_K = 0;
      expected_Fe = 0;
      expected_Al_plus_Si = 4;
      expected_Na_plus_Ca = 1;
      testCase.verifyEqual(round(results{'O',colName}),expected_O);
      testCase.verifyEqual(round(results{'K',colName}),expected_K);
      testCase.verifyEqual(round(results{'Fe',colName}),expected_Fe);
      actual_Al_plus_Si = results{'Al',colName} + results{'Si',colName};
      actual_Na_plus_Ca = results{'Na',colName} + results{'Ca',colName};
      testCase.verifyEqual(round(actual_Al_plus_Si), expected_Al_plus_Si);
      testCase.verifyEqual(round(actual_Na_plus_Ca), expected_Na_plus_Ca);
    end
   end

end