function [minerals,all_minerals] = msa_multiclassification(filename,varargin)
%EDS mineral particle identification using a multi-algorithm approach
%
% This function is currently in beta and may not be production-ready.
%
%DESCRIPTION
% Interprets the EDS spectrum in an MSA file using a multi-algorithm
% approach. The spectrum is classified using a combination of different
% algorithms (Donarummo et al., 2023; Kandler et al., 2011; Panta et al.,
% 2023; Weber, 2025; Kutuzov et al., 2026). Different algorithms can
% recognize different minerals but in many cases there is a lot of overlap.
% The `msa_multiclassification` function cross-references the results of the
% various mineral identification algorithms and assigns a mineralogy to
% each particle based on consistencies between the algorithm outputs. In
% general, two or more algorithms must agree with the mineral assignment in
% order for the assignment to be finalized. Mineral assignments are made
% via a logical cascading indexing search that begins with broader mineral
% groups and narrows down to more specific mineral groups or species as the
% search progresses. Any mineral assignments made during the search process
% are finalized and will not be overwritten by subsequent operations in the
% classification scheme.
%
%
%SYNTAX
% minerals = msa_multiclassification(data,varargin)
% [~,all_minerals] = msa_multiclassification(data)
%
%
%INPUTS
% filename {char} - Name of .msa or .emsa file
%
%OUTPUTS
% minerals {N×1 cell} - List of mineral assignments for each mineral-like
%                       particle in the input table.
%
% all_minerals {N×8 table} - Mineral assignments from all algorithms.
%                            Columns include: Final, DonarummoMineral, 
%                            KandlerGroup, KandlerClass, KutuzovMineral, 
%                            PantaMineral, WeberMineral, WeberProbability.
%                            The "Final" column is the same as the first
%                            output argument `minerals`.
%
%NAME-VALUE ARGUEMENTS
% OmitOther {logical} (default=false) When true, mineral IDs that are not
%                       confirmed by at least two algorithms are omitted
%                       from the final output.
%                       
%
%EXAMPLE 1
% minerals = msa_multiclassification('albite.msa');
% figure
% histogram(categorical(minerals))
%
%EXAMPLE 2
% [~,minerals] = msa_multiclassification('albite.emsa',OmitOther=false);
% histogram(categorical(minerals.Final))
%
% 
%See also
% eds_multiclassification, eds_classification, msa_classification


%
% Data input parsing
%
P = inputParser();
P.addRequired('filename', @(x) ischar(x));
P.addParameter('OmitOther',false,@(x) islogical(x) & isscalar(x));
parse(P,filename,varargin{:});
omit_other = P.Results.OmitOther;


%
% Identify mineralogy using multiple algorithms
% 
W = msa_classification(filename); % The Weber algorithm is the default


D = msa_classification(filename,'Algorithm','Donarummo');

A = msa_classification(filename,'Algorithm','Kandler'); % There are 2 algorithms that start with 'K', so I am labeling the Kandler algorithm as 'A'
K = msa_classification(filename,'Algorithm','Kutuzov');
P = msa_classification(filename,'Algorithm','Panta');

%
% Table of all output classes
%
all_minerals = array2table(D.Mineral,'VariableNames',{'DonarummoMineral'});
all_minerals.KandlerGroup = A.Group;
all_minerals.KandlerClass = A.Class;
all_minerals.KutuzovMineral = K.Mineral;
all_minerals.PantaMineral = P.Mineral;
all_minerals.WeberMineral = W.Mineral;
all_minerals.WeberProbability = max(W.Scores{1,:});


%
% Preallocate output
%   This isn't necessary and is simply an artifact of the
%   eds_multiclassification function, which has been copy-pasted here and
%   modified where appropriate.
%
minerals = repmat({'Other'},[size(file,1) 1]);

%
% Create an index that will be used in each assignment phase that is
% defined as "any element that is 'Other'". This index will be necessary
% so that once an element is assigned a mineralogy that is not 'Other' it
% cannot be re-assigned later on.
%
function idx = other_idx(M)
  % where M is the minerals vector
  idx = ismember(M, 'Other');
end

%
% Assign phosphate to data
%
W_ph = ismember(W.Mineral,'Apatite');
A_ph = ismember(A.Group, 'phosphates');
P_ph = ismember(P.Mineral,'Apatite');
ph_idx = (W_ph & A_ph) | (W_ph & P_ph) | (A_ph & P_ph);
minerals(ph_idx) = deal({'Phosphate-like'});  

%
% Assign gypsum/sulfate to data
%
A_sul = ismember(A.Group, 'sulfates');
P_sul = ismember(P.Mineral, {'Gypsum','Complex Sulfate'});
sul_idx = (A_sul & P_sul) & other_idx(minerals);
minerals(sul_idx) = deal({'Gypsum-like'});

%
% Assign chloride/salt to data
%
A_salt = ismember(A.Group, 'chlorides');
salt_idx = A_salt & other_idx(minerals);
minerals(salt_idx) = deal({'Chloride salt-like'});

