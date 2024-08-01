% Copyright Austin M. Weber 2024
%% Clear
close all
clear,clc

%% Define paths
% Get current folder
currentFolder = pwd;
% Define path to data
dataPath = [currentFolder '/example_spectra/'];
% Define path to functions
exStr = 'Examples';
functionPath = currentFolder(1:end-length(exStr));
addpath(functionPath)

%% Import data
% Define file extension
ext = '.msa';

% Import spectral data
ab = read_msa([dataPath 'albite' ext]);
ap = read_msa([dataPath 'apatite' ext]);
aug= read_msa([dataPath 'augite' ext]);
bt = read_msa([dataPath 'biotite' ext]);
chl= read_msa([dataPath 'chlorite' ext]);
en = read_msa([dataPath 'enstatite' ext]);
hbl= read_msa([dataPath 'hornblende' ext]);
kln= read_msa([dataPath 'kaolinite' ext]);
lab= read_msa([dataPath 'labradorite' ext]);
mc = read_msa([dataPath 'microcline' ext]);
mnt= read_msa([dataPath 'montmorillonite' ext]);
ms = read_msa([dataPath 'muscovite' ext]);
olig=read_msa([dataPath 'oligoclase' ext]);
plg =read_msa([dataPath 'palygorskite' ext]);
pgt =read_msa([dataPath 'pigeonite' ext]);
spn =read_msa([dataPath 'sphene' ext]);
spl =read_msa([dataPath 'spinel' ext]);
vrm =read_msa([dataPath 'vermiculite' ext]);

%% Visualize biotite spectrum with labels
figure(1)
plt = xray_plot(bt);
xray_peak_label(plt,95) % specifies a minimum peak prominence of 95%
title('Biotite  K_2(Mg,Fe^{2+})_{6-4}(Fe^{3+},Al,Ti)_{0-2}[Si_{6-5}Al_{2-3}O_{20}](OH,F)_4')

%% Visualize all spectra using normalized units
figure(2)
% Need to be in reverse order if you want the legend to display
% alphabetically
xray_plot(norm_spectra(vrm));
hold on
 xray_plot(norm_spectra(spl));
 xray_plot(norm_spectra(spn));
 xray_plot(norm_spectra(pgt));
 xray_plot(norm_spectra(plg));
 xray_plot(norm_spectra(olig));
 xray_plot(norm_spectra(ms));
 xray_plot(norm_spectra(mnt));
 xray_plot(norm_spectra(mc));
 xray_plot(norm_spectra(lab));
 xray_plot(norm_spectra(kln));
 xray_plot(norm_spectra(hbl));
 xray_plot(norm_spectra(en));
 xray_plot(norm_spectra(chl));
 xray_plot(norm_spectra(bt));
 xray_plot(norm_spectra(aug));
 xray_plot(norm_spectra(ap));
 xray_plot(norm_spectra(ab));
hold off

% Add a legend
labels = flip({'Ab','Ap','Aug',...
    'Bt','Chl','En',...
    'Hbl','Kln','Lab',...
    'Mc','Mnt','Ms',...
    'Olig','Plg','Pgt',...
    'Spl','Spn','Vrm'});
L=legend(gca,labels);
L.NumColumns=3;
L.Title.String='Mineral';

%% Local function
function ns = norm_spectra(s)
%Normalize spectral data from 0 to 1
%
%SYNTAX
% ns = norm_spectra(s)
%
%INPUT
% s::{Table} X-ray data imported using read_msa()
%
%OUTPUT
% ns::{Table} Normalized table of the data in s
%
%BEGIN FUNCTION BODY
 counts = s.Counts;
 counts_norm = normalize(counts,'Range',[0 1]);
 s.Counts = counts_norm;
 ns = s;
% END FUNCTION BODY
end