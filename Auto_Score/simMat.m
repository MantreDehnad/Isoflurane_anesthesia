function [out] = simMat(X)
%simMat constructs the similarity matrix for rows in X by computing the
%euclidean distance between points based on the dimensions given in the
%columns of X
N = size(X,1);
out = zeros(N);
for i=1:N,
    for j=1:N,
        out(i,j) = sqrt(sum((X(i,:)-X(j,:)).^2));
    end
end


end

