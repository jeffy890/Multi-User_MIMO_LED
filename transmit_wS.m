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

% wS signal processing
% preparation of send matrix
mimo1 = zeros(1, 16);
mimo2 = zeros(1, 16);
mimo3 = zeros(1, 16);
mimo4 = zeros(1, 16);
% MIMO processing for signal S (wS)
for i = 1:(16)  
    mimo1(i) = iH(1,1) * S(1,i) + iH(1,2) * S(2,i) + iH(1,3) * S(3,i) + iH(1,4) * S(4,i);
    mimo2(i) = iH(2,1) * S(1,i) + iH(2,2) * S(2,i) + iH(2,3) * S(3,i) + iH(2,4) * S(4,i);
    mimo3(i) = iH(3,1) * S(1,i) + iH(3,2) * S(2,i) + iH(3,3) * S(3,i) + iH(3,4) * S(4,i);
    mimo4(i) = iH(4,1) * S(1,i) + iH(4,2) * S(2,i) + iH(4,3) * S(3,i) + iH(4,4) * S(4,i);
end
% bias max min
bmax1 = max(mimo1);
bmin1 = min(mimo1);
bmax2 = max(mimo2);
bmin2 = min(mimo2);
bmax3 = max(mimo3);
bmin3 = min(mimo3);
bmax4 = max(mimo4);
bmin4 = min(mimo4);
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
% end of signal processing wS

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

% The transmitted signal wS must be given a different name to distinguish it from S.
txS = [signal1 ; signal2 ; signal3 ; signal4];
save('transmitted_signal.mat', 'txS_wS');

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
