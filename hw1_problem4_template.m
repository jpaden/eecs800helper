% 2026 EECS 800 hw1 problem 4 radar simulator
%
% SAR pulse compression

my_path_dir = 'C:\git\eecs800\'; % Update this if needed
my_temp_dir = 'C:\Temp\eecs800_sar_rds\'; % Update this if needed

path(pathdef)
addpath(fullfile(my_path_dir));
addpath(fullfile(my_path_dir,'eecs800helper'));

physical_constants;

% pc_window_fh: Fast time time-domain window function handle
pc_window_fh = @(time_norm) tukeywin_cont(time_norm,0);
%% 4.1 Load raw data parameters

fn_sys = fullfile(my_temp_dir,'raw_rds.mat');
load(fn_sys); % Loads sys, img, and raw
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
%% 4.2 Define dependent image parameters and axes

% Redefine Nt, dt, Nx, and dx from raw.time and raw.x
Nt = length(raw.time);
dt = raw.time(2)-raw.time(1);

Nx = length(raw.x);
dx = raw.x(2)-raw.x(1);

% HERE: Copy contents from:
% HERE: 3.3 Define dependent image parameters
% HERE: 3.7 Define dependent axes

%% 4.3 Pulse compression

% ref_fft: FFT of the reference pulse compression waveform raw.ref (V)
% HERE

% data_pc: pulse compression output with frequency domain window
% pc_window_fh(freq/sys.B). Include a time correction because the raw.ref
% is centered at t_ref and the raw.time axis does not start at 0.
% HERE

% time_pc: create a time axis associated with the pulse compression output
% HERE

% range_pc: create a range axis associated with the pulse compression time
% axis
% HERE
%% 4.4 Time vs space image plot in figure 3

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(raw.x,time_pc*1e6,db(data_pc));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]+max(db(data_pc(:))));
title('Pulse compressed image')
xlabel('Along-track position (m)');
ylabel('Time ({\mu}s)');
%% 4.5 Range vs slow-time image plot in figure 4

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(eta,time_pc*c/2,db(data_pc));
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
caxis([-30 0]+max(db(data_pc(:))));
title('Pulse compressed image')
xlabel('Slow/azimuth time (sec)');
ylabel('Range (m)');
%% 4.6 Range line (a-scope) plot of range line closest to scene center in figure 5

% This only produces useful results if there is an isolated target at the
% scene center

[~,rline] = min(abs(target.pos(1,1)-raw.x));
[~,rbin] = min(abs( sqrt(target.pos(2,1)^2+target.pos(3,1)^2) - (range_pc-r_ref)));

h_fig = figure(5); set(h_fig,'WindowStyle','docked'); clf;
plot(time_pc*1e6, db(data_pc(:,rline)))
grid on;
xlim(time_pc(rbin)*1e6 + dt*[-20 20]*1e6); % Comment these for debugging
ylim([-80 0]+max(db(data_pc(:,rline)))); % Comment these for debugging
title('Range line at scene center');
xlabel('Time ({\mu}s)');
ylabel('Relative power (dB)');
%% 4.7 Phase vs along-track and range vs along-track plot in figure 6

% This only works if there is one scatterer that is dominant in every range
% line

% max_val,max_idx: Find the peak value and peak index from each range line
% HERE

% max_phase: Unwrap the phase of the max_val and normalize so that the
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
plot(x, (time_pc(max_idx) - min(target.td(:,1)))*1e6); % Measured time
hold on
plot(x, -measured_phase/(2*pi*sys.fc)*1e6,'x'); % Measured phase (converted to time)
plot(x, (target.td(:,1) - min(target.td(:,1)))*1e6,'o') % Expected time
plot(x, -expected_phase/(2*pi*sys.fc)*1e6,'+') % Expected phase (converted to time)
grid('on');
xlim([x(1) x(end)]);
title('Compare measured and expected time and phase');
xlabel('Along-track (m)')
ylabel('Time delay ({\mu}s)')
legend('Measured Time','Measured Phase', 'Expected Time','Expected Phase','location','best')
%% 4.8 Instantaneous frequency vs along-track in figure 7

% This only works properly if previous section works

% expected_kx: Numerically calculate the instantaneous angular spatial
% frequency (i.e. wavenumber kx)
kx_measured = diff(measured_phase) ./ diff(x);
x_measured = (x(1:end-1)+x(2:end))/2; % x-position of kx_measured vector

% k_fc: wavenumber at the center frequency (rad/m)
% HERE

% target_kx: wavenumber of target for each range line
% HERE

h_fig = figure(7); set(h_fig,'WindowStyle','docked'); clf;
plot(x_measured, kx_measured);
hold on
plot(x, kx_expected);
grid('on');
xlim([x(1) x(end)]);
title('k_x for target')
xlabel('Along-track (m)')
ylabel('k_x (rad/s)')
legend('Measured k_x','Expected k_x','location','best')