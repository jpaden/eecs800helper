% 2026 EECS 800 hw5 problem 1 f-k migration SAR processor
%
% SAR processor using f-k migration SAR processor
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

fn_sys = fullfile(my_temp_dir,'raw_rds_hw3.mat');
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

% lambda_fc: wavelength at center frequency (m)
lambda_fc = c/sys.fc;

% r_ref: Range of closest approach for the range-midpoint (reference) of
% the scene. Define the range-midpoint to the beam center using the system
% altitude and inc_angle in the sys structure.
% HERE

% t_ref: Propagation time associated with r_ref
% HERE

% df: frequency domain spacing (Hz)
% HERE

% freq: baseband frequency axis (Hz). This should be a column vector since
% it is a fast-time axis. This should be ifftshift so it aligns with the
% fft output sample ordering.
% HERE

% dkx: wavenumber domain spacing (rad/m)
% HERE

% kx: wavenumber (spatial angular frequency) axis (rad/m). This should be a
% row vector since it is a slow-time axis. This should be ifftshift so
% it aligns with the fft output sample ordering.
% HERE

% deta: Define slow-time step size from dx and sys.vel.
% HERE

% df_eta: doppler frequency domain spacing (Hz)
% HERE

% f_eta: doppler frequency axis, eta is slow time variable (Hz). This
% should be a row vector since it is a slow-time axis. This should be
% ifftshift so it aligns with the fft output sample ordering.
% HERE

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

%% 4. Step 1. Two dimensional FFT

% data_fk: fft2 of the raw.data
% HERE

%% 5. Step 2. Reference function multiply (range compression and migration to scene center)

% D: cosine of the instantaneous squint angle
% HERE

% H_pc: define the bulk 2D compression filter
% * Very important note: the 2D compression filter removes all time delay
% to time zero. The next step requires that time zero be associated with
% the first bin in the discrete time domain (otherwise the math does not
% work out). We accomplish this by shifting our data so that time zero is
% in the first bin. Note that data_fk has raw.time(1) being in the first
% bin so this is the amount you need to shift by so that time zero is in
% the first bin. Use the Fourier time shift property in your H_pc filter to
% time-shift time zero to the first bin.
% HERE

% data_pc: apply bulk 2D compression filter H_pc to data_fk
% HERE

%% 6. Step 3. Stolt interpolation along range frequency axis (map uniform k sampling to uniform ky sampling)

% data_pc_fftshift: fftshift the frequency axis of data_pc to make the
% interpolation equations easier
% HERE

% freq_fftshift: fftshift the frequency axis, freq, to make the
% interpolation equations easier
% HERE

% D_fftshift: fftshift D to make the interpolation equations easier
% HERE

% fy_fftshift: matrix of spatial frequency (scaled for time so that ky =
% 4*pi*fy/c) values corresponding to each entry in data_pc
% HERE

% min_fy, max_fy: Observe fy_fftshift to determine the minimum and maximum
% values that will be fully supported at every along-track Doppler
% frequency
% min_fy HERE
% max_fy HERE

% dfy: Choose dfy to match the smallest step size in fy_fftshift
% HERE

% fy_out_fftshift: Create sorted and uniformly sampled fy axis from
% min_fy, max_fy, and dfy. Since sorted axes implies fftshift, the variable
% name indicates that.
% HERE

% Ninterp: set the size of the sinc-interpolation window
Ninterp = 5;

% interp_window: Define the sinc interpolation window
interp_window = kaiser(2*Ninterp+1,2.5);

% data_stolt_fftshift: Initialize data_stolt to match the desired output fy_out_fftshift
% HERE

% Loop through each Doppler bin
sar_tic = tic;
toc_cur = toc(sar_tic);
for eta_idx = 1:length(f_eta)
  % freq_out: the baseband freq_fftshift values that we need to sample to for this
  % particular Doppler frequency, f_eta(eta_idx), (these are the ones
  % corresponding to each of the fy_out_fftshift values). Remember, the data are
  % uniformly sampled on "freq_fftshift". We need to sample to the desired
  % "freq_out" values that correspond to the uniform fy_out_fftshift axis. freq_out
  % should be the same size as fy_out_fftshift.
  % HERE

  % bin_offset: Vector containing the closest index/bin (rounded) in freq_fftshift
  % to each freq_out value. Make this zero-indexed (i.e. not one-indexed
  % like matlab normally is). bin_offset should be the same size as
  % freq_out. This will be used to determine the center index of the values
  % from data_pc_fftshift that will contribute to the interpolation.
  % HERE

  % bin_frac: Determine the fractional offset from each of these rounded
  % bins to the desired freq_out value. bin_frac should satisfy:
  % * -0.5 <= bin_frac < 0.5. bin_frac should be the same size as
  % freq_out. This will be used to adjust the sinc evaluation so that the
  % peak of the sinc lies on the desired fy_out_fftshift value that we are
  % interpolating to.
  % HERE

  % Interpolate to fy_out_fftshift
  for f_idx = 1:length(fy_out_fftshift)
    % rbin_rng: normally -Ninterp:Ninterp except on the edges where there
    % is incomplete sample support (i.e. <1 and >Nt)
    % HERE

    % data_stolt_fftshift(f_idx,eta_idx): interpolate data_pc_fftshift to
    % the desired fy_out_fftshift(f_idx) using sinc interpolation with the
    % interp_window
    % HERE
  end

  if toc(sar_tic) > toc_cur + 1
    toc_cur = toc(sar_tic);
    fprintf('Range line %d of %d (%.0f of %.0f seconds)\n', eta_idx, Nx, toc_cur, toc_cur/eta_idx*Nx);
  end
