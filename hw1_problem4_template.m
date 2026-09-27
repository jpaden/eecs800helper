% 2026 EECS 800 hw1 problem 4 radar pulse compression
%
% SAR pulse compression
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

%% 2. Load raw data parameters

fn_sys = fullfile(my_temp_dir,'raw_rds.mat');
load(fn_sys); % Loads sys, img, raw, and target
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;

%% 3. Define dependent image parameters and axes

% Nt: Redefine from raw.time
Nt = length(raw.time);

% dt: Redefine from raw.time
dt = raw.time(2)-raw.time(1);

% Nx: Redefine from raw.x
Nx = length(raw.x);

% dx: Redefine from raw.x
dx = raw.x(2)-raw.x(1);

% HERE: Copy contents from these hw1_problem3 sections and reference raw.time and raw.x instead of time and x:
% HERE: 4. Define dependent image parameters
% HERE: 8. Define dependent axes

%% 4. Pulse compression

% ref_fft: FFT of the reference pulse compression waveform raw.ref (V)
% HERE

% data_pc: pulse compression output with frequency domain window
% pc_window_fh(freq/sys.B). Include a time correction because the raw.ref
% is centered at t_ref and the raw.time axis does not start at 0.
% HERE

% time_pc: time axis associated with the pulse compression output
time_pc = raw.time;

% range_pc: create a range axis associated with the pulse compression time
% axis
% HERE

%% 5. Time vs space image plot in figure 3

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(raw.x,time_pc*1e6,db(data_pc));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]+max(db(data_pc(:))));
title('Pulse compressed image')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');

%% 6. Range vs slow-time image plot in figure 4

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(eta,time_pc*c/2,db(data_pc));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]+max(db(data_pc(:))));
title('Pulse compressed image')
xlabel('Slow/azimuth time (sec)');
ylabel('Range (m)');

%% 7. Range line (a-scope) plot of range line closest to target in figure 5

% This only produces useful results if there is an isolated target at the
% scene center

% yc: y-offset of radar to scene center
yc = sys.altitude * tan(sys.inc_angle);

% zc: z-offset of radar to scene center
zc = sys.altitude;

% Find the range line, rline, and range bin, rbin, closest to the first target in the target.pos array.
[~,rline] = min(abs(target.pos(1,1)-raw.x));
[~,rbin] = min(abs( vecnorm([yc;zc]-target.pos([2 3],1),2,1) - range_pc ));

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
plot(time_pc*1e6, db(data_pc(:,rline)))
grid on;
xlim(time_pc(rbin)*1e6 + dt*[-20 20]*1e6); % Comment these for debugging
ylim([-80 0]+max(db(data_pc(:,rline)))); % Comment these for debugging
title('Range line at scene center');
xlabel('Time ({\mu}s)');
ylabel('Relative power (dB)');

%% 8. Phase vs along-track and range vs along-track plot in figure 6

% This only works if there is one scatterer that is dominant in every range
% line

% max_val,max_idx: Find the peak value and peak index from each range line
% HERE

% measured_phase: Unwrap the phase of the max_val and normalize so that the
% maximum phase is zero
% HERE

% expected_phase: Determine the phase from the target delay target.td(:,1)
% and normalize so that the maximum expected phase is zero
% HERE

% Plot time-representations of the target:
% 1. Measured time (by peak tracking)
% 2. Measured phase (by unwrapping phase of peak)
% 3. Expected time from td
% 4. Expected phase from td
h_fig = figure(6); set(h_fig,'WindowStyle','docked'); clf;
plot(raw.x, (time_pc(max_idx) - min(target.td(:,1)))*1e6); % Measured time
hold on
plot(raw.x, -measured_phase/(2*pi*sys.fc)*1e6,'x'); % Measured phase (converted to time)
plot(raw.x, (target.td(:,1) - min(target.td(:,1)))*1e6,'o') % Expected time
plot(raw.x, -expected_phase/(2*pi*sys.fc)*1e6,'+') % Expected phase (converted to time)
grid('on');
xlim([raw.x(1) raw.x(end)]);
title('Compare measured and expected time and phase');
xlabel('Along-track (m)')
ylabel('Time delay ({\mu}s)')
legend('Measured Time','Measured Phase', 'Expected Time','Expected Phase','location','best')

%% 9. Instantaneous frequency vs along-track in figure 7

% This only works properly if previous section works

% kx_measured: Numerically calculate the instantaneous angular spatial
% frequency (i.e. wavenumber kx)
kx_measured = diff(measured_phase) ./ diff(raw.x);

% x_measured: The value of x corresponding to the points of kx_measured
x_measured = (raw.x(1:end-1)+raw.x(2:end))/2; % x-position of kx_measured vector

% k_fc: wavenumber at the center frequency (rad/m)
% HERE

% kx_expected: wavenumber (at the center frequency) of first target for
% each range line
% HERE

% p_kx_linear: linear fit to kx_expected at the origin. Shows that
% hyperbolic phase is almost linear FM chirp in wavenumber domain. The
% short-time-Fourier-transform STFT of max_val also shows this.
p_kx_linear = polyfit(raw.x( (-1:1) + rline ), kx_expected( (-1:1) + rline ), 1);

h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
plot(x_measured, kx_measured,'LineWidth',3);
hold on
plot(raw.x, kx_expected, '--','LineWidth',2);
plot(raw.x( round(linspace(1,end,11)) ), polyval(p_kx_linear, raw.x( round(linspace(1,end,11)) )),'.','markersize',20);
grid('on');
xlim([raw.x(1) raw.x(end)]);
title('k_x for target')
xlabel('Along-track (m)')
ylabel('k_x (rad/m)')
legend('Measured k_x','Expected k_x','Linear approx. k_x','location','best')

% stft_out,stft_f,stft_x: short-time-Fourier-transform of max_val. The
% along-track sample spacing is dx, so the equivalent "sample rate" passed
% to stft is 1/dx (samples/m). stft then returns stft_f in cycles/m and
% stft_x in m relative to the first sample (raw.x(1)).
[stft_out,stft_f,stft_x] = stft(max_val,1/dx);

% stft_kx: convert the stft frequency axis (cycles/m) to wavenumber (rad/m)
stft_kx = 2*pi*stft_f;

h_fig = figure(8); set(h_fig,'WindowStyle','docked'); clf;
imagesc(raw.x(1)+stft_x, stft_kx, db(stft_out));
set(gca,'YDir','normal');
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-40 0]+max(db(stft_out(:))));
ylim([-1 1]*1.5*max(abs(kx_measured))); % Comment this to see the full k_x extent
title('STFT of target peak')
xlabel('Along-track (m)')
ylabel('k_x (rad/m)')

hw1_problem4_check;
