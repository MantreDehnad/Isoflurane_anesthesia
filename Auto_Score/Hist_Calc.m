function [N,X] = Hist_Calc(raw_data,divide_point,lastbin_center,bin_num)

% written by Sheng Xu, Oct., 2009


outliers = raw_data(find(raw_data > divide_point));

subset_data = raw_data(find(raw_data <= divide_point));

[N,X] = hist(subset_data,bin_num);

N = [N length(outliers)];
X = [X lastbin_center];

