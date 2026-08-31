function [Para2_Thres1,Para2_Thres2] = getPara2_Thres(Para_1,Para_2,Para1_Thres)
%Written by Roshan Nanu, July 2014
%getPara2_Thres returns values for EMG Thresholds
flag=0;
try
    Para2_Thres1 = findBimodalThresh(Para_2(find(Para_1<Para1_Thres)));
catch
    try
        Para2_Thres1 = findBimodalThresh(Para_2);
    catch
        Para2_Thres1 = median(Para_2);
%         flag=1;
    end
end
try
    Para2_Thres2 = findBimodalThresh(Para_2(find(Para_1>Para1_Thres | Para_2>Para2_Thres1)));
catch
    Para2_Thres2 = mean(Para_2);
end
if flag
    lim1 = (median(Para_2(find(Para_2<Para2_Thres1 & Para_1<Para1_Thres)))+min(Para_2))/2;
    lim2 = mean(Para_2);
    Threshs = lim1:(lim2-lim1)/100:lim2;
    wakeInREM = Threshs*0;
    for i=1:length(Threshs),
        Stages = simpleSort(Para_1,Para_2,Para1_Thres,Threshs(i),Para2_Thres2);
        Stages2 = contSort(Stages);
        wakeInREM(i) = sum(Para_2(find(Stages2==1))<Threshs(i) & Para_1(find(Stages2==1))<Para1_Thres);
    end
    try
        Para2_Thres1 = findBimodalThresh(wakeInREM);
    catch
        Para2_Thres1 = Threshs(findLocalMin(Threshs,wakeInREM));
    end
end
end

