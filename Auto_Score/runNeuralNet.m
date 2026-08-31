function [out,NNet] = runNeuralNet(NNet,Data)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
Layers = [NNet.Layer];
Nout = sum(Layers==max(Layers));
out = zeros(size(Data,1),Nout);
for i=1:size(Data,1),
    [NNet,out(i,:)] = FeedForward(NNet,Data(i,:));
end

end

