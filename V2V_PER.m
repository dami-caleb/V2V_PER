% Link parameters
mcs = 2;       % QPSK rate 1/2
psduLen = 500; % PSDU length in bytes

% Create a format configuration object for an 802.11p transmission
cfgNHT = wlanNonHTConfig;
cfgNHT.ChannelBandwidth = 'CBW10';
cfgNHT.PSDULength = psduLen;
cfgNHT.MCS = mcs;

% Create and configure the channel
fs = wlanSampleRate(cfgNHT); % Baseband sampling rate for 10 MHz

chan = V2VChannel;
chan.SampleRate = fs;
chan.DelayProfile = 'Urban NLOS';

snr = 15:5:30;

maxNumErrors = 20;   % The maximum number of packet errors at an SNR point
maxNumPackets = 200; % The maximum number of packets at an SNR point

% Set random stream for repeatability of results
s = rng(98);

% Set up a figure for visualizing PER results
h = figure;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([snr(1), snr(end)]);
ylim([1e-3 1]);
xlabel('SNR (dB)');
ylabel('PER');
h.NumberTitle = 'off';
h.Name = '802.11p ';
title(['MCS ' num2str(mcs) ', V2V channel - ' chan.DelayProfile ' profile']);

% Simulation loop for 802.11p link
S = numel(snr);
per_LS = zeros(S,1);
per_STA = per_LS;
for i = 1:S
    enableChanTracking = true;
    %802.11p link with channel tracking
    per_STA(i) = v2vPERSimulator(cfgNHT, chan, snr(i), ...
        maxNumErrors, maxNumPackets, enableChanTracking);

    enableChanTracking = false;
    % 802.11p link without channel tracking
    per_LS(i) = v2vPERSimulator(cfgNHT, chan, snr(i), ...
        maxNumErrors, maxNumPackets, enableChanTracking);

    semilogy(snr, per_STA, 'bd-');
    semilogy(snr, per_LS, 'ro--');
    legend('with Channel Tracking','without Channel Tracking')
    drawnow;
end

axis([10 35 1e-3 1])
hold off;

% Restore default stream
rng(s);
