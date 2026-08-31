function [ret, Stages] = markEEGArtifacts(EEG_By_Epoch,Stages,W,P,Sampling_Rate)
%This algorithm looks for EEG artifacts by looking for two distinct types
%of artifacts. here classfied as variance artifacts and range artifacts.
%This algorithms moves through each epoch and see how removing a subepoch
%of width W changes the variance and the range. The subepoch who chages the
%range or variance most is classifed as an artifact and a delta value is
%returned as well as the location of the artifact within the epoch
%In searching for variance artifacts data are split into high and low eeg
%power, since NREM epochs have higher variance and higher delta variance.
%The highest P percent of delta is taken from each category (high EEG
%variance, low EEG variance, and range) and the unions of these sets are
%returned.
%Addtionally, if the marked subepoch was at the beginning or the end of the
%epoch then the previous or next epochs respectively are returned as
%possible artifacts as well.
%Written by Roshan Nanu, July 2014
%This is currently the algorithm labeled 'Paradigm D3' in my notes

s=.5; %step size for sliding window

high = find(Stages==2);
low = find(Stages==1 | Stages==3);

ppe = length(EEG_By_Epoch(:,1));
te = length(EEG_By_Epoch(1,:));

%get variance artifacts
dv = zeros(1,te);
idx = zeros(2,te);
for i=1:te,
    [dv(i),idx(:,i)] = isolate_Artifacts(EEG_By_Epoch(:,i),W,s,Sampling_Rate,'variance');
end

hvd = dv(high);
hvi = idx(:,high);
lvd = dv(low);
lvi = idx(:,low);
[hs,hsi] = sort(hvd,'descend');
retHV = high(hsi(1:fix(P*length(hvd))));
extras = [];
for i=1:length(retHV),
    if idx(1,retHV(i))==1 && retHV(i)>1
        extras = [extras retHV(i)-1];
    end
    if idx(2,retHV(i))==ppe && retHV(i)<te
        extras = [extras retHV(i)+1];
    end
end
retHV2 = union(retHV,extras);
[ls,lsi] = sort(lvd,'descend');
retLV = low(lsi(1:fix(P*length(lvd))));
extras = [];
for i=1:length(retLV),
    if idx(1,retLV(i))==1 && retLV(i)>1
        extras = [extras retLV(i)-1];
    end
    if idx(2,retLV(i))==ppe && retLV(i)<te
        extras = [extras retLV(i)+1];
    end
end
retLV2 = union(retLV,extras);
retV = union(retLV2,retHV2);

%get range artifacts
dr = zeros(1,te);
idx = zeros(2,te);
for i=1:te,
    [dr(i),idx(:,i)] = isolate_Artifacts(EEG_By_Epoch(:,i),W,s,Sampling_Rate,'range');
end
[sdr,si] = sort(dr,'descend');
retR = si(1:fix(P*te/2));
extras = [];
for i=1:numel(retR),
    if idx(1,si(i)) == 1 && retR(i)>1
        extras = [extras retR(i)-1];
    end
    if idx(2,si(i)) == ppe && retR(i)<te
        extras = [extras retR(i)+1];
    end
end
retR = union(retR,extras);

ret = union(retV,retR);

%adds points surrounded by artifacts
extras = ret(find(diff(ret)==2))+1;
ret = union(ret,extras);

Stages(intersect(find(Stages==0),ret)) = 7;
Stages(intersect(find(Stages<4),ret)) = Stages(intersect(find(Stages<4),ret))+3;
end

