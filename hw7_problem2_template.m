% 2026 EECS 800 hw7 problem 2 coregistration
%
% Coregisters a secondary image to a primary image. The misregistration is
% estimated with cross correlation on the full image and then on a grid of
% tiles. The tile offsets are interpolated to every pixel and the secondary
% image is resampled with 2D sinc interpolation onto the primary image's
% pixel grid.
%
% This script only requires raw.primary_img, raw.secondary_img, img.Nr, and
% img.Nc from the file fn_raw so it can be used to coregister other image
% pairs by changing fn_raw. The truth structure is only used to print the
% error of the estimated offsets when it is present.
%
% Image coordinate system
% * rows are the first dimension of the image matrix (range in a SAR image)
% * columns are the second dimension of the image matrix (along-track in a
% SAR image)
% * The secondary image is the primary image shifted by shift_row rows and
% shift_col columns so that:
%   secondary_img(r,c) = primary_img(r + shift_row, c + shift_col)
% A positive shift_row moves the image content up (toward smaller row
% indices) and a positive shift_col moves the image content left (toward
% smaller column indices).
% * lag_row and lag_col are the estimates of shift_row and shift_col. The
% cross correlation peaks where the secondary image equals the primary
% image delayed by the lag so the lag axes are negated to get lag_row and
% lag_col.
% * The resampled secondary image is:
%   secondary_img_resampled(r,c) = secondary_img(r - lag_row, c - lag_col)
%
% Units
% * All shifts, lags, and offsets are in units of pixels (rows or columns)
% * Powers are relative (unitless)

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

physical_constants; % Loads c, Boltzmann's constant, e0, u0, etc.

%% 2. Load simulated data

fn_raw = fullfile(my_temp_dir,'raw_coregistration_hw7.mat');
load(fn_raw); % Loads raw, img, and truth

%% 3. Coregistration setup

% Nr_guard: number of rows on the top and bottom borders of the image that
% are excluded from the coregistered output image so that the search tiles
% and the misregistration search offsets stay inside the image and away
% from the edge artifacts of the simulator
Nr_guard = 50;

% Nc_guard: number of columns on the left and right borders of the image
% that are excluded from the coregistered output image
Nc_guard = 50;

% rows_out: rows of raw.primary_img that are in the coregistered output
% image
rows_out = 1+Nr_guard : img.Nr-Nr_guard;

% cols_out: columns of raw.primary_img that are in the coregistered output
% image
cols_out = 1+Nc_guard : img.Nc-Nc_guard;

% Nr: number of rows in the coregistered output image
Nr = length(rows_out);

% Nc: number of columns in the coregistered output image
Nc = length(cols_out);

% primary_img_all: full primary image used for estimating the offsets
primary_img_all = raw.primary_img;

% secondary_img_all: full secondary image used for estimating the offsets
secondary_img_all = raw.secondary_img;

if 0
  % Optional power detection of the images before estimating the offsets
  primary_img_all = abs(primary_img_all).^2;
  secondary_img_all = abs(secondary_img_all).^2;
end

% primary_img: output region of the primary image
primary_img = primary_img_all(rows_out,cols_out);

% secondary_img: output region of the secondary image
secondary_img = secondary_img_all(rows_out,cols_out);

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(cols_out,rows_out,db(primary_img));
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Primary image')
xlabel('Column');
ylabel('Row');

subplot(1,2,2);
imagesc(cols_out,rows_out,db(secondary_img));
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Secondary image')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 4. Full-image cross correlation

% xcorr_all: cross correlation of primary_img and secondary_img computed in
% the frequency domain. No zero padding is used so the cross correlation is
% circular, but the misregistration is small compared to the image size
% so the wrap-around only affects the edges of the cross correlation.
% Use the fft2 function on both images and the conj function on the
% primary image's FFT. Multiply them element by element with the .*
% operator and then use the ifft2 function on the product. The conjugate
% must be on the primary image to match the sign convention in the header.
% HERE

