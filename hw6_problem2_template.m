% 2026 EECS 800 hw6 problem 2 polar format algorithm SAR processor
%
% SAR processor using the polar format algorithm
%
% Slow-time (SAR) coordinate system
% * x is along-track (assumed straight and level flight path)
% * z is elevation projected on the plane that is orthogonal to the
% along-track (points to the zenith for straight and level flight paths)
% * y completes the right handed coordinate system (so points left)
% * [x,y,z].' origin is at the image/scene center (aka image reference
% point) so that [x,y,z] points from the image/scene center to the radar
% positions
% * eta is slow-time axis and should be aligned with the x-axis. Origin at
% scene center.
%
% Fast-time coordinate system
% * time is fast-time axis with its origin as the center of the transmit
% pulse when it is transmitted
% * range is the fast-time range axis and should be aligned with the time
% axis with origin at the radar's position
%
% Units
% * Always use SI units
% * Exceptions are allowed, but variable names storing non-SI units should
% end in the unit type (e.g. "_deg" if not using radians)

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

% pc_window_fh: Pulse compression frequency-domain window function handle
pc_window_fh = @(freq_norm) tukeywin_cont(freq_norm,0);

% sar_window_fh: SAR processing wavenumber-domain window function handle
sar_window_fh = @(kx_norm) tukeywin_cont(kx_norm,0);

%% 2. Load raw data parameters

fn_sys = fullfile(my_temp_dir,'raw_snow_hw6.mat');
load(fn_sys); % Loads sys, img, raw, and target
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;

%% 3. SAR Processor Setup

% Nt: Redefine from raw.time
Nt = length(raw.time);

% dt: Redefine from raw.time
dt = raw.time(2)-raw.time(1);

% Nx: Redefine from raw.x
Nx = length(raw.x);

% dx: Redefine from raw.x
dx = raw.x(2)-raw.x(1);

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

%% 4. Step 1. Uniform sampling in ky

% Ninterp: set the size of the sinc-interpolation window
Ninterp = 5;

% interp_window: Define the sinc interpolation window
interp_window = kaiser(2*Ninterp+1,2.5);

% elev_ang_c: Calculate the instantaneous elevation angle for each radar
% position to the scene center
% HERE

% squint_ang_c: Calculate the instantaneous squint angle for each radar
% position to the scene center
% HERE

% freq_rf: Calculate the RF frequency associated with a target at the scene
% center for each row of raw.data. Use sys.fc and the chirp rate to
% determine this.
% HERE

% k_fc: Calculate the wavenumber for each point in freq_rf
% HERE

% kx: Calculate the kx wavenumbers for each squint angle for a target at
% the scene center. Note that this kx vector tells you the rate of phase
% change w.r.t the x-dimension for a particular squint angle/along-track
% position.
% HERE

% ky: Calculate the ky wavenumbers for each squint angle for a target at
% the scene center. Note that this ky vector tells you the rate of phase
% change w.r.t the y-dimension for a particular squint angle/along-track
% position. To help determine the correct sign consider the following. The
% radar's location is at positive y, the scene center is at y-position 0.
% Therefore, moving the radar towards increasing y increases the distance
% from the target. Increasing range (which results in increasing time
% delay) results in a more negative phase because our signal model has a
% negative sign for the carrier phase delay term.
% 
% IMPORTANT: This is for 2D SAR, so ky is the same as k_range or the
% wavenumber for the range and the image is being formed in the slant
% plane. Therefore, the y-axis used in this code does NOT represent the "y"
% axis. It represents the "range" axis.
% HERE

