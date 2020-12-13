# Multi-User MIMO Experiments code

### based on the master research (2018.4 - 2020.3)

### Contents
code for Multi-User MIMO experiments
some wavedata that was captured in the experiments

### Required equipments
- AD9144 DAC
- ADS7 eval board
- DLM2024 2.5GS/s 200MHz Oscillo
- LED transmitters & PD receivers

### How to execute code and get data
The code "transmit_S.m" should be executed first. It transmits S for calculating H.<br>
After calculating H, use the H into "transmit_wd.m" and transmit wd.<br>
<br>
The "transmit_wS.m" transmits wS that is processed by iH. This signal can be used for calculating the next H.<br>
<br>
