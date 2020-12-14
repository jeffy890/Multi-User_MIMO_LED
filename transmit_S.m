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

% constant
resolution = 16;
att = 10;
repnumber = 20;
     
S = [0 0 0 0; 0 0 1 1; 1 1 0 0; 1 1 1 1;
   1 0 0 0; 0 1 0 1; 1 0 1 0; 0 1 1 1;
   0 0 0 1; 1 1 1 0; 1 0 0 1; 0 1 1 0;
   0 0 1 0; 0 1 0 0; 1 0 1 1; 1 1 0 1];
S = ((2*S)-1)';
S = (S*((2^resolution)-(2^(resolution-1))))/att;

signal1 = lowpass(repelem(S(1,:), repnumber));
signal2 = lowpass(repelem(S(2,:), repnumber));
signal3 = lowpass(repelem(S(3,:), repnumber));
signal4 = lowpass(repelem(S(4,:), repnumber));

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

txS = [signal1 ; signal2 ; signal3 ; signal4];
save('transmitted_signal_S.mat', 'txS');

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