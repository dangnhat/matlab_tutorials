function noise_filt=pinkNoise(Npts, Fs, fcorner, Pcorner_dBm,R)
% Derived from Dick Benson's phase noise block
% Npts=filter length
% Fs=sampling frequency
% fcorner=1/f noise frequency
% Pcorner_dBm=1/f noise level in dBm
%
% This function generates a discrete time model for a flicker noise source.
% The transfer function magnitude is constructed from a sample of the 
% flicker noise curve.  Linear phase is assumed.  Symmetry is enforced.
% IFFT of the transfer function generates the filter coefficients.  Apply Hann
% window to satisfy Fourier Series requirements.

%*** Define the Model in the Frequency Domain ***
Pcorner=1e-3*10^((Pcorner_dBm-3)/10); % dBm/Hz to watts conversion, 3dB offset to account for SSB power definition
Constant=Pcorner*fcorner; % PSD defined at fcorner, by definition noise has 1/f shape, so Constant/f @ fcorner is defined power

L     = round(Npts/2);      % filter TF is symmetric about f=0   
fnorm     =(0:(L-1))/L;     % frequency vector normalized to Fs/2
f = fnorm*Fs/2;             % frequency vector
ph    = pi*(0:L-1);         % phase shift to center filter kernel in time window

mag=zeros(1,L);
mag(2:end)=sqrt(Constant*R./f(2:end));
mag(1) = spline(f(2:end),mag(2:end),0);   % use spline to extrapolate f=0

magnitude=[mag,0, fliplr(mag(2:end))];    % construct magnitude
phase=[-ph,0,fliplr(ph(2:end))];          % and phase 
H=magnitude.*exp(j*phase);                % complex representation

% *** ifft to generate the corresponding filter coefficients ***
h=ifft(H);                                % FIR filter coefficients 
hout=h.*hann(2*L)';             
noise_filt=hout;