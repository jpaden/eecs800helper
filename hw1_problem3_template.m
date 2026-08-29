% 2026 EECS 800 hw1 problem 3 radar simulator
%
% SAR point-target simulator to create raw/phase-history data

my_path_dir = 'C:\git\eecs800\'; % Update this if needed
my_temp_dir = 'C:\Temp\eecs800_sar_rds\'; % Update this if needed

path(pathdef)
addpath(fullfile(my_path_dir));
addpath(fullfile(my_path_dir,'eecs800helper'));

physical_constants;

% fasttime_fh: Fast time time-domain window function handle
fasttime_fh = @(time_norm) tukeywin_cont(time_norm,0);

% slowtime_fh: Slow time beam pattern window function handle
slowtime_fh = @(eta_norm) tukeywin_cont(eta_norm,0);
%% 3.1 Load radar parameters

fn_sys = fullfile(my_path_dir,'eecs800helper','sys_rds.yaml');
sys = yaml.loadFile(fn_sys);
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
%% 3.2 Load image parameters

fn_img = fullfile(my_path_dir,'eecs800helper','img_rds.yaml');
img = yaml.loadFile(fn_img);
%% Notes

% Slow-time (SAR) coordinate system
% * x is along-track (assumed straight and level flight path)
% * z is elevation projected on the plane that is orthogonal to the
% along-track (points to the zenith for straight and level flight paths)
% * y completes the right handed coordinate system (so points left)
% * [x,y,z].' origin is at the image/scene center (aka image reference
% point) so that [x,y,z] points from the image/scene center to the radar
% positions
% * eta is slow-time axis and should be aligned with the x-axis

% Fast-time coordinate system
% * time is fast-time axis with its origin as the center of the transmit
% pulse
% * range is the fast-time range axis and should be aligned with the time
% axis

% Units
% * Always use SI units
% * Exceptions are allowed, but variable names storing non-SI units should
% end in the unit type (e.g. "_deg" if not using radians)
%% 3.3 Define dependent image parameters

% lambda_fc: wavelength at center frequency (m)
% HERE

% sigma_r: range resolution (m)
% HERE

% r_ref: Range of closest approach for the range-midpoint (reference) of
% the scene. Define the range-midpoint to the beam center using the system
% altitude and inc_angle.
% HERE

% t_ref: Propagation time associated with r_ref
% HERE

% r0: range of closest approach for near side of image swath. Define this
% relative to r_ref and img.r.
% HERE

% r1: range of closest approach for far side of image swath. Define this
% relative to r_ref and img.r.
% HERE

% L_sar: length of SAR aperture. Determine this by using the range of
% closest approach for the far side of the image swath, the center
% frequency, and the desired image along-track resolution (m).
% HERE
%% 3.4 Define target(s)

% target.pos: (3,N_targets) matrix
% * rows: x,y,z
% * columns: each column is a separate point target
% target.sigma_RCS: (1,N_targets) vector
target.pos = [ ...
  0
  0
  0];
target.sigma_RCS = [1];
%% 3.5 Create time axis

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

% dt: define the fast-time sample spacing from the system sampling
% frequency
% HERE

% Adjust start (t0) and stop (t1) of the time gate to align with a sample multiple so
% that the origin, 0, is one of the time samples.
% HERE

% time: Define time axis of simulated data to start at t0 and end at t1
% with a sample spacing of dt. This should be a column vector.
% HERE

% Nt: The length of the time vector. time should be size Nt,1
% HERE
%% 3.6 Create radar trajectory spatial axes

% dx: Define the range line spacing from sys.vel and sys.f_prf. It is the
% distance the radar travels from one pulse to the next.
% HERE

% x: Radar's x-position or along-track position for the simulated data.
% Should be a row-vector. Start half a SAR aperture before the first (in
% the x-dim) image pixel and continue half a SAR aperture past the last
% image pixel. The origin should be the image/scene center.
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
%% 3.7 Define dependent axes

% df: frequency domain spacing (Hz)
% HERE

% freq: baseband frequency axis (Hz)
% HERE

% range: create the range axis corresponding to the time axis (m)
% HERE

% eta: Define slow-time axis of simulated data. Should be aligned with the
% x-vector. Assume constant velocity sys.vel.
% HERE

% deta: Define slow-time step size from dx and sys.vel.
% HERE

% dkx: wavenumber domain spacing (rad/m)
% HERE

% kx: wavenumber (spatial angular frequency) axis (rad/m)
% HERE

% df_eta: doppler frequency domain spacing (Hz)
% HERE

% f_eta: doppler frequency axis, eta is slow time variable (Hz)
% HERE
%% 3.8 Define linear FM chirp

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

% ref: Define reference pulse compression waveform (V) with time. The pulse
% should be centered on the scene center, t_ref. The window function should
% use fasttime_fh(t)
% HERE
%% 3.9 Simulator loop

% data: Preallocate raw data matrix
data = zeros(Nt,Nx);

% target.td: Preallocate the time-delay calculations for each target for debugging
% later
target.td = nan(Nx, size(target.pos,2));

% For loop through each column of the target.pos matrix
for t_idx = 1:size(target.pos,2)

  % R: Calculate the range to each radar position for this target
  % HERE

  % td: Calculate the time delay to each radar position for this target
  % HERE

  % Store the result in target.td for debugging later
  target.td(:,t_idx) = td;

  % squint_ang: Calculate the instantaneous squint angle for each radar
  % position to the target
  % HERE

  % Update the raw data matrix
  % data = data + [target-contribution]
  % [target-contribution] should:
  % 1. include the target.sigma_RCS
  % 2. be weighted by the slowtime_fh(squint_angle) window with a width specified by sys.beta_x
  % 3. be at complex baseband
  % 4. include the carrier phase delay term
  % 5. include the chirp term (similar to the ref above)
  % HERE

end
%% 3.10 Save simulation data

raw = [];
raw.x = x;
raw.y = y;
raw.z = z;
raw.data = data;
raw.time = time;
raw.ref = ref;

fn_raw = fullfile(sys.temp_dir,'raw_rds.mat');
save(fn_raw,'raw','sys','img','target','-v7.3','-nocompression');
%% 3.11 Time vs space image plot in figure 1

h_fig = figure(1); set(h_fig,'WindowStyle','docked'); clf;
imagesc(x,time*1e6,db(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');
%% 3.12 Range vs slow-time image plot in figure 2

h_fig = figure(2); set(h_fig,'WindowStyle','docked'); clf;
imagesc(eta,time*c/2,db(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('Slow/azimuth time (sec)');
ylabel('Range (m)');