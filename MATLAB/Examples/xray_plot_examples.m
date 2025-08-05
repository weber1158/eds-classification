% Copyright 2025 Austin M. Weber

close all
clear,clc

%% Import spectral data
ab = read_msa('albite.msa');
ap = read_msa('apatite.msa');
aug= read_msa('augite.msa');
bt = read_msa('biotite.msa');
chl= read_msa('chlorite.msa');
en = read_msa('enstatite.msa');
hbl= read_msa('hornblende.msa');
kln= read_msa('kaolinite.msa');
lab= read_msa('labradorite.msa');
mc = read_msa('microcline.msa');
mnt= read_msa('montmorillonite.msa');
ms = read_msa('muscovite.msa');
olig=read_msa('oligoclase.msa');
plg =read_msa('palygorskite.msa');
pgt =read_msa('pigeonite.msa');
spn =read_msa('sphene.msa');
spl =read_msa('spinel.msa');
vrm =read_msa('vermiculite.msa');

%% Visualize biotite spectrum with labels
figure(1)
plt = xray_plot(bt);
title('Biotite  K_2(Mg,Fe^{2+})_{6-4}(Fe^{3+},Al,Ti)_{0-2}[Si_{6-5}Al_{2-3}O_{20}](OH,F)_4')

% Label each peak above the 88th percentile in height
% and show all possible elements for each peak
xray_peak_label(plt,88,[],'all')

%% Visualize multiple spectra in a single plot
figure(2)
p1 = xray_plot(ab);
p2 = add_xray_plot(p1,ap);
p3 = add_xray_plot(p2,aug);
p4 = add_xray_plot(p3,bt);
p5 = add_xray_plot(p4,chl);
p6 = add_xray_plot(p5,en);
p7 = add_xray_plot(p6,hbl);
p8 = add_xray_plot(p7,kln);
p9 = add_xray_plot(p8,lab);
p10= add_xray_plot(p9,mc);
p11= add_xray_plot(p10,mnt);
p12= add_xray_plot(p11,ms);
p13= add_xray_plot(p12,olig);
p14= add_xray_plot(p13,plg);
p15= add_xray_plot(p14,pgt);
p16= add_xray_plot(p15,spl);
p17= add_xray_plot(p16,spn);
p18= add_xray_plot(p17,vrm);

% Add a legend
labels = {'Ab','Ap','Aug',...
    'Bt','Chl','En',...
    'Hbl','Kln','Lab',...
    'Mc','Mnt','Ms',...
    'Olig','Plg','Pgt',...
    'Spl','Spn','Vrm'};
L=legend(gca,labels);
L.NumColumns=3;
L.Title.String='Mineral';