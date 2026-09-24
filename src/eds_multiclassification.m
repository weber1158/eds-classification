function minerals = eds_multiclassification(data,varargin)
%EDS mineral particle identification using a multi-algorithm approach
%
% This function is currently in beta and may not be production-ready.
%
%DESCRIPTION
% Filters a table EDS data (column headers must include F, Na, Mg, Al, Si,
% P, S, Cl, K, Ca, Ti, Cr, Mn, and Fe) using the Kandler classification
% algorithm (Kandler et al., 2011) to identify possible silicates, oxides,
% carbonates, phosphates, sulfates, and chlorides. Each particle (i.e.,
% each row) in the filtered data is then classified using a combination of
% different algorithms (Donarummo et al., 2023; Kandler et al., 2011; Panta
% et al., 2023; Weber, 2025; Kutuzov et al., 2026). Different algorithms
% can recognize different minerals but in many cases there is a lot of
% overlap. The `eds_mutliclassifiation` function cross-references the
% results of the various mineral identification algorithms and assigns a
% mineralogy to each particle based on consistencies between the algorithm
% outputs. In general, two or more algorithms must agree with the mineral
% assignment in order for the assignment to be finalized. Mineral
% assignments are made via a logical cascading indexing search that begins
% with broader mineral groups and narrows down to more specific mineral
% groups or species as the search progresses. Any mineral assignments made
% during the search process are finalized and will not be overwritten by
% subsequent operations in the classification scheme.
%
%
%SYNTAX
% minerals = eds_multiclassification(data,varargin)
%
%
%INPUTS
% data {N×M table} - EDS data table with column headers for the following
%                    elements: F, Na, Mg, Al, Si, P, S, Cl, K, Ca, Ti, Cr,
%                    Mn, and Fe.
%
%OUTPUTS
% minerals {N×1 cell} - List of mineral assignments for each mineral-like
%                       particle in the input table. Not necessarily the
%                       same length as size(data,1)!
%
%NAME-VALUE ARGUEMENTS
% DisplayMessages {logical} (default=false) Specifies whether progress
%                           lines are printed in the Command Window.
%                           Recommend "true" for very large datasets.
%
% Initialize {char} (default='default') The initialization method for
%                   filtering the dataset. By default, the dataset is
%                   is filtered using the 'Kandler' algorithm to narrow the
%                   input data down to only those particles whose composi-
%                   tions are determined "mineral-like". Alternatively,
%                   the user can specify 'none' to skip the initial 
%                   filtering or pass a vector of logical indexes
%                   designating which rows correspond to minerals.
%
% OmitOther {logical} (default=true) When true, mineral IDs that are not
%                       confirmed by at least two algorithms are omitted
%                       from the final output. Set 'OmitOther' equal to 
%                       false to keep the unconfirmed minerals and label
%                       them as 'Other'.
%                       
%
%EXAMPLE 1
% load('eds_data.mat','data')
% minerals = eds_multiclassification(data);
% figure
% histogram(categorical(minerals))
%
%EXAMPLE 2
% minerals = eds_multiclassification(data,DisplayMessages=true,...
%                    Intialize='none',OmitOther=false);
% histogram(categorical(minerals))
%
% 
%See also
% eds_classification, msa_classification


%
% TO DO / WISH LIST
%
% - Increase number of output arguments (or return a struct object) to
%   provide the mineral assignments from each algorithm, as well as the
%   probability scores from the machine learning model.
%
% - Include numeric outputs detailing the number of particles that were
%   filtered/identified as mineral-like, and possibly expressing the final
%   mineral assignments as relative abundances (%).
%
% - Create an optional argument (or make it the default) so that the 
%   function is more specific with certain mineral assignments. E.g.,
%   instead of "mafic-like" have the algorithm attempt to distinguish the
%   mafic minerals into narrower categories, such as pyroxenes and
%   amphiboles, or even more specific.
%
% - Create an optional argument that specifies the minimum number of
%   cross-algorithm agreements there needs to be in order to finalize a
%   mineral assignment. As of right now, most cases only require agreement
%   between at least 2 mineral classification algorithms. 


%
% Data input parsing
%
P = inputParser();
P.addRequired('data', @(x) istable(x));
P.addParameter('Initialize','default',@(x) ischar(x) | islogical(x));
P.addParameter('DisplayMessages',false,@(x) islogical(x) & isscalar(x));
P.addParameter('OmitOther',true,@(x) islogical(x) & isscalar(x));
parse(P,data,varargin{:});
initialization_method = P.Results.Initialize;
omit_other = P.Results.OmitOther;
msg = P.Results.DisplayMessages;
if ~islogical(initialization_method)
  if (~strcmpi(initialization_method,'default') & ...
      ~strcmpi(initialization_method,'Kandler') & ...
      ~strcmpi(initialization_method,'none'))
        error('Initialization method must be: ''default'' (or ''none''), ''Kandler'', or a custom vector of logical indecies of equivalent length to size(data,1).');
  else
    if (strcmpi(initialization_method,'default') | strcmpi(initialization_method,'Kandler'))
      initialization_method = 'default';
    else
      initialization_method = 'none';
    end
  end