% f_row: cross correlation row-lag axis (pixels) in the standard FFT order
% (zero lag first). Column vector of length Nr. Same as f_row in
% hw7_problem1 (use the ifftshift function) but without dividing by Nr
% since the lag is in pixels.
% Element 1 is lag 0, element 2 is lag 1, and the last element is lag -1.
% HERE

% f_col: cross correlation column-lag axis (pixels) in the standard FFT
% order (zero lag first). Row vector of length Nc. Same as f_row but with
% Nc and without the transpose.
% HERE

% max_vals: maximum value in each column of xcorr_all
% max_rows: row index of the maximum value in each column of xcorr_all
% Use the max function on xcorr_all with two outputs. max works down each
% column and compares the magnitudes of complex values.
% HERE

% max_val: maximum value of xcorr_all
% max_col: column index of the maximum value of xcorr_all
% Use the max function on max_vals with two outputs.
% HERE

% max_row: row index of the maximum value of xcorr_all. This is the
% element of max_rows in the column of the peak (max_col).
% HERE

% lag_row: estimated row shift of the secondary image relative to the
% primary image (pixels). Negate f_row at max_row (see the header for the
% sign convention).
% HERE

% lag_col: estimated column shift of the secondary image relative to the
% primary image (pixels). Negate f_col at max_col.
% HERE

h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(fftshift(f_col),fftshift(f_row),fftshift(db(xcorr_all)));
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Cross correlation')
xlabel('Column lag');
ylabel('Row lag');

%% 5. Full-image oversampled cross correlation

% Mr: oversampling factor in the row dimension
Mr = 4;

% Mc: oversampling factor in the column dimension
Mc = 4;

% Nr_M: number of rows in the oversampled cross correlation
Nr_M = Nr*Mr;

% Nc_M: number of columns in the oversampled cross correlation
Nc_M = Nc*Mc;

% f_row_M: oversampled cross correlation row-lag axis (pixels) in the
% standard FFT order. Column vector of length Nr_M. Same as f_row but with
% Nr_M elements spaced by 1/Mr pixels (use the ifftshift function).
% HERE

% f_col_M: oversampled cross correlation column-lag axis (pixels) in the
% standard FFT order. Row vector of length Nc_M. Same as f_col but with
% Nc_M elements spaced by 1/Mc pixels (use the ifftshift function).
% HERE

% xcorr_all_M: oversample xcorr_all by Mr in the row dimension and by Mc
% in the column dimension. Use the interpft function twice:
% interpft(X,N,DIM) resamples X to N samples along dimension DIM. First
% resample along dimension 1 to get Nr_M rows and then resample that
% result along dimension 2 to get Nc_M columns.
% HERE

% max_vals: maximum value in each column of xcorr_all_M
% max_rows: row index of the maximum value in each column of xcorr_all_M
% Same as section 4 (use the max function) but with xcorr_all_M.
% HERE

% max_val: maximum value of xcorr_all_M
% max_col: column index of the maximum value of xcorr_all_M
% HERE

% max_row: row index of the maximum value of xcorr_all_M
% HERE

% lag_row: estimated row shift from the oversampled cross correlation.
% Negate f_row_M at max_row.
% HERE

% lag_col: estimated column shift from the oversampled cross correlation.
% Negate f_col_M at max_col.
% HERE

subplot(1,2,2);
imagesc(fftshift(f_col_M),fftshift(f_row_M),fftshift(db(xcorr_all_M)));
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Oversampled cross correlation')
xlabel('Column lag');
ylabel('Row lag');

linkaxes(h_axes);

%% 6. Full-image polynomial peak fit

% Find x that is a least squares fit to the data centered on the peak at
% max_row,max_col:
% db(xcorr_all_M(max_row+R,max_col+C)) = x(1) + x(2)*C + x(3)*R + x(4)*R*C
%   + x(5)*C^2 + x(6)*R^2

% rel_rows: rows relative to the peak used in the fit
rel_rows = -2:2;

% rel_cols: columns relative to the peak used in the fit
rel_cols = -2:2;

% A: least squares model matrix, one row per fit pixel:
%   [1 C R R*C C^2 R^2]
A = [];

