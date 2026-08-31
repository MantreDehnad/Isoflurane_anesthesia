function varargout = Double_Plot(varargin)

% written by Sheng Xu, Nov. 2009


% DOUBLE_PLOT M-file for Double_Plot.fig
%      DOUBLE_PLOT, by itself, creates a new DOUBLE_PLOT or raises the existing
%      singleton*.
%
%      H = DOUBLE_PLOT returns the handle to a new DOUBLE_PLOT or the handle to
%      the existing singleton*.
%
%      DOUBLE_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOUBLE_PLOT.M with the given input arguments.
%
%      DOUBLE_PLOT('Property','Value',...) creates a new DOUBLE_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Double_Plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Double_Plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Double_Plot

% Last Modified by GUIDE v2.5 12-Nov-2009 13:16:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Double_Plot_OpeningFcn, ...
                   'gui_OutputFcn',  @Double_Plot_OutputFcn, ...
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


% --- Executes just before Double_Plot is made visible.
function Double_Plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Double_Plot (see VARARGIN)

% Choose default command line output for Double_Plot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Double_Plot wait for user response (see UIRESUME)
% uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = Double_Plot_OutputFcn(hObject, eventdata, handles) 
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

set(handles.Filename_Text, 'String', handles.File_Name);

guidata(hObject,handles);

clear name_txt path_str;



% --- Executes on button press in Get_Wheel_File_Push.
function Get_Wheel_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Get_Wheel_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[name_txt, path_str] = uigetfile('.xlsx', 'Pick The Wheel Experiment Excel File');

handles.Wheel_File_Name = strcat(path_str, name_txt);

set(handles.Wheel_Filename_Text, 'String', handles.Wheel_File_Name);

guidata(hObject,handles);

clear name_txt path_str;





function Sheetnumber_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Sheetnumber_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sheetnumber_Edit as text
%        str2double(get(hObject,'String')) returns contents of Sheetnumber_Edit as a double
snumber = get(hObject,'String');
snumber = str2num(snumber);

if length(snumber) > 1
    errordlg('You can only handle one sheet at a time.','Sheet Number Error');
    return;
end

if snumber < 0
    errordlg('Invalid sheet number, please re-enter.','Sheet Number Invalid');
    return;
end

handles.Sheet_Number = snumber;

guidata(hObject,handles);

clear snumber;



function Wheel_Sheetnumber_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Wheel_Sheetnumber_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wheel_Sheetnumber_Edit as text
%        str2double(get(hObject,'String')) returns contents of Wheel_Sheetnumber_Edit as a double
snumber = get(hObject,'String');
snumber = str2num(snumber);

if length(snumber) > 1
    errordlg('You can only handle one sheet at a time.','Sheet Number Error');
    return;
end

if snumber < 0
    errordlg('Invalid sheet number, please re-enter.','Sheet Number Invalid');
    return;
end

handles.Wheel_Sheet_Number = snumber;

guidata(hObject,handles);

clear snumber;



% --- Executes on button press in Wheel_Checkbox.
function Wheel_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Wheel_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Wheel_Checkbox
h_value = get(hObject,'Value');
if h_value == 1
    set(handles.Get_Wheel_File_Push,'Enable','On');
    set(handles.Wheel_Filename_Text,'Enable','On');
    set(handles.Wheel_Sheetnumber_Text,'Enable','On');
    set(handles.Wheel_Sheetnumber_Edit,'Enable','On');
    set(handles.Wheel_DRange_Text,'Enable','On');
    set(handles.Wheel_DRange_Edit,'Enable','On');
    set(handles.Plot_Separate_Checkbox,'Enable','On');
elseif h_value == 0
    set(handles.Get_Wheel_File_Push,'Enable','Off');
    set(handles.Wheel_Filename_Text,'Enable','Off');
    set(handles.Wheel_Sheetnumber_Text,'Enable','Off');
    set(handles.Wheel_Sheetnumber_Edit,'Enable','Off');
    set(handles.Wheel_DRange_Text,'Enable','Off');
    set(handles.Wheel_DRange_Edit,'Enable','Off');
    set(handles.Plot_Separate_Checkbox,'Enable','Off');
end

clear h_value;






% --- Executes on button press in Plot_Push.
function Plot_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global row_num Cycle_Dur;

snumber = get(handles.Sheetnumber_Edit,'String');
handles.Sheet_Number = str2num(snumber);

handles.Animal_ID_Location = get(handles.ID_Edit,'String');
handles.Data_Range = get(handles.DRange_Edit,'String');

edur = get(handles.EDur_Edit,'String');
handles.Epoch_Dur = str2num(edur);

