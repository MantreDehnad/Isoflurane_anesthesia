function [out] = slidingEpochWindows(p1,w)
%Written by Roshan Nanu, July 2014

margin = (w-1)/2;
out = zeros(length(p1),w-1);
for i=1:length(p1)
    if i<1+margin,
        row = p1(1:i+margin);
        row(i)=[];
        row = padarray(row,[0 margin-i+1],mean(row),'pre');
    elseif i>length(p1)-margin
        row = p1(i-margin:end);
        row(margin+1)=[];
        row = padarray(row,[0 margin+i-length(p1)],mean(row),'post');
    else
        row = p1(i-margin:i+margin);
        row(margin+1)=[];
    end
    out(i,:) = row;
end