% b: log-power detected cross correlation value at each fit pixel
b = [];

for rel_col = rel_cols
  for rel_row = rel_rows
    % A(end+1,:): Add another row to the end of A. The row is
    % [1 C R R*C C^2 R^2] with C = rel_col and R = rel_row.
    % HERE

    % b(end+1,1): Add another row to the end of b. Use the db function on
    % xcorr_all_M at row max_row + rel_row and column max_col + rel_col.
    % HERE
  end
end

% x: Use the pinv function on A to calculate the least squares solution of
% A*x = b for the polynomial coefficients (6 by 1)
% HERE

% The polynomial x(1) + x(2)*C + x(3)*R + x(4)*R*C + x(5)*C^2 + x(6)*R^2 is
% used to represent a 5x5 square of log-power detected (run db.m on the
% data) data centered on the peak lag where C is the column index relative
% to the peak (which should be in entry (3,3) in your square data matrix),
% and R is the row index relative to the peak. Solve this polynomial for
% its stationary point and use the R and C values to determine the peak.
% Set the partial derivatives of the polynomial with respect to R and C to
% zero. This gives two linear equations in R and C. Solve them for R and C
% in terms of x(2) through x(6).

% max_rel_row: This is the "R" from your derivation. It is the row of the
% stationary point of the polynomial fit relative to the peak (oversampled
% pixels)
% HERE

% max_rel_col: This is the "C" from your derivation. It is the column of
% the stationary point of the polynomial fit relative to the peak
% (oversampled pixels). You may use max_rel_row in this expression.
% HERE

% lag_row: correct the estimated row shift with the relative row offset.
% max_rel_row is in oversampled pixels so divide it by Mr to convert it to
% pixels. The lag is the negated lag axis (see the header) so subtract this
% correction from lag_row.
% HERE

% lag_col: correct the estimated column shift with the relative column
% offset. Same as lag_row but with max_rel_col and Mc.
% HERE

if exist('truth','var')
  fprintf('Full-image lag_row error: %g pixels\n', lag_row - truth.shift_row);
  fprintf('Full-image lag_col error: %g pixels\n', lag_col - truth.shift_col);
end

% b_est: polynomial fit evaluated at each fit pixel
b_est = [];

for rel_col = rel_cols
  for rel_row = rel_rows
    % A has already been created and never changes so we do not need to
    % make it again!

    % b_est(end+1,1): Add another row to the end of b_est. The row is the
    % polynomial evaluated at R = rel_row and C = rel_col. Multiply the same
    % row vector that was added to A by x.
    % HERE
  end
end

h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(rel_cols,rel_rows,reshape(b,[length(rel_rows) length(rel_cols)]));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Cross correlation peak actual')
xlabel('Relative column');
ylabel('Relative row');

subplot(1,2,2);
imagesc(rel_cols,rel_rows,reshape(b_est,[length(rel_rows) length(rel_cols)]));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Cross correlation peak fit')
xlabel('Relative column');
ylabel('Relative row');

%% 7. Tile-based cross correlation

% Nr_tile: tile size in rows (should be odd so the tile center is a pixel)
Nr_tile = 31;

% Nc_tile: tile size in columns (should be odd so the tile center is a
% pixel)
Nc_tile = 31;

% Nr_tile_step: spacing between the start rows of neighboring tiles
Nr_tile_step = 7;

% Nc_tile_step: spacing between the start columns of neighboring tiles
Nc_tile_step = 7;

% Nr_offsets: [min max] row misregistration search range (pixels) of the
% secondary image relative to the primary image
Nr_offsets = [-7 6];

% Nc_offsets: [min max] column misregistration search range (pixels) of
% the secondary image relative to the primary image
Nc_offsets = [-7 6];

% Nr_zero: number of rows in the zero padded tiles. Zero padding prevents
% circular convolution problems. (This is more than necessary, but
% efficiency was not the main priority here.)
Nr_zero = 2*(Nr_tile + diff(Nr_offsets));

% Nc_zero: number of columns in the zero padded tiles
Nc_zero = 2*(Nc_tile + diff(Nc_offsets));

