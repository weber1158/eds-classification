classdef test_eds_multiclassification < matlab.unittest.TestCase

  properties
    msa_file (1,:) char
    emsa_file (1,:) char
  end

  methods(TestMethodSetup)
    function setup(testCase)
      testCase.msa_file = which('apreo_cemas.msa');
      testCase.emsa_file= which('phenom_osu.emsa');
    end
  end

  methods (Test)
    % Test whether .msa files are read properly
    function test_msa_file_extension(testCase)
      data = net_intensity(subtract_background(testCase.msa_file));
      actual = eds_multiclassification(data);
      expected = 'cell';
      testCase.verifyClass(actual, expected);
    end

    % Test whether .emsa files are read properly
    function test_emsa_file_extension(testCase)
      data = net_intensity(subtract_background(testCase.emsa_file));
      actual = eds_multiclassification(data);
      expected = 'cell';
      testCase.verifyClass(actual, expected);
    end

    % Test whether eds_multiclassification works when optional name-value
    % arguments are specified
    function test_nameValue_pairs(testCase)
      data = net_intensity(subtract_background(testCase.msa_file));
      expected = 'cell';
      actual = eds_multiclassification(data,DisplayMessages=true);
      testCase.verifyClass(actual, expected);
      actual = eds_multiclassification(data,Initialize='none');
      testCase.verifyClass(actual, expected);
      actual = eds_multiclassification(data,OmitOther=false);
      testCase.verifyClass(actual, expected);
      actual = eds_multiclassification(data,DisplayMessages=true,Initialize='none',OmitOther=false);
      testCase.verifyClass(actual, expected);
    end

    % Test whether eds_multiclassification correctly identifies feldspars
    function test_mineralogy_feldspar(testCase)
      mineral = {'Albite','Microcline','Oligoclase'};
      for M = 1:numel(mineral)
        file = which([lower(mineral{M}) '.msa']);
        data = net_intensity(subtract_background(file));
        id = eds_multiclassification(data);
        actual = contains(id, 'Feldspar-like');
        testCase.verifyTrue(actual);
      end
    end

    % Test whether eds_multiclassification correctly identifies quartz
    %  I don't have a quartz standard because the composition of quartz is
    %  fairly trivial (SiO2). The test below demonstrates this.
    function test_mineralogy_quartz(testCase)
      elements = {'F','Na','Mg','Al','Si','P','S','Cl','K','Ca','Ti','Mn','Cr','Fe'};
      % Define net intensities for four theoretical "quartz" particles;
      %  start with a pure Si signal then gradually add noise while keeping
      %  the Si net intensity constant (net=3000 counts). In this case, the
      %  max net intensity for a non-Si element is 300 (i.e., 10% of the Si
      %  net intensity). Any more than 10% of any non-Si element would
      %  probably mean that the particle is not quartz.
      net = [0   0   0   0 3000 0 0 0 0 0   0 0 0  0;... % 1st row only Si peak
             0   0   0 100 3000 0 0 0 0 0  50 0 0  0;... % 2nd row a little noise
             0  10  20 150 3000 0 0 0 0 10 90 0 0 20;... % 3rd row more noise
             5  50 100 300 3000 5 5 5 5 90 200 0 0 100]; % 4th row a lot of noise
      quartz_net_intensity = array2table(net,'VariableNames',elements);
      id = eds_multiclassification(quartz_net_intensity);
      actual = nnz(ismember(id, 'Quartz-like'));
      testCase.verifyTrue(actual==size(net,1));
    end

    % Test whether eds_multiclassification correctly identifies clays
    function test_mineralogy_clay(testCase)
      mineral = {'Chlorite','Illite','Kaolinite','Montmorillonite','Palygorskite','Vermiculite'};
      mineral = {'Chlorite','Illite','Kaolinite','Montmorillonite'};
      for M = 1:numel(mineral)
        file = which([lower(mineral{M}) '.msa']);
        data = net_intensity(subtract_background(file));
        id = eds_multiclassification(data);
        actual = contains(id, [mineral{M} '-like']);
        testCase.verifyTrue(actual);
      end 
    end

    % Test whether eds_multiclassification correctly identifies carbonates
    %  I don't have a carbonate standard because the composition of carbonate
    %  minerals is fairly basic ([Ca,Mg]CO3). The test below demonstrates this.
    function test_mineralogy_carbonate(testCase)
      elements = {'F','Na','Mg','Al','Si','P','S','Cl','K','Ca','Ti','Mn','Cr','Fe'};
      % Define net intensities for six theoretical "carbonate" particles;
      %  start with a pure Ca signal then gradually add noise while keeping
      %  the max net intensity constant (net=3000 counts). In this case, the
      %  max net intensity for a non-Ca/Mg element is 300 (i.e., 10% of the Ca
      %  net intensity). Any more than 10% of any non-Ca element would
      %  probably mean that the particle is not a carbonate.
      net = [0 0      0   0   0  0 0 0  0 3000   0   0   0   0;... % 1st row pure CaCO3
             0 0   3000   0   0  0 0 0  0 3000   0   0   0   0;... % 2nd row pure dolomite ([Ca,Mg]CO3)
             0 0   2000   0   0  0 0 0  0 3000   0   0   0   0;... % 3rd row low-Mg dolomite (Ca0.6 Mg0.4 CO3)
             0 0   1000   0   0  0 0 0  0 3000   0   0   0   0;... % 4th row very low-Mg dolomite (Ca0.75 Mg0.25 CO3)
             0 0   1000 100   0  0 0 0  0 3000   0 100 100 100;... % 5th row, same as above, but with trace Al, Mn, Cr, and Fe impurities
             0 150 1000 300 100 50 0 0 50 3000 100 200 100 150]; % 6th row, similar to above, but with a lot more noise 
      carbonate_net_intensity = array2table(net,'VariableNames',elements);
      id = eds_multiclassification(carbonate_net_intensity);
      actual = nnz(ismember(id, 'Carbonate-like'));
      testCase.verifyTrue(actual==size(net,1));
    end

  end

end