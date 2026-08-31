function [out, bins] = findREMthresh(yy,bins)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
if ~exist('bins','var')
    bw = 2*iqr(yy)*(numel(yy)^(-1/3));
    bins = (max(yy)-min(yy))/bw;
    [yv,yb] = hist(yy,fix(bins));
    f = fit(yb',yv','smoothingspline');
    [pks,locs] = findpeaks(f(yb),'MINPEAKHEIGHT',3);
    while numel(pks)>1,
        bins = bins*.75;
        [yv,yb] = hist(yy,fix(bins));
        f = fit(yb',yv','smoothingspline');
        [pks,locs] = findpeaks(f(yb),'MINPEAKHEIGHT',3);
    end
else
    [yv,yb] = hist(yy,fix(bins));
    f = fit(yb',yv','smoothingspline');
end
fx = differentiate(f,yb);
[m idx] = max(yv);
out = yb(idx+find(fx(idx:end)>=-1,1,'first'));
end

