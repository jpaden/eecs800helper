% Script which creates radar depth sounder yaml system file

sys = [];
sys.name = 'rds';
sys.fc = 195e6; % fc: center frequency
sys.B = 60e6; % B: bandwidth
sys.inc_angle_deg = 45;
sys.inc_angle = sys.inc_angle_deg/180*pi; % inc_angle: incidence angle at scene center
sys.altitude = 500; % altitude: altitude (z-axis) of radar above target ground plane
sys.Pt = 1000; % Pt: transmit power
sys.f_prf = 500; % f_prf: pulse repetition frequency
sys.Tpd = 10e-6; % Tpd: pulse duration (uncompressed)
sys.Gt_dB = 6;
sys.Gt = 10.^(sys.Gt_dB/10); % Gt: transmit antenna gain
sys.Gr_dB = 6;
sys.Gr = 10.^(sys.Gr_dB/10); % Gr: receive antenna gain
sys.F_dB = 3;
sys.F = 10^(sys.F_dB/10); % F: receiver noise figure
sys.beta_x_deg = 120;
sys.beta_x = sys.beta_x_deg/180*pi; % beta_x: along-track beamdwidth of physical aperture
sys.beta_y_deg = 180;
sys.beta_y = sys.beta_y_deg/180*pi; % beta_y: cross-track beamdwidth of physical aperture
sys.vel = 125; % vel: velocity
sys.fs = 300e6; % fs: complex baseband sampling frequency

% path_dir: root to processing source code
sys.path_dir = 'C:\git\eecs800\';
% temp_dir: store raw and processed files here
sys.temp_dir = 'C:\Temp\eecs800_sar_rds\';

addpath(fullfile(sys.path_dir));
addpath(fullfile(sys.path_dir,'eecs800helper'));

fn_sys = fullfile(sys.path_dir,'eecs800helper','sys_rds.yaml');
yaml.dumpFile(fn_sys, sys,'block');
