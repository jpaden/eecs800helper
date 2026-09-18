% 2026 EECS 800 hw2 problem 1 radar simulator
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

%% 2. Load radar parameters

fn_sys = fullfile(my_path_dir,'eecs800helper','sys_rds_hw2.yaml');
sys = yaml.loadFile(fn_sys);
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
sys.fasttime_fh = str2func(sys.fasttime_fh);
sys.slowtime_fh = str2func(sys.slowtime_fh);

%% 3. Load image parameters

fn_img = fullfile(my_path_dir,'eecs800helper','img_rds_hw2.yaml');
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
if 0
  % Near range, start along-track (4.5 pixels from each border)
  target.pos = [ ...
    img.dx*-45.5
    img.dr*45.5*sin(sys.inc_angle)
    img.dr*45.5*cos(sys.inc_angle)];
  target.sigma_RCS = [1];

elseif 0
  % Far range, start along-track (4.5 pixels from each border)
  target.pos = [ ...
    img.dx*-45.5
    img.dr*-44.5*sin(sys.inc_angle)
    img.dr*-44.5*cos(sys.inc_angle)];
  target.sigma_RCS = [1];

elseif 0
  % Near range, end along-track (4.5 pixels from each border)
  target.pos = [ ...
    img.dx*44.5
    img.dr*45.5*sin(sys.inc_angle)
    img.dr*45.5*cos(sys.inc_angle)];
  target.sigma_RCS = [1];

elseif 0
  % Far range, end along-track (4.5 pixels from each border)
  target.pos = [ ...
    img.dx*44.5
    img.dr*-44.5*sin(sys.inc_angle)
    img.dr*-44.5*cos(sys.inc_angle)];
  target.sigma_RCS = [1];

else
  % Scene center
  target.pos = [ ...
    img.dx*0
    img.dr*0*sin(sys.inc_angle)
    img.dr*0*cos(sys.inc_angle)];
  target.sigma_RCS = [1];
end

%% 6. Create time axis

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

%% 7. Create space axis

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

%% 8. Define dependent axes

% eta: Define slow-time axis of simulated data. Should be aligned with the
% x-vector. Assume constant velocity sys.vel.
% HERE

%% 9. Define linear FM chirp

% Kr: fast time chirp rate (Hz/sec) from sys.B and sys.Tpd
% HERE

% ref: Define reference pulse compression waveform (V) with time. The pulse
% should be centered on the scene center, t_ref. The window function should
% use sys.fasttime_fh(t).
% HERE

%% 10. Simulator loop

% data: Preallocate raw data matrix
data = zeros(Nt,Nx);

% target.td: Preallocate the two-way travel time delay for each target.
target.td = nan(Nx, size(target.pos,2));

% For loop through each column of the target.pos matrix
for t_idx = 1:size(target.pos,2)

  % R: Calculate the range to each radar position for this target
  % HERE

  % td: Calculate the time delay to each radar position for this target
  % HERE

  % Store the result in target.td for debugging later
  % HERE

  % squint_ang: Calculate the instantaneous squint angle for each radar
  % position to the target
  % HERE

  % data: using the Born approximation which assumes target scattering
  % behaves like a linear function, update the data matrix with the
  % scattering from this target. Use the target.sigma_RCS to scale the
  % output, sys.slowtime_fh for the along-track beam pattern,
  % sys.fasttime_fh for the time domain window, assume there is no
  % cross-track beam pattern, and assume a linear FM up-chirp whose
  % transmission is centered on time-zero.
  % HERE

end

%% 11. Save simulation data

raw = [];
raw.x = x;
raw.y = y;
raw.z = z;
raw.data = data;
raw.time = time;
raw.ref = ref;

fn_raw = fullfile(sys.temp_dir,'raw_rds_hw2.mat');
save(fn_raw,'raw','sys','img','target','-v7.3','-nocompression');

%% 12. Time vs space image plot in figure 1
  
h_fig = figure(1); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(x,time*1e6,db(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');
  
subplot(1,2,2);
imagesc(x,time*1e6,angle(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase (rad)');
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

%% 13. Range vs slow-time image plot in figure 2

h_fig = figure(2); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(eta,time*c/2,db(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]);
title('Raw data')
xlabel('Slow/azimuth time (sec)');
ylabel('Range (m)');
  
subplot(1,2,2);
imagesc(eta,time*c/2,angle(data));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Phase (rad)');
title('Raw data')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

hw2_problem1_check;
