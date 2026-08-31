function [out] = contSort(Stages,fixed)
%Written by Roshan Nanu, October 2014
%contSort Sorts Epochs by continuity
%enforce 2 rules
%1) No transitions from waking directly to REM
%2) No single Epochs in any stage
if ~exist('fixed','var')
    fixed = Stages*0;
end
for i=1:length(Stages)-1,
    if i>1 && Stages(i)~=Stages(i-1) && Stages(i-1)==Stages(i+1) && Stages(i)<=3 && ~fixed(i)
        Stages(i)=Stages(i-1);
    elseif Stages(i)==1 && Stages(i+1)==3
        Stages(i+1)=1;
    end
end
out = Stages;
end

