% 2026 EECS 800 hw6 problem 1 radar simulator
%
% SAR point-target simulator to create raw/phase-history data
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

%% 2. Load radar parameters

fn_sys = fullfile(my_path_dir,'eecs800helper','sys_snow_hw6.yaml');
sys = yaml.loadFile(fn_sys);
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
sys.fasttime_fh = str2func(sys.fasttime_fh);
sys.slowtime_fh = str2func(sys.slowtime_fh);
sys.elev_fh = str2func(sys.elev_fh);

%% 3. Load image parameters

fn_img = fullfile(my_path_dir,'eecs800helper','img_snow_hw6.yaml');
img = yaml.loadFile(fn_img);

%% 4. Define dependent image parameters

% lambda_fc: wavelength at center frequency (m)
% HERE

% r_ref: Range of closest approach for the range-midpoint (reference) of
% the scene. Define the range-midpoint to the beam center using the system
% altitude and inc_angle in the sys structure.
% HERE

% t_ref: Propagation time associated with r_ref
% HERE

% r0: range of closest approach for near side of image swath. Define this
% relative to r_ref and img.r where img.r is the range extent of the SAR
% image to be formed.
% HERE

% r1: range of closest approach for far side of image swath. Define this
% relative to r_ref and img.r where img.r is the range extent of the SAR
% image to be formed.
% HERE

% L_sar: length of SAR aperture. Determine this by using the range of
% closest approach for the far side of the image swath, the center
% frequency, and the desired image along-track resolution (m) specified in
% the img structure.
% HERE

%% 5. Define target(s)

% target.pos: (3,N_targets) matrix
% * rows: x,y,z
% * columns: each column is a separate point target
% target.sigma_RCS: (1,N_targets) vector

target.pos = zeros(3,0);
target.sigma_RCS = [];

if 0
  % Near range, start along-track (on the border)
  target.pos(:,end+1) = [ ...
    -img.x/2
    img.r/2*sin(sys.inc_angle)
    img.r/2*cos(sys.inc_angle)];
  target.sigma_RCS(1,end+1) = [1];
end

if 0
  % Far range, start along-track (on the border)
  target.pos(:,end+1) = [ ...
    -img.x/2
    -img.r/2*sin(sys.inc_angle)
    -img.r/2*cos(sys.inc_angle)];
  target.sigma_RCS(1,end+1) = [1];
end

if 0
  % Near range, end along-track (on the border)
  target.pos(:,end+1) = [ ...
    img.x/2
    img.r/2*sin(sys.inc_angle)
    img.r/2*cos(sys.inc_angle)];
  target.sigma_RCS(1,end+1) = [1];
end

if 0
  % Far range, end along-track (on the border)
  target.pos(:,end+1) = [ ...
    img.x/2
    -img.r/2*sin(sys.inc_angle)
    -img.r/2*cos(sys.inc_angle)];
  target.sigma_RCS(1,end+1) = [1];
end

if isempty(target.pos) || 0 % Force at least one target to be present
  % Scene center
  target.pos(:,end+1) = [ ...
    img.dx*0
    img.dr*0*sin(sys.inc_angle)
    img.dr*0*cos(sys.inc_angle)];
  target.sigma_RCS(1,end+1) = [1];
end

%% 6. PRF calculation

% Given the spot size in the img structure and the other system parameters
% in the sys structure, determine the sys.f_prf required to avoid aliasing

% x: along-track axis for determining the required sys.f_prf. This should start
% at -img.x/2 - L_sar/2 and go to img.x/2 + L_sar/2 and have a sample
% spacing of 1 m.
% HERE

% theta_corner: instantaneous squint angle to the image corner that is
% closest to the start of the trajectory. Calculate for each location of
% the along-track axis (assume spot is the usual square image). Should be
% the same size as x.
% HERE

% theta_corner(2,:): instantaneous squint angle to the image corner that is
% closest to the end of the trajectory. Calculate for each location of the
% along-track axis (assume spot is the usual square image).
% HERE

