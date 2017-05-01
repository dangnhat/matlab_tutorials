%% Top-Down Design of a Spread Spectrum Receiver using Simulink
%
% *Design Specifications* 
%
% * data rate = 250 kBPS
% * direct sequence spread spectrum: chip rate = 2 Mchps
% * 1/2 sin pulse shaping filter
% * Sensivitity specification = -100 dBm
% * BER specification = 0.00625%
% * Existing ADC with 0 dBm saturation power and 10 effective bits
%
%% Design and verify 802.15 transmitter
%
% <matlab:open('TX_Model') transmitter>
%
% Compare to known waveform spectrum.
%
% <<.\Agilent_Zigbee.png>>
%
%% Determine SNR requirement
%
% <matlab:open('Link_Model') system model>
%
% _Design Outcome_
%
% _SNR=-0.5 dB_
%
%% Add ADC and determine system gain and NF
%
% RF Heuristic Design:
%
% * Noise Level = Sensitivity-SNR = -99.5 dBm
% * Noise Level = Noise Floor PSD + 10 log BW + NF
% * NF = -99.5 + 174 - 10 log (2.6 MHz) = 10 dB
%
% ADC Heuristic Design:
%
% * ENOB = 10
% * Saturation power = 0 dBm (50 Ohm normalization)
% * Dynamic Range = 6 ENOB + 2 = 62
% * 0.1 dB contribution to SNR: quantization noise = Noise Level - 16 dB
% * Gain = (Psat - Dynamic Range) - Noise Level + 16  = 53.5 dB
%
% <matlab:open('Idealized_BB_Model') idealized baseband model>
%
% _Design Outcome_
%
% * _NF=9 dB_
% * _Gain=45 dB_
%
% Note, simulation relaxes ADC SNR requirement from 16dB  to 8dB. 
%
%% Add direct conversion impairments and design RF Receiver
% * SAW Filter
% * LNA
% * Passive mixer for high IP2
% * VGA
%
% <matlab:open('Equivalent_BB_Model') equivalent baseband system model>
%
% _Design Outcome_
%
% * _System NF=7.5 dB (4,9,12)_
% * _Gain=42 dB (-2.5,20,-5,29)_
% * _In-band phase noise = -80dBc_
% * _Flicker noise corner frequency = 10 kHz_

%% Remove DSSS channel coding to reduce simulation time
%
% Disable channel coding to improve simulation performance
% 
% <matlab:open('Equivalent_BB_Model_CH') simplified equivalent baseband model>
%
%% Translate Eq. BB. design to Ckt. Env. and verify model performance
%
% <matlab:open('Circuit_Envelope_Model') circuit envelope system model>
%
% What's new?
% 
% * equivalent baseband mixer replaced with paramerizable I and Q mixers and phase
% shifter block
% * implicit I\O impedances replaced with broadband impedances (50 ohm)
% * explict phase noise source
% 
% Compare spectrum, power measurements, and BER to previous model
%
% Verify SAW filter performance
%
% Determine chip error rate: CER < 2.5%
%
%% Add wideband interference, LO feed-through and offset cancellation, and re-design RF receiver
%
% * -78 dB broadband RF-LO isolation in mixers modeled using subcircuits
% * digital offset cancellation block to compensate for DC offset
% * -20 dBm WCDMA blocker at 2500 MHz
%
% <matlab:open('Advanced_Circuit_Envelope_Model_SW') advanced circuit envelope model> 
%
% _Design Outcome_
%
% * _System NF=6 dB (2.5,9,12)_
% * _Mixer OIP2=60 dBm_
%
close all;
clear all;