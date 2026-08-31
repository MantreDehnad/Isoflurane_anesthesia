function [Stages] = Sorting(Para_1,Para_2,Para1_Thres,Para2_Thres1,Para2_Thres2)
%Written by Roshan Nanu, July 2014
%simpleSort Sorts data into 4 categories based on thresholds

Stages = ones(1,length(Para_1))*0;
for i = 1:min([numel(Para_1) numel(Para_2)])
    x1 = Para_1(i);
    x2 = Para_2(i);
    if x1 < Para1_Thres && x2 < Para2_Thres1 % lower left corner: REM
        Stages(i) = 3;
    elseif x1 < Para1_Thres && x2 >= Para2_Thres1 % upper left corner: Wake
        Stages(i) = 1;
    elseif x1 >= Para1_Thres && x2 <= Para2_Thres2 % lower right corner: NREM
        Stages(i) = 2;
    else
        Stages(i) = 0; % Undecided
    end
end


end

