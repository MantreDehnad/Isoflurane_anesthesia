function [delta idx] = isolate_Artifacts(Epoch,W,s,fs,type)
%Written by Roshan Nanu, July 2014
spe = fix(fs*W);
sps = fix(fs*s);
for i = 1: floor((length(Epoch)-spe)/sps)+1,
    %     miniE(:,i) = Epoch((i-1)*sps+1:(i-1)*sps+spe);
    indices(:,i) = [(i-1)*sps+1,(i-1)*sps+spe];
end

diffs = ones(1,length(indices(1,:)));
for i=1:numel(diffs),
    rest = Epoch;
    rest(indices(1,i):indices(2,i))=[];
    switch type
        case 'range'
            diffs(i) = abs(max(Epoch)-min(Epoch))- abs(max(rest)-min(rest));
        case 'variance'
            diffs(i) = var(Epoch)-var(rest);
    end
end
[delta,i] = max(diffs);
idx = indices(:,i);

end