% Observe the ky matrix to determine how to calculate the minimum and
% maximum ky values that will be fully supported at every along-track
% position.
h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
contour(ky,50);
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','k_y (rad/m)');
title('k_y');
xlabel('Column index');
ylabel('Row index');
subplot(1,2,2);
plot(ky([1 end],:).');
grid on
xlabel('Column index');
ylabel('k_y (rad/m)');
legend('First row','Last row','location','east');
xlim([1 size(ky,2)])

% start_ky: Calculate the start of the output ky axis. This will be the
% side of ky which has the smallest absolute value. Note that ky is
% negative in our case so decreases down each column, so the smallest
% absolute value is the first-row values. Use the ky figure to help.
% HERE

% stop_ky: Calculate the stop of the output ky axis. This will be the side
% of ky which has the largest absolute value. Note that ky is negative in
% our case so decreases down each column, so the largest absolute value is
% the last-row values. Use the ky figure to help.
% HERE

% dky: Choose dky to match the ky step size in the column corresponding to
% the smallest absolute step size. Note that dky is negative, so be mindful
% of checking for the smallest abs() step size while also preserving the
% sign of the step size.
% HERE

% ky_out_fftshift: Create sorted (may be increasing or decreasing depending
% on dky) and uniformly sampled ky axis from start_ky, stop_ky, and dky. Since
% sorted axes implies fftshift, the variable name indicates that. This axis
% is not adjusted to be a multiple of anything so start_ky should be the
% first value. This is the row-dimension axis so it should be a column
% vector.
% HERE

% kx_ky_out_fftshift: Recompute the kx axis at each of the new
% ky_out_fftshift samples. Note that squint_ang_c has not changed since the
% interpolation is along constant squint_ang_c lines. Use the definitions
% of kx and ky above to determine the equation for kx_ky_out_fftshift based
% on the ky_out_fftshift values.
% HERE

% Ny_image: number of rows in the ky-interpolated output
Ny_image = length(ky_out_fftshift);

% data_ky_fftshift: preallocate the output matrix
data_ky_fftshift = complex(zeros(Ny_image,Nx));

% Loop through each azimuth-frequency column
for rline = 1:Nx
  % dky_rline: Calculate the ky step size for this range line
  % HERE

  % Loop through each output range-frequency row
  for rbin = 1:Ny_image

    % bin_exact: Calculate the 1-indexed index value for the new
    % ky_out_fftshift(rbin) referenced to the old axis. This is the exact
    % bin with no rounding (so the index will not be a whole number)
    % HERE

    % bin_offset: round bin_exact
    % HERE

    % bin_frac: compute the bin fraction between bin_exact and bin_offset
    % so that bin_exact = bin_offset + bin_frac
    % HERE

    % bin_rng: Create the relative range bin vector to apply the sinc
    % interpolation on. This will nominally be -Ninterp:Ninterp, but
    % shorten it as required to prevent it from grabbing samples outside
    % the raw.data matrix (i.e. before 1 and after size(raw.data,1)).
    % HERE

    % data_ky_fftshift(rbin,rline): Perform sinc interpolation on raw.data
    % to find the value at ky_out_fftshift(rbin)
    % HERE
  end
end

%% 5. Step 2. Uniform sampling in kx

% Ninterp: set the size of the sinc-interpolation window
Ninterp = 5;

% interp_window: Define the sinc interpolation window
interp_window = kaiser(2*Ninterp+1,2.5).';

% Observe the kx matrix to determine how to calculate the minimum and
% maximum kx values that will be fully supported in every row
h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
contour(kx_ky_out_fftshift,20);
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','k_x (rad/m)');
title('k_x');
xlabel('Column index');
ylabel('Row index');
subplot(1,2,2);
plot(kx_ky_out_fftshift(:,[1 end]));
grid on
xlabel('Row index');
ylabel('k_x (rad/m)');
legend('First column','Last column','location','east');
xlim([1 size(kx_ky_out_fftshift,1)])

% start_kx: Calculate the smallest kx value that is supported by every
% range-frequency row. Use the kx figure to help.
% HERE

% stop_kx: Calculate the largest kx value that is supported by every
% range-frequency row. Use the kx figure to help.
% HERE

% dkx: Choose dkx to match the step size in kx_ky_out_fftshift which
% corresponds to the smallest absolute step size.
% HERE

% kx_out_fftshift: Create sorted and uniformly sampled kx axis from start_kx,
% stop_kx, and dkx. Since sorted axes implies fftshift, the variable name
% indicates that. This axis is not adjusted to be a multiple of anything so
% start_kx should be the first value. This is the column-dimension axis so
% it should be a row vector.
% HERE

% Nx_image: number of columns in the kx-interpolated output
% HERE

% data_kx_fftshift: preallocate the output matrix
% HERE

% Loop through each range-frequency row
for rbin = 1:Ny_image
  % dkx_rbin: Calculate the kx step size from kx_ky_out_fftshift for this
  % range-frequency row
  % HERE

  % Loop through each output azimuth-frequency column
  for rline = 1:Nx_image
    % bin_exact: Calculate the 1-indexed index value for the new
    % kx_out_fftshift(rline) referenced to the old axis. This is the exact
    % bin with no rounding (so the index will not be a whole number)
    % HERE

    % bin_offset: round bin_exact
    % HERE

    % bin_frac: compute the bin fraction between bin_exact and bin_offset
    % so that bin_exact = bin_offset + bin_frac
    % HERE

    % bin_rng: Create the relative range bin vector to apply the sinc
    % interpolation on. This will nominally be -Ninterp:Ninterp, but
    % shorten it as required to prevent it from grabbing samples outside
    % the data_ky_fftshift matrix (i.e. before 1 and after
    % size(data_ky_fftshift,2)).
    % HERE

    % data_kx_fftshift(rbin,rline): Perform sinc interpolation on
    % data_ky_fftshift to find the value at kx_out_fftshift(rline)
    % HERE
  end
end

%% 6. Step 3. Fast and slow-time windows, two dimensional IFFT

% Compute axes for output SAR image

% BW_kx: Using Nx_image and dkx, calculate the wavenumber-x sampling
% bandwidth of the output image column axis
% HERE

% BW_ky: Using Ny_image and dky, calculate the wavenumber-y sampling
% bandwidth of the output image row axis
% HERE

% kx_out: ifftshift the kx_out_fftshift axis
kx_out = ifftshift(kx_out_fftshift);

% ky_out: ifftshift the ky_out_fftshift axis
ky_out = ifftshift(ky_out_fftshift);

% data_kx: ifftshift the data_kx_fftshift matrix, data_kx is in standard
% complex baseband form now
% HERE

% kx_c: grab the center kx value from the kx_out axis
% HERE

% ky_c: grab the center ky value from the ky_out axis
% HERE

% data_window: window the data_kx matrix with pc_window_fh (row-dimension)
% and sar_window_fh (column-dimension). Center the windows on kx_c and
% ky_c and set their bandwidths equal to 2*pi/img.sigma_x and 2*pi/img.sigma_r.
% HERE

% data_img: convert the 2D frequency domain data_window into the space
% domain and fftshift the result so that the axes are sorted
% HERE

% dx: Determine the along-track/column sample spacing of data_img
% HERE

% dy: Determine the range/row sample spacing of data_img
% HERE

% x: Create an x-axis (column-dimension) for data_img. Use Nx_image, dx,
% and set the origin to be the scene center. Note that because of the
% deramp operation, the polar format algorithm makes the spatial-zero value
% after ifft to be the scene center.
% HERE

% y: Create a range-axis (row-dimension) for data_img. Use Ny_image, dy,
% and set the origin to be the scene center. Note that because of the
% deramp operation, the polar format algorithm makes the spatial-zero value
% after ifft to be the scene center.
% HERE

% sar_phase_center: Calculate the measurement phase center. Calculate this
% as the mean of the aperture positions.
% HERE

% t_ref: Calculate the time delay to the scene center from the relative
% measurement phase center. Remember that the scene center is the origin of
% our coordinate system.
% HERE

% time_img: Create a time axis using the range (y) dimension and t_ref.
% This will represent the time delay from the measurement phase center to
% each row of the SAR image along the column containing the scene center.
% HERE

% Store results in sar structure
sar = [];
sar.x_img = x;
sar.time_img = time_img;
sar.data_img = data_img;

% r_img: Create the relative r_img range axis whose origin is at the center of the
% scene (this is not the center of the image, just the origin)
r_img = c/2 * (sar.time_img - t_ref);

%% 7. Prepare frequency-wavenumber axes

% dt: redefine based on sar.time_img
dt = sar.time_img(2)-sar.time_img(1);

% Nr_img: redefine based on sar.time_img
Nr_img = length(sar.time_img);

% df: frequency spacing of the fast-time DFT of the SAR image based on dt
% and Nr_img
% HERE

% freq_img: image frequency axis
% HERE

% dx: redefine based on sar.x_img
dx = sar.x_img(2)-sar.x_img(1);

% Nx_img: redefine based on sar.x_img
Nx_img = length(sar.x_img);

% dkx: wavenumber spacing of the along-track DFT of the SAR image based on
% dx and Nx_img
% HERE

% kx_img: image wavenumber axis
% HERE

%% 8. Plot time-space and freq-kx image

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
imagesc(sar.x_img,sar.time_img*1e6,db(sar.data_img));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data time-space')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
imagesc(fftshift(kx_img),fftshift(freq_img)/1e6,db(fftshift(fft2(sar.data_img))));
set(gca,'ydir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data freq-kx')
xlabel('Along-track wavenumber k_x (rad/m)');
ylabel('Frequency (MHz)');

%% 9. Save SAR image

fn_raw = fullfile(sys.temp_dir,'sar_snow_hw6_problem2.mat');
save(fn_raw,'sar','sys','img','-v7.3','-nocompression');

%% 10. Oversampled range-cut and along-track-cut plots for each target

for t_idx = 1:size(target.pos,2)

  % =======================================================================
  % Range cut (single range line through target)
  % - uses sinc interpolation to cut directly through the target even when
  %   the target is not aligned with an image pixel
  % =======================================================================

  % Mt: Oversample rate in fast-time
  Mt = 20;

  % Ninterp: Set interpolation window size for resampling target cuts
  Ninterp = 5;

  % interp_window: Create the window for the resampling target cuts
  interp_window = kaiser(2*Ninterp+1,2.5).';

  % target_alongtrack: along-track target position relative to the scene
  % center
  target_alongtrack = target.pos(1,t_idx)

  % closest_rline: find the range line index that is closest to the
  % target's x-position, target.pos(1,t_idx)
  [~,closest_rline] = min(abs(sar.x_img - target_alongtrack));

  % interp_input_rlines: create a vector of the range lines that will be
  % input to the sinc_window resampling (these lines can extend before 1
  % and after Nx_img as we will use a mask, good_mask_rlines, to select the valid
  % lines)
  interp_input_rlines = closest_rline+(-Ninterp:Ninterp);

  % good_mask_rlines: create a logical vector aligned with interp_input_rlines
  % that is true where the range lines are in [1,Nx_img]
  good_mask_rlines = interp_input_rlines >= 1 & interp_input_rlines <= Nx_img;

  % sinc_window: create the along-track sinc-window sampled at the existing
  % positions and peak centered on the desired target position. The sinc
  % period must be the image pixel spacing, dx, so that the zero crossings
  % land on the neighboring pixels. Component-wise multiply by the
  % interp_window to truncate the sinc-window
  sinc_window = sinc( ( sar.x_img(interp_input_rlines(good_mask_rlines)) - target.pos(1,t_idx) ) / dx ) ...
    .* interp_window(good_mask_rlines);

  % range_cut: Resample in along-track at the particular target x-position for the
  % range-cut
  range_cut =  sum(sinc_window .* sar.data_img(:,interp_input_rlines(good_mask_rlines)), 2);

  % range_cut_Mt: Oversample the range-cut by Mt
  range_cut_Mt = interpft(range_cut,Nr_img*Mt);

  % time_img_Mt: Oversample the sar.time_img time-axis by a factor of Mt to
  % align with the results of interpft
  % HERE

  % range_img_Mt: Create an oversampled range axis aligned with time_img_Mt
  % that has its origin at the scene center
  % HERE

  % max_idx: Find the index of the maximum value in range_cut_Mt
  [~,max_idx] = max(range_cut_Mt);

  % target_range_imaged: Determine the range position of the target in the image
  target_range_imaged = range_img_Mt(max_idx)

  h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
  plot(range_img_Mt,db(range_cut_Mt));
  ylim(max(db(range_cut_Mt)) + [-70 0]);
  grid on;
  title('Range-cut amplitude (dB)')
  xlabel('Range (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
  plot(range_img_Mt,angle(range_cut_Mt)*180/pi);
  grid on;
  title('Range-cut phase')
  xlabel('Range (m)');
  ylabel('Phase (deg)');

  % =======================================================================
  % Along-track cut (single range bin through target)
  % - uses sinc interpolation to cut directly through the target even when
  %   the target is not aligned with an image pixel
  % =======================================================================

  % Mx: Oversample rate in along-track
  Mx = 20;

  % Ninterp: Set interpolation window size for resampling target cuts
  Ninterp = 5;

  % interp_window: Create the window for the resampling target cuts
  interp_window = kaiser(2*Ninterp+1,2.5);
  %interp_window = rectwin(2*Ninterp+1);

  % yc: y-offset of radar to scene center
  yc = sys.altitude * tan(sys.inc_angle);

  % zc: z-offset of radar to scene center
  zc = sys.altitude;

  % target_range: determine the target's range position relative to the
  % scene center. Note that the target's coordinates in target.pos are
  % relative to the scene center.
  target_range = vecnorm([yc;zc]-target.pos([2 3],t_idx),2,1) - vecnorm([yc;zc],2,1)

  % closest_rbin: find the range bin index that is closest to the
  % target's range-position using r_img (which is relative to the scene
  % center)
  [~,closest_rbin] = min(abs(r_img - target_range));

  % interp_input_rbins: create a vector of the range bins that will be
  % input to the sinc_window resampling (these bins can extend before 1
  % and after Nr_img as we will use a mask, good_mask_rbins, to select the valid
  % lines)
  interp_input_rbins = closest_rbin+(-Ninterp:Ninterp);

  % good_mask_rbins: create a logical vector aligned with interp_input_rbins
  % that is true where the range bins are in [1,Nr_img]
  good_mask_rbins = interp_input_rbins >= 1 & interp_input_rbins <= Nr_img;

  % sinc_window: create the range sinc-window sampled at the existing range
  % positions and peak centered on the desired target position. The sinc
  % period must be the image pixel spacing in range, c/2*dt, so that the zero
  % crossings land on the neighboring pixels. Component-wise multiply by the
  % interp_window to truncate the sinc-window
  sinc_window = sinc( ( r_img(interp_input_rbins(good_mask_rbins)) - target_range ) / (c/2*dt) ) ...
    .* interp_window(good_mask_rbins);

  % along_track_cut: Resample in range at the particular target r-position for the
  % along-track-cut
  along_track_cut =  sum(sinc_window .* sar.data_img(interp_input_rbins(good_mask_rbins),:), 1);

  % along_track_cut_Mx: Oversample the along-track-cut by Mx
  along_track_cut_Mx = interpft(along_track_cut,Nx_img*Mx);

  % x_img_Mx: Oversample the sar.x_img x-axis by Mx to align with the
  % output of interpft
  % HERE

  % max_idx: Find the index of the maximum value in along_track_cut_Mx
  [~,max_idx] = max(along_track_cut_Mx);
  % target_alongtrack_imaged: Determine the x position of the target in the image
  target_alongtrack_imaged = x_img_Mx(max_idx)

  h_fig = figure(9); set(h_fig,'WindowStyle','docked'); clf;
  plot(x_img_Mx,db(along_track_cut_Mx));
  ylim(max(db(along_track_cut_Mx)) + [-70 0]);
  grid on;
  title('Along-track-cut amplitude (dB)')
  xlabel('Along-track (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(10); set(h_fig,'WindowStyle','docked'); clf;
  plot(x_img_Mx,angle(along_track_cut_Mx)*180/pi);
  grid on;
  title('Along-track-cut phase')
  xlabel('Along-track (m)');
  ylabel('Phase (deg)');

  if t_idx < size(target.pos,2)
    fprintf('Pausing before displaying the results for the next target.\n')
    fprintf('Press any key to continue.\n')
    pause
  end
end

% hw6_problem2_check;