% theta_corner(3,:): instantaneous squint angle to the image corner that is
% closest to the start of the trajectory, but far side of spot. Calculate
% for each location of the along-track axis (assume spot is the usual
% square image).
% HERE

% theta_corner(4,:): instantaneous squint angle to the image corner that is
% closest to the end of the trajectory, but far side of spot. Calculate for
% each location of the along-track axis (assume spot is the usual square
% image).
% HERE

% theta_c: instantaneous squint angle to scene center. Calculate for each
% location of the along-track axis (assume spot is the usual square image).
% HERE

% k_fc: magnitude of the wavenumber at the center frequency
% HERE

% kx_corner: for every element in theta_corner, compute the kx component
% for that element at the center frequency
% HERE

% B_kx: maximum instantaneous wavenumber bandwidth as a function of
% along-track position
% HERE

% B_kx_max: maximum wavenumber bandwidth over all along-track positions
% HERE

% dx_max: sample spacing (Nyquist sample spacing) to avoid aliasing
% the bandwidth B_kx_max (i.e. this is the maximum or largest step size in
% along-track that we can tolerate and not have aliasing)
% HERE

% sys.f_prf: Minimum PRF to avoid aliasing with a 50% guard band. Convert
% this maximum step size to a PRF and then increase that minimum PRF by 50%
% (i.e. oversample by 50% or a factor of 1.5).
% HERE

%% 7. Create time axis

% t0: time of first arrival from the near side of the image swath. Define
% this using the range to the near-side of the image swath and consider
% that the transmit pulse is centered so the simulator needs to start Tpd/2
% early to fully capture the pulse. This will be the time of the first
% time-sample of the raw data (sometimes called "raw data" is called the
% "phase history data")
% HERE

% t1: time of last arrival from the far side of the image swath. Compute
% from the range to the far side of the image swath, the maximum SAR
% aperture, and the pulse duration is centered so that the simulator time
% needs to end Tpd/2 late to fully capture the pulse.
% HERE

% tg_t0: t0 without the sys.Tpd term
% HERE

% tg_t1: t1 without the sys.Tpd term
% HERE

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

% sys.fs: Determine the required IF sampling rate to not alias a deramped
% signal with a propagation delay from tg_t0 to tg_t1 seconds. Include a
% 50% guard. In other words, our time gate is tg_t0 to tg_t1 in time. Using
% the chirp rate, convert this to an associated IF bandwidth. Then
% oversample that IF bandwidth by 50% or a factor of 1.5.
% HERE

% dt: define the fast-time sample spacing from the system sampling
% frequency
% HERE

% t0: Use floor to adjust the start of the time gate to align with a sample
% multiple so that the origin, 0, is one of the time samples.
% HERE

% t1: Use ceil to adjust the stop of the time gate to align with a sample
% multiple so that the origin, 0, is one of the time samples.
% HERE

% time: Define time axis of simulated data to start at t0 and end at t1
% with a sample spacing of dt. This should be a column vector since it is a
% fast-time axis.
% HERE

% Nt: The length of the time vector. time should be size Nt,1
% HERE

%% 8. Create radar trajectory spatial axes

% dx: Define the range line spacing from sys.vel and sys.f_prf. It is the
% distance the radar travels from one pulse to the next.
% HERE

% x: Radar's x-position or along-track position for the simulated data.
% Should be a row-vector. Start half a SAR aperture before the first (in
% the x-dim) image pixel and continue half a SAR aperture past the last
% image pixel. The origin should be the image/scene center. For
% convenience, ensure full support by using floor() for the start and
% ceil() for the end. This will also ensure that x has a sample at x == 0.
% HERE

% Nx: The length of the along-track vector
% HERE

% y: Radar's y-position or cross-track position for the simulated data. The
% cross-track position is the ground-range offset from the scene center using
% sys.altitude and sys.inc_angle. Should be size 1,Nx
% HERE

