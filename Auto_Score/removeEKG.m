function [out] = removeEKG(EMG,epochEMG,t,epochNum, fs, ed)
%Written by Roshan Nanu, July 2014
[epochEKG medSep p1] = QRSdetectFAS(epochEMG,t);
if medSep<10
    msgbox({'EKG Threshold too LOW.','Re-try with higher threshold.'},'EKG Analysis Failed')
    return;
elseif medSep>40
    msgbox({'EKG Threshold too HIGH.',' Re-try with lower threshold.'},'EKG Analysis Failed')
    return;
end
spe = fs*ed;
N = spe*(epochNum-1)+p1;
Rps(1) = N;
i=2;
%find all R-points to left
while N-medSep>=1
    N1=N-medSep;
    if N>2
    [m N] = max(abs(EMG(N1-2:N1+2)));
    N = N1+N-3;
    else
        [m N] = max(abs(EMG(1:N1+2)));
    end
    Rps(i) = N;
    i = i+1;
end
%find all R-point to the right
N = Rps(1);
while N+medSep<=length(EMG)
    N1=N+medSep;
    if N<length(EMG)-2
    [m N] = max(abs(EMG(N1-2:N1+2)));
    N = N1+N-3;
    else
        [m N] = max(abs(EMG(N1-2:end)));
        N = N1+N-3;
    end
    Rps(i) = N;
    i = i+1;
end

%find all corresponding Q and S points
Rps = sort(Rps);
Sps = Rps*0;
Qps = Sps;
for i=1:length(Rps),
    N = Rps(i);
    if N>2
       k=1;
       while Qps(i)==0,
           if sign(EMG(N-k)-EMG(N-k+1))==sign(EMG(N-k)-EMG(N-k-1)) ...
                   && sign(EMG(N-k)-EMG(N-k+1))~=sign(EMG(N))
               Qps(i) = N-k;
           else
               k=k+1;
           end
       end
    elseif N==2
        Qps(i)==1;
    else
        Rps(i)=0;
    end
    if N<=length(EMG)-2
       k=1;
       while Sps(i)==0,
           if sign(EMG(N+k)-EMG(N+k+1))==sign(EMG(N+k)-EMG(N+k-1)) ...
                   && sign(EMG(N+k)-EMG(N+k+1))~=sign(EMG(N))
               Sps(i) = N+k;
           else
               k=k+1;
           end
       end
    elseif N==length(EMG)-1
        Sps(i)==length(EMG);
    else
        Rps(i)=0;
    end 
end

end

