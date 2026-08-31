function [out] = sigmoid(x,s)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~exist('s','var')
    s=0;
end
out = 1/(1+exp(-(x-s)));

end

