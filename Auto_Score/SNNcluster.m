function [clusters,Core,Density,simSNN, simEuc] = SNNcluster(X,k,Rval,similarity)
N = size(X,1);

%compute similarity matrix
if ~exist('similarity','var')
    disp('Computing Similiarity matrix...');
    similarity = simMat(X);
end
if ~exist('Rval','var')
    Rval = .7;
end

disp('Performing k-nearest neighbor sparsification...');
%identify k nearest neighbors for each point
NN = zeros(N,k);
for i=1:N,
    [~,idx] = sort(similarity(i,:)','ascend');
    NN(i,:) = idx(2:k+1);
end
RN = NN;
%remove links that aren't reciprocally connected
for i=1:N,
    for j=1:k,
        if ~any(NN(NN(i,j),:) == i)
            RN(i,j)=0;
        end
    end
end


for i=1:N,
    SN{i} = RN(i,find(RN(i,:)));
end

%find which points share neighbors & assigns strength to links & assigns
%density to each point as sum of strengths of links
disp('Creating Shared Nearest Neighbor graph...');
Density = zeros(1,N);
for i=1:N,
    nn = SN{i};
    links = [];
    for j=1:numel(nn),
        nn2 = SN{nn(j)};
        link.PointA = i;
        link.PointB = nn(j);
        shared = intersect(nn,nn2);
        strength = 0;
        for l=1:numel(shared),
            strength = (k+1-find(nn==shared(l)))*(k+1-find(nn2==shared(l)))+strength;
        end
        link.Strength = strength;
        if strength~=0,
            links = [links;link];
            Density(i) = Density(i)+strength;
        end
    end
    SNN{i} = links;
end

disp('Removing Weak Links...');
%Identify highest density points as representative points and lowest
%density points as noise
r1 = Rval*max(Density);
r2 = .3*max(Density);

[dSort,dSortI] = sort(Density,'descend');
coreCutoff = find(dSort>r1,1,'last');
borderCutoff = find(dSort>r2,1,'last');
Core = dSortI(1:coreCutoff);
% Border = dSortI(coreCutoff+1:borderCutoff);
Outliers = dSortI(borderCutoff+1:end);

% figure
% hold on
% plot(X(Outliers,1),X(Outliers,2),'b.');
% plot(X(Border,1),X(Border,2),'g.');
% plot(X(Core,1),X(Core,2),'r.');

SNNO = SNN;

%remove outlier links
for i=1:numel(Outliers),
    if ~isempty(SNN{Outliers(i)})
        linked = [SNN{Outliers(i)}.PointB];
        for j=1:numel(linked),
            links = SNN{linked(j)};
            links(find([links.PointB] == Outliers(i))) = [];
            SNNO{linked(j)} = links;
        end
        SNNO{Outliers(i)} = [];
    end
end


%remove all links with strength below a threshold
for i=1:numel(SNNO),
    if isempty(SNNO{i})
        strengths(i,:) = [0 0];
    else
        strengths(i,:) = [min([SNNO{i}.Strength]) max([SNNO{i}.Strength])];
    end
end
thresh = max(strengths(:,2))*.2;

for i=1:numel(SNNO),
    if ~isempty(SNNO{i})
        links = SNNO{i};
        remove = [];
        for j=1:numel(links),
            if links(j).Strength<thresh,
                remove = [remove;j];
            end
        end
        links(remove) = [];
        SNNO{i} = links;
    end
end

% plot all links
% figure
% hold on
% for i=1:numel(SNNO),
%     if isempty(SNNO{i})
%         plot(X(i,1),X(i,2),'m.');
%     else
%         links = SNNO{i};
%         for j=1:numel(links),
%             B = links(j).PointB;
%             xd = [X(i,1) X(B,1)];
%             yd = [X(i,2) X(B,2)];
%             line(xd,yd,'Color',[0 0 0]);
%         end
%     end
% end
% plot(X(Outliers,1),X(Outliers,2),'b.');
% plot(X(Border,1),X(Border,2),'g.');
% plot(X(Core,1),X(Core,2),'r.');
disp('Creating clusters...');

clusters = zeros(N,1);
% numClust = 1;
%make clusters from connected links, looks at links of each point and
%assigns it the same cluster value as that of its strongest link and
%numbers any of its links that are unnumbered the same



checked = [];
i= Core(1);
j=1;
while numel(checked)~=N,
    if isempty(SNNO{i}) || ~any(Core==i)
        checked = union(checked,i);
    else
        linked = [SNNO{i}.PointB];
        LinkedSet{j} = i;
        while numel(intersect(LinkedSet{j},linked)) ~= numel(linked),
            LinkedSet{j} = union(LinkedSet{j},linked);
            next = intersect(linked,Core);
            linked = [];
            for l=1:numel(next),
                linked = union(linked,[SNNO{next(l)}.PointB]);
            end
        end
        checked = union(checked,LinkedSet{j});
        j=j+1;
    end
    left = setdiff(1:N,checked);
    if ~isempty(left)
        i=left(1);
    end
end

for i=1:numel(LinkedSet),
    clusters(LinkedSet{i}) = i;
end

% 
% 
% for i=1:numel(SNNO),
% %     disp(i)
%     if ~isempty(SNNO{i})
%         links = SNNO{i};
%         thisPoint = links(1).PointA;
%         linked = [links.PointB];
%         if clusters(i) == 0 || ~all(clusters(linked)==clusters(i))
%             %determine this point's cluster number
%             if clusters(i) == 0,
%                 [~,idx] = sort([links.Strength],'descend');
%                 closest = [links(idx).PointB];
%                 closestCluster = find(clusters(closest),1,'first');
%                 if ~isempty(closestCluster)
%                     clusters(thisPoint) = clusters(closest(closestCluster));
%                 else
%                     clusters(thisPoint) = numClust;
%                     numClust = numClust+1;
%                 end
%             end
%             
%             %make sure all links have same cluster number & iterate
%             checked = find(clusters==clusters(i));
%             while numel(intersect(linked,checked)) ~= numel(linked),
%                 clusters(linked) = clusters(i);
%                 linked2 = [];
%                 for j=1:numel(linked),
%                     if ~isempty(SNNO{linked(j)})
%                         links = SNNO{linked(j)};
%                         linked2 = union(linked2,[links.PointB]);
%                     end
%                 end
%                 linked = linked2;
%                 checked = find(clusters==clusters(i));
%             end
%         end
%     end
% end


%create SNN similarity matrix
simSNN = zeros(N);
for i=1:N,
    if ~isempty(SNNO{i})
        links = SNNO{i};
        for j=1:numel(links),
            simSNN(i,links(j).PointB) = links(j).Strength;
        end
    end
end

simEuc = similarity;

disp('Done!');