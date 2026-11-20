% 2026 EECS 800 hwA UAV SAR system design
%
% System design of a small UAV side-looking SAR: swath geometry, resolution,
% antenna size and gain, link budget and platform velocity, data rate, and
% receiver gain needed to drive the ADC
%
% The system is assumed to be an impulse radar (short pulse with no pulse
% compression). The last section considers what the chirp parameters would
% be for a deramp-on-receive system.

%% 1. Setup

clear;

if exist('eecs800helper','dir')
  % Add the eecs800helper directory to the path if it exists. This is where
  % the check function is usually located.
  addpath(fullfile('.','eecs800helper'));
end

%% 2. Given parameters

% BoltzmannConst: Boltzmann's constant (J/K)
BoltzmannConst = 1.380650524e-23;

% c: speed of light in free space (m/s)
c = 2.997924580003452e+08;

% NF: receiver noise figure (linear power ratio, 3 dB)
NF = 10^(3/10);

% Temp: noise temperature (K)
Temp = 290;

% H: height of the UAV above the ground (m)
H = 100;

% elev0_deg: elevation angle at the near edge of the swath (deg)
elev0_deg = 30;

% elev1_deg: elevation angle at the far edge of the swath (deg)
elev1_deg = 60;

% BW: transmit bandwidth (Hz)
BW = 1e9;

% fc: center frequency (Hz)
fc = 9.6e9;

% Pt: peak transmit power (W)
Pt = 0.1;

% bytes_per_sample: number of bytes recorded for each complex ADC sample
% (16 bit I and 16 bit Q, or 32 bits per complex sample)
bytes_per_sample = 4;

% SNR_adc_dB: ADC signal to quantization noise ratio at full scale (dB)
SNR_adc_dB = 72;

% Vpp: ADC full scale input voltage, peak to peak (V)
Vpp = 2;

% Z0: ADC input impedance (ohms), power is V^2/R
Z0 = 50;

% sigma_NESZ: required noise equivalent sigma zero (linear, -35 dB)
sigma_NESZ = 10^(-35/10);

% y0: ground range to the near edge of the swath (m)
y0 = H * tand(elev0_deg);

% y1: ground range to the far edge of the swath (m)
y1 = H * tand(elev1_deg);

% Plot the system geometry in the cross-track plane
figure(1); clf;
plot([0 1.1*y1], [0 0], 'k-', 'LineWidth', 2);
hold on;
plot([0 0], [0 H], 'k:');
plot([0 y0], [H 0], 'b-');
plot([0 y1], [H 0], 'r-');
plot([y0 y1], [0 0], 'g-', 'LineWidth', 4);
plot(0, H, 'kv', 'MarkerFaceColor', 'k');
hold off;
axis equal; grid on;
xlabel('Ground range (m)');
ylabel('Height (m)');
title('UAV SAR system geometry');
legend('Ground', 'Nadir', ...
  sprintf('Near edge (%g deg)', elev0_deg), ...
  sprintf('Far edge (%g deg)', elev1_deg), ...
  'Swath', 'UAV', 'Location', 'northeast');

%% 3. Swath range and time gate, r0, r1, t0, and t1

% r0: slant range to the near edge of the swath (m)
% HERE (EXAMPLE: "r0 = H / cosd(elev0_deg);")

% r1: slant range to the far edge of the swath (m)
% HERE

% t0: two-way travel time to the near edge of the swath (s)
% HERE

% t1: two-way travel time to the far edge of the swath (s)
% HERE

%% 4. Sampling frequency and resolution, fs, sigma_t, sigma_r, and sigma_x

% fs: sampling frequency (Hz), 25% oversampling of the bandwidth
% HERE

% sigma_t: time resolution (s), also the duration of the transmitted impulse
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

% beta_elev: cross-track antenna beamwidth (rad) needed to cover the swath
% from elev0_deg to elev1_deg
% HERE

% beta_sar_ideal: along-track antenna beamwidth (rad) needed to achieve the
% desired along-track resolution (use the arc-length approximation with the
% range to the far edge of the swath)
% HERE

% beta_sar: version 2 of the along-track antenna beamwidth (rad) where we
% assume that the along-track beamwidth is equal to the beamwidth that was
% calculated for beta_elev -- this is a reasonable approximate solution for
% a commercial off the shelf horn antenna
% beta_sar = beta_elev; % Uncomment this line

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
% Gr = G; % Uncomment this line

% Gt: transmit antenna gain (linear)
% Gt = G; % Uncomment this line

%% 6. Link budget and platform velocity, Pn, Ncoh, PRI, and vel

% sigma_rg: ground range resolution at the far edge of the swath (m)
% HERE

% A: scattering area of one ground resolution cell (m^2)
% HERE

% dx: along-track sample spacing of the recorded data (m)
% HERE

% Pn: noise power in W
% HERE

% Ncoh: number of pulses that must be coherently integrated to achieve
% sigma_NESZ at the far edge of the swath
% HERE

% PRI: pulse repetition interval (s), set equal to twice the maximum
% two-way travel time to the far edge of the swath
% HERE

% vel: platform velocity (m/s) that collects Ncoh pulses over the SAR
% aperture length L_sar
% HERE

%% 7. Data rate, Nsamp, EPRI, data_rate, and data_rate_MBPS

% Nsamp: number of fast-time samples across the swath
% HERE

% EPRI: effective pulse repetition interval (s), one record every dx. The
% pulses transmitted within each EPRI are coherently averaged into one
% record. dx is the maximum distance the radar can move before the Nyquist
% criterion requires a new sample in order to capture the along-track
% bandwidth needed for the desired SAR resolution.
% HERE

% data_rate: recorded data rate (bytes/s)
% HERE

% data_rate_MBPS: recorded data rate (megabytes/s)
% HERE

%% 8. ADC noise and receiver gain, P_fullscale_dBm, Pn_dBm, and G_rx_dB

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

%% 9. Deramp-on-receive system, dx_Tpd, Tpd, Kr, and BW_if

% NOTE: This section is a side calculation of the chirp parameters and IF
% bandwidth for a deramp-on-receive system. The rest of the assignment
% assumes an impulse radar design.

% dx_Tpd: the maximum along-track sample spacing for a real physical
% aperture of l_x (m). This is half the physical aperture because synthetic
% aperture radar moves both the transmit and receive antennas which doubles
% the wavenumber bandwidth and therefore also doubles the Nyquist sampling
% rate.
% HERE

% Tpd: pulse duration (s), set to be equal to the travel time for the radar
% to move one sample spacing dx_Tpd considering the velocity vel
% HERE

% Kr: chirp rate (Hz/s) from bandwidth, BW, and pulse duration, Tpd
% HERE

% BW_if: intermediate frequency (IF) bandwidth of the dechirped signal
% across the swath (Hz). This would be the complex sampling rate required
% for this deramp-on-receive system. Consider the maximum time gate across
% the swath and the chirp rate, Kr.
% HERE

hwA_uavsar_check;