% z: Radar's z-position or elevation position. The elevation position is
% the offset from the scene center using sys.altitude. Should be size 1,Nx
% HERE

%% 9. Define dependent axes

% eta: Define slow-time axis of simulated data. Should be aligned with the
% x-vector. Assume constant velocity sys.vel.
% HERE

%% 10. Define linear FM chirp

% ref: Define reference pulse compression waveform (V) with time. The pulse
% should be centered on the scene center, t_ref. The window function should
% use sys.fasttime_fh(t).
% HERE

%% 11. Simulator loop

% data: Preallocate raw data matrix using Nt and Nx
data = zeros(Nt,Nx);

% target.td: Preallocate the two-way travel time delay for each target.
target.td = nan(Nx, size(target.pos,2));

% Rc: Calculate the range to each radar position for the scene center
% HERE

% td_c: Calculate the time delay to each radar position for the scene
% center
% HERE

% Store the result in target.td_c for debugging later
target.td_c = td_c;

% elev_ang_c: Calculate the instantaneous elevation angle for each radar
% position to the scene center. The elevation angle is not a function of
% the alongtrack position, x.
% HERE

% squint_ang_c: Calculate the instantaneous squint angle for each radar
% position to the scene center
% HERE

% kx: compute the kx component for the scene center for each radar position
% HERE

% For loop through each column of the target.pos matrix
for t_idx = 1:size(target.pos,2)

  % R: Calculate the range to each radar position for this target.
  % HERE

  % td: Calculate the time delay to each radar position for this target
  % HERE

  % Store the result in target.td for debugging later
  target.td(:,t_idx) = td;

  % elev_ang: Calculate the instantaneous elevation angle for each radar
  % position to the target
  % HERE

  % squint_ang_c: Calculate the instantaneous squint angle for each radar
  % position to the target
  % HERE

  % data: using the Born approximation which assumes target scattering
  % behaves like a linear function, update the data matrix with the
  % scattering from this target:
  % 1. Use the target.sigma_RCS to scale the output
  % 2. sys.slowtime_fh for the along-track beam pattern centered on the
  % scene center with beamwidth sys.beta_x
  % 3. sys.elev_fh for the elevation beam pattern centered on the scene
  % center with beamwidth sys.beta_y
  % 4. assume a linear FM up-chirp whose transmission is centered on
  % time-zero and is at complex baseband (demodulated from sys.fc)
  % For deramp:
  % 1. Add a deramp term for the carrier term AND the chirp term. This is
  % spotlight SAR mode with deramp on receive and deramp in azimuth.
  % HERE

end

%% 12. Save simulation data

raw = [];
raw.x = x;
raw.y = y;
raw.z = z;
raw.data = data;
raw.time = time;
raw.ref = ref;

fn_raw = fullfile(sys.temp_dir,'raw_snow_hw6.mat');
save(fn_raw,'raw','sys','img','target','-v7.3','-nocompression');

%% 13. Time vs space image plot in figure 1
  
h_fig = figure(1); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(x,time*1e6,db(data));
set(gca,'YDir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');
  
subplot(1,2,2);
imagesc(x,time*1e6,angle(data));
set(gca,'YDir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase (rad)');
clim([-pi pi]);
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

%% 14. Frequency vs wavenumber image plot in figure 2

h_fig = figure(2); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(kx,(time-mean(target.td_c))*Kr/1e6,db(data));
set(gca,'YDir','normal');
set(gca,'XDir','reverse');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('k_x (rad/m)');
ylabel('Frequency (MHz)');

subplot(1,2,2);
imagesc(kx,(time-mean(target.td_c))*Kr/1e6,angle(data));
set(gca,'YDir','normal');
set(gca,'XDir','reverse');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase (rad)');
clim([-pi pi]);
title('Raw data')
xlabel('k_x (rad/m)');
ylabel('Frequency (MHz)');

% hw6_problem1_check;
