function [P1T] = getPara1_Thres(Para_1,Para_2,P2T1,P2T2)
%Written by Roshan Nanu, July 2014
%getPara1_Thres uses a distribution sort to return the distribution min
%for Para1 in the relevant catgories
if sum(Para_1>3*mean(Para_1))<.05*length(Para_1)
    nonextremes = find(Para_1<=3*mean(Para_1));
    Para_1 = Para_1(nonextremes);
    Para_2 = Para_2(nonextremes);
end

sp = 1e-7;
P1T = max(Para_1);
while sum(Para_1>P1T)<.2*length(Para_1) && sp<1
    try
        [P1T] = findBimodalThresh(Para_1(find(Para_2<max([P2T1,P2T2]))),sp);
    catch
        try
            [P1T] = findBimodalThresh(Para_1,sp);
        catch
            P1T = median(Para_1);
        end
    end
    sp = sp*10;
end
if sp>=1e-5,
    P1T = median(Para_1);
end
end

