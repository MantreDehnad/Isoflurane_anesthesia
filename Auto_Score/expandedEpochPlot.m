function varargout = expandedEpochPlot(varargin)
%Written by Roshan Nanu, July 2014
% EXPANDEDEPOCHPLOT MATLAB code for expandedEpochPlot.fig
%      EXPANDEDEPOCHPLOT, by itself, creates a new EXPANDEDEPOCHPLOT or raises the existing
%      singleton*.
%
%      H = EXPANDEDEPOCHPLOT returns the handle to a new EXPANDEDEPOCHPLOT or the handle to
%      the existing singleton*.
%
%      EXPANDEDEPOCHPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPANDEDEPOCHPLOT.M with the given input arguments.
%
%      EXPANDEDEPOCHPLOT('Property','Value',...) creates a new EXPANDEDEPOCHPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before expandedEpochPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to expandedEpochPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help expandedEpochPlot

% Last Modified by GUIDE v2.5 08-Aug-2014 11:56:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @expandedEpochPlot_OpeningFcn, ...
    'gui_OutputFcn',  @expandedEpochPlot_OutputFcn, ...
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


% --- Executes just before expandedEpochPlot is made visible.
function expandedEpochPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to expandedEpochPlot (see VARARGIN)

global EEG EMG Current_Epoch_Num parent Epoch_Dur Stages Time_EEG Sampling_Rate_EEG;
global Current_Epoch_Set Epoch_Set_Index Sampling_Rate_EMG Time_EMG;
global Ext_Stage_Change_Flag;
global Choose_Subset_Val;
global Single_Epoch_Flag;
Single_Epoch_Flag = 0;
parent = varargin{1};
if varargin{2}
    set(handles.uipanel3,'Visible','off');
end
phandles = guidata(parent);
set(handles.Choose_Subset_Pop,'String',get(phandles.Choose_Subset_Pop,'String'));
set(handles.Choose_Subset_Pop,'Value',Choose_Subset_Val);
Time_EEG = 0:1/Sampling_Rate_EEG:length(Stages)*Epoch_Dur;
Time_EEG = Time_EEG(2:end);
Time_EMG = 0:1/Sampling_Rate_EMG:length(Stages)*Epoch_Dur;
Time_EMG = Time_EMG(2:end);
set(handles.Epoch_Total_Text,'String',['  /    ' int2str(length(Stages))]);
set(handles.Epoch_Num_Box,'String',int2str(Current_Epoch_Num));
set(handles.Total_Epochs_Text,'String',[int2str(Epoch_Set_Index) '/' int2str(length(Current_Epoch_Set)) ' in set']);

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
Create_Plot(handles.EMG_Axes,handles);


function Create_Plot(hObject, handles)
global EEG EMG Current_Epoch_Num Epoch_Dur Stages Time_EEG Sampling_Rate_EEG;
global Time_EMG Sampling_Rate_EMG;


xlimit = [Epoch_Dur*(Current_Epoch_Num-2) Epoch_Dur*(Current_Epoch_Num+1)];


set(handles.EMG_Axes,'NextPlot','add');
set(handles.EEG_Axes,'NextPlot','add');

spe1 = Sampling_Rate_EMG*Epoch_Dur;
spe2 = Sampling_Rate_EEG*Epoch_Dur;

for i=1:length(Stages),
    switch Stages(i)
        case 1
            plot_color = [1 0 0];
        case 2
            plot_color = [0 0 1];
        case 3
            plot_color = [0 1 0];
        case 4
            plot_color = [180 51 180]/256;
        case 5
            plot_color = [0.1 0.6 0.88];
        case 6
            plot_color = [0.23 0.44 0.34];
        case 0
            plot_color = [0 0 0];
        case 7
            plot_color = [255 131 47]/256;
    end
    
    h = plot(handles.EMG_Axes,Time_EMG(spe1*(i-1)+1:spe1*i),EMG(spe1*(i-1)+1:spe1*i));
    set(h,'Color',plot_color);
    h = plot(handles.EEG_Axes,Time_EEG(spe2*(i-1)+1:spe2*i),EEG(spe2*(i-1)+1:spe2*i));
    set(h,'Color',plot_color);
