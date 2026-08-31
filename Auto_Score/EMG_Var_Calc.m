function EMG_Var = EMG_Var_Calc(EMG, Sampling_Rate, Epoch_Dur)
% written by Sheng Xu, Oct. 2009

EMG = abs(EMG);

Mini_Epoch_Dur = 0.5;   % 0.5 seconds mini epoch
Mini_Epoch_Length = Mini_Epoch_Dur * Sampling_Rate;

EMG_By_Mini_Epoch = reshape(EMG, Mini_Epoch_Length, []);
EMG_Integ = sum(EMG_By_Mini_Epoch);

Mini_Epoch_Count = Epoch_Dur/Mini_Epoch_Dur;
EMG_Integ_By_Epoch = reshape(EMG_Integ, Mini_Epoch_Count, []);

EMG_Var = var(EMG_Integ_By_Epoch);

