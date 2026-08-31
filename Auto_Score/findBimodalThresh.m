function [thresh, mx1, mx2] = findBimodalThresh(x1,sp)
%Written by Roshan Nanu, July 2014
%findBimodalThresh finds the threshold between two modes in bimodally
%distributed data
mn = min(x1);
mx = max(x1);
if ~exist('sp','var')
    sp = 1e-7;
end
edges = mn:(mx-mn)/50:mx;
hs = histc(x1,edges);

%spline fit distribution
f = fit((edges+(mx-mn)/100)',hs','smoothingspline','SmoothingParam',sp);

ss = f(edges);
%get all local maxima
maxima = ss*0;
if ss(1)>ss(2)
    maxima(1)=1;
end
if ss(end)>ss(end-1)
    maxima(end)=1;
end
for i=2:length(ss)-1;
    if ss(i)>ss(i-1) && ss(i)>ss(i+1) && ss(i)>=.2*mean(ss)
        maxima(i)=1;
    end
    
end
%get two tallest peaks
if sum(maxima)<2
%     figure
%     hist(x1,50)
%     hold on
%     plot(f,edges+(mx-mn)/100,hs)
%     hold off
    error('Unimodal Distribution')
end
v1 = max(ss(find(maxima)));
n1 = find((ss==v1)+maxima == 2,1,'first');
maxima(n1) = 0;
v2 = max(ss(find(maxima)));
n2 = find((ss==v2)+maxima == 2,1,'first');
maxima(n1) = 1;

if n1>n2
    tmp = n1;
    n1 = n2;
    n2 = tmp;
end

%find minimum between maxes
[t1 ti] = min(ss(n1:n2));
ti = ti+n1-1;


%t1 = find(ds(n1:end)>0,1,'first')
%t1 = t1+n1-1;
%[v2 n2] = max(ss(t1:end));
%n2 = n2+t1;
%t2 = find(hs==min(hs(n1:n2)));
%mx1 = find(hs==max(hs(1:t2)));
%mx2 = find(hs==max(hs(t2:end)));

mx1 = edges(n1) + (mx-mn)/100;
mx2 = edges(n2) + (mx-mn)/100;
thresh = edges(ti)+(mx-mn)/100; 

% fig = figure;
% hist(x1,50);
% hold on
% plot(f,edges+(mx-mn)/100,hs)
% hold off
% addLines(fig,[],[mx1,thresh,mx2])
% fig=0;
end

