% Script which creates snow radar yaml image file for hw6

sys_rds;

img = [];

img.name = 'snow';

% sigma_x: desired along-track resolution (m)
img.sigma_x = 0.3;

% sigma_r: desired range resolution (m)
img.sigma_r = 0.3;

% img.dx: SAR image along-track sample spacing
img.dx = 0.3;

% image_dr: SAR image range sample spacing
img.dr = 0.3;

% img.x: SAR image along-track length (centered on scene center)
img.x = round(25/0.3)*0.3;

% img.r: SAR image range length (centered on scene center)
img.r = round(25/0.3)*0.3;

fn_img = fullfile(sys.path_dir,'eecs800helper','img_snow_hw6.yaml');
yaml.dumpFile(fn_img, img,'block');
