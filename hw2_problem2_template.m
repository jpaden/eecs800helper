% 2026 EECS 800 hw2 problem 2 time-space 2D correlation SAR processor
%
% SAR processor using time-space 2D correlation (brute force)
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

% pc_window_fh: Fast time time-domain window function handle
pc_window_fh = @(time_norm) tukeywin_cont(time_norm,0);

% sar_window_fh: Slow time azimuth-angle-domain window function handle
sar_window_fh = @(time_norm) tukeywin_cont(time_norm,0);

%% 2. Load raw data parameters

fn_sys = fullfile(my_temp_dir,'raw_rds_hw2.mat');
load(fn_sys); % Loads sys, img, raw, and target
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
img.x = img.x/4;
img.r = img.r/4;

%% 3. SAR Processor loop

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

% Double check that SAR is right-looking, SAR image is in slant-plane and
% centered on the origin, and the target is at the origin.
h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
[x_img_mesh,y_img_mesh] = meshgrid(x_img,y_img);
[x_img_mesh,z_img_mesh] = meshgrid(x_img,z_img);
subplot(1,2,1);
h_plot_img = plot3(x_img_mesh(:),y_img_mesh(:),z_img_mesh(:),'c.');
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
grid on;
hold on;
h_plot_radar = plot3(raw.x,raw.y,raw.z,'b');
h_plot_radar_start = plot3(raw.x(1),raw.y(1),raw.z(1),'bo');
h_plot_target = plot3(target.pos(1),target.pos(2),target.pos(3),'rx','linewidth',4);
h_plot_target_current = plot3(NaN,NaN,NaN,'bx','linewidth',4);
legend([h_plot_img h_plot_radar h_plot_radar_start h_plot_target],'SAR image','Radar','Radar Start','Target')
subplot(1,2,2);
h_img = imagesc(nan(Nr_img,Nx_img)); % Used for optional saveVideo

saveVideo = false;
if saveVideo
  fps = 30;
  vidName = 'hw2_movie';
  vidName = 'hw2_movie_sar';
  try
    vw = VideoWriter(vidName, 'MPEG-4');
  catch
    vw = VideoWriter([vidName '.avi'], 'Motion JPEG AVI');
  end
  vw.FrameRate = fps;
  vw.Quality   = 95;
  open(vw);
  fig = 3;
  Nfr = 0;
end

% data_img: Preallocate image matrix (range by along-track)
data_img = zeros(Nr_img, Nx_img);

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

    % squint_ang: Calculate the instantaneous squint angle for each radar
    % position to the image pixel
    % HERE

    % H_squint_ang: squint angle window sys.slowtime_fh, 1 by Nx
    % HERE

    % H_time: time domain window sys.fasttime_fh for each range line, Nt by Nx
    % HERE

    % H_chirp: fast-time chirp response for each range line, Nt by Nx
    % HERE

    % H_sar: slow-time sar, 1 by Nx
    % HERE

    % img_matched_filter: create a 2D simulated raw dataset for a target at
    % the image pixel using H_squint_ang, H_sar, H_time, and H_chirp.
    % HERE

    % data_img(r_idx,x_idx): update the image pixel with the inner product
    % between the img_matched_filter and the raw.data
    % HERE

    if saveVideo
      % Update system geometry plot
      set(h_plot_target_current,'XData',x_img(x_idx),'YData',y_img(r_idx),'ZData',z_img(r_idx))
      set(h_img,'CData',db(data_img));
      drawnow;
      writeVideo(vw, getframe(fig));
      Nfr = Nfr + 1;
    end

  end
  toc_cur = toc(sar_tic);
  fprintf('Range line %d of %d (%.0f of %.0f seconds)\n', x_idx, Nx_img, toc_cur, toc_cur/x_idx*Nx_img);
end

if saveVideo
  close(vw);
  fprintf('Movie written: %s (%d frames, %g fps, %.1f s)\n', ...
    vw.Filename, Nfr, fps, Nfr/fps);
end

% Store results in sar structure
sar = [];
sar.x_img = x_img;
sar.time_img = time_img;
sar.data_img = data_img;

%% 4. Prepare frequency-wavenumber axes

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

%% 5. Plot time-space and freq-kx image before windowing

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

%% 6. Apply frequency-wavenumber domain windowing

% B_kx: image wavenumber axis (angular) bandwidth at the center frequency
% determined with img.sigma_x
% HERE

% sar.data_img: Update sar.data_img by applying the sar_window_fh
% wavenumber domain window and pc_window_fh frequency domain window using
% the wavenumber bandwidth and fast-time bandwidth to scale the windows.
% HERE

%% 7. Save SAR image

fn_raw = fullfile(sys.temp_dir,'sar_rds_hw2_problem2.mat');
save(fn_raw,'sar','sys','img','-v7.3','-nocompression');

%% 8. Plot time-space and freq-kx image after windowing

h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
imagesc(sar.x_img,sar.time_img*1e6,db(sar.data_img));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% caxis([-30 0]);
title('SAR data time-space after windowing')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
imagesc(fftshift(kx_img),fftshift(freq_img)/1e6,db(fftshift(fft2(sar.data_img))));
set(gca,'ydir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
% caxis([-30 0]);
title('SAR data freq-kx after windowing')
xlabel('Along-track wavenumber k_x (rad/m)');
ylabel('Frequency (MHz)');

%% 9. Oversampled range-cut and along-track-cut plots for each target

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

hw2_problem2_check;