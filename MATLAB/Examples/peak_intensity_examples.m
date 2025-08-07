%% Import spectral data for various reference minerals, and subtract the Bremsstrahlung radiation from each
ab   = subtract_background( read_msa('albite.msa') );
ap   = subtract_background( read_msa('apatite.msa') );
aug  = subtract_background( read_msa('augite.msa') );
bt   = subtract_background( read_msa('biotite.msa') );
chl  = subtract_background( read_msa('chlorite.msa') );
en   = subtract_background( read_msa('enstatite.msa') );
hbl  = subtract_background( read_msa('hornblende.msa') );
kln  = subtract_background( read_msa('kaolinite.msa') );
lab  = subtract_background( read_msa('labradorite.msa') );
mc   = subtract_background( read_msa('microcline.msa') );
mnt  = subtract_background( read_msa('montmorillonite.msa') );
ms   = subtract_background( read_msa('muscovite.msa') );
olig = subtract_background( read_msa('oligoclase.msa') );
plg  = subtract_background( read_msa('palygorskite.msa') );
pgt  = subtract_background( read_msa('pigeonite.msa') );
spn  = subtract_background( read_msa('sphene.msa') );
spl  = subtract_background( read_msa('spinel.msa') );
vrm  = subtract_background( read_msa('vermiculite.msa') );

%% Evaluate the peak intensities for the mineral-forming elements and identify the corresponding mineral
weber_classification(peak_intensity(ab))
weber_classification(peak_intensity(ap))
weber_classification(peak_intensity(aug))
weber_classification(peak_intensity(bt))
weber_classification(peak_intensity(chl))
weber_classification(peak_intensity(en))
weber_classification(peak_intensity(hbl))
weber_classification(peak_intensity(kln))
weber_classification(peak_intensity(lab))
weber_classification(peak_intensity(mc))
weber_classification(peak_intensity(mnt))
weber_classification(peak_intensity(ms))
weber_classification(peak_intensity(olig))
weber_classification(peak_intensity(plg))
weber_classification(peak_intensity(pgt))
weber_classification(peak_intensity(spn))
weber_classification(peak_intensity(spl))
weber_classification(peak_intensity(vrm))