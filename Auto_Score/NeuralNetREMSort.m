function [Stages,Threshold] = NeuralNetREMSort(NNet,DataSet,allStages,rest,Para2)

Stages = allStages(rest);
%run neural net with sequential updating of previous epoch column in dataset
for i=1:size(DataSet,1),
    curPos = rest(i);
    if i~=numel(rest)
        nextPos = rest(i+1);
    end
    if Stages(i)~=2,
        [~,out] = FeedForward(NNet,DataSet(i,:));
        out = round(out);
        switch out
            case 0
                Stages(i) = 1;
            case 1
                Stages(i) = 3;
        end
        %set prevEpoch column for next epoch
        if i~=numel(rest),
            if nextPos == curPos+1
                DataSet(i+1,25) = out*2-1;
            end
        end
        
    end
end
%find best threshold
if nargin==5 && nargout==2
    if ~any(Stages==3) || ~any(Stages==1)
        if ~any(Stages==3)
            Tag = 'No';
        else
            Tag = 'Only';
        end
        msgbox({'REM Neural Network not conclusive.',[tag ' REM Epochs found.'] ,'Threshold set at mean.'});
        Threshold = mean(Para2);
    else
        tStart = min(Para2(Stages==3));
        tEnd = max(Para2(Stages==3));
        step = (tEnd-tStart)/100;
        threshs = tStart:step:tEnd;
        Acc = zeros(1,numel(threshs));
        for i=1:numel(threshs)
            tmp = Stages*0;
            T = threshs(i);
            tmp(Para2<=T) = 3;
            tmp(Para2>T) = 1;
            tmp(Stages==2) = 2;
            tmp = contSort(tmp);
            Acc(i) = sum(tmp==Stages)/numel(Stages);
        end
        [~,ip]= max(Acc);
        Threshold = threshs(ip);
    end
elseif nargout==2
    Threshold = -1;
end

end
