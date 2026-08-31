function [out] = hpf(sig, sr, w0)
%Written by Roshan Nanu, July 2014

%normalize signal
%EMG = EMG - mean(EMG);
%EMG = EMG/max(abs(EMG));

wp = 2*w0/sr;
[b,a] = butter(2,wp,'high');
%filt = filter(b,a,[1 zeros(1,12)]);
%filtEMG = conv(EMG,filt);
%filtEMG = filtEMG/max(abs(filtEMG));
out = filter(b,a,sig);
end

