function [NNet,out] = FeedForward(NNet,Input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
L1 = find([NNet.Layer]==1);
if numel(Input)~=numel(L1)-1,
    msgbox('Please provide the correct number of inputs.');
    return;
end
Layers = [NNet.Layer];


for i=1:max(Layers),
    layer = find(Layers==i);
    layerAct = NNet(layer(1)).Activation;
    if strcmp(layerAct,'Input')
        for j=1:numel(layer),
            switch NNet(layer(j)).Activation
                case 'Input'
                    NNet(j).Input = Input(j);
                    NNet(j).Output = Input(j);
                case 'Bias'
                    NNet(layer(j)).Input = 1;
                    NNet(layer(j)).Output = 1;
            end
        end
    elseif strcmp(layerAct,'Sigmoid')
        for j=1:numel(layer),
            k = layer(j);
            switch NNet(k).Activation
                case 'Sigmoid'
                    lp = NNet(k).inID;
                    input = [NNet(lp).Output];
                    NNet(k).Input = input;
                    NNet(k).Output = sigmoid(sum(input.*NNet(k).Weights));
                case 'Bias'
                    NNet(k).Input = 1;
                    NNet(k).Output = 1;
            end
        end
    elseif strcmp(layerAct,'Softmax')
        NetIns = zeros(1,numel(layer));
        for j=1:numel(layer),
            k = layer(j);
            lp = NNet(k).inID;
            input = [NNet(lp).Output];       
            NNet(k).Input = input;
            NetIns(j) = sum(input.*NNet(k).Weights);
        end
        scale = sum(exp(NetIns));
        for j = 1:numel(layer),
            k = layer(j);
            NNet(k).Output = exp(NetIns(j))/scale;
        end 
    end
    
    out = [NNet(Layers==max(Layers)).Output];
    
    
end

