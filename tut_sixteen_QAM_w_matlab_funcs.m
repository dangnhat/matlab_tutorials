
%%% Generate a Random Binary Data Stream %%%
M = 16;                     % Size of signal constellation
k = log2(M);                % Number of bits per symbol
n = 30000;                  % Number of bits to process
numSamplesPerSymbol = 1;    % Oversampling factor

rng default                 % Use default random number generator
dataIn = randi([0 1],n,1);  % Generate vector of binary data

%%% Convert the Binary Signal to an Integer-Valued Signal %%%
dataInMatrix = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers

figure; % Create new figure window.
stem(dataSymbolsIn(1:10));
title('Random Symbols');
xlabel('Symbol Index');
ylabel('Integer Value');

%%% Modulate using 16-QAM %%%
dataMod = qammod(dataSymbolsIn,M,0);         % Binary coding, phase offset = 0
dataModG = qammod(dataSymbolsIn,M,0,'gray'); % Gray coding, phase offset = 0

%%% Add White Gaussian Noise %%%
EbNo = 10; % ratio of bit energy to noise power spectral density, Eb/N0, is arbitrarily set to 10 dB
snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol); % SNR

receivedSignal = awgn(dataMod,snr,'measured');
receivedSignalG = awgn(dataModG,snr,'measured');

%%% Create a Constellation Diagram %%%
sPlotFig = scatterplot(receivedSignal,1,0,'g.');
hold on
scatterplot(dataMod,1,0,'k*',sPlotFig)

%%% Demodulate 16-QAM %%%
dataSymbolsOut = qamdemod(receivedSignal,M);
dataSymbolsOutG = qamdemod(receivedSignalG,M,0,'gray');

%%% Convert the Integer-Valued Signal to a Binary Signal %%%
dataOutMatrix = de2bi(dataSymbolsOut,k);
dataOut = dataOutMatrix(:);                   % Return data in column vector
dataOutMatrixG = de2bi(dataSymbolsOutG,k);
dataOutG = dataOutMatrixG(:);                 % Return data in column vector

%%% Compute the System BER %%%
[numErrors,ber] = biterr(dataIn,dataOut);
fprintf('\nThe binary coding bit error rate = %5.2e, based on %d errors\n', ...
    ber,numErrors)
[numErrorsG,berG] = biterr(dataIn,dataOutG);
fprintf('\nThe Gray coding bit error rate = %5.2e, based on %d errors\n', ...
    berG,numErrorsG)
