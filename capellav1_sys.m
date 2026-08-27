% Script which creates the Capella V1 radar yaml system file
% Whitney-Class / Earlier Constellation

sys.name = 'Capella v1'
sys.fc = 9.65e9;
sys.B = 500e6;
sys.inc_angle_deg = 45;
sys.inc_angle = sys.inc_angle_deg/180*pi;
sys.altitude = 525e3;
sys.Pt = 600;
sys.f_prf = 5000;
sys.Tpd = 40e-6;
sys.Gt_dB = 48;
sys.Gt = 10.^(sys.Gt_dB/10);
sys.Gr_dB = 48;
sys.Gr = 10.^(sys.Gr_dB/10);
sys.F_dB = 3.2;
sys.F = 10^(sys.F_dB/10);
sys.beta_x_deg = 0.39;
sys.beta_x = sys.beta_x_deg/180*pi;
sys.beta_y_deg = 1.65;
sys.beta_y = sys.beta_y_deg/180*pi;
sys.vel = 7565;
% path_dir: root to processing source code
sys.path_dir = 'C:\git\eecs800\';
% temp_dir: store raw and processed files here
sys.temp_dir = 'C:\Temp\eecs800_sar_capella\';

addpath(fullfile(sys.path_dir));
addpath(fullfile(sys.path_dir,'eecs800helper'));

fn_capella_sys = fullfile(sys.path_dir,'eecs800helper','capellav1.yaml');
yaml.dumpFile(fn_capella_sys, sys,'block');