end
% plot(handles.EMG_Axes,Time,EMG);
title(handles.EMG_Axes,'EMG');
title(handles.EEG_Axes,'EEG');

ylimit = [min(EMG) max(EMG)];
for i=1:length(Stages),
    plot(handles.EMG_Axes,[1 1]*Epoch_Dur*(i-1),ylimit,'k-.');
end
set(handles.EMG_Axes,'NextPlot','replace');
set(handles.EMG_Axes,'XLim',xlimit);
set(handles.EMG_Axes,'YLim',ylimit);
set(handles.EMG_Axes,'YGrid','on');
xlabel(handles.EMG_Axes,'Time (Sec)');
ylabel(handles.EMG_Axes,'Amplitude');

ylimit = [min(EEG) max(EEG)];
for i=1:length(Stages),
    plot(handles.EEG_Axes,[1 1]*Epoch_Dur*(i-1),ylimit,'k-.');
end
set(handles.EEG_Axes,'NextPlot','replace');
set(handles.EEG_Axes,'XLim',xlimit);
set(handles.EEG_Axes,'YLim',ylimit);
set(handles.EEG_Axes,'YGrid','on');
xlabel(handles.EEG_Axes,'Time (Sec)');
ylabel(handles.EEG_Axes,'Amplitude');

guidata(hObject,handles)
Epoch_Update(hObject,handles);


function Epoch_Update(hObject, handles)
global Epoch_Dur Current_Epoch_Num EMG EEG parent Epoch_Set_Index;
global Sampling_Rate_EEG Current_Epoch_Set Last_Epoch_Num;
global Single_Epoch_Flag Sampling_Rate_EMG;

if ~isempty(Current_Epoch_Set)
    if Current_Epoch_Num ~= Current_Epoch_Set(Epoch_Set_Index) ...
            && any(Current_Epoch_Set==Current_Epoch_Num)
        Epoch_Set_Index = find(Current_Epoch_Set == Current_Epoch_Num);
    end
else
    Epoch_Set_Index = 0;
end
if ~Single_Epoch_Flag
    xlimit = [Epoch_Dur*(Current_Epoch_Num-2) Epoch_Dur*(Current_Epoch_Num+1)];
else
    xlimit = [Epoch_Dur*(Current_Epoch_Num-1) Epoch_Dur*Current_Epoch_Num];
end
set(handles.EMG_Axes,'XLim',xlimit);
set(handles.EEG_Axes,'XLim',xlimit);

% spe1 = Sampling_Rate_EMG * Epoch_Dur;
% spe2 = Sampling_Rate_EEG * Epoch_Dur;

% if Current_Epoch_Num > 1 && Current_Epoch_Num < Last_Epoch_Num
%     y1 = max(abs(EMG(spe*(Current_Epoch_Num-2)+1:spe*(Current_Epoch_Num+1))))*1.2;
%     y2 = max(abs(EEG(spe*(Current_Epoch_Num-2)+1:spe*(Current_Epoch_Num+1))))*1.2;
% elseif Current_Epoch_Num == 1 
%     y1 = max(abs(EMG(1:spe*(Current_Epoch_Num+1))))*1.2;
%     y2 = max(abs(EEG(1:spe*(Current_Epoch_Num+1))))*1.2;
% else
%     y1 = max(abs(EMG(spe*(Current_Epoch_Num-2)+1:spe*Current_Epoch_Num)))*1.2;
%     y2 = max(abs(EEG(spe*(Current_Epoch_Num-2)+1:spe*Current_Epoch_Num)))*1.2;
% end
% ylim1 = [-y1 y1];
% ylim2 = [-y2 y2];
% set(handles.EMG_Axes,'YLim',ylim1);
% set(handles.EEG_Axes,'YLim',ylim2);

