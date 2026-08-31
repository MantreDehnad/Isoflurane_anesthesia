function varargout = Hypnogram_Generation(varargin)
% HYPNOGRAM_GENERATION M-file for Hypnogram_Generation.fig
%      HYPNOGRAM_GENERATION, by itself, creates a new HYPNOGRAM_GENERATION or raises the existing
%      singleton*.
%
%      H = HYPNOGRAM_GENERATION returns the handle to a new HYPNOGRAM_GENERATION or the handle to
%      the existing singleton*.
%
%      HYPNOGRAM_GENERATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYPNOGRAM_GENERATION.M with the given input arguments.
%
%      HYPNOGRAM_GENERATION('Property','Value',...) creates a new HYPNOGRAM_GENERATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Hypnogram_Generation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Hypnogram_Generation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Hypnogram_Generation

% Last Modified by GUIDE v2.5 19-Nov-2009 13:20:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Hypnogram_Generation_OpeningFcn, ...
                   'gui_OutputFcn',  @Hypnogram_Generation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Hypnogram_Generation is made visible.
function Hypnogram_Generation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Hypnogram_Generation (see VARARGIN)

% Choose default command line output for Hypnogram_Generation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Hypnogram_Generation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Hypnogram_Generation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Get_File_Push.
function Get_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Get_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[name_txt, path_str] = uigetfile('.xlsx', 'Pick The Excel File');

handles.File_Name = strcat(path_str, name_txt);

set(handles.File_Name_Text, 'String', handles.File_Name);

guidata(hObject,handles);

clear name_txt path_str;



% --- Executes on button press in Plot_Push.
function Plot_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global epoch_dur bin_dur total_length1 total_length2;

snumber = get(handles.SNumber_Edit,'String');
snumber = str2num(snumber);

if length(snumber) > 1
    errordlg('You can only handle one sheet at a time.','Sheet Number Error');
    return;
end

if snumber < 0
    errordlg('Invalid sheet number, please re-enter.','Sheet Number Invalid');
    return;
end



Data_Range = get(handles.DRange_Edit,'String');

real_data = xlsread(handles.File_Name, snumber, Data_Range);

if size(real_data,2) > 1
    errordlg('You can only handle one animal''s data per time.','Multiple Animals Error');
    return;
end


epoch_dur = get(handles.EDur_Edit,'String');
epoch_dur = str2num(epoch_dur);

bin_dur = get(handles.BDur_Edit,'String');
bin_dur = str2num(bin_dur);

num_per_bin = bin_dur*60/epoch_dur;

if round(num_per_bin) ~= num_per_bin
     errordlg('Bin duration should be the multiple of the epoch duration.', 'Duration Error');
     return;
end


xtick_step1 = round(length(real_data)/10);
xtick_vec1 = 0:xtick_step1:length(real_data);

if xtick_vec1(end) ~= length(real_data)
    if abs(xtick_vec1(end) - length(real_data)) < (xtick_vec1(end) - xtick_vec1(end-1))/4
        xtick_vec1(end) = length(real_data);
    else
        xtick_vec1 = [xtick_vec1 length(real_data)];
    end
end

xtick_label1 = round(xtick_vec1*epoch_dur/3600*100)/100;
ytick_label1(1,:) = ' REM';
ytick_label1(2,:) = 'NREM';
ytick_label1(3,:) = 'WAKE';

hypno_state = [];

for i = 1:length(real_data)
    if real_data(i) == 1 | real_data(i) == 4
        hypno_state(i) = 3;
    elseif real_data(i) == 2 | real_data(i) == 5
        hypno_state(i) = 2;
    elseif real_data(i) == 3 | real_data(i) == 6
        hypno_state(i) = 1;
    else
        error_msg = strcat('Epoch #', num2str(i),': unspecified state.');
        errordlg(error_msg,'Unrecognized State');
        return;
        
        clear error_msg;
    end
end


total_length1 = length(real_data);

plot_handles1.plot_figure = figure(1);
guidata(plot_handles1.plot_figure,plot_handles1);

plot_handles1.axes1 = axes('Position',[0.1300 0.1600 0.7750 0.7650]);
guidata(plot_handles1.axes1,plot_handles1);

for i = 1:length(real_data)
    if i ~= length(real_data)
        plot([i-1 i],[hypno_state(i) hypno_state(i)],'LineWidth',1.5,'LineStyle','-','Color',[0 0 0]);
        hold on;
        plot([i i],[hypno_state(i) hypno_state(i+1)],'LineWidth',1.5,'LineStyle','-','Color',[0 0 0]);
        hold on;
    else
        plot([i-1 i],[hypno_state(i) hypno_state(i)],'LineWidth',1.5,'LineStyle','-','Color',[0 0 0]);
        hold on;
    end
