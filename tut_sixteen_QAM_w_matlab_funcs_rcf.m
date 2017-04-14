
%%% Generate a Random Binary Data Stream %%%
M = 16;                     % Size of signal constellation
k = log2(M);                % Number of bits per symbol
n = 3e5;                    % Number of bits to process
numSamplesPerSymbol = 4;    % Oversampling factor

span = 10;                  % Filter span in symbols
rolloff = 0.25;             % Rolloff factor

rng default                 % Use default random number generator
dataIn = randi([0 1],n,1);  % Generate vector of binary data

%%% Convert the Binary Signal to an Integer-Valued Signal %%%
dataInMatrix = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers

% figure; % Create new figure window.
% stem(dataSymbolsIn(1:10));
% title('Random Symbols');
% xlabel('Symbol Index');
% ylabel('Integer Value');

%%% Modulate using 16-QAM %%%
dataMod = qammod(dataSymbolsIn,M,0);         % Binary coding, phase offset = 0
%dataModG = qammod(dataSymbolsIn,M,0,'gray'); % Gray coding, phase offset = 0

%%% Create Raised Cosine filter %%%
rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);

%%% Generate Tx signal %%%
txSignal = upfirdn(dataMod, rrcFilter, numSamplesPerSymbol, 1);

%%% Add White Gaussian Noise %%%
EbNo = 10; % ratio of bit energy to noise power spectral density, Eb/N0, is arbitrarily set to 10 dB
snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol); % SNR

%%% Pass filtered signal to AWGN channel %%%
rxSignal = awgn(txSignal, snr, 'measured');

%%% Filter the received signal and remove a portion of signal to account
%%% for filter delay
rxFiltSignal = upfirdn(rxSignal,rrcFilter,1,numSamplesPerSymbol);   % Downsample and filter
rxFiltSignal = rxFiltSignal(span+1:end-span);                       % Account for delay


%%% Demodulate 16-QAM %%%
dataSymbolsOut = qamdemod(rxFiltSignal,M);

%%% Convert the Integer-Valued Signal to a Binary Signal %%%
dataOutMatrix = de2bi(dataSymbolsOut,k);
dataOut = dataOutMatrix(:);                   % Return data in column vector

%%% Compute the System BER %%%
[numErrors,ber] = biterr(dataIn,dataOut);
fprintf('\nThe binary coding bit error rate = %5.2e, based on %d errors\n', ...
    ber,numErrors)

%%% Visualization of Filter Effects %%%
% Filtered noiseless signal
eyediagram(txSignal(1:2000),numSamplesPerSymbol*2);

% Scatter plot of the received signal 
h = scatterplot(sqrt(numSamplesPerSymbol)*...
    rxSignal(1:numSamplesPerSymbol*5e3),...
    numSamplesPerSymbol,0,'g.');
hold on;
scatterplot(rxFiltSignal(1:5e3),1,0,'kx',h);
title('Received Signal, Before and After Filtering');
legend('Before Filtering','After Filtering');
axis([-5 5 -5 5]); % Set axis ranges
hold off;