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

% make the base signal
data1 = preprocessing(bit);
% copy and shift data1 to other channels
data2 = circshift(data1, 10);
data3 = circshift(data1, 20);
data4 = circshift(data1, 30);

signal1 = repelem(data1, repnumber/4);
signal2 = repelem(data2, repnumber/4);
signal3 = repelem(data3, repnumber/4);
signal4 = repelem(data4, repnumber/4);

signal1 = (signal1*2-1)*(2^resolution)/att;
signal2 = (signal2*2-1)*(2^resolution)/att;
signal3 = (signal3*2-1)*(2^resolution)/att;
signal4 = (signal4*2-1)*(2^resolution)/att;
% end of signal processing

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

% The transmitted signal must be given a different name to distinguish it from S.
%txS = [signal1 ; signal2 ; signal3 ; signal4];
%save('transmitted_signal.mat', 'txS_LASER');

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