set(handles.Epoch_Num_Box,'String',int2str(Current_Epoch_Num));

set(handles.Total_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);


% Auto_Score('Epoch_Update1_Callback',hObject,[],guidata(parent))

guidata(hObject,handles);
Update_Double_Axis1(hObject,guidata(parent));


% --- Outputs from this function are returned to the command line.
function varargout = expandedEpochPlot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Epoch_Num_Box_Callback(hObject, eventdata, handles)
% hObject    handle to Current_Epoch_Num_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Current_Epoch_Num_Box as text
%        str2double(get(hObject,'String')) returns contents of Current_Epoch_Num_Box as a double
global Current_Epoch_Num Last_Epoch_Num;

Epoch_Num = str2num(get(hObject,'String'));
if Epoch_Num < 0 | Epoch_Num > Last_Epoch_Num
    errordlg('Invalid epoch num. Please re-enter.','Epoch Num Error');
    return;
end
Current_Epoch_Num = Epoch_Num;
Epoch_Update(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Epoch_Num_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Current_Epoch_Num_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Next_Push.
function Next_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Next_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num Epoch_Set_Index Current_Epoch_Set;
if ~isempty(Current_Epoch_Set)
    if Epoch_Set_Index<length(Current_Epoch_Set)
        Epoch_Set_Index = Epoch_Set_Index+1;
    end
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
else
    Epoch_Set_Index=0;
end
Epoch_Update(hObject,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');


% --- Executes on button press in Prev_Push.
function Prev_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num Epoch_Set_Index Current_Epoch_Set;
if ~isempty(Current_Epoch_Set)
    if Epoch_Set_Index>1
        Epoch_Set_Index = Epoch_Set_Index-1;
    end
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
    
else
    Epoch_Set_Index=0;
end
Epoch_Update(hObject,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    uiresume(handles.output)
catch
    msgbox('Close Request Error!')
end
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num
if strcmp(eventdata.Key,'rightarrow')
    Current_Epoch_Num = Current_Epoch_Num +1;
    Epoch_Update(hObject,handles);
elseif strcmp(eventdata.Key,'leftarrow')
    Current_Epoch_Num = Current_Epoch_Num -1;
    Epoch_Update(hObject,handles);
end


% --- Executes on selection change in Choose_Subset_Pop.
function Choose_Subset_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_Subset_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% contents = cellstr(get(hObject,'String'));% returns Choose_Subset_Pop contents as cell array
% val = contents{get(hObject,'Value')};% returns selected item from Choose_Subset_Pop
global Current_Epoch_Set Epoch_Set_Index Stages Current_Epoch_Num;
global Choose_Subset_Val Area_Epochs parent;
global Para1_Pop Para2_Pop Para1_Thres Para2_Thres1;

choice = get(hObject,'Value');
phandles = guidata(parent);
if Choose_Subset_Val == 7
    set(phandles.Area_Edge1,'Visible','Off');
    set(phandles.Area_Edge2,'Visible','Off');
    set(phandles.Area_Edge3,'Visible','Off');
    set(phandles.Area_Edge4,'Visible','Off');
end

Choose_Subset_Val = choice;

switch choice
    case 1
        Current_Epoch_Set = 1:length(Stages);
    case 2
        Current_Epoch_Set = find(Stages==1);
    case 3
        Current_Epoch_Set = find(Stages==3);
    case 4
        Current_Epoch_Set = find(Stages==2);
    case 5
        Current_Epoch_Set = find(Stages>3 | Stages==0);
    case 6
        Current_Epoch_Set = find(Stages==0);
    case 7
        if ~isempty(Area_Epochs)
            errordlg('Using Previously set area. \n To select new area close this window first.');
            Current_Epoch_Set = Area_Epochs;
            set(phandles.Area_Edge1,'Visible','On');
            set(phandles.Area_Edge2,'Visible','On');
            set(phandles.Area_Edge3,'Visible','On');
            set(phandles.Area_Edge4,'Visible','On');
        else
            errordlg('Please close this window and select an area first.');
            Choose_Subset_Val = 1;
            set(handles.Choose.Subset_Pop,'Value',1);
            Current_Epoch_Set = 1:length(Stages);
        end
        phandles = guidata(parent);
        set(phandles.Point_Selection_Toggle,'Value',0);
    case 8 %border select
        pts = fix(.05*numel(Stages)/2);
        [p1,ip1] = sort(Para1_Pop,'ascend');
        nonsws = find(Para1_Pop<=Para1_Thres);
        [p2,ip2] = sort(Para2_Pop(nonsws),'ascend');
        t1 = find(p1<=Para1_Thres,1,'last');
        t2 = find(p2<=Para2_Thres1,1,'last');
        z1 = ip1(max([1 t1-pts]):min([t1+pts length(ip1)]));
        z2 = ip2(max([1 t2-pts]):min([t2+pts length(ip2)]));
        z2 = nonsws(z2);
        Current_Epoch_Set = union(z1,z2);
        Choose_Subset_Val = choice;

end
if ~isempty(Current_Epoch_Set)
    Epoch_Set_Index=1;
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
else
    Epoch_Set_Index=0;
end
Epoch_Update(hObject,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');

% --- Executes during object creation, after setting all properties.
function Choose_Subset_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Choose_Subset_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Close_Push_Callback(hObject,eventdata,handles)
figure1_CloseRequestFcn(handles.figure1,eventdata,handles);

function Change_Epoch_State_Callback(hObject, handles, state)
global Stages External_Stage_Change_Flag Current_Epoch_Num;
global Epoch_Dur Sampling_Rate_EEG Time_EEG EEG EMG;
global Sampling_Rate_EMG Time_EMG;
global Current_Epoch_Set Epoch_Set_Index Choose_Subset_Val;
global Area_Epochs Fixed_Points;

External_Stage_Change_Flag = 1;
Stages(Current_Epoch_Num) = state;
Fixed_Points(Current_Epoch_Num) = 1;
spe1 = Sampling_Rate_EMG*Epoch_Dur;
spe2 = Sampling_Rate_EEG*Epoch_Dur;

set(handles.EMG_Axes,'NextPlot','add');
set(handles.EEG_Axes,'NextPlot','add');
i = Current_Epoch_Num;
switch Stages(i)
    case 1
        plot_color = [1 0 0];
    case 2
        plot_color = [0 0 1];
    case 3
        plot_color = [0 1 0];
    case 4
        plot_color = [180 51 180]/256;
    case 5
        plot_color = [0.1 0.6 0.88];
    case 6
        plot_color = [0.23 0.44 0.34];
    case 0
        plot_color = [0 0 0];
    case 7
        plot_color = [255 131 47]/256;
end

h = plot(handles.EMG_Axes,Time_EMG(spe1*(i-1)+1:spe1*i),EMG(spe1*(i-1)+1:spe1*i));
set(h,'Color',plot_color);
h = plot(handles.EEG_Axes,Time_EEG(spe2*(i-1)+1:spe2*i),EEG(spe2*(i-1)+1:spe2*i));
set(h,'Color',plot_color);
set(handles.EMG_Axes,'NextPlot','replace');
set(handles.EEG_Axes,'NextPlot','replace');

if Epoch_Set_Index ~= 0 && ~isempty(Current_Epoch_Set)
    if Epoch_Set_Index>=length(Current_Epoch_Set)
        Epoch_Set_Index = length(Current_Epoch_Set);
        
    else
        Epoch_Set_Index = Epoch_Set_Index+1;
    end
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);    
else
    Current_Epoch_Num = Current_Epoch_Num+1;
end

switch Choose_Subset_Val
    case 1
        Current_Epoch_Set = 1:length(Stages);
    case 2
        Current_Epoch_Set = find(Stages==1);
    case 3
        Current_Epoch_Set = find(Stages==3);
    case 4
        Current_Epoch_Set = find(Stages==2);
    case 5
        Current_Epoch_Set = find(Stages>3 | Stages==0);
    case 6
        Current_Epoch_Set = find(Stages==0);
    case 7 
        Current_Epoch_Set = Area_Epochs;
end
if ~isempty(Current_Epoch_Set)
    if any(Current_Epoch_Set==Current_Epoch_Num)
        Epoch_Set_Index = find(Current_Epoch_Set==Current_Epoch_Num);
    end
else
    Epoch_Set_Index=0;
end

Epoch_Update(hObject,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');
guidata(hObject,handles);


% --- Executes on button press in Wake_Push.
function Wake_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,1);


% --- Executes on button press in NREM_Push.
function NREM_Push_Callback(hObject, eventdata, handles)
% hObject    handle to NREM_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,2);


% --- Executes on button press in REM_Push.
function REM_Push_Callback(hObject, eventdata, handles)
% hObject    handle to REM_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,3);


% --- Executes on button press in Wake_Artifact_Push.
function Wake_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,4);


