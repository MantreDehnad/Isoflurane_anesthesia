function [Stages,Para1_Thres] = NeuralNetSort(NNet,Dataset,netType,Para1)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Out = runNeuralNet(NNet,Dataset);

switch netType
    case 0 %Wake/NREM/REM separation 
        Stages = round(Out*2)+1;
    case 1 %Wake/NREM separation
        Stages = round(Out)+1;
    case 2 %Wake/NREM/REM softmax
        Stages = arrayfun(@(x) find(Out(x,:)==max(Out(x,:))),1:size(Out,1));
    case 3 %Wake+REM/NREM separation
        Stages = round(Out)+1;
    case 4 %Wake/REM separation
        Stages = round(Out)*2 +1;
    case 5 %artifact separation
    case 6
        Stages = round(Out)+1;
        
    otherwise
        Stages = Out;
end

if nargin==4 && nargout==2 && netType~=4
    if ~any(Stages==2) || ~any(Stages==1)
        if ~any(Stages==2)
            Tag = 'No';
        else
            Tag = 'Only';
        end
        msgbox({'NREM Neural Network not conclusive.',[tag ' NREM Epochs found.'] ,'Threshold set at mean.'});
        Para1_Thres = mean(Para1);
    else
        tStart = min(Para1(Stages==2));
        tEnd = max(Para1(Stages==1));
        step = (tEnd-tStart)/100;
        threshs = tStart:step:tEnd;
        Acc = zeros(1,numel(threshs));
        for i=1:numel(threshs)
            tmp = Stages*0;
            T = threshs(i);
            tmp(Para1<T) = 1;
            tmp(Para1>=T) = 2;
            tmp = contSort(tmp);
            Acc(i) = sum(tmp==Stages)/numel(Stages);
        end
        [~,ip]= max(Acc);
        Para1_Thres = threshs(ip);
    end
elseif nargout==2
    Para1_Thres=-1;
end
        

end

