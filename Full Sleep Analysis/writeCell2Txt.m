function [status] = writeCell2Txt(fn,cellArr,headerLines)
%written by Roshan Nanu, Jan 2015
status = 0;
fid = fopen(fn,'w+');

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
for i=1:rows,
    fprintf(fid,'%s\n',outArr(i,:));
end
fclose(fid);
status = 1;


end

