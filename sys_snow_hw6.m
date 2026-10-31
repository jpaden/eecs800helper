% Script which creates snow radar sounder yaml system file for hw6

sys = [];
sys.name = 'snow';
sys.fc = 10e9;
sys.B = 500e6;
sys.inc_angle_deg = 30;
sys.inc_angle = sys.inc_angle_deg/180*pi;
sys.altitude = 5000;
sys.Pt = 1;
sys.f_prf = 1;
sys.Tpd = 250e-6;
sys.Gt_dB = 10;
sys.Gt = 10.^(sys.Gt_dB/10);
sys.Gr_dB = 10;
sys.Gr = 10.^(sys.Gr_dB/10);
sys.F_dB = 3;
sys.F = 10^(sys.F_dB/10);
% Beamwidth with 1.5x scaling factor for 25 m spot on the ground:
sys.beta_x_deg = 1.5*25 / (5000/cos(sys.inc_angle)) * 180/pi;
sys.beta_x = sys.beta_x_deg/180*pi;
% Beamwidth with 1.5x scaling factor for 25 m range spot projected on the
% ground:
sys.beta_y_deg = 1.5*25/sin(sys.inc_angle) / (5000/cos(sys.inc_angle)) * 180/pi;
sys.beta_y = sys.beta_y_deg/180*pi;
sys.vel = 125;
sys.fs = 1; % fs: complex baseband sampling frequency

% fasttime_fh: fast-time window function handle
sys.fasttime_fh = func2str(@(time_norm) tukeywin_cont(time_norm,0));

% slowtime_fh: slow-time (squint-angle/beam-pattern) window function handle
sys.slowtime_fh = func2str(@(eta_norm) tukeywin_cont(eta_norm,0));

% elev_fh: elevation (elev-angle/beam-pattern) window function handle
sys.elev_fh = func2str(@(elev_ang) tukeywin_cont(elev_ang,0));

% path_dir: root to processing source code
sys.path_dir = 'C:\git\eecs800\';
% temp_dir: store raw and processed files here
sys.temp_dir = 'C:\Temp\eecs800_sar_capella\';

addpath(fullfile(sys.path_dir));
addpath(fullfile(sys.path_dir,'eecs800helper'));

fn_sys = fullfile(sys.path_dir,'eecs800helper','sys_snow_hw6.yaml');
yaml.dumpFile(fn_sys, sys,'block');
