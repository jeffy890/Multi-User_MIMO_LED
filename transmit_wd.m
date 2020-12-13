clear all;
clc;

% Load the AnalogDevices DPG .Net Assembly
NET.addAssembly('AnalogDevices.DPG.Interfaces');
%disp('DPG.Interfaces.dll assembly was loaded.');

ads7 = GetAds7(false);   % true = force download FPGA config, false = auto
disp(['Found Device: ', char(ads7.FriendlyName)]);

jesd204 = ads7.JESD204;
frameNum = 0+1;      % first frame index (.net uses 0 based arrays)

mode = 0;
ad9144setup(ads7, mode);

resolution = 16;
bit = 8;
bitlength = 2^bit;
att = 10;
repnumber = 20;

%  channel matrix h
H = [1 0 0 0;
     0 1 0 0;
     0 0 1 0;
     0 0 0 1 ];
% if you have H data, you can import it.     
% H = importdata('');

% inverce of H
iH = inv(H);

% the degree of interference
DI = zeros(1,4);
DI(1) = ( H(1,2) + H(1,3) + H(1, 4) ) / H(1,1);
DI(2) = ( H(2,1) + H(2,3) + H(2, 4) ) / H(2,2);
DI(3) = ( H(3,1) + H(3,2) + H(3, 4) ) / H(3,3);
DI(4) = ( H(4,1) + H(4,2) + H(4, 3) ) / H(4,4);

% make the base signal
data1 = preprocessing(bit);
% copy and shift data1 to other channels
data2 = circshift(data1, 10);
data3 = circshift(data1, 20);
data4 = circshift(data1, 30);

% wd signal processing
%  preparation of send matrix
mimo1 = zeros(1, bitlength*5/4);
mimo2 = zeros(1, bitlength*5/4);
mimo3 = zeros(1, bitlength*5/4);
mimo4 = zeros(1, bitlength*5/4);
%  MIMO processing (wX)
for i = 1:(2^8)*5/4
    mimo1(i) = iH(1,1) * data1(i) + iH(1,2) * data2(i) + iH(1,3) * data3(i) + iH(1,4) * data4(i);
    mimo2(i) = iH(2,1) * data1(i) + iH(2,2) * data2(i) + iH(2,3) * data3(i) + iH(2,4) * data4(i);
    mimo3(i) = iH(3,1) * data1(i) + iH(3,2) * data2(i) + iH(3,3) * data3(i) + iH(3,4) * data4(i);
    mimo4(i) = iH(4,1) * data1(i) + iH(4,2) * data2(i) + iH(4,3) * data3(i) + iH(4,4) * data4(i);
end

% bias max min
bmax = [bmax1 bmax2 bmax3 bmax4];
bmin = [bmin1 bmin2 bmin3 bmin4];
bmax = max(bmax);
bmin = min(bmin);

% (wX + bmin) / bmax
mimo1 = (mimo1 + abs(bmin)) / (bmax + abs(bmin));
mimo2 = (mimo2 + abs(bmin)) / (bmax + abs(bmin));
mimo3 = (mimo3 + abs(bmin)) / (bmax + abs(bmin));
mimo4 = (mimo4 + abs(bmin)) / (bmax + abs(bmin));

signal1 = ((repelem(mimo1, repnumber)*(2^resolution))-(2^(resolution-1)))/att;
signal2 = ((repelem(mimo2, repnumber)*(2^resolution))-(2^(resolution-1)))/att;
signal3 = ((repelem(mimo3, repnumber)*(2^resolution))-(2^(resolution-1)))/att;
signal4 = ((repelem(mimo4, repnumber)*(2^resolution))-(2^(resolution-1)))/att;
% end of signal processing wd

subplot(4,1,1);
plot(signal1);
title('signal1');

subplot(4,1,2);
plot(signal2);
title('signal2');

subplot(4,1,3);
plot(signal3);
title('signal3');

subplot(4,1,4);
plot(signal4);
title('signal4');

% The transmitted signal wd must be given a different name to distinguish it from S.
txS = [signal1 ; signal2 ; signal3 ; signal4];
save('transmitted_signal.mat', 'txS_wd');

signal1 = lowpass(signal1);
signal2 = lowpass(signal2);
signal3 = lowpass(signal3);
signal4 = lowpass(signal4);

% Fill the vector array for all dacs.
% DPG arrays are organized as: [DAC][Array of samples]
numDacs = jesd204.Framers(frameNum).M+1;
if (numDacs > 2)
    dpg_array = [signal1; signal2; signal3; signal4];
elseif (numDacs > 1)
    dpg_array = [signal1; signal2; signal3; signal4];
else
    dpg_array = signal1;
end

jesd204.Framers(frameNum).DownloadData(dpg_array, false);

ads7.PlayMode = AnalogDevices.DPG.Interfaces.HardwareDeviceTypes.PlayModeE.Loop;
ads7.StartPlayback;
pause(1)
disp(['Serial Line Rate: ', num2str(jesd204.Framers(frameNum).LineRate)]);
