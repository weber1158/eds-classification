function plt2 = add_xray_plot(plt,new)
%Add a new spectrum to an xray plot on a normalized y-axis
%
%Syntax
% plt2 = ADD_XRAY_PLOT(plt,new)
%
%
%Inputs
% plt {axis handle} :: Handle to an open xray plot
% new {table OR text} :: Either a table produced by the read_msa() function
%                        or the name of a spectral file (e.g., 'file.msa')
%
%
%Output
% plt2 {axis handle} :: Axis handle for editing the plot after compilation
%
%
%Example
% f1 = xray_plot('file1.msa');
% f2 = ADD_XRAY_PLOT('file2.msa');
% legend('File1','File2')
%
%
% See also
%  xray_plot, xray_peak_label, clear_xray_labels, read_msa

% Copyright 2025 Austin M. Weber

  % Input parsing
  if ~strcmp(class(plt),'matlab.graphics.chart.primitive.Area')
    error('First input must be an axes handle to an xray plot object.')
  end
  if isstring(new) || ischar(new)
    newchar = char(new);
    if ~strcmp('msa',newchar(end-2:end))
      new2 = [newchar '.msa'];
      if ~exist(new2,"file")
        error(['The file ''' new2 ''' does not exist on the search path.'])
      end
    else
      if ~exist(newchar,"file")
        error(['The file ''' newchar ''' does not exist on the search path.'])
      end
    end
  elseif ~istable(new)
    error('Second input must be a file name (e.g., ''file1.msa'') or a table of x-ray energies produced from the read_msa() function.')
  end

  % Normalize the original data
  normalize_xray_plot(plt)

  % Add the new data, also normalized
  hold on
   plt2 = xray_plot(new);
   normalize_xray_plot(plt2);
  hold off
  
  % Increase transparency of the area plots
  idealAlpha = 0.1;
  pltAlpha = plt.FaceAlpha;
  plt2Alpha = plt2.FaceAlpha;
  if pltAlpha > idealAlpha
    plt.FaceAlpha = idealAlpha;
  end
  if plt2Alpha > idealAlpha
    plt2.FaceAlpha = idealAlpha;
  end
end

function normalize_xray_plot(plt)
  % Extract spectral data
  counts = plt.YData;
  % Normalization
  counts_norm = normalize(counts,'Range',[0 1]);
  % Reassign YData
  plt.YData = counts_norm;
  % Adjust axes limits
  ylim([0 1])
  % Clear labels
  clear_xray_labels(plt)
end