% --- Executes on button press in NREM_Artifact_Push.
function NREM_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to NREM_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,5);


% --- Executes on button press in REM_Artifact_Push.
function REM_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to REM_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,6);


% --- Executes on button press in Artifact_Push.
function Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Change_Epoch_State_Callback(hObject, handles,7);

%updates the double axis plot on the main GUI when Current_Epoch is changed
function Update_Double_Axis1(hObject,handles)
global EEG_By_Epoch EMG_By_Epoch Current_Epoch_Num;
global EEG_Spectrum;
global Epoch_Dur;
global Stages Freq_Step;
global Para1_Pop Para2_Pop;
global Para1_XLim Para2_YLim;
global Disp_Start_Freq Disp_End_Freq;
global Epoch_Set_Index Current_Epoch_Set;

if ~isempty(Current_Epoch_Set)
    if Current_Epoch_Num ~= Current_Epoch_Set(Epoch_Set_Index) ...
            && any(Current_Epoch_Set==Current_Epoch_Num)
        Epoch_Set_Index = find(Current_Epoch_Set == Current_Epoch_Num);
    end
else
    Epoch_Set_Index=0;
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

EEG_to_plot = EEG_By_Epoch(:, Current_Epoch_Num);
EMG_to_plot = EMG_By_Epoch(:, Current_Epoch_Num);

