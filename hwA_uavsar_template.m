% 2026 EECS 800 hwA UAV SAR system design
%
% System design of a small UAV side-looking SAR: swath geometry, resolution,
% antenna size and gain, link budget and platform velocity, data rate,
% chirp parameters, and receiver gain needed to drive the ADC

%% 1. Setup

clear

my_path_dir = 'C:\git\eecs800\'; % Update this if needed

path(pathdef)
addpath(fullfile(my_path_dir));
addpath(fullfile(my_path_dir,'eecs800helper'));

physical_constants('c','BoltzmannConst'); % Loads c and Boltzmann's constant

%% 2. Given parameters

% NF: receiver noise figure (linear power ratio, 3 dB)
NF = 10^(3/10);

% Temp: noise temperature (K)
Temp = 290;

% H: height of the UAV above the ground (m)
H = 100;

% inc0_deg: incidence angle at the near edge of the swath (deg)
inc0_deg = 30;

% inc1_deg: incidence angle at the far edge of the swath (deg)
inc1_deg = 60;

% BW: transmit bandwidth (Hz)
BW = 1e9;

% fc: center frequency (Hz)
fc = 9.6e9;

% Pt: transmit power (W)
Pt = 0.1;

% bytes_per_sample: number of bytes recorded for each ADC sample
bytes_per_sample = 4;

% SNR_adc_dB: ADC signal to quantization noise ratio at full scale (dB)
SNR_adc_dB = 72;

% Vpp: ADC full scale input voltage, peak to peak (V)
Vpp = 2;

% Z0: ADC input impedance (ohms), power is V^2/R
Z0 = 50;

% sigma_NESZ: required noise equivalent sigma zero (linear, -35 dB)
sigma_NESZ = 10^(-35/10);

%% 3. Swath range and time gate, r0, r1, t0, and t1

% r0: slant range to the near edge of the swath (m)
% HERE (EXAMPLE: "r0 = H / cosd(inc0_deg);")

% r1: slant range to the far edge of the swath (m)
% HERE

% t0: two-way travel time to the near edge of the swath (s)
% HERE

% t1: two-way travel time to the far edge of the swath (s)
% HERE

%% 4. Sampling frequency and resolution, fs, sigma_t, sigma_r, and sigma_x

% fs: sampling frequency (Hz), 25% oversampling of the bandwidth
% HERE

% sigma_t: time resolution (s)
% HERE

% sigma_r: range resolution (m)
% HERE

% sigma_x: along-track resolution (m), set equal to the range resolution
% HERE

%% 5. SAR aperture length and antenna, L_sar, l_x, l_y, Ae, and G

% lambda_fc: wavelength at the center frequency
% HERE

% L_sar: SAR aperture length needed for sigma_x resolution at the far edge
% of the swath (m)
% HERE

% beta_deg: antenna beamwidth needed to cover the swath from inc0_deg to
% inc1_deg (deg)
% HERE

% beta: antenna beamwidth (rad)
% HERE

% l_x: along-track length of the antenna (m)
% HERE

% l_y: cross-track length of the antenna (m)
% HERE

% Ae: effective area of the antenna (m^2)
% HERE

% G: antenna gain (linear)
% HERE

% G_dB: antenna gain (dBi)
% HERE

% Gr: receive antenna gain (linear)
% HERE

% Gt: transmit antenna gain (linear)
% HERE

%% 6. Link budget and platform velocity, Pn, Ncoh, PRI, and vel

% sigma_rg: ground range resolution at the far edge of the swath (m)
% HERE

% A: scattering area of one resolution cell (m^2)
% HERE

% dx: along-track sample spacing of the recorded data (m)
% HERE

% Pn: noise power in W
% HERE

% Ncoh: number of pulses that must be coherently integrated to achieve
% sigma_NESZ at the far edge of the swath
% HERE

% PRI: pulse repetition interval (s), set equal to the two-way travel time
% across the swath
% HERE

% vel: platform velocity (m/s) that collects Ncoh pulses over the SAR
% aperture length L_sar
% HERE

%% 7. Data rate, Nsamp, EPRI, data_rate, and data_rate_MBPS

% Nsamp: number of fast-time samples across the swath
% HERE

% EPRI: effective pulse repetition interval (s), one record every dx
% HERE

% data_rate: recorded data rate (bytes/s)
% HERE

% data_rate_MBPS: recorded data rate (megabytes/s)
% HERE

%% 8. Chirp parameters and IF bandwidth, Tpd, Kr, and BW_if

% Tpd: pulse duration (s), one chirp every dx
% HERE

% Kr: chirp rate (Hz/s)
% HERE

% BW_if: intermediate frequency (IF) bandwidth of the dechirped signal
% across the swath (Hz)
% HERE

%% 9. ADC noise and receiver gain, P_fullscale_dBm, Pn_dBm, and G_rx_dB

% P_fullscale: power of a full scale sine wave at the ADC input (W)
% HERE

% P_fullscale_dBm: power of a full scale sine wave at the ADC input (dBm)
% HERE

% Pn_quantization_dBm: ADC quantization noise power (dBm)
% HERE

% Pn_dBm: thermal noise power at the receiver input (dBm)
% HERE

% G_rx_dB: receiver gain that puts the thermal noise 10 dB above the ADC
% quantization noise (dB)
% HERE

hwA_uavsar_check;