% Nr_0_list: start row of each tile in the primary image. The tile
% centers span rows_out. Column vector.
Nr_0_list = ( rows_out(1) : Nr_tile_step : rows_out(end) ).' - (Nr_tile-1)/2;

% Nc_0_list: start column of each tile in the primary image. The tile
% centers span cols_out. Row vector.
Nc_0_list = ( cols_out(1) : Nc_tile_step : cols_out(end) ) - (Nc_tile-1)/2;

% rows_tile: row of the center of each tile. The offset estimated for
% each tile is assigned to the tile center.
rows_tile = Nr_0_list + (Nr_tile-1)/2;

% cols_tile: column of the center of each tile
cols_tile = Nc_0_list + (Nc_tile-1)/2;

% Nr_search: number of row lags to search through in the cross
% correlation (only the valid offsets)
Nr_search = diff(Nr_offsets);

% Nc_search: number of column lags to search through in the cross
% correlation (only the valid offsets)
Nc_search = diff(Nc_offsets);

% Nr_zero_M: number of rows in the oversampled tile cross correlation
Nr_zero_M = Nr_zero*Mr;

% Nc_zero_M: number of columns in the oversampled tile cross correlation
Nc_zero_M = Nc_zero*Mc;

% f_row_tile: tile cross correlation row-lag axis (pixels). The secondary
% tile starts Nr_offsets(1) rows before the primary tile so the first
% row of the cross correlation corresponds to a lag of Nr_offsets(1).
% Column vector of length Nr_zero. Make the standard FFT-order lag axis of
% length Nr_zero (same as f_row in section 4) and add Nr_offsets(1).
% HERE

% f_col_tile: tile cross correlation column-lag axis (pixels). Row vector
% of length Nc_zero. Same as f_row_tile but with Nc_zero and Nc_offsets(1)
% and without the transpose.
% HERE

% f_row_tile_M: oversampled tile cross correlation row-lag axis (pixels).
% Column vector of length Nr_zero_M. Same as f_row_M in section 5 but with
% Nr_zero_M elements, then add Nr_offsets(1).
% HERE

% f_col_tile_M: oversampled tile cross correlation column-lag axis
% (pixels). Row vector of length Nc_zero_M. Same as f_col_M in section 5
% but with Nc_zero_M elements, then add Nc_offsets(1).
% HERE

% row_offsets: preallocate the estimated row offset for each tile. Each
% inner loop iteration fills one element. Use zeros with one row per tile
% row and one column per tile column. Use the zeros function and the
% length function on Nr_0_list and Nc_0_list.
% HERE

% col_offsets: preallocate the estimated column offset for each tile. Each
% inner loop iteration fills one element. Same size as row_offsets (use
% the zeros function).
% HERE

