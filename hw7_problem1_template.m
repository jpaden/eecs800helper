% 2026 EECS 800 hw7 problem 1 coregistration simulator
%
% Simulator to create a primary image and a misregistered secondary image
% for testing image coregistration
%
% Image coordinate system
% * rows are the first dimension of the image matrix (range in a SAR image)
% * columns are the second dimension of the image matrix (along-track in a
% SAR image)
% * The secondary image is the primary image shifted by shift_row rows and
% shift_col columns so that:
%   secondary_img(r,c) = primary_img(r + shift_row, c + shift_col)
% A positive shift_row moves the image content up (toward smaller row
% indices) and a positive shift_col moves the image content left (toward
% smaller column indices).
% * The shifts are not required to be an integer number of pixels so the
% shifts are applied in the frequency domain.
%
% Units
% * All shifts, lags, and offsets are in units of pixels (rows or columns)
% * Powers are relative (unitless)

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

%% 2. Define image parameters

img = [];

img.name = 'speckle';

% img.Nr: number of rows in the simulated images
img.Nr = 200;

% img.Nc: number of columns in the simulated images
img.Nc = 200;

%% 3. Define signal and noise parameters

% signal_power: mean power of the speckle signal in each pixel of the
% primary image (relative, unitless)
signal_power = 1;

% SNR_dB: signal to noise ratio (dB) of the complex white Gaussian noise
% that is independently added to the primary and secondary images
SNR_dB = 20;

% noise_power: mean power of the noise in each pixel from signal_power and
% SNR_dB
noise_power = signal_power / 10^(SNR_dB/10);

% oversample: factor by which the speckle is oversampled. The speckle is
% low pass filtered with a 2D sinc filter whose zero crossings are spaced
% by oversample pixels so that the images are oversampled by this factor in
% each dimension. This >2x oversampling is necessary so that when we power
% detect the data, it will still be Nyquist sampled. Power detection
% doubles the bandwidth since the time-space domain multiplication with the
% matrix's conjugate is the same as convolution in the frequency-wavenumber
% domain of the spectrum with its own conjugate-reversed copy. This doubles
% the bandwidth (similar to how a rect function convolved with itself
% produces a triangle that is twice as wide as the original rect function).
oversample = 2.5;

% Nr_lpf: half-width of the low pass filter kernel in rows. The kernel has
% 2*Nr_lpf+1 rows.
Nr_lpf = 5;

% Nc_lpf: half-width of the low pass filter kernel in columns. The kernel
% has 2*Nc_lpf+1 columns.
Nc_lpf = 5;

% shift_row: row misregistration of the secondary image relative to the
% primary image (pixels). See the header for the sign convention.
shift_row = 2.5;

% shift_col: column misregistration of the secondary image relative to the
% primary image (pixels). See the header for the sign convention.
shift_col = -3.375;

%% 4. Create primary image

% Reset random number generator so that the results are repeatable
rng(0);

% primary_img_unfiltered: random complex Gaussian (speckle) image with each
% pixel independent and identically distributed with power signal_power.
% Size img.Nr by img.Nc.
% * Use the randn function. randn returns Gaussian random numbers with
%   zero mean and unit variance (unit power). randn(img.Nr,img.Nc) returns
%   an img.Nr by img.Nc matrix of them, each independent of the others.
% * A complex Gaussian random number has independent Gaussian real and
%   imaginary parts. The power of a complex number z is
%   abs(z)^2 = real(z)^2 + imag(z)^2, so the power is split evenly between
%   the real and imaginary parts. For a single scalar pixel with power P:
%     z = sqrt(P/2) * (randn + 1i*randn);
%   Each part has power P/2 so the mean of abs(z)^2 is P.
% * Do the same thing for a whole img.Nr by img.Nc matrix with P equal to
%   signal_power. Call randn for the real part first and then for the
%   imaginary part so that the random numbers match the check.
% HERE

% H_window_lpf_rows: relative row axis of the low pass filter kernel.
% Column vector.
H_window_lpf_rows = (-Nr_lpf:Nr_lpf).';

% H_window_lpf_cols: relative column axis of the low pass filter kernel.
% Row vector.
H_window_lpf_cols = -Nc_lpf:Nc_lpf;

