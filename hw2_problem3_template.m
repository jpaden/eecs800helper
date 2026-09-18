% 2026 EECS 800 hw2 problem 3 time-space 1D correlation SAR processor
%
% SAR processor using time-space 1D correlation (Fourier domain pulse
% compression and sinc interpolation)
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

fn_sys = fullfile(my_temp_dir,'raw_rds_hw2.mat');
load(fn_sys); % Loads sys, img, raw, and target
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;

%% 3. SAR Processor setup

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

% Nx_img: Determine the number of output image x-axis pixels from the image
% x-extent, img.x, and the image x-spacing img.dx
% HERE

% Nr_img: Determine the number of output image range-axis pixels from the image
% slant-range-extent, img.r, and the image slant-range-spacing img.dr
% HERE

% x_img: Create the output image x-axis. This axis is parallel to the
% along-track vector. The origin is at the scene center. Use (1) the IDFT
% definition after ifftshift, (2) Nx_img, and (3) img.dx to determine the
% points.
% HERE

% r_img: Create the output image slant-range-axis. This is the "rho" axis
% in the SAR's cylindrical coordinate system where the length of the
% cylinder is parallel and centered on the along-track vector. Normally rho
% must be positive, but shift this axis so that the zero lies on the scene
% center. To determine the start/stop of this axis, use (1) the IDFT
% definition after ifftshift, (2) Nr_img, and (3) img.dr to determine the
% points.
% HERE

% y_img: Calculate the y-axis value for each point in r_img. The scene
% center is the origin, same as r_img.
% HERE

% z_img: Calculate the z-axis value for each point along r_img. The scene
% center is the origin, same as r_img.
% HERE

% time_img: Calculate the two-way travel time for each point along r_img
% for the range of closest approach (perpendicular to the flight path so at
% zero squint angle and intersecting the scene center).
% HERE

%% 4. Pulse compression

% Nt: Redefine from raw.time
Nt = length(raw.time);

% dt: Redefine from raw.time
dt = raw.time(2)-raw.time(1);

% Nx: Redefine from raw.x
Nx = length(raw.x);

% dx: Redefine from raw.x
dx = raw.x(2)-raw.x(1);

% df: frequency domain spacing (Hz)
df = 1/(Nt*dt);

% freq: baseband frequency axis (Hz). This should be a column vector since
% it is a fast-time axis. This should be ifftshift so it aligns with the
% fft output sample ordering.
% HERE

% ref_fft: FFT of the reference pulse compression waveform raw.ref (V)
% HERE

% r_ref: Range of closest approach for the range-midpoint (reference) of
% the scene. Define the range-midpoint to the beam center using the system
% altitude and inc_angle in the sys structure.
% HERE

% t_ref: Propagation time associated with r_ref
% HERE

% data_pc: pulse compression output with frequency domain window
% pc_window_fh(freq/sys.B). Include a time correction because the raw.ref
% is centered at t_ref and the raw.time axis does not start at 0.
% HERE

% time_pc: time axis associated with the pulse compression output
time_pc = raw.time;

%% 5. Time vs space image plot in figure 3

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(raw.x,time_pc*1e6,db(data_pc));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]+max(db(data_pc(:))));
title('Pulse compressed image')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

%% 6. SAR processor loop

% data_img: Preallocate image matrix (range by along-track)
% HERE

% sinc_window_length: number of range bins in the sinc interpolation filter
sinc_window_length = 11;

% sinc_window_start: how many bins before the center bin to use
sinc_window_start = floor(sinc_window_length/2);

% sinc_window_end: how many bins after the center bin to use (handles even
% filter length)
sinc_window_end = floor((sinc_window_length-1)/2);

% lambda_fc: wavelength at center frequency (m)
% HERE

% k_fc: wavenumber at the center frequency (rad/m)
% HERE

% B_kx: image wavenumber axis (angular) bandwidth at the center frequency
% determined with img.sigma_x
% HERE

% For loops through each target pixel in the image
sar_tic = tic;

for x_idx = 1:Nx_img

  for r_idx = 1:Nr_img

    % img_pos: 3x1 vector containing the position of the current image
    % pixel. Construct from x_img, y_img, and z_img.
    % HERE

    % R: Calculate the range to each radar position for this image pixel
    % HERE

    % td: Calculate the time delay to each radar position for this image
    % pixel
    % HERE

    % kx_expected: wavenumber (at the center frequency) of this image pixel
    % in order to apply the sar_window_fh
    % HERE

    % td_bins: Convert time delay to range bins (do not round the result)
    % HERE

    % H_kx: create the sar processor window from kx_expected and B_kx
    % HERE
    
    % x_mask: mask of which raw range lines will contribute to the output
    % using H_kx > 0.
    x_mask = find(H_kx > 0);

    % sinc_rbins: Create a vector of the range bins that will be required
    % for the sinc-interpolation Normally this type of SAR processor would
    % be done one range line at a time, but is slow when working on scalars
    % and small vectors so instead we will implement this like a 2D filter
    % so that we can take advantage of Matlab's efficient vector
    % operations. This extent of this 2D filter will be much smaller since
    % we have done pulse compression and will restrict to our along-track
    % window. sinc_rbins covers the range bin support for all the sinc
    % interpolation filters required for this image pixel.
    sinc_rbins = max(1,floor(min(td_bins(x_mask))-sinc_window_start)) : min(Nt,ceil(max(td_bins(x_mask))+sinc_window_end));

    % h_sinc: create the sinc-interpolation filters for every range line
    % all at once, this will be a length(sinc_rbins) by length(x_mask)
    % 2D filter, use tukeywin_cont(TIME_ARGUMENT,1) to truncate the since
    % with a Hanning window to sinc_window_length range bins
    % HERE

    % sinc_out: apply the 2D sinc interpolation filter to create a 1 by
    % length(x_mask) vector
    % HERE

    % data_img(r_idx,x_idx): write the image pixel by applying the SAR
    % phase filter and SAR window to sinc_out
    % HERE

  end
  toc_cur = toc(sar_tic);
  fprintf('Range line %d of %d (%.0f of %.0f seconds)\n', x_idx, Nx_img, toc_cur, toc_cur/x_idx*Nx_img);
