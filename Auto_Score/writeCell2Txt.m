function [status] = writeCell2Txt(fn,cellArr,headerLines)
status = 0;


[rows,cols] = size(cellArr);

outArr = '';
spacer = repmat(char(9),rows-headerLines,1);
for j=1:cols,
    colOut = '';
    for i=1+headerLines:rows,
        if ischar(cellArr{i,j}) || isempty(cellArr{i,j})
            colOut = char(colOut,cellArr{i,j});
        else
            colOut = char(colOut,num2str(cellArr{i,j}));
        end
    end
    colOut = strjust(colOut(2:end,:),'center');
    outArr = [outArr colOut spacer];
end
for i=1:headerLines,
    outArr = char(cellArr{headerLines-i+1,1},outArr);
end

if ~isempty(fn)
    fid = fopen(fn,'w+');
    for i=1:rows,
        fprintf(fid,'%s\n',outArr(i,:));
    end
    fclose(fid);
    status = 1;
else
    status = outArr(1,:);
    for i=2:rows,
        status = [status char(10) outArr(i,:)];
    end
end


end