time_start = (Current_Epoch_Num - 1) * Epoch_Dur;
time_end = Current_Epoch_Num * Epoch_Dur;

set(handles.Epoch_Num_Edit,'String',num2str(Current_Epoch_Num));

stage = Stages(Current_Epoch_Num);

if stage == 1
    plot_color2 = [1 0 0];
elseif stage == 2
    plot_color2 = [0 0 1];
elseif stage == 3
    plot_color2 = [0 1 0];
elseif stage == 4
    plot_color2 = [180 51 180]/256;
elseif stage == 5
    plot_color2 = [0.1 0.6 0.88];
elseif stage == 6
    plot_color2 = [0.23 0.44 0.34];
elseif stage == 0
    plot_color2 = [0 0 0];
elseif stage == 7
    plot_color2 = [255 131 47]/256;
end

set(handles.Current_EEG_Plot,'YData',EEG_to_plot,'Color',plot_color2);
set(handles.EEG_Axis, 'XTickLabel', time_start:2:time_end);


set(handles.Current_EMG_Plot,'YData',EMG_to_plot,'Color',plot_color2);
set(handles.EMG_Axis, 'XTickLabel', time_start:2:time_end);



if get(handles.Spectrum_Checkbox,'Value') == 1
    
    Start_Index = floor(Disp_Start_Freq/Freq_Step + 1);
    End_Index = ceil(Disp_End_Freq/Freq_Step + 1);
    
    EEG_spectrum_to_plot = EEG_Spectrum(Start_Index:End_Index,Current_Epoch_Num);
    
    set(handles.Current_Spectrum_Plot,'YData',EEG_spectrum_to_plot,'Color',plot_color2);
    
    clear Start_Index End_Index EEG_spectrum_to_plot;
