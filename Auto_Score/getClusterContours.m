function [wContours,nContours,rContours,K,R] = getClusterContours(X,weights,x1,y1,xLabel,yLabel,K,R)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rContours = [];
wContours = [];
nContours = [];
if size(X,2)~=numel(weights)
    errordlg('The Number of weights must be equal to the number of parameters being used to cluster.');
    return;
end
if isrow(x1)
    x1 = x1';
end
if isrow(y1)
    y1 = y1';
end
if numel(x1) ~= size(X,1) || numel(y1) ~= size(X,1)
    errordlg('x1 and y1 must be the same length as each column of X.')
    return;
end
for i=1:numel(weights),
    X(i,:) = X(i,:).^weights(i);
end
if ~exist('R','var')
    if ~exist('K','var')
        K = 35;
    else 
        K = K-5;
    end
    R = .7;
    q = 'No';
    q2 = 'Too Many';
    while strcmp(q,'No')
        if strcmp(q2,'Too Many')
            K = K+5;
        else
            K = K-5;
        end
        if exist('simEuc','var')
            [clusters,Core,Density,simSNN] = SNNcluster(X,K,R,simEuc);
        else
            [clusters,Core,Density,simSNN,simEuc] = SNNcluster(X,K,R);
        end
        f1 = figure;
        scatter(x1,y1,4,[.8 .8 .8],'filled')
        hold on
        scatter(x1(Core),y1(Core),4,clusters(Core),'filled')
        title({'Cluster Core Scatter Plot',sprintf('K = %i; R = %g',K,R)})
        xlabel(xLabel)
        ylabel(yLabel)
        
        q = questdlg('Are these clusters acceptable?','Cluster Check','Yes','No',{'Yes'});
        if strcmp(q,'No')
            q2 = questdlg('Are there too many clusters of too few?','Fix Clustering','Too Many','Too Few',{'Too Few'});
        end
        
        close(f1);
    end
else
    [clusters,Core,Density,simSNN,simEuc] = SNNcluster(X,K,R);
end
f2 = figure;
scatter(x1,y1,4,[.8 .8 .8],'filled')
hold on
scatter(x1(Core),y1(Core),4,clusters(Core),'filled')
xlabel(xLabel)
ylabel(yLabel)
title('Clusters');
q = questdlg('Include REM?','REM?','Yes','No',{'No'});
if strcmp(q,'Yes')
    
    title('Choose REM Cluster:')
    waitforbuttonpress;
    Cp = get(gca,'CurrentPoint');
    [~,Ip] = min((x1(Core)-Cp(2,1)).^2 + (y1(Core)-Cp(2,2)).^2);
    rC = Core(Ip);
    
    %create REM linked sets
    rCore = rC;
    nextSet = intersect(find(simSNN(rC,:)),Core);
    while numel(intersect(nextSet,rCore))~=numel(nextSet)
        rCore = union(rCore,nextSet);
        tmpSet = nextSet;
        nextSet = [];
        for i=1:numel(tmpSet),
            nextSet = union(nextSet,intersect(find(simSNN(tmpSet(i),:)),Core));
        end
    end
    
    
    rLink1 = [];
    for i=1:numel(rCore),
        rLink1 = union(rLink1,setdiff(find(simSNN(rCore(i),:)),Core));
    end
    
    rLink2 = [];
    for i=1:numel(rLink1),
        rLink2 = union(rLink2,setdiff(find(simSNN(rLink1(i),:)),union(rLink1,rCore)));
    end
    
    rLink1 = union(rLink1,rCore);
    rLink2 = union(rLink1,rLink2);
    
    rRing1 = convhull(x1(rCore),y1(rCore));
    rRing2 = convhull(x1(rLink1),y1(rLink1));
    rRing3 = convhull(x1(rLink2),y1(rLink2));
    
    rContours = cell(1,3);
    rContours{1} = [x1(rCore(rRing1)),y1(rCore(rRing1))];
    rContours{2} = [x1(rLink1(rRing2)),y1(rLink1(rRing2))];
    rContours{3} = [x1(rLink2(rRing3)),y1(rLink2(rRing3))];  
end

title('Choose Wake Cluster:')
waitforbuttonpress;
Cp = get(gca,'CurrentPoint');
[~,Ip] = min((x1(Core)-Cp(2,1)).^2 + (y1(Core)-Cp(2,2)).^2);
wC = Core(Ip);

%create Wake linked sets
wCore = wC;
nextSet = intersect(find(simSNN(wC,:)),Core);
while numel(intersect(nextSet,wCore))~=numel(nextSet)
    wCore = union(wCore,nextSet);
    tmpSet = nextSet;
    nextSet = [];
    for i=1:numel(tmpSet),
        nextSet = union(nextSet,intersect(find(simSNN(tmpSet(i),:)),Core));
    end
end


wLink1 = [];
for i=1:numel(wCore),
    wLink1 = union(wLink1,setdiff(find(simSNN(wCore(i),:)),Core));
end

wLink2 = [];
for i=1:numel(wLink1),
    wLink2 = union(wLink2,setdiff(find(simSNN(wLink1(i),:)),union(wLink1,wCore)));
end


title('Choose NREM Cluster:')
waitforbuttonpress;
Cp = get(gca,'CurrentPoint');
[~,Ip] = min((x1(Core)-Cp(2,1)).^2 + (y1(Core)-Cp(2,2)).^2);
nC = Core(Ip);
close(f2);

%create NREM linked sets
nCore = nC;
nextSet = intersect(find(simSNN(nC,:)),Core);
while numel(intersect(nextSet,nCore))~=numel(nextSet)
    nCore = union(nCore,nextSet);
    tmpSet = nextSet;
    nextSet = [];
    for i=1:numel(tmpSet),
        nextSet = union(nextSet,intersect(find(simSNN(tmpSet(i),:)),Core));
    end
end


nLink1 = [];
for i=1:numel(nCore),
    nLink1 = union(nLink1,setdiff(find(simSNN(nCore(i),:)),Core));
end

nLink2 = [];
for i=1:numel(nLink1),
    nLink2 = union(nLink2,setdiff(find(simSNN(nLink1(i),:)),union(nLink1,nCore)));
end

wLink1 = union(wLink1,wCore);
wLink2 = union(wLink1,wLink2);
nLink1 = union(nLink1,nCore);
nLink2 = union(nLink1,nLink2);

wRing1 = convhull(x1(wCore),y1(wCore));
wRing2 = convhull(x1(wLink1),y1(wLink1));
wRing3 = convhull(x1(wLink2),y1(wLink2));

nRing1 = convhull(x1(nCore),y1(nCore));
nRing2 = convhull(x1(nLink1),y1(nLink1));
nRing3 = convhull(x1(nLink2),y1(nLink2));

wContours = cell(1,3);
wContours{1} = [x1(wCore(wRing1)),y1(wCore(wRing1))];
wContours{2} = [x1(wLink1(wRing2)),y1(wLink1(wRing2))];
wContours{3} = [x1(wLink2(wRing3)),y1(wLink2(wRing3))];

nContours = cell(1,3);
nContours{1} = [x1(nCore(nRing1)),y1(nCore(nRing1))];
nContours{2} = [x1(nLink1(nRing2)),y1(nLink1(nRing2))];
nContours{3} = [x1(nLink2(nRing3)),y1(nLink2(nRing3))];




end

