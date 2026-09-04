% 2026 EECS 800 hw1 problem 2 radar simulator
% 
% Radar equation link budget, along-track SAR resolution/sampling

my_path_dir = 'C:\git\eecs800\'; % Update this if needed
my_temp_dir = 'C:\Temp\eecs800_sar_capella\'; % Update this if needed

path(pathdef)
addpath(fullfile(my_path_dir));
addpath(fullfile(my_path_dir,'eecs800helper'));

physical_constants;

fn_sys = fullfile(my_path_dir,'eecs800helper','sys_capellav1.yaml');
sys = yaml.loadFile(fn_sys);
sys.path_dir = my_path_dir;
sys.temp_dir = my_temp_dir;
%% 2.1 Expected receiver power, Pr and Pr_dB

% R: magnitude of range vector to target
% HERE R = sys.altitude / cosd(sys.inc_angle_deg);

% sigma_RCS: radar cross section of point target
% HERE sigma_RCS = 1;

% lambda_c: wavelength at the center frequency
% HERE lambda_c = c / sys.fc;

% Pr: received signal power in W
% HERE

% Pr_dB: received signal power in dBW
% HERE

%% 2.2 Expected receiver power, Pr and Pr_dB

% R: magnitude of range vector to target
% HERE

% sigma_0: area-normalized backscatter
% HERE

% sigma_r: range resolution (m)
% HERE

% sigma_rg: ground range resolution (m)
% HERE

% A: scattering area (m^2)
% HERE

% Gpc: pulse compression gain
% HERE

% Pr: received signal power in W
% HERE

% Pr_dB: received signal power in dBW
% HERE

%% 2.3 Expected noise power, Pn and Pn_dB

% Pn: noise power in W
% HERE

% Pn_dB: noise power in dBW
% HERE

%% 2.4 Orbital velocity, sys.vel

% sys.vel: Original sys.vel
% HERE

% sys.vel: New sys.vel using orbital velocity equation and sys.altitude
% HERE

%% 2.5 Noise equivalent sigma zero (NESZ), sigma_NESZ and sigma_NESZ_dB

% sigma_NESZ: Noise equivalent sigma zero (NESZ) 1/m^2
% HERE

% sigma_NESZ_dB: Noise equivalent sigma zero (NESZ) dB/m^2
% HERE

%% 2.6 SAR along-track (x-dimension) sample spacing, dx

% Physical antenna is 3.5-3.6 m
% dx: along-track spacing
% HERE

%% 2.7 SAR wavenumber

% k: magnitude of the wavenumber at the center frequency
% HERE

% kx_min: minimum along-track (x-dim) wavenumber
% HERE

% kx_max: maximum along-track (x-dim) wavenumber
% HERE

%% 2.8 Nyquist sampling rate, dx_max

% B_kx: along-track wavenumber bandwidth
% HERE

% dx_max: maximum sample spacing (Nyquist sample spacing)
% HERE