%
% Assign ilmenite
%
A_ilmenite = ismember(A.Class, 'Fe Ti oxide');
P_ilmenite = ismember(P.Mineral, 'Ilmenite');
ilmenite_idx = (A_ilmenite & P_ilmenite) & other_idx(minerals);
minerals(ilmenite_idx) = deal({'Ilmenite-like'});

%
% Assign Ti-bearing
%
W_titanite = ismember(W.Mineral, 'Titanite');
A_rutile = ismember(A.Class, 'Ti oxide');
A_titanite = ismember(A.Class, {'SiCaTi'});
P_rutile = ismember(P.Mineral, 'Rutile');
  titanite_idx = (W_titanite & A_titanite) & other_idx(minerals);
  minerals(titanite_idx) = deal({'Titanite-like'});
  
  rutile_idx = (W_titanite & A_rutile) | (W_titanite & P_rutile) |...
    (A_rutile & P_rutile) & other_idx(minerals);
  minerals(rutile_idx) = deal({'Ti oxide-like'});


%
% Assign quartz to data
%
W_qz = ismember(W.Mineral,'Palygorskite'); % W algorithm confuses Qz for Plg
D_qz = ismember(D.Mineral,'Hectorite'); % D algorithm confuses Qz for Hct
A_qz = ismember(A.Group, 'Qz');
K_qz = ismember(K.Mineral,'Quartz');
P_qz = ismember(P.Mineral,{'Quartz','Complex Quartz'});
qz_idx = (A_qz & K_qz) | (A_qz & P_qz) | (K_qz & P_qz) | ...
         (K_qz & W_qz & D_qz) | (P_qz & W_qz & D_qz) & other_idx(minerals);
minerals(qz_idx) = deal({'Quartz-like'});

%
% Assign carbonate to data
%
A_carb = ismember(A.Group, 'carbonates');
K_carb = ismember(K.Mineral, 'Ca-dominant');
P_carb = ismember(P.Mineral, {'Calcite','Dolomite'});
carb_idx = (K_carb & P_carb) | (A_carb & K_carb) | (A_carb & P_carb) & other_idx(minerals);
minerals(carb_idx) = deal({'Carbonate-like'});

%
% Assign Fe-oxide to data
%
A_feo = ismember(A.Class, 'Fe oxide');
K_feo = ismember(K.Mineral, 'Fe-dominant');
P_feo = ismember(P.Mineral, 'Hematite');
feo_idx = (A_feo & K_feo) | (A_feo & P_feo) | (K_feo & P_feo) & other_idx(minerals);
minerals(feo_idx) = deal({'Fe oxide-like'});

%
% Assign Al-oxide to data
%
A_alo = ismember(A.Class, 'Al oxide'); % Only Kandler algorithm recognizes
alo_idx = A_alo & other_idx(minerals);
minerals(alo_idx) = deal({'Al oxide-like'});

%
% Assign non-clay mixture to data
%
A_mix = ismember(A.Group, 'mixtures');
K_mix = ismember(K.Mineral, 'Unknown');
P_mix = ismember(P.Mineral, {'Ca-rich silicate/Ca-Si-mix','Complex Feldspar/Clay mix'});
mix_idx = (A_mix & P_mix) | (K_mix & P_mix) & other_idx(minerals);
minerals(mix_idx) = deal({'Complex Mixture'});

%
% Assign mafic to data
%
W_maf = ismember(W.Mineral, {'Augite','Enstatite','Hornblende','Pigeonite','Spinel'});
D_maf = ismember(D.Mineral, {'Augite','Hornblende'});
A_maf = ismember(A.Class, {'SiAlFeMg','SiMgFe','SiMg'});
K_maf = ismember(K.Mineral, {'Augite','Diopside','High-Fe Hornblende','High-Mg Hornblende','Hypersthene','Pigeonite'});
maf_idx = (W_maf & D_maf) | (W_maf & A_maf) | (W_maf & K_maf) | ...
  (D_maf & A_maf) | (D_maf & K_maf) | (A_maf & K_maf) & other_idx(minerals);
minerals(maf_idx) = deal({'Mafic-like'});

%
% Assign feldspar to data
%
W_feld = ismember(W.Mineral, {'Albite','Microcline','Oligoclase','Labradorite'});
D_feld = ismember(D.Mineral, {'Albite','Alkali feldspar','Oligoclase/Andesine','Labradorite/Bytownite'});
A_feld = ismember(A.Class, {'SiAlK','SiAlNa','SiAlNaCa','SiAlNaK'});
K_feld = ismember(K.Mineral, {'Albite','Anorthite'});
P_feld = ismember(P.Mineral, {'Albite','Microcline','Complex Feldspar'});
feld_idx = (W_feld & D_feld) | (W_feld & K_feld & P_feld) | ...
  (D_feld & K_feld & P_feld) | (A_feld & K_feld & P_feld) | ...
  (D_feld & K_feld & A_feld) | (W_feld & A_feld & K_feld) | ...
  (W_feld & A_feld & P_feld) & other_idx(minerals);
