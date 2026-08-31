function [out] = notchFilter(sig,fs,wf,wc)
%Written by Roshan Nanu, July 2014
%notchFilter bandstop a signal with a 4th order Butterworth filter to
%attentuate the frequency range wf to wc
wf = 2*wf/fs;
wc = 2*wc/fs;
[b,a] = butter(4,[wf wc],'stop');
out = filter(b,a,sig);

end

