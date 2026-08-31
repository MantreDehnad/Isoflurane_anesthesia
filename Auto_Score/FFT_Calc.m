function [EEG_Spectrum, EEG_Freq_Axis] = FFT_Calc(EEG_By_Epoch, Sampling_Rate)

% written by Sheng Xu, Oct. 2009
EEG_Spectrum = [];
EEG_Freq_Axis = [];

h = spectrum.welch('Hamming',512,50);

for i = 1:size(EEG_By_Epoch,2)
    x = EEG_By_Epoch(:,i);
    Hmss = msspectrum(h,x,'Fs',Sampling_Rate); 
              
    EEG_Spectrum(:,i) = Hmss.Data;
    
    if i == 1
        EEG_Freq_Axis = Hmss.Frequencies;
        
    end
    clear x Hmss;
   
end




