% 2026 EECS 800 hw8 problem 2 phase unwrapping
%
% Simulates an interferogram phase image, wraps it, finds the phase residues,
% and then unwraps the phase with a simple row and column unwrap and with
% snaphu. The unwrapped results are compared to the known absolute phase.
%
% Image coordinate system
% * rows are the first dimension of the phase matrix (range or fast-time in
% a SAR image). There are Nt rows.
% * columns are the second dimension of the phase matrix (along-track in a
% SAR image). There are Nx columns.
% * A row gradient is the phase in the next row minus the phase in this row
% (the gradient points down in an image plot). The row gradient matrices are
% Nt-1 by Nx.
% * A column gradient is the phase in the next column minus the phase in
% this column (the gradient points right in an image plot). The column
% gradient matrices are Nt by Nx-1.
% * residues(r,c) is the sum of the wrapped gradients around the 2 by 2 loop
% of pixels with pixel (r,c) in the upper left corner. The loop order is:
% top gradient, right gradient, minus the bottom gradient, minus the left
% gradient:
%   (r,c)   -> (r,c+1)    top:    +col_grad_wrapped(r,c)
%   (r,c+1) -> (r+1,c+1)  right:  +row_grad_wrapped(r,c+1)
%   (r+1,c) -> (r+1,c+1)  bottom: -col_grad_wrapped(r+1,c)
%   (r,c)   -> (r+1,c)    left:   -row_grad_wrapped(r,c)
% The residues matrix is Nt-1 by Nx-1.
%
% Units
% * All phases, gradients, and residues are in radians divided by 2*pi
% (cycles) unless noted otherwise
% * Wrapped phases and wrapped gradients are modulo [-0.5,0.5)

%% 1. Setup

clear

my_path_dir = 'C:\git\eecs800\'; % Update this if needed
my_temp_dir = 'C:\Temp\eecs800_sar_rds\'; % Update this if needed

path(pathdef)
addpath(fullfile(my_path_dir));
addpath(fullfile(my_path_dir,'eecs800helper'));

if ~exist(my_temp_dir,'dir')
  mkdir(my_temp_dir);
end

% Seed the random number generator so that the results are the same every
% time the script is run. All random matrices must be the exact size
% specified and created in the order specified so that the results can be
% checked.
rng(0);

%% 2. Define phase image parameters

% Nt: number of rows in the phase image
Nt = 300;

% Nx: number of columns in the phase image
Nx = 300;

% signal_std: standard deviation of the signal phase (radians/(2*pi))
signal_std = 1;

% noise_std: standard deviation of the noise phase (radians/(2*pi))
noise_std = 0.1;

% snaphu_en: true to run snaphu in section 10. snaphu must be installed
% (see the lecture notes) and snaphu_path must be set.
snaphu_en = false;

% snaphu_path: path to the snaphu executable
snaphu_path = '/kucresis/scratch/dangermo/scripts/snaphu/bin/snaphu'; % Update this if needed

%% 3. Generate signal phase

% Nf_signal: size parameter of the low pass filter for the signal phase. The
% filter is Nf_signal+1 by Nf_signal+1 and Nf_signal extra pixels are
% generated on each edge of the image so that the edge effects of the filter
% can be removed.
Nf_signal = 30;

% signal_white: white Gaussian random matrix of size Nt+2*Nf_signal by
% Nx+2*Nf_signal with zero mean and a standard deviation of signal_std. Use
% a single call to the randn function and multiply it by signal_std.
% HERE

% Hfilt_signal: 2D Hanning low pass filter (Nf_signal+1 by Nf_signal+1). Use
% the hanning function twice: hanning(N) returns an N by 1 Hanning window.
% Multiply the window by its own transpose with the matrix multiply operator
% * so that the 2D filter is the outer product of the two 1D windows. Then
% normalize the filter so that the square root of the sum of the square of
% all of the 2D filter elements is 1 (divide the filter by this value). This
% ensures that the variance does not change after applying the filter.
% HERE

% signal_filt: signal_white after low pass filtering with Hfilt_signal
% (same size as signal_white). Use the filter2 function with the 'same'
% option: filter2(H,X,'same') filters X with the 2D filter H.
% HERE

% signal: signal phase (Nt by Nx). Use the colon operator to remove
% Nf_signal pixels from each of the four edges of signal_filt.
% HERE

fprintf('Signal phase std %g\n', std(signal(:)));

%% 4. Generate noise phase and absolute phase

% Nf_noise: size parameter of the low pass filter for the noise phase. Same
% as Nf_signal, but the filter is much smaller so that the noise phase has
% higher spatial frequencies than the signal phase.
Nf_noise = 3;

% noise_white: white Gaussian random matrix of size Nt+2*Nf_noise by
% Nx+2*Nf_noise with zero mean and a standard deviation of noise_std. Same
% as signal_white (use the randn function) but with noise_std and Nf_noise.
% This must be created after signal_white.
% HERE

