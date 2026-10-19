% 2026 EECS 800 hw4 problem 1 chirp scaling algorithm SAR processor
%
% SAR processor using chirp scaling algorithm (CSA) SAR processor
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

% time_pc: time axis associated with the pulse compression output
% HERE

% range_pc: create a range axis associated with the pulse compression time
% axis, time_pc
% HERE

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

%% 4. Step 1. Azimuth FFT

% data_afft: azimuth FFT of raw data
% HERE

%% 5. Step 2. Chirp Scaling

% D: cosine of the instantaneous squint angle
% HERE

% D_ref: D at the reference Doppler
% HERE

% Km: modified chirp rate
% HERE

% data_cs: chirp scaled data in range-Doppler domain
% HERE

%% 6. Step 3. Range FFT

% data_cs_fft: chirp-scaled data in the frequency-Doppler domain
% HERE

%% 7. Step 4. Secondary Phase Function (range compression + SRC, bulk RCMC)

% Km_ref: modified chirp rate at the reference range
% HERE

% data_pc_fk: data pulse compressed in f-k domain. Several operations get
% applied here:
% * secondary phase function which does range compression, secondary range
% compression, and bulk RCMC
% * apply the pulse compression window for sidelobe suppression,
% pc_window_fh
% HERE

%% 8. Step 5. Range IFFT

% data_pc: pulse compressed data in the range-Doppler domain
% HERE

%% 9. Step 6. Azimuth compression (with phase correction)

% B_kx: image wavenumber axis (angular) bandwidth at the center frequency
% determined with img.sigma_x
% HERE

% H_kx: create the sar processor window from kx and B_kx
% HERE

% data_img_afft: SAR image in the range-Doppler domain. The azimuth
% compression is applied at this step.
% HERE

%% 10. Step 7. Azimuth IFFT

% data_img: take the azimuth IFFT of data_img_afft
% HERE

% Store results in sar structure
sar = [];
sar.x_img = raw.x;
sar.time_img = time_pc;
sar.data_img = data_img;

% r_img: Create the relative r_img range axis whose origin is at the center of the
% scene (this is not the center of the image, just the origin)
r_img = c/2 * (sar.time_img - t_ref);

%% 11. Prepare frequency-wavenumber axes

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

%% 12. Plot time-space and freq-kx image

h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
imagesc(sar.x_img,sar.time_img*1e6,db(sar.data_img));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data time-space')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

h_fig = figure(9); set(h_fig,'WindowStyle','docked'); clf;
imagesc(fftshift(kx_img),fftshift(freq_img)/1e6,db(fftshift(fft2(sar.data_img))));
set(gca,'ydir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% clim([-30 0]);
title('SAR data freq-kx')
xlabel('Along-track wavenumber k_x (rad/m)');
ylabel('Frequency (MHz)');

%% 13. Save SAR image

fn_raw = fullfile(sys.temp_dir,'sar_rds_hw4_problem1.mat');
save(fn_raw,'sar','sys','img','-v7.3','-nocompression');

%% 14. Oversampled range-cut and along-track-cut plots for each target

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

  h_fig = figure(10); set(h_fig,'WindowStyle','docked'); clf;
  plot(range_img_Mt,db(range_cut_Mt));
  ylim(max(db(range_cut_Mt)) + [-70 0]);
  grid on;
  title('Range-cut amplitude (dB)')
  xlabel('Range (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(11); set(h_fig,'WindowStyle','docked'); clf;
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

  h_fig = figure(12); set(h_fig,'WindowStyle','docked'); clf;
  plot(x_img_Mx,db(along_track_cut_Mx));
  ylim(max(db(along_track_cut_Mx)) + [-70 0]);
  grid on;
  title('Along-track-cut amplitude (dB)')
  xlabel('Along-track (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(13); set(h_fig,'WindowStyle','docked'); clf;
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

hw4_problem1_check;