% H_window_lpf: 2D separable sinc low pass filter kernel with zero
% crossings spaced by oversample pixels. Normalize the kernel to have unit
% energy so that the filtered image has the same mean power as the
% unfiltered image.
% * Use the sinc function. MATLAB's sinc(x) is sin(pi*x)/(pi*x). The
%   row-axis sinc is sinc(H_window_lpf_rows/oversample), which has zero
%   crossings every oversample pixels. The column-axis sinc is the same
%   with H_window_lpf_cols.
% * Multiply the row-axis sinc (column vector) by the column-axis sinc (row
%   vector) with the matrix multiply operator *. This outer product is
%   (2*Nr_lpf+1) by (2*Nc_lpf+1).
% * Divide the kernel by the square root of its energy. Use the sum
%   function on the squared values of every element, H_window_lpf(:).^2,
%   and then the sqrt function.
% HERE

% primary_img_noiseless: primary image created by applying the 2D low pass
% filter to primary_img_unfiltered. Use the filter2 function with
% H_window_lpf as the first input, primary_img_unfiltered as the second
% input, and the 'same' option so that the size is unchanged.
% HERE

%% 5. Create secondary image

% f_row: DFT row-frequency axis (cycles per pixel) in the standard FFT
% order (zero frequency first). Column vector of length img.Nr. Start with
% the centered integer axis -floor(img.Nr/2) : floor((img.Nr-1)/2), use
% the ifftshift function to move zero frequency to the first element,
% divide by img.Nr
% to convert to cycles per pixel, and transpose to a column vector.
% HERE

% f_col: DFT column-frequency axis (cycles per pixel) in the standard FFT
% order (zero frequency first). Row vector of length img.Nc. Same as f_row
% but with img.Nc and without the transpose.
% HERE

% primary_img_f: 2D DFT of primary_img_noiseless. Use the fft2 function.
% HERE

% secondary_img_f: apply a linear phase to primary_img_f in the row
% dimension to shift the image up by shift_row rows and a linear phase in
% the column dimension to shift the image left by shift_col columns
% * DFT shift property: x(n + n0) has the DFT X(f)*exp(1i*2*pi*f*n0) where
%   f is in cycles per sample. Use the exp function to make the linear
%   phase. Apply it in the row dimension with f_row and shift_row and in
%   the column dimension with f_col and shift_col. Multiply element by
%   element with the .* operator.
% * The column vector f_row and the row vector f_col expand automatically
%   to the img.Nr by img.Nc size of primary_img_f.
% HERE

% secondary_img_noiseless: inverse 2D DFT of secondary_img_f to create the
% shifted secondary image. Use the ifft2 function.
% HERE

%% 6. Add noise

% primary_img: add independent complex white Gaussian noise with power
% noise_power to primary_img_noiseless. Create the img.Nr by img.Nc noise
% matrix the same way as primary_img_unfiltered (use the randn function
% for the real part first and then for the imaginary part) but with the
% power P equal to noise_power instead of signal_power. "White" means that
% the noise in each pixel is independent of the noise in every other pixel,
% which randn already gives you.
% HERE

% secondary_img: add independent complex white Gaussian noise with power
% noise_power to secondary_img_noiseless. Same as primary_img. Call randn
% again for a new noise matrix (do not reuse the primary image's noise)
% after the primary image noise so that the random numbers match the check.
% HERE

%% 7. Save simulation data

raw = [];
raw.primary_img = primary_img;
raw.secondary_img = secondary_img;

truth = [];
truth.shift_row = shift_row;
truth.shift_col = shift_col;

fn_raw = fullfile(my_temp_dir,'raw_coregistration_hw7.mat');
save(fn_raw,'raw','img','truth','-v7.3','-nocompression');

%% 8. Low pass filter kernel plot in figure 1

h_fig = figure(1); set(h_fig,'WindowStyle','docked'); clf;
imagesc(H_window_lpf_cols,H_window_lpf_rows,H_window_lpf);
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Amplitude');
title('Sinc low pass filter kernel')
xlabel('Relative column');
ylabel('Relative row');

%% 9. Unfiltered and filtered primary image plots in figure 2

h_fig = figure(2); set(h_fig,'WindowStyle','docked'); clf;
subplot(1,2,1);
imagesc(db(primary_img_unfiltered));
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Unfiltered primary image')
xlabel('Column');
ylabel('Row');

subplot(1,2,2);
imagesc(db(primary_img_noiseless));
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Filtered primary image')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

%% 10. Primary and secondary image plots in figure 3

h_fig = figure(3); set(h_fig,'WindowStyle','docked'); clf;
imagesc(db(primary_img));
h_axes = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Primary image')
xlabel('Column');
ylabel('Row');

h_fig = figure(4); set(h_fig,'WindowStyle','docked'); clf;
imagesc(db(secondary_img));
h_axes(2) = gca;
hcolor = colorbar;
set(get(hcolor,'YLabel'),'String','Relative power (dB)');
title('Secondary image')
xlabel('Column');
ylabel('Row');

linkaxes(h_axes);

hw7_problem1_check;