% Loop through each of the tiles
for Nc_0_idx = 1:length(Nc_0_list) % Each column of tiles
  % Nc_0: start column of this tile
  Nc_0 = Nc_0_list(Nc_0_idx);

  for Nr_0_idx = 1:length(Nr_0_list) % Each row of tiles in this column
    % Nr_0: start row of this tile
    Nr_0 = Nr_0_list(Nr_0_idx);

    % =====================================================================
    % Extract the primary and secondary tiles
    % =====================================================================

    % primary_tile: zero padded primary tile. The primary tile is placed in
    % the upper left corner so that the cross correlation peak for the
    % primary tile's location in the secondary tile lands in the upper left
    % corner of the cross correlation.
    primary_tile = zeros(Nr_zero,Nc_zero);

    % rows: rows of the primary image in this tile
    rows = Nr_0 + (0:Nr_tile-1);

    % cols: columns of the primary image in this tile
    cols = Nc_0 + (0:Nc_tile-1);

    primary_tile(1:Nr_tile,1:Nc_tile) = primary_img_all(rows,cols);

    % secondary_tile: zero padded secondary tile. The secondary tile is
    % extended by the search offsets on each side of the primary tile's
    % location.
    secondary_tile = zeros(Nr_zero,Nc_zero);

    % rows: rows of the secondary image in this tile
    rows = Nr_0 + (Nr_offsets(1) : Nr_tile-1+Nr_offsets(2));

    % cols: columns of the secondary image in this tile
    cols = Nc_0 + (Nc_offsets(1) : Nc_tile-1+Nc_offsets(2));

    secondary_tile(1:Nr_tile+diff(Nr_offsets),1:Nc_tile+diff(Nc_offsets)) = secondary_img_all(rows,cols);

    % Plot the tiles on the first iteration
    if Nr_0_idx == 1 && Nc_0_idx == 1
      h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
      subplot(1,2,1);
      imagesc(db(primary_tile));
      h_axes = gca;
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      title('Primary tile')
      xlabel('Column');
      ylabel('Row');

      subplot(1,2,2);
      imagesc(db(secondary_tile));
      h_axes(2) = gca;
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      title('Secondary tile')
      xlabel('Column');
      ylabel('Row');

      linkaxes(h_axes);
    end

    % =====================================================================
    % Cross correlation (same as section 4)
    % =====================================================================

    % xcorr_tile: cross correlation of primary_tile and secondary_tile
    % computed in the frequency domain. The zero padding prevents
    % wrap-around. Same as xcorr_all in section 4 (use the fft2, conj, and
    % ifft2 functions) but with primary_tile and secondary_tile.
    % HERE

    % max_vals: maximum value in each column of the searched region of
    % xcorr_tile
    % max_rows: row index of the maximum value in each column
    % Use the max function with two outputs. The searched region is the
    % first Nr_search rows and the first Nc_search columns of xcorr_tile.
    % These are the lags allowed by Nr_offsets and Nc_offsets.
    % HERE

    % max_val: maximum value of the searched region of xcorr_tile
    % max_col: column index of the maximum value
    % Use the max function on max_vals with two outputs.
    % HERE

    % max_row: row index of the maximum value
    % HERE

    % lag_row: estimated row shift of the secondary tile relative to the
    % primary tile (pixels). Negate f_row_tile at max_row.
    % HERE

    % lag_col: estimated column shift of the secondary tile relative to the
    % primary tile (pixels). Negate f_col_tile at max_col.
    % HERE

    if Nr_0_idx == 1 && Nc_0_idx == 1
      % Print the lags for the first tile
      lag_row = -f_row_tile(max_row)
      lag_col = -f_col_tile(max_col)

      h_fig = figure(9); set(h_fig,'WindowStyle','docked'); clf;
      subplot(1,2,1);
      imagesc(f_col_tile(1:Nc_search),f_row_tile(1:Nr_search), ...
        db(xcorr_tile(1:Nr_search,1:Nc_search)) - db(max_val));
      h_axes = gca;
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      clim([-30 0]);
      title('Tile cross correlation')
      xlabel('Column lag');
      ylabel('Row lag');
    end

    % =====================================================================
    % Oversampled cross correlation (same as section 5)
    % =====================================================================

    % xcorr_tile_M: oversample xcorr_tile by Mr in the row dimension and
    % by Mc in the column dimension. Use the interpft function twice, the
    % same as section 5, but with Nr_zero_M rows and Nc_zero_M columns.
    % HERE

    % max_vals: maximum value in each column of the searched region of
    % xcorr_tile_M
    % max_rows: row index of the maximum value in each column
    % Use the max function with two outputs. The searched region is the
    % first Nr_search*Mr rows and the first Nc_search*Mc columns of
    % xcorr_tile_M.
    % HERE

    % max_val: maximum value of the searched region of xcorr_tile_M
    % max_col: column index of the maximum value
    % Use the max function on max_vals with two outputs.
    % HERE

    % max_row: row index of the maximum value
    % HERE

    % lag_row: estimated row shift from the oversampled cross correlation.
    % Negate f_row_tile_M at max_row.
    % HERE

    % lag_col: estimated column shift from the oversampled cross
    % correlation. Negate f_col_tile_M at max_col.
    % HERE

    if Nr_0_idx == 1 && Nc_0_idx == 1
      % Print the lags for the first tile
      lag_row = -f_row_tile_M(max_row)
      lag_col = -f_col_tile_M(max_col)

      subplot(1,2,2);
      imagesc(f_col_tile_M(1:Nc_search*Mc),f_row_tile_M(1:Nr_search*Mr), ...
        db(xcorr_tile_M(1:Nr_search*Mr,1:Nc_search*Mc)) - db(max_val));
      h_axes(2) = gca;
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      clim([-30 0]);
      title('Oversampled tile cross correlation')
      xlabel('Column lag');
      ylabel('Row lag');

      linkaxes(h_axes);
    end

    % =====================================================================
    % Polynomial peak fit (same as section 6)
    % =====================================================================

    % b: log-power detected cross correlation value at each fit pixel
    b = [];

    for rel_col = rel_cols
      for rel_row = rel_rows
        % b(end+1,1): Add another row to the end of b. Same as section 6
        % (use the db function) but with xcorr_tile_M.
        % HERE
      end
    end

    % x: use the pinv function to compute the least squares solution for
    % the polynomial coefficients. A from section 6 is reused.
    % HERE

    % max_rel_row: row of the stationary point of the polynomial fit
    % relative to the peak (oversampled pixels). Same equation as before.
    % HERE

    % max_rel_col: column of the stationary point of the polynomial fit
    % relative to the peak (oversampled pixels). Same equation as before.
    % HERE

    % row_offsets(Nr_0_idx,Nc_0_idx): add the relative row offset to the
    % estimated row shift and store the result for this tile. Same
    % correction as lag_row in section 6.
    % HERE

    % col_offsets(Nr_0_idx,Nc_0_idx): add the relative column offset to the
    % estimated column shift and store the result for this tile. Same
    % correction as lag_col in section 6.
    % HERE

    if Nr_0_idx == 1 && Nc_0_idx == 1
      % Print the lags for the first tile
      lag_row = row_offsets(Nr_0_idx,Nc_0_idx)
      lag_col = col_offsets(Nr_0_idx,Nc_0_idx)

      % b_est: polynomial fit evaluated at each fit pixel
      b_est = [];

      for rel_col = rel_cols
        for rel_row = rel_rows
          % A has already been created and never changes so we do not need to
          % make it again!

          % b_est(end+1,1): Add another row to the end of b_est. Same as
          % section 6.
          % HERE
        end
      end

      h_fig = figure(10); set(h_fig,'WindowStyle','docked'); clf;
      subplot(1,2,1);
      imagesc(rel_cols,rel_rows,reshape(b,[length(rel_rows) length(rel_cols)]));
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      title('Tile cross correlation peak actual')
      xlabel('Relative column');
      ylabel('Relative row');

      subplot(1,2,2);
      imagesc(rel_cols,rel_rows,reshape(b_est,[length(rel_rows) length(rel_cols)]));
      hcolor = colorbar;
      set(get(hcolor,'YLabel'),'String','Relative power (dB)');
      title('Tile cross correlation peak fit')
      xlabel('Relative column');
      ylabel('Relative row');
      hold on;
      h_plot = plot(max_rel_col, max_rel_row,'x','MarkerSize',15,'LineWidth',2);
      legend(h_plot, 'Peak from quadratic fit stationary point');
    end

  end
