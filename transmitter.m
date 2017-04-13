close all;
clear all;

%%%%% parameters %%%%%
freq = 200;     % operating freq.
Fs = 20*freq;   % sampling freq.
L = 100;        % number of samples / symbol period.
Ts = 1/Fs;      % sampling period.
T = Ts:Ts:1/freq;  
alpha = 0.5;    % roll-off factor for the square-root raised cosine filters
N = 8*L;        % N+1 is the length of the square-root raised cosine filters
sigma_v = 0;    % standard deviation of channel noise
h = 1;          % channel impluse response

%%%%% Source %%%%%
pt_dt = input('Data you want to send:','s');
if isempty(pt_dt)
    pt_dt = 'Waleed Ejaz';
else
    pt_dt = pt_dt;
end
display(pt_dt);

RR = double(pt_dt);
bb = 1;
Rp = dec2bin(RR,7);
[TA TC] = size(Rp);

for ll = 1:1:TA
    for lg = 1:1:TC
        msg(bb) = Rp(ll,lg);
        bb = bb + 1;
    end
end

rt = 1; ht = 1;
for ls = 1:1:TA
    for ll = 1:2:(TC-1)
        Inp_msg(rt,(ht:ht+1)) = Rp(ls,(ll:ll+1));
    rt = rt + 1;
    end
end

%%%%% Transmit filter %%%%%
%pT = f_sr_cos_p(N,L,alpha);         % Transmit filter
%pT = rcosdesign(N, L, alpha);
pT = comm.RaisedCosineTransmitFilter(...
  'Shape',                  'Square root', ...
  'RolloffFactor',          alpha, ...
  'FilterSpanInSymbols',    N/L, ...
  'OutputSamplesPerSymbol', L)
xT = conv(f_expander(msg,L),pT);    % Transmit signal

%%%%% Modulation %%%%%
display('Select Type of Modulation');
display('1. BPSK');
display('2. QPSK');
Mod_Type = input('Plz Enter the Type of Modulation:','s');
Carrier = [];

% BPSK Modulation
if (Mod_Type=='1')
    display('Binary PSK');
    
for ii = 1:1:length(T)
    car1(ii) = sin((2*pi*freq*T(ii)));
end

for ii = 1:1:length(xT)
    if xT(ii) == '0'
        car = -1*car1;
    else
    car = 1*car1;
    end

    Carrier = [Carrier car];
end

% QPSK Modulation
else if(Mod_Type=='2')
    for ii = 1:1:length(T)
        car1(ii) = sin((2*pi*freq*T(ii))+360); %CARRIER TO BE TRANSMITTED
        car2(ii) = sin((2*pi*freq*T(ii))+90); %CARRIER TO BE TRANSMITTED
        car3(ii) = sin((2*pi*freq*T(ii))+180); %CARRIER TO BE TRANSMITTED
        car4(ii) = sin((2*pi*freq*T(ii))+270); %CARRIER TO BE TRANSMITTED
    end
    
    for ii = 1:1:length(Inp_msg)
        if Inp_msg(ii) == '00'
            car = car1;
        else if Inp_msg(ii) == '01'
            car = car2;
        else if Inp_msg(ii) == '10'
            car = car3;
        else if Inp_msg(ii) == '11'
            car = car4;
            end
            end
            end
        end
        
        Carrier = [Carrier car];
    end
    end % end of if
end %end of else if

%%%%% CHANNEL %%%%%
xR = conv(h,Carrier);
xR = xR+sigma_v*randn(size(xR)); % Received signal