% Hfilt_noise: 2D Hanning low pass filter (Nf_noise+1 by Nf_noise+1). Same
% as Hfilt_signal (use the hanning function and normalize) but with
% Nf_noise.
% HERE

% noise_filt: noise_white after low pass filtering with Hfilt_noise (same
% size as noise_white). Same as signal_filt (use the filter2 function).
% HERE

% noise: noise phase (Nt by Nx). Same as signal but remove Nf_noise pixels
% from each of the four edges of noise_filt.
% HERE

fprintf('Noise phase std %g\n', std(noise(:)));

% phase_unwrapped: absolute (unwrapped) phase (Nt by Nx). This is the
% correct answer that the phase unwrapping algorithms are compared to. Add
% the signal phase and the noise phase.
% HERE

%% 5. Unwrapped and wrapped phase plots in figure 1, 2

% phase_wrapped: phase_unwrapped wrapped to the interval [-0.5,0.5). This is
% the phase that a radar measures. Use the mod function: add 0.5, take the
% result modulo 1, and then subtract 0.5.
% HERE

% phase_clim: color limits used for every plot of unwrapped phase so that
% the plots can be compared
phase_clim = [min(phase_unwrapped(:)) max(phase_unwrapped(:))];

h_fig = figure(1); set(h_fig,'WindowStyle','docked'); clf;
imagesc(phase_unwrapped);
h_axes = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
clim(phase_clim);
title('Absolute phase')
xlabel('Column');
ylabel('Row');

h_fig = figure(2); set(h_fig,'WindowStyle','docked'); clf;
imagesc(phase_wrapped);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Wrapped phase')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 6. Gradients of unwrapped phase in figure 3, 4

% row_grad_unwrapped: gradient of phase_unwrapped in the row dimension
% (Nt-1 by Nx). Use the diff function: diff(X,1,DIM) is the first difference
% of X along dimension DIM.
% HERE

% col_grad_unwrapped: gradient of phase_unwrapped in the column dimension
% (Nt by Nx-1). Same as row_grad_unwrapped (use the diff function) but along
% dimension 2.
% HERE

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(row_grad_unwrapped);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Row gradient of unwrapped phase')
xlabel('Column');
ylabel('Row');

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(col_grad_unwrapped);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Column gradient of unwrapped phase')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 7. Gradients of wrapped phase modulo [-0.5,0.5) in figure 5, 6

% row_grad_wrapped: gradient of phase_wrapped in the row dimension taken
% modulo [-0.5,0.5) (Nt-1 by Nx). One vector operation: use the diff
% function on phase_wrapped the same as row_grad_unwrapped and then wrap the
% result the same as phase_wrapped (use the mod function).
% HERE

% col_grad_wrapped: gradient of phase_wrapped in the column dimension taken
% modulo [-0.5,0.5) (Nt by Nx-1). Same as row_grad_wrapped but along
% dimension 2.
% HERE

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
imagesc(row_grad_wrapped);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Row gradient of wrapped phase modulo [-0.5,0.5)')
xlabel('Column');
ylabel('Row');

h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
imagesc(col_grad_wrapped);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Column gradient of wrapped phase modulo [-0.5,0.5)')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 8. Residues in figure 7

% residues: sum of the wrapped gradients around every 2 by 2 loop of pixels
% (Nt-1 by Nx-1). Each element is -1, 0, or 1. One vector operation: use the
% colon operator to line up the four gradients of every loop and add them in
% the loop order given in the header:
%   top:    col_grad_wrapped without its last row
%   right:  row_grad_wrapped without its first column
%   bottom: col_grad_wrapped without its first row (subtract)
%   left:   row_grad_wrapped without its last column (subtract)
% Use the round function on the result to fix rounding errors.
% HERE

% pos_rows: row of each positive residue (column vector)
% pos_cols: column of each positive residue (column vector)
% Use the find function with two outputs on the logical matrix
% residues > 0. find returns the row and column of every true element.
% HERE

% neg_rows: row of each negative residue (column vector)
% neg_cols: column of each negative residue (column vector)
% Same as pos_rows and pos_cols (use the find function) but with
% residues < 0.
% HERE

fprintf('Number of residues: %d positive, %d negative\n', ...
  length(pos_rows), length(neg_rows));

h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
imagesc(residues);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Residue phase/(2*\pi)');
hold on;
h_plot = plot(pos_cols,pos_rows,'r+','MarkerSize',10,'LineWidth',1);
h_plot(2) = plot(neg_cols,neg_rows,'bo','MarkerSize',10,'LineWidth',1);
legend(h_plot,'Positive residue','Negative residue');
title('Residues')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 9. Simple unwrap in figure 8, 9