end

if exist('truth','var')
  fprintf('Tile row_offsets error: mean %g, max abs %g pixels\n', ...
    mean(row_offsets(:) - truth.shift_row), max(abs(row_offsets(:) - truth.shift_row)));
  fprintf('Tile col_offsets error: mean %g, max abs %g pixels\n', ...
    mean(col_offsets(:) - truth.shift_col), max(abs(col_offsets(:) - truth.shift_col)));
end

h_fig = figure(11); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(cols_tile,rows_tile,row_offsets);
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Offset (rows)');
title('Tile row offsets')
xlabel('Column');
ylabel('Row');

subplot(1,2,2);
imagesc(cols_tile,rows_tile,col_offsets);
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Offset (columns)');
title('Tile column offsets')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 8. Interpolate tile offsets to every pixel

% row_offsets_filt: median filter the tile row offsets with a 3 by 3
% window to remove outliers from tiles with a bad cross correlation peak.
% Use the medfilt2 function with a [3 3] window and the 'symmetric' option
% so that the edge tiles are padded with mirrored values instead of zeros.
% HERE

% col_offsets_filt: median filter the tile column offsets with a 3 by 3
% window to remove outliers from tiles with a bad cross correlation peak.
% Same as row_offsets_filt (use the medfilt2 function) but with
% col_offsets.
% HERE

