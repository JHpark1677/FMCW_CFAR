numADCsamples = 256;
numChirps = 128;
numTx=2;
numFrames =200; % Frame time 50ms
numAntennas = 4;
numVirtualAnt=numAntennas*numTx;
Tidle = 100e-6;    % duration of idle time
Tramp = 60e-6;    % duration of ramp
Tc = Tramp+Tidle;    % duraion of chirp

fc = 77e9;    % carrier frequency
S = 29.982e12;    % slope of the chirp
B = Tramp*S;    % bandwidth

fs =10e6;    % sampling frequency
Ts = 1/fs;    % sampmling period

ADC_start_time = 6e-6;    % time until sampling starts
fc_start = fc+ADC_start_time*S;    % frequency of the first sample
fc_end = fc_start+numADCsamples*Ts*S;   % frequency of the last sample
Beff = fc_end-fc_start;    % effective bandwidth spanned by samples
c = physconst('Lightspeed');
lambda = c/mean([fc_start,fc_end]);    % wavelength of the signal
d = lambda/2;    % distance between adjacent antennas

Rres = c/(2*Beff); 
Rmax = (fs*c)/(2*S);    % 0~Rmax
vres = lambda/(2*numChirps*Tc);
vmax = lambda/(4*Tc);    % -vmax~vmax

Raxis = 0:Rres:Rres*(numADCsamples-1);
Raxis_rev = Raxis(1:numADCsamples/2);
vaxis = -vres*(numChirps/2):vres:vres*(numChirps/2-1);
angleFFTsize = 64;
angleaxis = rad2deg(asin((lambda/d)*(1/angleFFTsize)*linspace(-angleFFTsize/2,angleFFTsize/2-1,angleFFTsize)));

% % plot the transmitted chirp signal
% t = linspace(Ts,Tc,Tc/Ts);
% s = zeros(1,length(t));
% num_Tidle_samples = floor(Tidle/Ts);
% num_Tramp_samples = floor(Tramp/Ts);
% for i = 1:num_Tramp_samples
%     temp(i) = fc+Ts*i*S;
% end
% s(1:num_Tidle_samples) = fc;
% s(num_Tidle_samples+1:end) = temp;
% 
% samples = zeros(1,numADCsamples);
% for i = 1:numADCsamples
%     samples(i) = fc_start+i*Ts*S;
% end
% tstart = (Tidle+ADC_start_time)/Ts;
% tsamples = (tstart+1:tstart+numADCsamples)*Ts;
% 
% figure()
% plot(t,s)
% hold on
% plot(tsamples,samples,'*')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% axis([0 Tc 7.65e10,7.95e10])
% grid on