cdur = get(handles.CDur_Edit,'String');
handles.Cycle_Dur = str2num(cdur);
Cycle_Dur = str2num(cdur);

handles.CScheme_Type = get(handles.CScheme_Listbox,'Value');

real_data = xlsread(handles.File_Name, handles.Sheet_Number, handles.Data_Range);
if get(handles.Dragging_Checkbox,'Value') == 1
    if size(real_data,2) > 1
        errordlg('You can only handle one animal''s data per time.','Multiple Animals Error');
        return;
    end
end


if get(handles.Wheel_Checkbox,'Value') == 1
    wheel_snumber = get(handles.Wheel_Sheetnumber_Edit,'String');
    handles.Wheel_Sheet_Number = str2num(wheel_snumber);
    handles.Wheel_Data_Range = get(handles.Wheel_DRange_Edit,'String');
    wheel_real_data = xlsread(handles.Wheel_File_Name, handles.Wheel_Sheet_Number, handles.Wheel_Data_Range);
    if size(wheel_real_data) ~= size(real_data)
        errordlg('The sizes of the sleep data and the wheel data do not match!','Size Match Error');
        return;
    end
    
    clear wheel_snumber;
end




if ~isempty(handles.Animal_ID_Location)
    [num,animal_id] = xlsread(handles.File_Name, handles.Sheet_Number, handles.Animal_ID_Location);
    if size(animal_id,2) ~= size(real_data,2)
        errordlg('Animal ID and data do not match, please check.','Matching Error');
        return;        
    end
    clear num;
else
    animal_id = [];
end   

    
num_percycle = handles.Cycle_Dur/handles.Epoch_Dur;
if round(num_percycle) ~= num_percycle
     errordlg('Cycle duration should be the multiple of the epoch duration.', 'Duration Error');
     return;
end
        
row_num = ceil(size(real_data,1)/num_percycle) - 1;

ytick_step = round(row_num/10);
ytick_vec = 0:ytick_step:row_num;
if ytick_vec(end) ~= row_num
    if abs(row_num - ytick_vec(end)) < abs(ytick_vec(end) - ytick_vec(end-1))/3
        ytick_vec(end) = row_num;
    else
        ytick_vec = [ytick_vec row_num];
    end
end

xtick_step = round(num_percycle/4);
xtick_vec = 0:xtick_step:num_percycle;
if xtick_vec(end) ~= num_percycle
    if abs(xtick_vec(end) - num_percycle) < (xtick_vec(end) - xtick_vec(end-1))/4
        xtick_vec(end) = num_percycle;
    else
        xtick_vec = [xtick_vec num_percycle];
    end
end
xtick_vec = [xtick_vec xtick_vec(2:end) + num_percycle];
    



figure_colormap = colormap(jet(64));
data_min = 0;
data_max = 100;
coeff_a = (64-1)/(data_max-data_min);
coeff_b = 1 - coeff_a*data_min;