end

% Store results in sar structure
sar = [];
sar.x_img = x_img;
sar.time_img = time_img;
sar.data_img = data_img;

%% 7. Prepare frequency-wavenumber axes

% dt: redefine based on sar.time_img
dt = sar.time_img(2)-sar.time_img(1);

% Nr_img: redefine based on sar.time_img
Nr_img = length(sar.time_img);

% df: frequency spacing of the fast-time DFT of the SAR image based on dt
% and Nt_img
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

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(sar.x_img,sar.time_img*1e6,db(sar.data_img));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% caxis([-30 0]);
title('SAR data time-space')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
imagesc(fftshift(kx_img),fftshift(freq_img)/1e6,db(fftshift(fft2(sar.data_img))));
set(gca,'ydir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% caxis([-30 0]);
title('SAR data freq-kx')
xlabel('Along-track wavenumber k_x (rad/m)');
ylabel('Frequency (MHz)');

%% 9. Save SAR image

fn_raw = fullfile(sys.temp_dir,'sar_rds_hw2_problem3.mat');
save(fn_raw,'sar','sys','img','-v7.3','-nocompression');

%% 10. Oversampled range-cut and along-track-cut plots for each target

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
  interp_window = kaiser(2*Ninterp+1,2.5);

  % target_alongtrack: along-track target position relative to the scene
  % center
  target_alongtrack = target.pos(1,t_idx)

  % closest_rline: find the range line index that is closest to the
  % target's x-position, target.pos(1,t_idx)
  [~,closest_rline] = min(abs(x_img - target_alongtrack));

  % interp_input_rlines: create a vector of the range lines that will be
  % input to the sinc_window resampling (these lines can extend before 1
  % and after Nx_img as we will use a mask, good_mask_rlines, to select the valid
  % lines)
  interp_input_rlines = closest_rline+(-Ninterp:Ninterp);

  % good_mask_rlines: create a logical vector aligned with interp_input_rlines
  % that is true where the range lines are in [1,Nx_img]
  good_mask_rlines = interp_input_rlines >= 1 & interp_input_rlines <= Nx_img;

  % sinc_window: create the along-track sinc-window sampled at the existing
  % positions and peak centered on the desired target position
  sinc_window = sinc( ( x_img(interp_input_rlines(good_mask_rlines)) - target.pos(1,t_idx) ) / 1 );

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

  [~,max_idx] = max(range_cut_Mt);
  target_range_imaged = range_img_Mt(max_idx)

  h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
  plot(range_img_Mt,db(range_cut_Mt));
  ylim(max(db(range_cut_Mt)) + [-70 0]);
  grid on;
  title('Range-cut amplitude (dB)')
  xlabel('Range (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(9); set(h_fig,'WindowStyle','docked'); clf;
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

  % good_mask_rbins: create a logical vector aligned with interp_input_rlines
  % that is true where the range lines are in [1,Nr_img]
  good_mask_rbins = interp_input_rbins >= 1 & interp_input_rbins <= Nr_img;

  % sinc_window: create the along-track sinc-window sampled at the existing
  % positions and peak centered on the desired target position
  sinc_window = sinc( ( r_img(interp_input_rbins(good_mask_rbins)) - target_range ) / 1 );

  % along_track_cut: Resample in range at the particular target r-position for the
  % along-track-cut
  along_track_cut =  sum(sinc_window .* sar.data_img(interp_input_rbins(good_mask_rbins),:), 1);

  % along_track_cut_Mx: Oversample the range-cut by Mx
  along_track_cut_Mx = interpft(along_track_cut,Nx_img*Mx);

  % x_img_Mx: Oversample the sar.x_img x-axis by Mx to align with the
  % output of interpft
  % HERE

  [~,max_idx] = max(along_track_cut_Mx);
  target_alongtrack_imaged = x_img_Mx(max_idx)

  h_fig = figure(10); set(h_fig,'WindowStyle','docked'); clf;
  plot(x_img_Mx,db(along_track_cut_Mx));
  ylim(max(db(along_track_cut_Mx)) + [-70 0]);
  grid on;
  title('Along-track-cut amplitude (dB)')
  xlabel('Along-track (m)');
  ylabel('Relative power (dB)');

  h_fig = figure(11); set(h_fig,'WindowStyle','docked'); clf;
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

hw2_problem3_check;