end


x_lim = get(handles.Double_Plot_Axis,'XLim');
y_lim = get(handles.Double_Plot_Axis,'YLim');


if Para1_Pop(Current_Epoch_Num) >= x_lim(2)
    new_xlim(1) = x_lim(1);
    new_xlim(2) = Para1_Pop(Current_Epoch_Num)/0.9;
    if new_xlim(2) > Para1_XLim(2)
        new_xlim(2) = Para1_XLim(2);
    end
    set(handles.Double_Plot_Axis,'XLimMode','Manual','XLim',new_xlim,'XTickMode','Auto');
    x_tick = get(handles.Double_Plot_Axis,'XTick');
    x_ticklabel = get(handles.Double_Plot_Axis,'XTickLabel');
    
    set(handles.Histogram_Axis1,'XLimMode','Manual','XLim',new_xlim,'XTickMode','Manual','XTick',x_tick,'XTickLabel',x_ticklabel);
    h_value = (new_xlim(2) - Para1_XLim(1))/(Para1_XLim(2)-Para1_XLim(1));
    set(handles.Para1_Slider,'Value',h_value);
    
    clear new_xlim x_tick x_ticklabel h_value;
end

if Para2_Pop(Current_Epoch_Num) >= y_lim(2)
    new_ylim(1) = y_lim(1);
    new_ylim(2) = Para2_Pop(Current_Epoch_Num)/0.9;
    if new_ylim(2) > Para2_YLim(2)
        new_ylim(2) = Para2_YLim(2);
    end
    set(handles.Double_Plot_Axis,'YLimMode','Manual','YLim',new_ylim,'YTickMode','Auto');
    y_tick = get(handles.Double_Plot_Axis,'YTick');
    y_ticklabel = get(handles.Double_Plot_Axis,'YTickLabel');
    
    set(handles.Histogram_Axis2,'YLimMode','Manual','YLim',new_ylim,'YTickMode','Manual','YTick',y_tick,'YTickLabel',y_ticklabel);
    h_value = (new_ylim(2) - Para2_YLim(1))/(Para2_YLim(2)-Para2_YLim(1));
    set(handles.Para2_Slider,'Value',h_value);
    
    clear new_ylim y_tick y_ticklabel h_value;
    
end

hobj = findobj(handles.Double_Plot_Axis,'Marker','*');
set(hobj,'XData',Para1_Pop(Current_Epoch_Num),'YData',Para2_Pop(Current_Epoch_Num),'Color',plot_color2);
guidata(handles.Double_Plot_Axis, handles);

clear EEG_to_plot EMG_to_plot time_start time_end;
clear stage plot_color2;
clear x_lim y_lim hobj;


% --- Executes on button press in Single_Epoch_Check.
function Single_Epoch_Check_Callback(hObject, eventdata, handles)
% hObject    handle to Single_Epoch_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Single_Epoch_Check
global Single_Epoch_Flag;
Single_Epoch_Flag = get(hObject,'Value');
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');
Epoch_Update(hObject,handles);


% --- Executes on slider movement.
function EEG_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ylim = get(handles.EEG_Axes,'YLim');
val = get(hObject,'Value');
ylim = (1.5-val)*ylim;
set(handles.EEG_Axes,'YLim',ylim);
set(hObject,'Value',.5);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function EEG_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EEG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function EMG_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ylim = get(handles.EMG_Axes,'YLim');
val = get(hObject,'Value');
ylim = (1.5-val)*ylim;
set(handles.EMG_Axes,'YLim',ylim);
set(hObject,'Value',.5);
guidata(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function EMG_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