if get(handles.Dragging_Checkbox,'Value') == 0

    if get(handles.Wheel_Checkbox,'Value') == 0
        

        for i = 1:size(real_data,2)
            plot_data = real_data(:,i);            
          
            figure(i);
                      
            for j = 1:row_num
                current_bottom = 1.5*j-1.5;
                current_top = 1.5*j-0.5;
                for k = 1:2*num_percycle
                    current_value = plot_data(num_percycle*(j-1)+k);                
                  
                    if ~isnan(current_value)
                
                        if handles.CScheme_Type == 1                   
                    
                            if current_value >= 0 & current_value < 33.33
                                current_color = [0 0 1];
                            elseif current_value >= 33.33 & current_value < 66.67
                                current_color = [0 1 0];
                            elseif current_value >= 66.67 & current_value <= 100
                                current_color = [1 0 0];               
                            end
                        
                        elseif handles.CScheme_Type == 2
                        
                            color_index = current_value*coeff_a + coeff_b;
                            color_index = round(color_index);
                            current_color = figure_colormap(color_index,:);
                            clear color_index;
                        end
                    end
                
                    fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],current_color);
                    hold on;
                    clear current_color;  
                    clear current_value;
                
                end
           
                clear current_bottom current_top;       
        
            end
            
            hold off;
    
            ha = gca;       
            set(ha,'Box','Off');
            set(ha,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
            set(ha,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
            xlabel('Time (minutes)');
        
                   
            set(ha,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
            ylabel('(Hours)');
        
            if ~isempty(animal_id)
                title(animal_id(1,i));
            end            
               
        
            set(gcf,'Color','White');    
                      
          
                 
            clear plot_data ha;
        end
        
    elseif get(handles.Wheel_Checkbox,'Value') == 1
        if get(handles.Plot_Separate_Checkbox,'Value') == 1
            
            for i = 1:size(real_data,2)
                plot_data = real_data(:,i);            
          
                figure(2*i-1);
                      
                for j = 1:row_num
                    current_bottom = 1.5*j-1.5;
                    current_top = 1.5*j-0.5;
                    for k = 1:2*num_percycle
                        current_value = plot_data(num_percycle*(j-1)+k);                
                  
                        if ~isnan(current_value)
                
                            if handles.CScheme_Type == 1                   
                    
                                if current_value >= 0 & current_value < 33.33
                                    current_color = [0 0 1];
                                elseif current_value >= 33.33 & current_value < 66.67
                                    current_color = [0 1 0];
                                elseif current_value >= 66.67 & current_value <= 100
                                    current_color = [1 0 0];               
                                end
                        
                            elseif handles.CScheme_Type == 2
                        
                                color_index = current_value*coeff_a + coeff_b;
                                color_index = round(color_index);
                                current_color = figure_colormap(color_index,:);
                                clear color_index;
                       
                            end
                        end
                
                        fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],current_color);
                        hold on;
                        clear current_color;  
                        clear current_value;
                
                    end
           
                    clear current_bottom current_top;       
        
                end
            
                hold off;
    
                ha = gca;       
                set(ha,'Box','Off');
                set(ha,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
                set(ha,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
                xlabel('Time (minutes)');
        
                   
                set(ha,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
                ylabel('(Hours)');
        
                if ~isempty(animal_id)
                    title(animal_id(1,i));
                end            
               
        
                set(gcf,'Color','White');                         
          
                 
                clear plot_data ha;
                
                
                plot_wheel_data = wheel_real_data(:,i);
                figure(2*i);
                
                for j = 1:row_num
                    current_bottom = 1.5*j-1.5;
                    current_top = 1.5*j-0.5;
                    for k = 1:2*num_percycle
                        current_value = plot_wheel_data(num_percycle*(j-1)+k);                
                  
                        if ~isnan(current_value)
                            
                            if current_value == 1
                                fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],[0 0 0]);
                            elseif current_value == 0
                                fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],[1 1 1],'EdgeColor',[0 0 0]);
                            end
                                            
                        end
                
                       
                        hold on;
                        
                        clear current_value;
                
                    end
           
                    clear current_bottom current_top;       
        
                end
            
                hold off;
    
                ha = gca;       
                set(ha,'Box','Off');
                set(ha,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
                set(ha,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
                xlabel('Time (minutes)');
        
                   
                set(ha,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
                ylabel('(Hours)');
        
                if ~isempty(animal_id)
                    title(animal_id(1,i));
                end            
               
        
                set(gcf,'Color','White');  
                
                clear plot_wheel_data ha;
                
            end    
        elseif get(handles.Plot_Separate_Checkbox,'Value') == 0
            
            for i = 1:size(real_data,2)
                plot_data = real_data(:,i);            
                plot_wheel_data = wheel_real_data(:,i);
                figure(i);
                      
                for j = 1:row_num
                    current_bottom1 = 3.5*j-3.5;
                    current_top1 = 3.5*j-2.5;
                    
                    current_bottom2 = 3.5*j-2.25;
                    current_top2 = 3.5*j-1.25;
                    
                    
                    for k = 1:2*num_percycle
                        current_value1 = plot_data(num_percycle*(j-1)+k);   
                        current_value2 = plot_wheel_data(num_percycle*(j-1)+k);  
                  
                        if ~isnan(current_value1)
                
                            if handles.CScheme_Type == 1                   
                    
                                if current_value1 >= 0 & current_value1 < 33.33
                                    current_color = [0 0 1];
                                elseif current_value1 >= 33.33 & current_value1 < 66.67
                                    current_color = [0 1 0];
                                elseif current_value1 >= 66.67 & current_value1 <= 100
                                    current_color = [1 0 0];               
                                end
                        
                            elseif handles.CScheme_Type == 2
                        
                                color_index = current_value1*coeff_a + coeff_b;
                                color_index = round(color_index);
                                current_color = figure_colormap(color_index,:);
                                clear color_index;
                       
                            end
                        end
                
                        fill([(k-1) k k (k-1)],[current_bottom1 current_bottom1 current_top1 current_top1],current_color);
                        hold on;
                        
                        
                        if ~isnan(current_value2)
                            
                            if current_value2 == 1
                                fill([(k-1) k k (k-1)],[current_bottom2 current_bottom2 current_top2 current_top2],[0 0 0]);
                            elseif current_value2 == 0
                                fill([(k-1) k k (k-1)],[current_bottom2 current_bottom2 current_top2 current_top2],[1 1 1],'EdgeColor',[0 0 0]);
                            end
                                            
                        end
                        hold on;
                        
                        clear current_color;  
                        clear current_value1 current_value2;
                
                    end
           
                    clear current_bottom1 current_top1 current_bottom2 current_top2;       
        
                end
            
                hold off;
    
                ha = gca;       
                set(ha,'Box','Off');
                set(ha,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-1.25 3.5*row_num]);
        
                 
                set(ha,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
                xlabel('Time (minutes)');
        
                   
                set(ha,'YTickMode','Manual','YTick',ytick_vec*3.5-1.25,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
                ylabel('(Hours)');
        
                if ~isempty(animal_id)
                    title(animal_id(1,i));
                end            
               
        
                set(gcf,'Color','White');                         
          
                 
                clear plot_data plot_wheel_data ha;
            end
                
                          
        end
    end

elseif get(handles.Dragging_Checkbox,'Value') == 1
    if get(handles.Wheel_Checkbox,'Value') == 0
        
        plot_handles.plot_figure = figure(1);
        guidata(plot_handles.plot_figure,plot_handles);
        
        plot_handles.axes1 = axes('Position',[0.16 0.11 0.755 0.815]);      
        guidata(plot_handles.axes1,plot_handles);
                
        for j = 1:row_num
            current_bottom = 1.5*j-1.5;
            current_top = 1.5*j-0.5;
            for k = 1:2*num_percycle
                current_value = real_data(num_percycle*(j-1)+k);                
                  
                if ~isnan(current_value)
                
                    if handles.CScheme_Type == 1                   
                    
                        if current_value >= 0 & current_value < 33.33
                            current_color = [0 0 1];
                        elseif current_value >= 33.33 & current_value < 66.67
                            current_color = [0 1 0];
                        elseif current_value >= 66.67 & current_value <= 100
                            current_color = [1 0 0];               
                        end
                        
                    elseif handles.CScheme_Type == 2
                        
                        color_index = current_value*coeff_a + coeff_b;
                        color_index = round(color_index);
                        current_color = figure_colormap(color_index,:);
                        clear color_index;
                    end
                end
                
                fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],current_color);
                hold on;
                clear current_color;  
                clear current_value;
                
            end
           
            clear current_bottom current_top;       
        
        end
            
        hold off;
    
               
        set(plot_handles.axes1,'Box','Off');
        set(plot_handles.axes1,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
        set(plot_handles.axes1,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
        xlabel('Time (minutes)');
        
                   
        set(plot_handles.axes1,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
        
        if ~isempty(animal_id)
            title(animal_id);
        end            
               
        
        plot_handles.axes2 = axes('Position',[0.08 0.11 0.05 0.815]);
        set(plot_handles.axes2,'XLimMode','Manual','XLim',[0 1],'XTickMode','Manual','XTick',[]);
        set(plot_handles.axes2,'YLimMode','Manual','YLim',[-0.5 1.5*row_num],'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
        ylabel('(Hours)');      
        guidata(plot_handles.axes2,plot_handles);
        
        
        plot_handles.range_bar = line([0.5 0.5],[0 1.5*row_num],'Parent',plot_handles.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
        guidata(plot_handles.range_bar,plot_handles);
        
        
        set(plot_handles.plot_figure,'Color','White');    
                      
               
        set(plot_handles.range_bar,'ButtonDownFcn','Double_Plot(''Range_Bar_Callback'',gcbo,guidata(gcbo))');
       
        
        
        set(plot_handles.plot_figure,'WindowButtonMotionFcn','Double_Plot(''Start_Dragging'',gcbo,guidata(gcbo))');
        set(plot_handles.plot_figure,'WindowButtonUpFcn','Double_Plot(''Stop_Dragging'',gcbo,guidata(gcbo))');
        
        plot_handles.mouse_action = 0;
        plot_handles.rbar_action = 0;
        plot_handles.rbar_click_pos = 0;
        plot_handles.y_bar = [0 1.5*row_num];
        
        
    elseif get(handles.Wheel_Checkbox,'Value') == 1
        if get(handles.Plot_Separate_Checkbox,'Value') == 1
            
            plot_handles.plot_figure = figure(1);
            guidata(plot_handles.plot_figure,plot_handles);
        
            plot_handles.axes1 = axes('Position',[0.16 0.11 0.755 0.815]);      
            guidata(plot_handles.axes1,plot_handles);
                
            for j = 1:row_num
                current_bottom = 1.5*j-1.5;
                current_top = 1.5*j-0.5;
                for k = 1:2*num_percycle
                    current_value = real_data(num_percycle*(j-1)+k);                
                  
                    if ~isnan(current_value)
                
                        if handles.CScheme_Type == 1                   
                    
                            if current_value >= 0 & current_value < 33.33
                                current_color = [0 0 1];
                            elseif current_value >= 33.33 & current_value < 66.67
                                current_color = [0 1 0];
                            elseif current_value >= 66.67 & current_value <= 100
                                current_color = [1 0 0];               
                            end
                        
                        elseif handles.CScheme_Type == 2
                        
                            color_index = current_value*coeff_a + coeff_b;
                            color_index = round(color_index);
                            current_color = figure_colormap(color_index,:);
                            clear color_index;
                        end
                    end
                
                    fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],current_color);
                    hold on;
                    clear current_color;  
                    clear current_value;
                
                end
           
                clear current_bottom current_top;       
        
            end
            
            hold off;
    
               
            set(plot_handles.axes1,'Box','Off');
            set(plot_handles.axes1,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
            set(plot_handles.axes1,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
            xlabel('Time (minutes)');
        
                   
            set(plot_handles.axes1,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
        
            if ~isempty(animal_id)
                title(animal_id);
            end            
               
        
            plot_handles.axes2 = axes('Position',[0.08 0.11 0.05 0.815]);
            set(plot_handles.axes2,'XLimMode','Manual','XLim',[0 1],'XTickMode','Manual','XTick',[]);
            set(plot_handles.axes2,'YLimMode','Manual','YLim',[-0.5 1.5*row_num],'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
            ylabel('(Hours)');      
            guidata(plot_handles.axes2,plot_handles);
        
        
            plot_handles.range_bar = line([0.5 0.5],[0 1.5*row_num],'Parent',plot_handles.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
            guidata(plot_handles.range_bar,plot_handles);
        
        
            set(plot_handles.plot_figure,'Color','White');    
                      
               
            set(plot_handles.range_bar,'ButtonDownFcn','Double_Plot(''Range_Bar_Callback'',gcbo,guidata(gcbo))');
       
        
        
            set(plot_handles.plot_figure,'WindowButtonMotionFcn','Double_Plot(''Start_Dragging'',gcbo,guidata(gcbo))');
            set(plot_handles.plot_figure,'WindowButtonUpFcn','Double_Plot(''Stop_Dragging'',gcbo,guidata(gcbo))');
        
            plot_handles.mouse_action = 0;
            plot_handles.rbar_action = 0;
            plot_handles.rbar_click_pos = 0;
            plot_handles.y_bar = [0 1.5*row_num];
           
            
            wheel_plot_handles.plot_figure = figure(2);
            guidata(wheel_plot_handles.plot_figure,wheel_plot_handles);
        
            wheel_plot_handles.axes1 = axes('Position',[0.16 0.11 0.755 0.815]);      
            guidata(wheel_plot_handles.axes1,wheel_plot_handles);
                
            for j = 1:row_num
                
                current_bottom = 1.5*j-1.5;
                current_top = 1.5*j-0.5;
                for k = 1:2*num_percycle
                    current_value = wheel_real_data(num_percycle*(j-1)+k);                
                  
                    if ~isnan(current_value)
                        if current_value == 1
                            fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],[0 0 0]);
                        elseif current_value == 0
                            fill([(k-1) k k (k-1)],[current_bottom current_bottom current_top current_top],[1 1 1],'EdgeColor',[0 0 0]);
                        end
                        
                    end
                
                  
                    hold on;
                   
                    clear current_value;
                
                end
           
                clear current_bottom current_top;       
        
            end
            
            hold off;
    
               
            set(wheel_plot_handles.axes1,'Box','Off');
            set(wheel_plot_handles.axes1,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-0.5 1.5*row_num]);
        
                 
            set(wheel_plot_handles.axes1,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
            xlabel('Time (minutes)');
        
                   
            set(wheel_plot_handles.axes1,'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
        
            if ~isempty(animal_id)
                title(animal_id);
            end            
               
        
            wheel_plot_handles.axes2 = axes('Position',[0.08 0.11 0.05 0.815]);
            set(wheel_plot_handles.axes2,'XLimMode','Manual','XLim',[0 1],'XTickMode','Manual','XTick',[]);
            set(wheel_plot_handles.axes2,'YLimMode','Manual','YLim',[-0.5 1.5*row_num],'YTickMode','Manual','YTick',ytick_vec*1.5-0.5,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
            ylabel('(Hours)');      
            guidata(wheel_plot_handles.axes2,wheel_plot_handles);
        
        
            wheel_plot_handles.range_bar = line([0.5 0.5],[0 1.5*row_num],'Parent',wheel_plot_handles.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
            guidata(wheel_plot_handles.range_bar,wheel_plot_handles);
        
        
            set(wheel_plot_handles.plot_figure,'Color','White');    
                      
               
            set(wheel_plot_handles.range_bar,'ButtonDownFcn','Double_Plot(''Range_Bar_Callback'',gcbo,guidata(gcbo))');
       
        
        
            set(wheel_plot_handles.plot_figure,'WindowButtonMotionFcn','Double_Plot(''Start_Dragging'',gcbo,guidata(gcbo))');
            set(wheel_plot_handles.plot_figure,'WindowButtonUpFcn','Double_Plot(''Stop_Dragging'',gcbo,guidata(gcbo))');
        
            wheel_plot_handles.mouse_action = 0;
            wheel_plot_handles.rbar_action = 0;
            wheel_plot_handles.rbar_click_pos = 0;
            wheel_plot_handles.y_bar = [0 1.5*row_num];
                 
                
            
        elseif get(handles.Plot_Separate_Checkbox,'Value') == 0
            
            plot_handles.plot_figure = figure(1);
            guidata(plot_handles.plot_figure,plot_handles);
        
            plot_handles.axes1 = axes('Position',[0.16 0.11 0.755 0.815]);      
            guidata(plot_handles.axes1,plot_handles);
               
                      
            for j = 1:row_num
                current_bottom1 = 3.5*j-3.5;
                current_top1 = 3.5*j-2.5;
                    
                current_bottom2 = 3.5*j-2.25;
                current_top2 = 3.5*j-1.25;
                    
                    
                for k = 1:2*num_percycle
                    current_value1 = real_data(num_percycle*(j-1)+k);   
                    current_value2 = wheel_real_data(num_percycle*(j-1)+k);  
                  
                    if ~isnan(current_value1)
                
                        if handles.CScheme_Type == 1                   
                            
                            if current_value1 >= 0 & current_value1 < 33.33
                                current_color = [0 0 1];
                            elseif current_value1 >= 33.33 & current_value1 < 66.67
                                current_color = [0 1 0];
                            elseif current_value1 >= 66.67 & current_value1 <= 100
                                current_color = [1 0 0];               
                            end
                        
                        elseif handles.CScheme_Type == 2
                        
                            color_index = current_value1*coeff_a + coeff_b;
                            color_index = round(color_index);
                            current_color = figure_colormap(color_index,:);
                            clear color_index;
                       
                        end
                    end
                
                    fill([(k-1) k k (k-1)],[current_bottom1 current_bottom1 current_top1 current_top1],current_color);
                    hold on;
                        
                        
                    if ~isnan(current_value2)
                           
                        if current_value2 == 1
                            fill([(k-1) k k (k-1)],[current_bottom2 current_bottom2 current_top2 current_top2],[0 0 0]);
                        elseif current_value2 == 0
                            fill([(k-1) k k (k-1)],[current_bottom2 current_bottom2 current_top2 current_top2],[1 1 1],'EdgeColor',[0 0 0]);
                        end
                                           
                    end
                    hold on;
                        
                    clear current_color;  
                    clear current_value1 current_value2;
                
                end
           
                clear current_bottom1 current_top1 current_bottom2 current_top2;       
        
            end
            
            hold off;
                
            set(plot_handles.axes1,'Box','Off');
            set(plot_handles.axes1,'XLimMode','Manual','XLim',[-1 2*num_percycle+1],'YLimMode','Manual','YLim',[-1.25 3.5*row_num]);
        
                 
            set(plot_handles.axes1,'XTickMode','Manual','XTick',xtick_vec,'XTickLabel',xtick_vec*handles.Epoch_Dur);
            xlabel('Time (minutes)');
        
                   
            set(plot_handles.axes1,'YTickMode','Manual','YTick',ytick_vec*3.5-1.25,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
        
            if ~isempty(animal_id)
                title(animal_id);
            end            
               
        
            plot_handles.axes2 = axes('Position',[0.08 0.11 0.05 0.815]);
            set(plot_handles.axes2,'XLimMode','Manual','XLim',[0 1],'XTickMode','Manual','XTick',[]);
            set(plot_handles.axes2,'YLimMode','Manual','YLim',[-1.25 3.5*row_num],'YTickMode','Manual','YTick',ytick_vec*3.5-1.25,'YTickLabel',ytick_vec*handles.Cycle_Dur/60);
            ylabel('(Hours)');      
            guidata(plot_handles.axes2,plot_handles);
        
        
            plot_handles.range_bar = line([0.5 0.5],[0 3.5*row_num],'Parent',plot_handles.axes2,'Tag','range_bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
            guidata(plot_handles.range_bar,plot_handles);
        
        
            set(plot_handles.plot_figure,'Color','White');    
                      
               
            set(plot_handles.range_bar,'ButtonDownFcn','Double_Plot(''Range_Bar_Callback'',gcbo,guidata(gcbo))');
       
        
        
            set(plot_handles.plot_figure,'WindowButtonMotionFcn','Double_Plot(''Start_Dragging_2'',gcbo,guidata(gcbo))');
            set(plot_handles.plot_figure,'WindowButtonUpFcn','Double_Plot(''Stop_Dragging_2'',gcbo,guidata(gcbo))');
        
            plot_handles.mouse_action = 0;
            plot_handles.rbar_action = 0;
            plot_handles.rbar_click_pos = 0;
            plot_handles.y_bar = [0 3.5*row_num];
        
    
            
                          
        end
    end


end

clear snumber edur cdur real_data wheel_real_data animal_id num_percycle row_num;
clear figure_colormap data_max data_min coeff_a coeff_b;
clear ytick_step ytick_vec xtick_step xtick_vec;


function Range_Bar_Callback(hObject,handles)

global row_num Cycle_Dur;

handles.mouse_action = 1;
h_bar = hObject;
h_axes = get(h_bar,'Parent');

click_pos = get(h_axes,'CurrentPoint');
y_click = click_pos(1,2);
handles.rbar_click_pos = y_click;
handles.y_bar = get(h_bar,'YData');


y_lim = get(h_bar,'YData');
y_up_thres = y_lim(2) - (y_lim(2) - y_lim(1))/10;
y_down_thres = y_lim(1) + (y_lim(2) - y_lim(1))/10;

if y_click > y_up_thres
    handles.rbar_action = 3;  % stretch upward
elseif y_click < y_down_thres
    handles.rbar_action = 2;  % stretch downward
else
    handles.rbar_action = 1;  % shift
end

guidata(hObject,handles);

clear h_bar h_axes click_pos y_click y_lim y_up_thres y_down_thres;





function Start_Dragging(hObject,handles)

global row_num Cycle_Dur;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0
    return;
end

y_lim(1) = 0;
y_lim(2) = row_num*1.5;
    
if handles.mouse_action == 1
    if handles.rbar_action == 0
        return;
    end
    
    h_bar = handles.range_bar;
    h_axes = get(h_bar,'Parent');
    mouse_pos = get(h_axes,'CurrentPoint');
    
    y_bar = get(h_bar,'YData');
    
    if handles.rbar_action == 1 %shift
        
        dist = mouse_pos(1,2) - handles.rbar_click_pos;
    
        if dist + handles.y_bar(2) > y_lim(2) % too far up, condense           
            set(h_bar,'YData', [round((y_lim(2)-handles.y_bar(2)+handles.y_bar(1))/1.5)*1.5,y_lim(2)]); 
        elseif dist + handles.y_bar(1) < y_lim(1) % too far down, condense
            set(h_bar,'YData', [y_lim(1), round((y_lim(1)+handles.y_bar(2)-handles.y_bar(1))/1.5)*1.5]);	
        else % shift over
            set(h_bar,'YData',round((handles.y_bar+dist)/1.5)*1.5);
        end    
        
        
    elseif handles.rbar_action == 2  % stretch of the lower end
        if mouse_pos(1,2) < y_bar(1)
            if mouse_pos(1,2) < y_lim(1)
                set(h_bar,'YData',[y_lim(1) y_bar(2)]);
            else
                set(h_bar,'YData',[round(mouse_pos(1,2)/1.5)*1.5 y_bar(2)]);
            end
        else
            if mouse_pos(1,2) <= y_bar(2)
                set(h_bar,'YData',[round(mouse_pos(1,2)/1.5)*1.5 y_bar(2)]);
            end
        end
    elseif handles.rbar_action == 3 % stretch of the upper end
        if mouse_pos(1,2) > y_bar(2)
            if mouse_pos(1,2) > y_lim(2)
                set(h_bar,'YData',[y_bar(1) y_lim(2)]);
            else
                set(h_bar,'YData',[y_bar(1) round(mouse_pos(1,2)/1.5)*1.5]);
            end
        else
            if mouse_pos(1,2) >= y_bar(1)
                set(h_bar,'YData',[y_bar(1) round(mouse_pos(1,2)/1.5)*1.5]);
            end
        end
    end           
   
    guidata(hObject,handles);     
    clear h_bar h_axes mouse_pos dist y_bar;
    
end

clear y_lim;


function Start_Dragging_2(hObject,handles)

global row_num Cycle_Dur;

if isfield(handles,'mouse_action') == 0
    return;
end

if handles.mouse_action == 0
    return;
end

y_lim(1) = 0;
y_lim(2) = row_num*3.5;
    
if handles.mouse_action == 1
    if handles.rbar_action == 0
        return;
    end
    
    h_bar = handles.range_bar;
    h_axes = get(h_bar,'Parent');
    mouse_pos = get(h_axes,'CurrentPoint');
    
    y_bar = get(h_bar,'YData');
    
    if handles.rbar_action == 1 %shift
        
        dist = mouse_pos(1,2) - handles.rbar_click_pos;
    
        if dist + handles.y_bar(2) > y_lim(2) % too far up, condense           
            set(h_bar,'YData', [round((y_lim(2)-handles.y_bar(2)+handles.y_bar(1))/3.5)*3.5,y_lim(2)]); 
        elseif dist + handles.y_bar(1) < y_lim(1) % too far down, condense
            set(h_bar,'YData', [y_lim(1), round((y_lim(1)+handles.y_bar(2)-handles.y_bar(1))/3.5)*3.5]);	
        else % shift over
            set(h_bar,'YData',round((handles.y_bar+dist)/3.5)*3.5);
        end    
        
        
    elseif handles.rbar_action == 2  % stretch of the lower end
        if mouse_pos(1,2) < y_bar(1)
            if mouse_pos(1,2) < y_lim(1)
                set(h_bar,'YData',[y_lim(1) y_bar(2)]);
            else
                set(h_bar,'YData',[round(mouse_pos(1,2)/3.5)*3.5 y_bar(2)]);
            end
        else
            if mouse_pos(1,2) <= y_bar(2)
                set(h_bar,'YData',[round(mouse_pos(1,2)/3.5)*3.5 y_bar(2)]);
            end
        end
    elseif handles.rbar_action == 3 % stretch of the upper end
        if mouse_pos(1,2) > y_bar(2)
            if mouse_pos(1,2) > y_lim(2)
                set(h_bar,'YData',[y_bar(1) y_lim(2)]);
            else
                set(h_bar,'YData',[y_bar(1) round(mouse_pos(1,2)/3.5)*3.5]);
            end
        else
            if mouse_pos(1,2) >= y_bar(1)
                set(h_bar,'YData',[y_bar(1) round(mouse_pos(1,2)/3.5)*3.5]);
            end
        end
    end           
   
    guidata(hObject,handles);     
    clear h_bar h_axes mouse_pos dist y_bar;
    
end

clear y_lim;






function Stop_Dragging(hObject,handles)

global row_num Cycle_Dur;

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
    
    
    data_range = get(handles.range_bar,'YData');
    y_range_1 = data_range(1)/1.5;
    y_range_2 = data_range(2)/1.5;
    
    ytick_step = round((y_range_2 - y_range_1)/4);
    
    ytick_vector = [y_range_1 y_range_1 + ytick_step y_range_1 + 2*ytick_step y_range_1 + 3*ytick_step y_range_2];
    set(handles.axes1,'YLimMode','Manual','YLim',[data_range(1)-0.5 data_range(2)-0.5],'YTickMode','Manual','YTick',ytick_vector*1.5-0.5,'YTickLabel',ytick_vector*Cycle_Dur/60);
    
    guidata(hObject,handles);
    
    clear data_range y_range_1 y_range_2 ytick_step ytick_vector;
end


function Stop_Dragging_2(hObject,handles)

global row_num Cycle_Dur;

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
    
    
    data_range = get(handles.range_bar,'YData');
    y_range_1 = data_range(1)/3.5;
    y_range_2 = data_range(2)/3.5;
    
    ytick_step = round((y_range_2 - y_range_1)/4);
    
    ytick_vector = [y_range_1 y_range_1 + ytick_step y_range_1 + 2*ytick_step y_range_1 + 3*ytick_step y_range_2];
    set(handles.axes1,'YLimMode','Manual','YLim',[data_range(1)-1.25 data_range(2)-0.5],'YTickMode','Manual','YTick',ytick_vector*3.5-1.25,'YTickLabel',ytick_vector*Cycle_Dur/60);
    
    guidata(hObject,handles);
    
    clear data_range y_range_1 y_range_2 ytick_step ytick_vector;
end

