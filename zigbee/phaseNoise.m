function noise_filt=phaseNoise(Npts, Freq, Level_dB, Fs,Verify)
% noise_filt=noise_profile(Npts,Level,Freq,Fs,Verify); 
% Npts = length of filter kernel. More provides increased freq resolution
% Freq     = Vector of frequencies in Hz
% Level_dB = Corresponding Vector of noise levels
% Fs       = Sampling rate in Hz
% Verify   = true to show plots
% Create a filter kernel (FIR coefficients) that approximates a user spec'd
% power spectrum Level is dB/Hz
% To get dBc, carrier must be 1 Watt.
% Dick Benson  May 2007

L     = round(Npts/2);         
f     =(0:(L-1))/L;     % frequency vector normalized to Fs/2
ph    = pi*(0:L-1);     % phase shift to center filter kernel in time window

  if(Fs < 2*Freq(end))
     errordlg('Sampling rate: Fs,  must be  > 2*Freq(end)')
  end;
  
  Level    = [Level_dB(1),Level_dB,Level_dB(end)]; % pad start and end
  Freq     = [0,Freq,Fs/2];                        % ditto
  % linearly interpolate in the dB realm.
  shape_dB = interp1(Freq,Level,f*Fs/2,'linear');
  shape    =   10.^(shape_dB/20);

  dFspec = min(diff(Freq(2:end)));
  dF     = Fs/Npts;
  if dFspec<dF
     warndlg(['The frequency resolution of the Spec is greater than can be achieved. Consider Increasing the number of Points in the FIR Kernel, or removing the low Frequency Specs.',sprintf('F=%10.2f  ',Freq(2:3)), 'etc.'],[ 'Freq REsolution']); 
  end;

% Need to create a complex spectral description 
% which, when transformed with the ifft, creates a REAL impulse response.

mag=[shape,0, fliplr(shape(2:end))]; % construct magnitude
phase=[-ph,0,fliplr(ph(2:end))];     % and phase 
H=mag.*exp(j*phase);  % complex representation
h=ifft(H);            % Filter Kernel 

%  sanity checks ....
if Verify
   hf    =  findobj('Tag','plot_8b');
   if isempty(hf) 
      hf =  figure('Tag','plot_8b');
   else
      figure(hf);
   end

   subplot(2,1,1)
   plot((h)); title('Filter Impulse Response (no window)');
   xlabel('samples')
end;

% If the filter is used as is, there may be ripples in the frequency
% reponse due to the abrupt transistions at the impulse response endpoints.
% To mitigate this, apply a Hanning window and compare computed response with
% the spec and interpoloted spec. 

hout=h.*hann(2*L)';

if Verify
   H2=fft(hout);            % take fft of windowed filter kernel
   subplot(2,1,2)
   semilogx(f/2*Fs,20*log10(abs(H2(1:L))),f/2*Fs,20*log10(shape),'x',Freq,Level,'o'); 
   legend('Filter Response','Interpolated Spec','Spec','location','southwest');
   title('Freq Responses of Specification and Attained Noise Profiles.  ');
   xlabel('Freq'); ylabel('dB');
end;

noise_filt=hout;