% row_mesh: row of the center of each tile for every element of
% row_offsets_filt (same size as row_offsets_filt)
% col_mesh: column of the center of each tile for every element of
% col_offsets_filt (same size as col_offsets_filt)
[col_mesh,row_mesh] = meshgrid(cols_tile,rows_tile);

% Frow: scatteredInterpolant for the row offsets with natural neighbor
% interpolation and linear extrapolation. Use the scatteredInterpolant
% function with five inputs: the row of each sample point (row_mesh(:)),
% the column of each sample point (col_mesh(:)), the value at each sample
% point (row_offsets_filt(:)), the interpolation method 'natural', and the
% extrapolation method 'linear'. The (:) turns each matrix into a column
% vector.
% HERE

% Fcol: scatteredInterpolant for the column offsets with natural neighbor
% interpolation and linear extrapolation. Same as Frow (use the
% scatteredInterpolant function) but with col_offsets_filt.
% HERE

% row_mesh: row of every pixel in the output image (Nr by Nc)
% col_mesh: column of every pixel in the output image (Nr by Nc)
[col_mesh,row_mesh] = meshgrid(cols_out,rows_out);

% row_offset_full: interpolated row offset for every pixel in the output
% image (Nr by Nc). A scatteredInterpolant is called like a function: pass
% Frow the row_mesh and col_mesh matrices as its two inputs and it returns
% the interpolated value at each point.
% HERE

% col_offset_full: interpolated column offset for every pixel in the
% output image (Nr by Nc). Same as row_offset_full but call Fcol.
% HERE

h_fig = figure(12); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(cols_out,rows_out,row_offset_full);
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Offset (rows)');
title('Row offsets interpolated')
xlabel('Column');
ylabel('Row');

subplot(1,2,2);
imagesc(cols_out,rows_out,col_offset_full);
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Offset (columns)');
title('Column offsets interpolated')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 9. Resample secondary image

% secondary_img_resampled: preallocate the coregistered secondary image (Nr
% by Nc). The complex raw.secondary_img is resampled (not the power detected
% secondary_img_all) so that the output can be used for interferometry.
secondary_img_resampled = complex(zeros(Nr,Nc));

% Nr_sinc: half-width of the sinc interpolation kernel in rows. The kernel
% has 2*Nr_sinc+1 rows.
Nr_sinc = 4;

% Nc_sinc: half-width of the sinc interpolation kernel in columns. The
% kernel has 2*Nc_sinc+1 columns.
Nc_sinc = 4;

% Hwind: 2D Kaiser window that truncates the sinc interpolation kernel
% ((2*Nr_sinc+1) by (2*Nc_sinc+1)). Use the kaiser function twice:
% kaiser(N,beta) returns an N by 1 Kaiser window. Use beta = 2.5 for both.
% Multiply the row-dimension window (2*Nr_sinc+1 by 1) by the transpose of
% the column-dimension window (2*Nc_sinc+1 by 1) with the matrix multiply
% operator * so that the 2D window is the outer product of the two 1D
% windows.
% HERE

