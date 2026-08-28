% Script which creates the Gotcha radar yaml system file

sys = [];
sys.name = 'Gotcha';
sys.fc = 9.601659250259411e9;
sys.B = 639.9965e6;
sys.inc_angle_deg = 40;
sys.inc_angle = sys.inc_angle_deg/180*pi;
sys.altitude = 7251;
sys.Pt = 1000;
sys.f_prf = 2172;
sys.Tpd = 30e-6;
sys.Gt_dB = 30.5;
sys.Gt = 10.^(sys.Gt_dB/10);
sys.Gr_dB = 30.5;
sys.Gr = 10.^(sys.Gr_dB/10);
sys.F_dB = 3;
sys.F = 10^(sys.F_dB/10);
sys.beta_x_deg = 6;
sys.beta_x = sys.beta_x_deg/180*pi;
sys.beta_y_deg = 6;
sys.beta_y = sys.beta_y_deg/180*pi;
sys.vel = 125;
% path_dir: root to processing source code
sys.path_dir = 'C:\git\eecs800\';
% temp_dir: store raw and processed files here
sys.temp_dir = 'C:\Temp\eecs800_sar_gotcha\';

addpath(fullfile(sys.path_dir));
addpath(fullfile(sys.path_dir,'eecs800helper'));

fn_sys = fullfile(sys.path_dir,'eecs800helper','sys_gotcha.yaml');
yaml.dumpFile(fn_sys, sys,'block');
