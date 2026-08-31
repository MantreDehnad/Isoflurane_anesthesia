function [out] = findLocalMin(x1,y1)
%Written by Roshan Nanu, July 2014
%findLocalMin fits the data and returns index of the lowest local min
%if there is no local minima then it returns the index of lowest value past
%the peak
f = fit(x1',y1','smoothingspline','SmoothingParam',2e-6);
out = max(y1);
for i=2:length(x1)-1,
    if f(x1(i))<f(x1(i-1)) && f(x1(i))<f(x1(i+1))
        if f(x1(i))<out;
            out = f(x1(i));
        end
    end
end
if out==max(y1)
    peak = find(y1==max(y1),1,'last');
    out = min(y1(peak:end));
end

out = find(y1==out,1,'last');

end


