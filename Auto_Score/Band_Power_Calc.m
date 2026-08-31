function band_power = Band_Power_Calc(EEG_Spectrum,start_freq,end_freq,freq_step)

% written by Sheng Xu, Oct. 2009

start_index = floor(start_freq/freq_step + 1);
end_index = ceil(end_freq/freq_step + 1);

band_power = sum(EEG_Spectrum(start_index:end_index,:));

