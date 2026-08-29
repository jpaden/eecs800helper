% Script which creates radar depth sounder yaml image file

sys_rds;

img = [];

img.name = 'rds';

% sigma_x: desired along-track resolution (m)
img.sigma_x = 2.5;

% img.dx: SAR image along-track sample spacing
img.dx = 1.25;

% image_dr: SAR image range sample spacing
img.dr = 1.25;

% img.x: SAR image along-track length (centered on scene center)
img.x = 125;

% img.r: SAR image range length (centered on scene center)
img.r = 125;

fn_img = fullfile(sys.path_dir,'eecs800helper','img_rds.yaml');
yaml.dumpFile(fn_img, img,'block');