end

hold off;

set(plot_handles1.axes1,'XLimMode','Manual','XLim',[0 length(real_data)]);
set(plot_handles1.axes1,'XTickMode','Manual','XTick',xtick_vec1,'XTickLabel',xtick_label1);
xlabel('Hours');
title('Hypnogram');

set(plot_handles1.axes1,'YLimMode','Manual','YLim',[0.5 3.3]);
set(plot_handles1.axes1,'YTickMode','Manual','YTick',[1 2 3],'YTickLabel',ytick_label1);
set(plot_handles1.axes1,'Box','Off');
set(plot_handles1.plot_figure,'Color',[1 1 1]);

plot_handles1.axes2 = axes('Position',[0.1300 0.0400 0.7750 0.0800]);
guidata(plot_handles1.axes2,plot_handles1);

plot_handles1.range_bar = line([0 length(real_data)],[0.5 0.5],'Parent',plot_handles1.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
guidata(plot_handles1.range_bar,plot_handles1);     
    
set(plot_handles1.axes2,'XLimMode','Manual','XLim',[0 length(real_data)],'XTickMode','Manual','XTick',xtick_vec1,'XTickLabel',xtick_label1);
set(plot_handles1.axes2,'YLimMode','Manual','YLim',[0 1],'YTickMode','Manual','YTick',[]);
set(plot_handles1.axes2,'YColor',[1 1 1]);

set(plot_handles1.range_bar,'ButtonDownFcn','Hypnogram_Generation(''Range_Bar_Callback'',gcbo,guidata(gcbo))');       
        
        
set(plot_handles1.plot_figure,'WindowButtonMotionFcn','Hypnogram_Generation(''Start_Dragging'',gcbo,guidata(gcbo))');
set(plot_handles1.plot_figure,'WindowButtonUpFcn','Hypnogram_Generation(''Stop_Dragging'',gcbo,guidata(gcbo))');
        
plot_handles1.mouse_action = 0;
plot_handles1.rbar_action = 0;
plot_handles1.rbar_click_pos = 0;
plot_handles1.x_bar = [0 length(real_data)];


wake_perct = [];
nrem_perct = [];
rem_perct = [];

total_length2 = floor(total_length1/num_per_bin);


xtick_step2 = round(total_length2/10);
xtick_vec2 = 0:xtick_step2:total_length2;

if xtick_vec2(end) ~= total_length2
    if abs(xtick_vec2(end) - total_length2) < (xtick_vec2(end) - xtick_vec2(end-1))/4
        xtick_vec2(end) = total_length2;
    else
        xtick_vec2 = [xtick_vec2 total_length2];
    end
end

xtick_label2 = round(xtick_vec2*bin_dur/60*100)/100;



for i = 1:total_length2
    current_data = real_data((i-1)*num_per_bin+1:i*num_per_bin);
    temp1 = find(current_data == 1 | current_data == 4);
    temp2 = find(current_data == 2 | current_data == 5);
    temp3 = find(current_data == 3 | current_data == 6);
    
    wake_perct(i) = length(temp1)/num_per_bin*100;
    nrem_perct(i) = length(temp2)/num_per_bin*100;
    rem_perct(i) = length(temp3)/num_per_bin*100;
    
    clear current_data temp1 temp2 temp3;
end

plot_handles2.plot_figure = figure(2);
guidata(plot_handles2.plot_figure,plot_handles2);

plot_handles2.axes1 = axes('Position',[0.1300 0.1600 0.7750 0.7650]);
guidata(plot_handles2.axes1,plot_handles2);

h = bar(0.5:1:total_length2-0.5,wake_perct,0.85);
set(h,'FaceColor',[0.5 0.5 0.5]);

set(plot_handles2.axes1,'XLimMode','Manual','XLim',[0 total_length2]);
set(plot_handles2.axes1,'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
xlabel('Hours');
ylabel('%');
title('Wake Time Percentage');

set(plot_handles2.axes1,'YLimMode','Manual','YLim',[0 100]);
set(plot_handles2.axes1,'YTickMode','Manual','YTick',[0 25 50 75 100]);
set(plot_handles2.axes1,'Box','Off');
set(plot_handles2.plot_figure,'Color',[1 1 1]);


plot_handles2.axes2 = axes('Position',[0.1300 0.0400 0.7750 0.0800]);
guidata(plot_handles2.axes2,plot_handles2);

plot_handles2.range_bar = line([0 total_length2],[0.5 0.5],'Parent',plot_handles2.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
guidata(plot_handles2.range_bar,plot_handles2);     
    
set(plot_handles2.axes2,'XLimMode','Manual','XLim',[0 total_length2],'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
set(plot_handles2.axes2,'YLimMode','Manual','YLim',[0 1],'YTickMode','Manual','YTick',[]);
set(plot_handles2.axes2,'YColor',[1 1 1]);

set(plot_handles2.range_bar,'ButtonDownFcn','Hypnogram_Generation(''Range_Bar_Callback'',gcbo,guidata(gcbo))');       
        
        
set(plot_handles2.plot_figure,'WindowButtonMotionFcn','Hypnogram_Generation(''Start_Dragging_2'',gcbo,guidata(gcbo))');
set(plot_handles2.plot_figure,'WindowButtonUpFcn','Hypnogram_Generation(''Stop_Dragging_2'',gcbo,guidata(gcbo))');
        
plot_handles2.mouse_action = 0;
plot_handles2.rbar_action = 0;
plot_handles2.rbar_click_pos = 0;
plot_handles2.x_bar = [0 total_length2];



plot_handles3.plot_figure = figure(3);
guidata(plot_handles3.plot_figure,plot_handles3);

plot_handles3.axes1 = axes('Position',[0.1300 0.1600 0.7750 0.7650]);
guidata(plot_handles3.axes1,plot_handles3);

h = bar(0.5:1:total_length2-0.5,nrem_perct,0.85);
set(h,'FaceColor',[0.5 0.5 0.5]);

set(plot_handles3.axes1,'XLimMode','Manual','XLim',[0 total_length2]);
set(plot_handles3.axes1,'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
xlabel('Hours');
ylabel('%');
title('NREM Time Percentage');

set(plot_handles3.axes1,'YLimMode','Manual','YLim',[0 100]);
set(plot_handles3.axes1,'YTickMode','Manual','YTick',[0 25 50 75 100]);
set(plot_handles3.axes1,'Box','Off');
set(plot_handles3.plot_figure,'Color',[1 1 1]);


plot_handles3.axes2 = axes('Position',[0.1300 0.0400 0.7750 0.0800]);
guidata(plot_handles3.axes2,plot_handles3);

plot_handles3.range_bar = line([0 total_length2],[0.5 0.5],'Parent',plot_handles3.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
guidata(plot_handles3.range_bar,plot_handles3);     
    
set(plot_handles3.axes2,'XLimMode','Manual','XLim',[0 total_length2],'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
set(plot_handles3.axes2,'YLimMode','Manual','YLim',[0 1],'YTickMode','Manual','YTick',[]);
set(plot_handles3.axes2,'YColor',[1 1 1]);

set(plot_handles3.range_bar,'ButtonDownFcn','Hypnogram_Generation(''Range_Bar_Callback'',gcbo,guidata(gcbo))');       
        
        
set(plot_handles3.plot_figure,'WindowButtonMotionFcn','Hypnogram_Generation(''Start_Dragging_2'',gcbo,guidata(gcbo))');
set(plot_handles3.plot_figure,'WindowButtonUpFcn','Hypnogram_Generation(''Stop_Dragging_2'',gcbo,guidata(gcbo))');
        
plot_handles3.mouse_action = 0;
plot_handles3.rbar_action = 0;
plot_handles3.rbar_click_pos = 0;
plot_handles3.x_bar = [0 total_length2];



plot_handles4.plot_figure = figure(4);
guidata(plot_handles4.plot_figure,plot_handles4);

plot_handles4.axes1 = axes('Position',[0.1300 0.1600 0.7750 0.7650]);
guidata(plot_handles4.axes1,plot_handles4);

h = bar(0.5:1:total_length2-0.5,rem_perct,0.85);
set(h,'FaceColor',[0.5 0.5 0.5]);

set(plot_handles4.axes1,'XLimMode','Manual','XLim',[0 total_length2]);
set(plot_handles4.axes1,'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
xlabel('Hours');
ylabel('%');
title('REM Time Percentage');

set(plot_handles4.axes1,'YLimMode','Manual','YLim',[0 100]);
set(plot_handles4.axes1,'YTickMode','Manual','YTick',[0 25 50 75 100]);
set(plot_handles4.axes1,'Box','Off');
set(plot_handles4.plot_figure,'Color',[1 1 1]);


plot_handles4.axes2 = axes('Position',[0.1300 0.0400 0.7750 0.0800]);
guidata(plot_handles4.axes2,plot_handles4);

plot_handles4.range_bar = line([0 total_length2],[0.5 0.5],'Parent',plot_handles4.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
guidata(plot_handles4.range_bar,plot_handles4);     
    
set(plot_handles4.axes2,'XLimMode','Manual','XLim',[0 total_length2],'XTickMode','Manual','XTick',xtick_vec2,'XTickLabel',xtick_label2);
set(plot_handles4.axes2,'YLimMode','Manual','YLim',[0 1],'YTickMode','Manual','YTick',[]);
set(plot_handles4.axes2,'YColor',[1 1 1]);

set(plot_handles4.range_bar,'ButtonDownFcn','Hypnogram_Generation(''Range_Bar_Callback'',gcbo,guidata(gcbo))');       
        
        
set(plot_handles4.plot_figure,'WindowButtonMotionFcn','Hypnogram_Generation(''Start_Dragging_2'',gcbo,guidata(gcbo))');
set(plot_handles4.plot_figure,'WindowButtonUpFcn','Hypnogram_Generation(''Stop_Dragging_2'',gcbo,guidata(gcbo))');
        
plot_handles4.mouse_action = 0;
plot_handles4.rbar_action = 0;
plot_handles4.rbar_click_pos = 0;
plot_handles4.x_bar = [0 total_length2];



clear snumber Data_Range real_data num_per_bin;
clear xtick_step1 xtick_vec1 xtick_label1 ytick_label1;
clear hypno_state wake_perct nrem_perct rem_perct;
clear xtick_step2 xtick_vec2 xtick_label2 h;


function Range_Bar_Callback(hObject,handles)


handles.mouse_action = 1;
h_bar = hObject;
h_axes = get(h_bar,'Parent');

click_pos = get(h_axes,'CurrentPoint');
x_click = click_pos(1,1);
handles.rbar_click_pos = x_click;
handles.x_bar = get(h_bar,'XData');


x_lim = get(h_bar,'XData');
x_right_thres = x_lim(2) - (x_lim(2) - x_lim(1))/10;
x_left_thres = x_lim(1) + (x_lim(2) - x_lim(1))/10;

if x_click > x_right_thres
    handles.rbar_action = 3;  % stretch to the right
elseif x_click < x_left_thres
    handles.rbar_action = 2;  % stretch to the left
else
    handles.rbar_action = 1;  % shift
end

guidata(hObject,handles);

clear h_bar h_axes click_pos x_click x_lim x_right_thres x_left_thres;



function Start_Dragging(hObject,handles)

global total_length1;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0
    return;
end

x_lim(1) = 0;
x_lim(2) = total_length1;
    
if handles.mouse_action == 1
    if handles.rbar_action == 0
        return;
    end
    
    h_bar = handles.range_bar;
    h_axes = get(h_bar,'Parent');
    mouse_pos = get(h_axes,'CurrentPoint');
    
    x_bar = get(h_bar,'XData');
    
    if handles.rbar_action == 1 %shift
        
        dist = mouse_pos(1,1) - handles.rbar_click_pos;
    
        if dist + handles.x_bar(2) > x_lim(2) % too far right, condense           
            set(h_bar,'XData', [round(x_lim(2)-handles.x_bar(2)+handles.x_bar(1)),x_lim(2)]); 
        elseif dist + handles.x_bar(1) < x_lim(1) % too far left, condense
            set(h_bar,'XData', [x_lim(1), round(x_lim(1)+handles.x_bar(2)-handles.x_bar(1))]);	
        else % shift over
            set(h_bar,'XData',round(handles.x_bar+dist));
        end    
        
        
    elseif handles.rbar_action == 2  % stretch of the left end
        if mouse_pos(1,1) < x_bar(1)
            if mouse_pos(1,1) < x_lim(1)
                set(h_bar,'XData',[x_lim(1) x_bar(2)]);
            else
                set(h_bar,'XData',[round(mouse_pos(1,1)) x_bar(2)]);
            end
        else
            if mouse_pos(1,1) <= x_bar(2)
                set(h_bar,'XData',[round(mouse_pos(1,1)) x_bar(2)]);
            end
        end
    elseif handles.rbar_action == 3 % stretch of the right end
        if mouse_pos(1,1) > x_bar(2)
            if mouse_pos(1,1) > x_lim(2)
                set(h_bar,'XData',[x_bar(1) x_lim(2)]);
            else
                set(h_bar,'XData',[x_bar(1) round(mouse_pos(1,1))]);
            end
        else
            if mouse_pos(1,1) >= x_bar(1)
                set(h_bar,'XData',[x_bar(1) round(mouse_pos(1,1))]);
            end
        end
    end           
   
    guidata(hObject,handles);     
    clear h_bar h_axes mouse_pos dist x_bar;
    
end

clear x_lim;


function Start_Dragging_2(hObject,handles)

global total_length2;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0
    return;
end

x_lim(1) = 0;
x_lim(2) = total_length2;
    
if handles.mouse_action == 1
    if handles.rbar_action == 0
        return;
    end
    
    h_bar = handles.range_bar;
    h_axes = get(h_bar,'Parent');
    mouse_pos = get(h_axes,'CurrentPoint');
    
    x_bar = get(h_bar,'XData');
    
    if handles.rbar_action == 1 %shift
        
        dist = mouse_pos(1,1) - handles.rbar_click_pos;
    
        if dist + handles.x_bar(2) > x_lim(2) % too far right, condense           
            set(h_bar,'XData', [round(x_lim(2)-handles.x_bar(2)+handles.x_bar(1)),x_lim(2)]); 
        elseif dist + handles.x_bar(1) < x_lim(1) % too far left, condense
            set(h_bar,'XData', [x_lim(1), round(x_lim(1)+handles.x_bar(2)-handles.x_bar(1))]);	
        else % shift over
            set(h_bar,'XData',round(handles.x_bar+dist));
        end    
        
        
    elseif handles.rbar_action == 2  % stretch of the left end
        if mouse_pos(1,1) < x_bar(1)
            if mouse_pos(1,1) < x_lim(1)
                set(h_bar,'XData',[x_lim(1) x_bar(2)]);
            else
                set(h_bar,'XData',[round(mouse_pos(1,1)) x_bar(2)]);
            end
        else
            if mouse_pos(1,1) <= x_bar(2)
                set(h_bar,'XData',[round(mouse_pos(1,1)) x_bar(2)]);
            end
        end
    elseif handles.rbar_action == 3 % stretch of the right end
        if mouse_pos(1,1) > x_bar(2)
            if mouse_pos(1,1) > x_lim(2)
                set(h_bar,'XData',[x_bar(1) x_lim(2)]);
            else
                set(h_bar,'XData',[x_bar(1) round(mouse_pos(1,1))]);
            end
        else
            if mouse_pos(1,1) >= x_bar(1)
                set(h_bar,'XData',[x_bar(1) round(mouse_pos(1,1))]);
            end
        end
    end           
   
    guidata(hObject,handles);     
    clear h_bar h_axes mouse_pos dist x_bar;
    
end

clear x_lim;



function Stop_Dragging(hObject,handles)

global epoch_dur;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0 
    return;
end

if handles.mouse_action == 1       
    handles.mouse_action = 0; 
    handles.rbar_action = 0;
	handles.rbar_click_pos = 0;
    
    
    data_range = get(handles.range_bar,'XData');
    
    xtick_step = round((data_range(2) - data_range(1))/10);
    
    xtick_vec = data_range(1):xtick_step:data_range(2);
    
    if xtick_vec(end) ~= data_range(2)
        if abs(xtick_vec(end) - data_range(2)) < (xtick_vec(end) - xtick_vec(end-1))/4
            xtick_vec(end) = data_range(2);
        else
            xtick_vec = [xtick_vec data_range(2)];
        end
    end

    xtick_label = round(xtick_vec*epoch_dur/3600*100)/100;
    
    
    set(handles.axes1,'XLimMode','Manual','XLim',data_range,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_label);
    
    guidata(hObject,handles);
    
    clear data_range xtick_step xtick_vec xtick_label;
end


function Stop_Dragging_2(hObject,handles)

global bin_dur;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0 
    return;
end

if handles.mouse_action == 1       
    handles.mouse_action = 0; 
    handles.rbar_action = 0;
	handles.rbar_click_pos = 0;
    
    
    data_range = get(handles.range_bar,'XData');
    
    xtick_step = round((data_range(2) - data_range(1))/10);
    
    xtick_vec = data_range(1):xtick_step:data_range(2);
    
    if xtick_vec(end) ~= data_range(2)
        if abs(xtick_vec(end) - data_range(2)) < (xtick_vec(end) - xtick_vec(end-1))/4
            xtick_vec(end) = data_range(2);
        else
            xtick_vec = [xtick_vec data_range(2)];
        end
    end

    xtick_label = round(xtick_vec*bin_dur/60*100)/100;
    
    
    set(handles.axes1,'XLimMode','Manual','XLim',data_range,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_label);
    
    guidata(hObject,handles);
    
    clear data_range xtick_step xtick_vec xtick_label;
end
