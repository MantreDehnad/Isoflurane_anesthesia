function [rest] = selectArtifacts(x1,y1,Labels)
%selectArtifacts allows user to select any artifacts that they want to
%exclude from the neural network sorting and returns the indexes of all
%other epochs

h = msgbox({'Use the following window to select extreme artifacts that should be excluded when performing the neural network sorting.',...
    'The neural netowork can be thrown off by epochs that are extreme on either axis or in the top right quadrant',...
    '','In this window you can click on points to indivually mark or unmark them; Or you can click and drag to box multiple points.'});
waitfor(h);

f1 = figure;
ax = axes;
title('Extreme Artifact Selection')

if exist('Labels','var')
    xlabel(Labels{1})
    ylabel(Labels{2})
end

Markers = ones(1,numel(x1));
mouse_act = 0;
init_pos = [0 0];

dashed_lines{1} = line([0 0],[0 10],'LineStyle','--','Visible','off','Color','k');
dashed_lines{2} = line([0 10],[10 10],'LineStyle','--','Visible','off','Color','k');
dashed_lines{3} = line([10 10],[10 0],'LineStyle','--','Visible','off','Color','k');
dashed_lines{4} = line([10 0],[0 0],'LineStyle','--','Visible','off','Color','k');

pos = get(f1,'Position');

Done_Push = uicontrol(f1,'Style','pushbutton','String','Done',...
    'Position',[pos(3)-100 0 100 30],'Callback',@Close_Fcn);
Reset_Push = uicontrol(f1,'Style','pushbutton','String','Reset',...
    'Position',[pos(3)-100 pos(4)-30 100 30],'Callback',@Reset);

for i=1:numel(x1),
    plotPoints(i) = line(x1(i),y1(i),'marker','.','userdata',i,'Color',[1 0 0],...
        'MarkerSize',6,'ButtonDownFcn',@Point_Select);
end

set(f1,'WindowButtonMotionFcn',@Motion_Fcn,...
    'WindowButtonUpFcn',@Button_Up_Fcn)
set(ax,'ButtonDownFcn',@Point_Select)

waitfor(f1);
rest = find(Markers);

    function Close_Fcn(~,~,~)
        delete(f1);
    end

    function Point_Select(hObject,~,~)
        if hObject==ax
            mouse_act = 1;
            init_pos = get(ax,'CurrentPoint');
            for j=1:4,
                set(dashed_lines{j},'Visible','on');
            end
            cur_pos = get(ax,'CurrentPoint');
            xx1 = init_pos(1,1);
            yy1 = init_pos(1,2);
            xx2 = cur_pos(1,1);
            yy2 = cur_pos(1,2);
            set(dashed_lines{1},'XData',[xx1 xx1],'YData',[yy1 yy2]);
            set(dashed_lines{2},'XData',[xx1 xx2],'YData',[yy2 yy2]);
            set(dashed_lines{3},'XData',[xx2 xx2],'YData',[yy2 yy1]);
            set(dashed_lines{4},'XData',[xx2 xx1],'YData',[yy1 yy1]);
        else
            pointNum = get(hObject,'userdata');
            if get(hObject,'Marker')=='.'
                set(hObject,'Marker','*','Color',[0 0 1],'MarkerSize',15);
                Markers(pointNum) = 0;
            else
                Markers(pointNum) = 1;
                set(hObject,'Marker','.','Color',[1 0 0],'MarkerSize',6);
            end
            mouse_act=0;
        end
    end

    function Motion_Fcn(~,~,~)
        if mouse_act
            cur_pos = get(ax,'CurrentPoint');
            xx1 = init_pos(1,1);
            yy1 = init_pos(1,2);
            xx2 = cur_pos(1,1);
            yy2 = cur_pos(1,2);
            set(dashed_lines{1},'XData',[xx1 xx1],'YData',[yy1 yy2]);
            set(dashed_lines{2},'XData',[xx1 xx2],'YData',[yy2 yy2]);
            set(dashed_lines{3},'XData',[xx2 xx2],'YData',[yy2 yy1]);
            set(dashed_lines{4},'XData',[xx2 xx1],'YData',[yy1 yy1]);
            drawnow;
        end
    end

    function Button_Up_Fcn(~,~,~)
        if mouse_act
            yy = get(dashed_lines{1},'YData');
            xx = get(dashed_lines{2},'XData');
            xx1 = min(xx);
            xx2 = max(xx);
            yy1 = min(yy);
            yy2 = max(yy);
            arts = find(x1>=xx1 & x1<=xx2 & y1>=yy1 & y1<=yy2);
            for j=1:numel(arts),
                p1 = plotPoints(arts(j));
                if get(p1,'Marker') == '.'
                    set(p1,'Marker','*','Color',[0 0 1],'MarkerSize',15);
                    Markers(arts(j)) = 0;
                else
                    Markers(arts(j)) = 1;
                    set(p1,'Marker','.','Color',[1 0 0],'MarkerSize',6);
                end
            end
        end
        
        mouse_act=0;
        for j=1:4,
            set(dashed_lines{j},'Visible','off');
        end
    end

    function Reset(~,~,~)
        for j=1:numel(x1),
            p1 = plotPoints(j);
            Markers(j) = 1;
            set(p1,'Marker','.','Color',[1 0 0],'MarkerSize',6);
        end
    end
end