end

% fy_out: ifftshift the fy_out_fftshift axis along the range frequency
% dimension
% HERE

% data_stolt: ifftshift the data_stolt_fftshift matrix along the range
% frequency dimension
% HERE

%% 7. Step 3b. Pulse compression and azimuth windows

% B_kx: image wavenumber axis (angular) bandwidth at the center frequency
% determined with img.sigma_x
% HERE

% H_kx: create the sar processor window from kx and B_kx
% HERE

% data_stolt_window: apply pulse compression window (center the window on
% fy_out's center frequency and use sys.B for the width) and apply the
% azimuth window
% HERE

%% 8. Step 4. Two dimensional IFFT

% data_img_ifftshift: take ifft2 of data_stolt_window, ifftshift in name
% because in the time domain the IDFT is centered on the scene center (sort
% of like being complex baseband in time as mentioned earlier)
% HERE

%% 9. Extra Step. Create the time-axis

% Recall from the math in step 3, that the output y-axis is relative to
% r_ref which is different than all the other SAR algorithms. Since this
% places the center of the range-domain at time bin 0, let's compute this
% new axis and then do fftshift([],1).

% Nt: length of the fast-time, y, dimension
% HERE

% fs_y: sampling rate of fy axis
% HERE

% dt: time step along y-axis is the inverse of the sampling rate of the fy
% axis
% HERE

% time_img: compute the time axis just like we normally do with the
% frequency axis. The first bin is at the scene center time, t_ref. Then
% create time axis centered on this point (use the floor(...):floor(...)
% method that handles even/odd lengths properly.
% HERE

% data_img: fftshift the data_img_ifftshift axis along the range frequency
% dimension to match the sorted time_img axis
% HERE

% Store results in sar structure
sar = [];
sar.x_img = raw.x;
sar.time_img = time_img;
sar.data_img = data_img;

% r_img: Create the relative r_img range axis whose origin is at the center of the
% scene (this is not the center of the image, just the origin)
r_img = c/2 * (sar.time_img - t_ref);

%% 10. Prepare frequency-wavenumber axes

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

%% 11. Plot time-space and freq-kx image

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(sar.x_img,sar.time_img*1e6,db(sar.data_img));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data time-space')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(fftshift(kx_img),fftshift(freq_img)/1e6,db(fftshift(fft2(sar.data_img))));
set(gca,'ydir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data freq-kx')
xlabel('Along-track wavenumber k_x (rad/m)');
ylabel('Frequency (MHz)');

%% 12. Save SAR image

fn_raw = fullfile(sys.temp_dir,'sar_rds_hw5_problem1.mat');
save(fn_raw,'sar','sys','img','-v7.3','-nocompression');

%% 13. Oversampled range-cut and along-track-cut plots for each target

for t_idx = 1:size(target.pos,2)

  % =======================================================================
  % Range cut (single range line through target)
  % - uses sinc interpolation to cut directly through the target even when
  %   the target is not aligned with an image pixel
  % =======================================================================

  % Mt: Oversample rate in fast-time
  Mt = 10;

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
  % positions and peak centered on the desired target position. Component-wise
  % multiply by the interp_window to truncate the sinc-window
  sinc_window = sinc( ( sar.x_img(interp_input_rlines(good_mask_rlines)) - target.pos(1,t_idx) ) / img.dx ) ...
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

  h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
  plot(range_img_Mt,db(range_cut_Mt));
  ylim(max(db(range_cut_Mt)) + [-70 0]);
  grid on;
  title('Range-cut amplitude (dB)')
  xlabel('Range (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
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
  Mx = 10;

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
  % positions and peak centered on the desired target position. Component-wise
  % multiply by the interp_window to truncate the sinc-window
  sinc_window = sinc( ( r_img(interp_input_rbins(good_mask_rbins)) - target_range ) / img.dr ) ...
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

  h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
  plot(x_img_Mx,db(along_track_cut_Mx));
  ylim(max(db(along_track_cut_Mx)) + [-70 0]);
  grid on;
  title('Along-track-cut amplitude (dB)')
  xlabel('Along-track (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
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

hw5_problem1_check;
