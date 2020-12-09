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
By executing "mu_mimo_transmitter.m" in main directory, the transmitted signal will be generated.
In "mu_mimo_transmitter.m", the generated signal can be choose by selecting the below number.

```matlab
prompt = 'What is the mode for mu_mimo function --> ';
mode_mu_mimo = input(prompt);
% mode 4  :  output signal S
% mode 3  :  output signal S plus 4b5b and nrzi
% mode 2  :  100Mbps data for Laser Diode
% mode 1  :  wS output
% mode 0  :  wd output
```  
In a normal experiment, choose mode4 > mode0 > mode1.  
The receiver code is in Rx_processing directory.
