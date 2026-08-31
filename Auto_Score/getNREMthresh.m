function [out] = getNREMthresh(x1,y1)
%getNREMthresh uses clustering algorithm to determine NREM threhsold along
%x1
if isrow(x1),
    x1 = x1';
end
if isrow(y1),
    y1 = y1';
end

try
    [cidx,cmean] = kmeans([x1,y1],2,'dist','sqeuclidean');
    if cmean(1,1)>cmean(2,1)
        n=1;
        w=2;
    else
        n=2;
        w=1;
    end
    nrem = find(cidx==n);
    wake = find(cidx==w);
    
    out = mean([min(x1(nrem)) max(x1(wake))]);
catch
    out = median(x1);
end

end

