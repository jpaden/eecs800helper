% Script which creates radar depth sounder yaml system file

img = [];

img.name = 'rds';

% sigma_x: desired along-track resolution (m)
img.sigma_x = 2.5;

% img.dx: SAR image along-track sample spacing
img.dx = 1.25;

% image_dr: SAR image range sample spacing
img.dr = 1.25;

% img.x: SAR image along-track length
img.x = 125;

% img.r: SAR image range length
img.r = 125;

fn_img = fullfile(img.path_dir,'eecs800helper','img_rds.yaml');
yaml.dumpFile(fn_img, sys,'block');