end

%
% Initial filtering method used to narrow search to rows that are
% consistent with mineral particles.
%
if msg
  fprintf('===========================================================================\n')
  fprintf('Performing initial dataset filtering...\n')
  original_size = size(data,1);
end
if strcmpi(initialization_method,'none')
  % No pre-filtering

elseif strcmpi(initialization_method,'default')
  % Kandler method
  kandler = eds_classification(data,'Algorithm','Kandler');
  kandler_groups = kandler.Group;
  group_filter = ismember(kandler_groups, {'sulfates','carbonates',...
    'phosphates','oxides','Qz','silicates','mixutures'});
  data = data(group_filter,:);

else
  % User passed custom filtering method
  data = data(initialization_method,:);
end


%
% Identify mineralogy using multiple algorithms
% 
if msg
  fprintf('Running machine learning model...\n')
end
W = eds_classification(data); % The Weber algorithm is the default

if msg
  fprintf('Running sorting scheme algorithm...\n')
end
D = eds_classification(data,'Algorithm','Donarummo');

if msg
  fprintf('Running comparative criteria algorithms...\n')
end
A = eds_classification(data,'Algorithm','Kandler'); % There are 2 algorithms that start with 'K', so I am labeling the Kandler algorithm as 'A'
K = eds_classification(data,'Algorithm','Kutuzov');
P = eds_classification(data,'Algorithm','Panta');

if msg
  fprintf('Performing cascading indexing search...\n')
end

%
% Preallocate output
%
minerals = repmat({'Other'},[size(data,1) 1]);

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
% Assign Ti oxide
%
W_titanite = ismember(W.Mineral, 'Titanite');
A_rutile = ismember(A.Class, 'Ti oxide');
P_rutile = ismember(P.Mineral, 'Rutile');
rutile_idx = (W_titanite & A_rutile) | (W_titanite & P_rutile) | ...
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
A_kln = ismember(A.Class, 'AlSi');
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
W_ilt = ismember(W.Mineral, 'Illite');
D_ilt = ismember(D.Mineral, {'Illite','Illite/Smectite 70/30 mix.','Muscovite'});
A_ilt = ismember(A.Class, 'SiAlK');
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_ilt = ismember(P.Mineral, {'Illite', 'Complex Clay','Mica'}); % Mica could be illite if muscovite
ilt_idx = (W_ilt & D_ilt) | (W_ilt & A_ilt & K_phy) | (W_ilt & A_ilt & P_ilt) | ...
          (D_ilt & A_ilt & K_phy & P_ilt) & other_idx(minerals);
minerals(ilt_idx) = deal({'Illite-like'});

%
% Assign montmorillonite/smectite to data
%
W_sme = ismember(W.Mineral, 'Montmorillonite');
D_sme = ismember(D.Mineral, {'Ca-Montmorillonite','Illite/Smectite 70/30 mix.'});
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_sme = ismember(P.Mineral, {'Smectite','Complex Clay'});
sme_idx = (W_sme & D_sme) | (W_sme & K_phy) | (W_sme & P_sme) | ...
          (D_sme & K_phy & P_sme) & other_idx(minerals);
minerals(sme_idx) = deal({'Montmorillonite-like'});

%
% Assign mica to data
%
W_mica = ismember(W.Mineral, {'Muscovite','Biotite'});
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
verm_idx = (W_verm & D_verm) & other_idx(minerals);
minerals(verm_idx) = deal({'Vermiculite-like'});

%
% Assign palygorskite to data
%
W_paly = ismember(W.Mineral,'Palygorskite'); % (Mg,Al)2Si4O10(OH)·4H2O
D_hect = ismember(D.Mineral,'Hectorite'); % Na0.3(Mg,Li)3(Si4O10)(F,OH)2
K_phy = ismember(K.Mineral, 'Phyllosilicate');
P_clay = ismember(P.Mineral, {'Complex Clay'});
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
if msg
  nno = nnz(~ismember(minerals,'Other')); % Number Non-Other (NNO)
  fprintf('Done!\n')
  fprintf('The multiclassification method found %d mineral-like particles whose IDs were confirmed by \nat least two mineral identification algorithms (%0.1f%% of the original data).\n',...
    nno, 100*nno/original_size)
end

end % End main function