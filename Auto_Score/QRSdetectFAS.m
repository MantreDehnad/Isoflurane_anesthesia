function [out,ms,p1] = QRSdetectFAS(x1,t)
%Written by Roshan Nanu, July 2014
if ~exist('t','var')
    t=3*std(x1);
end
m1 = mean(x1);
x1 = x1-m1;
Rps = find(abs(x1)>t);
tang = find(diff(Rps)==1);
while ~isempty(tang)
    for i=1:length(tang),
        if Rps(tang(i))~=0,
            [a,b] = max(abs(x1(Rps(tang(i):tang(i)+1))));
            if b==1 | sign(x1(Rps(tang(i))))~=sign(x1(Rps(tang(i)+1)))
                Rps(tang(i)+1)=0;
            else
                Rps(tang(i))=0;
            end
        end
    end
    Rps(find(Rps==0))=[];
    tang = find(diff(Rps)==1);
end
Qps = Rps*0;
Sps = Qps;

%find Q peaks
for i=1:length(Rps),
    k=Rps(i);
    ret = 0;
    while ret==0 && k>2,
        k=k-1;
        if sign(x1(k)-x1(k-1))==sign(x1(k)-x1(k+1)) ...
                && sign(x1(k)-x1(k+1))~=sign(x1(Rps(i)))
            ret = k;
        end
    end
    if ret~=0
        Qps(i)=ret;
    else
        Rps(i)=0;
        Qps(i)=0;
        Sps(i)=0;
    end
end
Qps(find(Qps==0))=[];
Rps(find(Rps==0))=[];
Sps(find(Sps==0))=[];
%find S peaks
for i=1:length(Rps),
    k=Rps(i);
    ret = 0;
    while ret==0 && k<length(x1)-2,
        k=k+1;
        if sign(x1(k)-x1(k-1))==sign(x1(k)-x1(k+1)) ...
                && sign(x1(k)-x1(k+1))~=sign(x1(Rps(i)))
            ret = k;
        end
    end
    if ret~=0
        Sps(i)=ret;
    else
        Rps(i)=0;
        Qps(i)=0;
        Sps(i)=0;
    end
end
Qps(find(Qps==0))=[];
Rps(find(Rps==0))=[];
Sps(find(Sps==0))=[];


out = x1*0;
for i=1:length(Rps),
    out(Qps(i))=x1(Qps(i));
    out(Rps(i))=x1(Rps(i));
    out(Sps(i))=x1(Sps(i));
end
out = out+m1;
out(find(out==m1))=0;
ms = median(diff(Rps));
p1 = Rps(1);
end