% phase_simple: phase unwrapped by unwrapping the first row of the image and
% then unwrapping each of the columns (Nt by Nx). Four steps:
% 1. Scale phase_wrapped to radians by multiplying by 2*pi since the unwrap
%    function works in radians.
% 2. Use the unwrap function on the first row and store the result back in
%    the first row.
% 3. Use the unwrap function on every column: unwrap(X,[],1) unwraps along
%    dimension 1. Each column starts from its first row element which was
%    unwrapped in step 2. Scale the result back to radians/(2*pi) by dividing
%    by 2*pi.
% 4. Phase unwrapping only finds the relative phase. Use the first pixel as
%    ground control: add phase_unwrapped(1) and subtract phase_simple(1) so
%    that the first pixel of phase_simple matches phase_unwrapped.
% HERE

% phase_simple_error: error of the simple unwrap. Subtract phase_unwrapped
% from phase_simple. Every element should be an integer since the unwrapping
% errors are whole cycles.
% HERE

fprintf('Simple unwrap: %d of %d pixels have an error\n', ...
  sum(abs(phase_simple_error(:)) > 0.5), numel(phase_simple_error));

h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
imagesc(phase_simple);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
clim(phase_clim);
title('Simple unwrap')
xlabel('Column');
ylabel('Row');

h_fig = figure(9); set(h_fig,'WindowStyle','docked'); clf;
imagesc(phase_simple_error);
h_axes(end+1) = gca;
colormap(1-gray(256));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
title('Simple unwrap error')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 10. SNAPHU unwrap in figure 10, 11

% SNAPHU: Statistical-cost, Network-flow Algorithm for Phase Unwrapping
if snaphu_en
  % fn_snaphu_in: snaphu input file name
  fn_snaphu_in = fullfile(my_temp_dir,'hw8_snaphu_in.bin');

  % fn_snaphu_out: snaphu output file name
  fn_snaphu_out = fullfile(my_temp_dir,'hw8_snaphu_out.bin');

  % snaphu_in: complex interferogram that is passed to snaphu (Nt by Nx).
  % The magnitude is 1 and the angle is phase_wrapped scaled back to radians
  % (multiply by 2*pi). Use the exp function.
  % HERE

  % snaphu_in_interleaved: snaphu_in in snaphu's COMPLEX_DATA file format
  % (2*Nt by Nx). Each complex sample is written as its real part followed
  % by its imaginary part, in the order that the samples occur in the
  % matrix (down each column).
  snaphu_in_interleaved = reshape([real(snaphu_in(:)) imag(snaphu_in(:))].', [2*Nt Nx]);

  % Write the snaphu input file as 32-bit floats
  fid = fopen(fn_snaphu_in,'wb');
  fwrite(fid,snaphu_in_interleaved,'float32');
  fclose(fid);

  % cmd_str: command that runs snaphu. The inputs are the input file name,
  % the number of rows (Nt), and the output file name.
  cmd_str = sprintf('%s %s %d -o %s', snaphu_path, fn_snaphu_in, Nt, fn_snaphu_out);
  fprintf('Running: %s\n', cmd_str);
  system(cmd_str);

  % snaphu_out: snaphu output in snaphu's ALT_LINE_DATA file format (Nt by
  % 2*Nx). The columns alternate between a column of the magnitude image and
  % a column of the unwrapped phase image (radians).
  fid = fopen(fn_snaphu_out,'rb');
  snaphu_out = fread(fid,[Nt 2*Nx],'float32');
  fclose(fid);

  % phase_snaphu: phase unwrapped by snaphu (Nt by Nx). Two steps:
  % 1. Use the colon operator to keep every second column of snaphu_out
  %    starting with column 2 (the unwrapped phase columns) and scale the
  %    result to radians/(2*pi) by dividing by 2*pi.
  % 2. Use the first pixel as ground control the same as phase_simple.
  % HERE

  % phase_snaphu_error: error of the snaphu unwrap. Subtract
  % phase_unwrapped from phase_snaphu.
  % HERE

  fprintf('SNAPHU unwrap: %d of %d pixels have an error\n', ...
    sum(abs(phase_snaphu_error(:)) > 0.5), numel(phase_snaphu_error));

  h_fig = figure(10); set(h_fig,'WindowStyle','docked'); clf;
  imagesc(phase_snaphu);
  h_axes(end+1) = gca;
  colormap(1-gray(256));
  hcolor = colorbar;
  set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
  clim(phase_clim);
  title('SNAPHU unwrap')
  xlabel('Column');
  ylabel('Row');

  h_fig = figure(11); set(h_fig,'WindowStyle','docked'); clf;
  imagesc(phase_snaphu_error);
  h_axes(end+1) = gca;
  colormap(1-gray(256));
  hcolor = colorbar;
  set(get(hcolor,'YLabel'),'String','Phase/(2*\pi)');
  title('SNAPHU unwrap error')
  xlabel('Column');
  ylabel('Row');

  linkaxes(h_axes);
end

hw8_problem2_check;