minerals(feld_idx) = deal({'Feldspar-like'});

%
% Assign kaolinite to data
%
W_kln = ismember(W.Mineral, 'Kaolinite');
D_kln = ismember(D.Mineral, 'Kaolinite');
A_kln = ismember(A.Class, 'SiAl');
K_kln = ismember(K.Mineral, 'Kaolinite');
P_kln = ismember(P.Mineral, {'Kaolinite','Complex Feldspar/Clay mix','Complex clay'});
kln_idx = (W_kln & D_kln) | (W_kln & A_kln & P_kln) | (D_kln & A_kln & K_kln) ...
  | (W_kln & K_kln & P_kln) | (A_kln & K_kln & P_kln) & other_idx(minerals);
minerals(kln_idx) = deal({'Kaolinite-like'});

%
% Assign chlorite to data
% 
W_chl = ismember(W.Mineral, 'Chlorite');
D_chl = ismember(D.Mineral, 'Chlorite');
A_chl = ismember(A.Class, 'SiAlFeMg');
K_chl = ismember(K.Mineral, 'Chlorite');
P_chl = ismember(P.Mineral, 'Chlorite');
chl_idx = (W_chl & D_chl) | (W_chl & A_chl) | (W_chl & K_chl) | (W_chl & P_chl) |...
          (D_chl & A_chl & K_chl) | (D_chl & A_chl & P_chl) |...
          (A_chl & K_chl & P_chl) & other_idx(minerals);
minerals(chl_idx) = deal({'Chlorite-like'});

%
% Assign illite to data
%
W_ilt = ismember(W.Mineral, 'Muscovite (Illite)');
D_ilt = ismember(D.Mineral, {'Illite','Illite/Smectite 70/30 Mix','Muscovite'});
A_ilt = ismember(A.Class, 'SiAlK');
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_ilt = ismember(P.Mineral, {'Illite', 'Complex clay','Mica'}); % Mica could be illite if muscovite
ilt_idx = (W_ilt & D_ilt) | (W_ilt & A_ilt & K_phy) | (W_ilt & A_ilt & P_ilt) | ...
          (D_ilt & A_ilt & K_phy & P_ilt) & other_idx(minerals);
minerals(ilt_idx) = deal({'Illite-like'});

%
% Assign montmorillonite/smectite to data
%
W_sme = ismember(W.Mineral, 'Montmorillonite');
D_sme = ismember(D.Mineral, {'Ca-Montmorillonite','Illite/Smectite 70/30 Mix'});
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_sme = ismember(P.Mineral, {'Smectite','Complex clay'});
sme_idx = (W_sme & D_sme) | (W_sme & K_phy) | (W_sme & P_sme) | ...
          (D_sme & K_phy & P_sme) & other_idx(minerals);
minerals(sme_idx) = deal({'Montmorillonite-like'});

%
% Assign mica to data
%
W_mica = ismember(W.Mineral, {'Muscovite (Illite)','Biotite'});
W_verm = ismember(W.Mineral, 'Vermiculite'); % Could be confused with biotite
D_mica = ismember(D.Mineral, {'Muscovite','Biotite'});
D_verm = ismember(D.Mineral, 'Vermiculite'); % Could be confused with biotite
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_mica = ismember(P.Mineral, {'Mica'});
mica_idx = (W_mica & D_mica) | (W_mica & K_phy) | (W_mica & P_mica) | ...
           (D_mica & K_phy) | (D_mica & P_mica) | ...
           (K_phy & P_mica & W_verm) | (K_phy & P_mica & D_verm) |...
           (W_mica & D_verm & K_phy) | (W_mica & D_verm & P_mica) &...
           other_idx(minerals);
minerals(mica_idx) = deal({'Mica-like'});

%
% Assign vermiculite to data
%
W_biotite = ismember(W.Mineral, 'Biotite');
D_biotite = ismember(D.Mineral, 'Biotite');
verm_idx = (W_verm & D_verm) | (W_biotite & D_verm)...
  | (W_verm & D_biotite) & other_idx(minerals);
minerals(verm_idx) = deal({'Vermiculite-like'});

%
% Assign palygorskite to data
%
W_paly = ismember(W.Mineral,'Palygorskite'); % (Mg,Al)2Si4O10(OH)·4H2O
D_hect = ismember(D.Mineral,'Hectorite'); % Na0.3(Mg,Li)3(Si4O10)(F,OH)2
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_clay = ismember(P.Mineral, {'Complex clay'});
paly_idx = (W_paly & D_hect & K_phy) | (W_paly & D_hect & P_clay) | ...
           (W_paly & K_phy & P_clay) & other_idx(minerals);
minerals(paly_idx) = deal({'Palygorskite-like'});


%
% Delete 'other' (i.e., "unknown") minerals
%
if omit_other
  un_idx = ismember(minerals, 'Other');
  minerals(un_idx) = [];
end

%
% Append final assignment to all_minerals
%
all_minerals.Final = categorical(minerals);
all_minerals = movevars(all_minerals,'Final','Before','DonarummoMineral');


end % End main function