% Iterate through every pixel in the resampled image
for col_idx = 1:Nc
  % col: column of raw.secondary_img for output column col_idx
  col = cols_out(col_idx);

  for row_idx = 1:Nr
    % row: row of raw.secondary_img for output row row_idx
    row = rows_out(row_idx);

    % row_off: coregistration row offset for this pixel
    row_off = row_offset_full(row_idx,col_idx);

    % col_off: coregistration column offset for this pixel
    col_off = col_offset_full(row_idx,col_idx);

    % row_center: integer part of the row offset
    row_center = round(row_off);

    % row_frac: fractional part of the row offset so that
    % row_off = row_center + row_frac
    row_frac = row_off - row_center;

    % col_center: integer part of the column offset
    col_center = round(col_off);

    % col_frac: fractional part of the column offset so that
    % col_off = col_center + col_frac
    col_frac = col_off - col_center;

    % secondary_img_resampled(row_idx,col_idx): 2D sinc interpolation of
    % raw.secondary_img at the non-integer secondary image position
    % (p_row, p_col) = (row - row_off, col - col_off)
    %
    % 1D sinc interpolation: a Nyquist sampled signal s(n) that is only
    % known at the integer samples n can be evaluated at any non-integer
    % position p with
    %   s(p) = sum over n of s(n) * sinc(p - n)
    % The sinc is 1 when n = p and decays away from p so only the samples
    % near p matter. Keep only the 2*Nr_sinc+1 nearest samples
    %   n = round(p) + k for k = -Nr_sinc:Nr_sinc
    % and multiply each term by a window to reduce the error caused by
    % truncating the sum.
    %
    % 2D sinc interpolation: the 2D sinc kernel is separable, so it is the
    % product of a row sinc and a column sinc:
    %   s(p_row,p_col) = sum over k_row and k_col of
    %     s(n_row,n_col) * Hwind(k_row,k_col)
    %       * sinc(p_row - n_row) * sinc(p_col - n_col)
    % where n_row = round(p_row) + k_row = row - row_center + k_row and
    % n_col = round(p_col) + k_col = col - col_center + k_col.
    %
    % Steps for this pixel:
    % 1. Use the colon operator to extract the (2*Nr_sinc+1) by
    %    (2*Nc_sinc+1) block of neighbors s(n_row,n_col) from
    %    raw.secondary_img with rows row - row_center + (-Nr_sinc:Nr_sinc)
    %    and columns col - col_center + (-Nc_sinc:Nc_sinc).
    % 2. Use the sinc function to make the row weights as a column vector.
    %    p_row - n_row = -(row_frac + k_row) and the sinc is symmetric, so
    %    the row weights are the sinc of row_frac + (-Nr_sinc:Nr_sinc).'
    %    Make the column weights as a row vector the same way with
    %    col_frac and (-Nc_sinc:Nc_sinc).
    % 3. Multiply the block of neighbors, Hwind, the row weights, and the
    %    column weights element by element with the .* operator. The column
    %    vector and the row vector expand automatically to the block size.
    % 4. Use the sum function to add up every element.
    % HERE

  end
end

%% 10. Save coregistered output

coreg = [];
coreg.rows = rows_out;
coreg.cols = cols_out;
coreg.primary_img = raw.primary_img(rows_out,cols_out);
coreg.secondary_img = secondary_img_resampled;
coreg.row_offsets = row_offset_full;
coreg.col_offsets = col_offset_full;

fn_coreg = fullfile(my_temp_dir,'coreg_speckle_hw7_problem2.mat');
save(fn_coreg,'coreg','img','-v7.3','-nocompression');

%% 11. Primary and coregistered secondary image plots in figure 13, 14

h_fig = figure(13); set(h_fig,'WindowStyle','docked'); clf;
imagesc(coreg.cols,coreg.rows,db(coreg.primary_img));
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Primary image')
xlabel('Column');
ylabel('Row');

h_fig = figure(14); set(h_fig,'WindowStyle','docked'); clf;
imagesc(coreg.cols,coreg.rows,db(coreg.secondary_img));
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Coregistered secondary image')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 12. Interferogram phase plot in figure 15

% The secondary image is a shifted copy of the primary image so the phase
% of the interferogram should be close to zero everywhere if the
% coregistration worked.
h_fig = figure(15); set(h_fig,'WindowStyle','docked'); clf;
imagesc(coreg.cols,coreg.rows,angle(coreg.primary_img .* conj(coreg.secondary_img)));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase (rad)');
clim([-pi pi]);
title('Interferogram phase')
xlabel('Column');
ylabel('Row');

hw7_problem2_check;
