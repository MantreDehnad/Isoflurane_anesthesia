function varargout = BH_Scoring(varargin)
% BH_SCORING MATLAB code for BH_Scoring.fig
%      BH_SCORING, by itself, creates a new BH_SCORING or raises the existing
%      singleton*.
%
%      H = BH_SCORING returns the handle to a new BH_SCORING or the handle to
%      the existing singleton*.
%
%      BH_SCORING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BH_SCORING.M with the given input arguments.
%
%      BH_SCORING('Property','Value',...) creates a new BH_SCORING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BH_Scoring_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BH_Scoring_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BH_Scoring

% Last Modified by GUIDE v2.5 14-Jan-2015 10:31:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BH_Scoring_OpeningFcn, ...
    'gui_OutputFcn',  @BH_Scoring_OutputFcn, ...
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


% --- Executes just before BH_Scoring is made visible.
function BH_Scoring_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BH_Scoring (see VARARGIN)

% Choose default command line output for BH_Scoring
handles.output = hObject;
setappdata(hObject,'mouse_action',0);



setappdata(hObject,'x2',varargin{3});
setappdata(hObject,'x1',varargin{1});
setappdata(hObject,'y1',varargin{2});

if numel(varargin)>= 4
    setappdata(hObject,'y2',varargin{4});
else
    setappdata(hObject,'y2',varargin{2});
end
x1 = getappdata(hObject,'x1');
x2 = getappdata(hObject,'x2');
y1 = getappdata(hObject,'y1');
y2 = getappdata(hObject,'y2');

setappdata(hObject,'wakeXLim', [min(x2) max(x2)]);
setappdata(hObject,'wakeYLim', [min(y2) max(y2)]);
setappdata(hObject,'sleepYLim', [min(y1) max(y1)]);
setappdata(hObject,'sleepXLim', [min(x1) max(x1)]);
if numel(varargin) >= 5,
    stages = varargin{5};
else
    stages = ones(1,length(x1));
end
setappdata(hObject,'stages',stages);
xint = getNREMthresh(x1,y1);
yy = y2(x1<xint);
yint = mean(yy);
handles.plot2scatter = scatter(handles.Wake_Axes,x2,y2,4,'filled');
set(handles.Wake_Axes,'NextPlot','add');
set(handles.Sleep_Axes,'XLim',getappdata(hObject,'sleepXLim'),...
    'YLim',getappdata(hObject,'sleepYLim'));

Wake_XLim = get(handles.Wake_Axes,'XLim');
Sleep_YLim = get(handles.Sleep_Axes,'YLim');
slopeStep = max([1/10^floor(log10(Wake_XLim(2)*1000)) 1E-9]);
% set(handles.Slope_Slider,'SliderStep',[slopeStep 0.1]);
setappdata(handles.output,'slopeStep',slopeStep);

setappdata(hObject,'Slope',0);


setappdata(hObject,'Y_Intercept',yint);
setappdata(hObject,'Sleep_Thresh',xint);

axes(handles.Wake_Axes)
handles.Wake_Thresh_Bar = line(Wake_XLim,[yint 0*Wake_XLim(2)+yint],...
    'Parent',handles.Wake_Axes,'Tag','Wake_Thresh_Bar','LineWidth',3,...
    'Color',[0 0 0],'LineStyle','-','Visible','on');
set(handles.Wake_Thresh_Bar,'ButtonDownFcn','BH_Scoring(''Wake_Thresh_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');

axes(handles.Sleep_Axes)
handles.Sleep_Thresh_Bar = line([xint xint],Sleep_YLim,...
    'Parent',handles.Sleep_Axes,'Tag','Sleep_Thresh_Bar','LineWidth',3,...
    'Color',[0 0 0],'LineStyle','-','Visible','on');
set(handles.Sleep_Thresh_Bar,'ButtonDownFcn','BH_Scoring(''Sleep_Thresh_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');

Update_Sleep_Plot(handles);
Update_Wake_Plot(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BH_Scoring wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = BH_Scoring_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%Exexcutes on wake plot Y slider movement to scale plot
function Wake_Y_Scroll_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_Y_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
lim = getappdata(handles.output,'wakeYLim');
limy =[lim(1) lim(2)*val+(1-val)*lim(1)];
if limy(2)>limy(1)
    set(handles.Wake_Axes,'YLim',limy);
end
Change_Wake_Thresh(handles);

% --- Executes during object creation, after setting all properties.
function Wake_Y_Scroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wake_Y_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%Exexcutes on wake plot X slider movement to scale plot
function Wake_X_Scroll_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_X_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
lim = getappdata(handles.output,'wakeXLim');
limx = [lim(1) max([1,lim(2)*val+(1-val)*lim(1)])];
if limx(2)>limx(1)
    set(handles.Wake_Axes,'XLim',limx);
end
slopeStep = max([1/10^floor(log10(limx(2)*1000)) 1E-9]);
setappdata(handles.output,'slopeStep',slopeStep);
% set(handles.Slope_Slider,'SliderStep',[slopeStep 0.1]);
Change_Wake_Thresh(handles);

% --- Executes during object creation, after setting all properties.
function Wake_X_Scroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wake_X_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%closes figure without deleting so that info can be retrieved
function Done_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Done_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Determine_Stages(handles);
set(handles.output,'Visible','off');

%Exexcutes on sleep plot Y slider movement to scale plot
function Sleep_Y_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Sleep_Y_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
lim = getappdata(handles.output,'sleepYLim');
limy = [lim(1) lim(2)*val+(1-val)*lim(1)];
if limy(2)>limy(1)
    set(handles.Sleep_Axes,'YLim',limy);
end
set(handles.Sleep_Thresh_Bar,'YData',get(handles.Sleep_Axes,'YLim'));

% --- Executes during object creation, after setting all properties.
function Sleep_Y_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sleep_Y_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%Exexcutes on sleep plot X slider movement to scale plot
function Sleep_X_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Sleep_X_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
lim = getappdata(handles.output,'sleepXLim');
limx = [lim(1) lim(2)*val+(1-val)*lim(1)];
if limx(2) > limx(1)
    set(handles.Sleep_Axes,'XLim',limx);
end

% --- Executes during object creation, after setting all properties.
function Sleep_X_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sleep_X_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% this is called whenever the parameters for the Wake Theshold bar are
% changed and it sets the bar accordingly on the plot. This also calls to
% update the the sleep plot to reflect the new position of the wake
% threshold.
function Change_Wake_Thresh(handles)

yint = getappdata(handles.output,'Y_Intercept');
slope = getappdata(handles.output,'Slope');
wake_xlim = get(handles.Wake_Axes,'XLim');
wake_ylim = get(handles.Wake_Axes,'YLim');
set(handles.Wake_Thresh_Bar,'XData',wake_xlim,'YData',[slope*wake_xlim(1)+yint slope*wake_xlim(2)+yint]);
set(handles.Wake_Axes,'XLim',wake_xlim,'YLim',wake_ylim);

% This looks at all of the data and the threshold bars and determines the
% state of each point: wake - 1, NREM sleep - 2, and REM sleep - 3
function Determine_Stages(handles)

y2 = getappdata(handles.output,'y2');
x2 = getappdata(handles.output,'x2');
x1 = getappdata(handles.output,'x1');
sleepThresh = getappdata(handles.output, 'Sleep_Thresh');
wakeSlope = getappdata(handles.output,'Slope');
wakeInt = getappdata(handles.output,'Y_Intercept');

stages = y2*0;
for i=1:length(stages),
    if x1(i)>=sleepThresh
        stages(i)=2;
    elseif y2(i)< wakeSlope*x2(i)+wakeInt
        stages(i)=1;
    else
        stages(i)=3;
    end
end

if get(handles.Auto_Sort_Toggle,'Value')
    stages = getappdata(handles.output,'netStages');
else
    stages = contSort(stages);
end
setappdata(handles.output,'stages',stages);

% this is called when the wake threshold bar is clicked on
function Wake_Thresh_Bar_Callback(hObject,eventdata,handles)
setappdata(handles.output,'mouse_action',1);
mouse_pos = get(handles.Wake_Axes,'CurrentPoint');
setappdata(handles.output,'mouse_start',mouse_pos);

% this is called when the sleep threshold bar is clicked on
function Sleep_Thresh_Bar_Callback(hObject,eventdata,handles)
setappdata(handles.output,'mouse_action',2);
mouse_pos = get(handles.Wake_Axes,'CurrentPoint');
setappdata(handles.output,'mouse_start',mouse_pos);

% this redraws the sleep plot with colors to relfect the state of each
% point. wake - red, NREM - blue, REM - green
function Update_Sleep_Plot(handles)
Determine_Stages(handles);

if ~get(handles.Import_Sort_Toggle,'Value') || ~isfield(getappdata(handles.output),'trueStages')
    stages = getappdata(handles.output,'stages');
else
    stages = getappdata(handles.output,'trueStages');
end
y1 = getappdata(handles.output,'y1');
x1 = getappdata(handles.output,'x1');
threshX = get(handles.Sleep_Thresh_Bar,'XData');
threshY = get(handles.Sleep_Thresh_Bar,'YData');
xlim = get(handles.Sleep_Axes,'XLim');
ylim = get(handles.Sleep_Axes,'YLim');
set(handles.Sleep_Thresh_Bar,'XData',[],'YData',[]);

axes(handles.Sleep_Axes);


set(handles.Sleep_Axes,'NextPlot','Add');
hobj = findobj(handles.Sleep_Axes,'Marker','.');
delete(hobj);
for i=1:length(stages),
    if stages(i)==1
        pcolor = [1 0 0];
    elseif stages(i)==2
        pcolor = [0 0 1];
    elseif stages(i)==3
        pcolor = [0 1 0];
    else
        pcolor = [0 0 0];
    end
    if get(handles.Contour_Toggle,'Value')
        pcolor = [.8 .8 .8];
    end
    plot(x1(i),y1(i),'Marker','.','MarkerSize',6,'Color',pcolor);
end

if get(handles.Contour_Toggle,'Value')
    cHandles = getappdata(handles.Contour_Toggle,'cHandles');
    for i=1:numel(cHandles),
        uistack(cHandles,'top');
    end
end

set(handles.Sleep_Thresh_Bar,'XData',threshX,'YData',threshY);
xlabel(handles.Sleep_Axes,'EEG Power');
ylabel(handles.Sleep_Axes,'EMG Power');
uistack(handles.Sleep_Thresh_Bar,'top');
set(handles.Sleep_Axes,'XLim',xlim);
set(handles.Sleep_Axes,'YLim',ylim);



% this redraws the wake plot
function Update_Wake_Plot(handles)
Determine_Stages(handles);
sleepThresh = getappdata(handles.output,'Sleep_Thresh');
x2 = getappdata(handles.output,'x2');
y2 = getappdata(handles.output,'y2');

stages = getappdata(handles.output,'stages');

red = find(stages==1);
green = find(stages==3);
blue = find(stages==2);
xr = x2(red);
yr = y2(red);
xb = x2(blue);
yb = y2(blue);
xg = x2(green);
yg = y2(green);
setappdata(handles.output,'wakeXLim', [min(x2) max(x2)]);
setappdata(handles.output,'wakeYLim', [min(y2) max(y2)]);
axes(handles.Wake_Axes);
delete(findobj(handles.Wake_Axes,'type','patch'));
set(handles.Wake_Axes,'NextPlot','Add');
if isfield(getappdata(handles.output),'trueStages') && get(handles.Import_Sort_Toggle,'Value')
    trueStages = getappdata(handles.output,'trueStages');
    scatter(handles.Wake_Axes,x2(trueStages==2),y2(trueStages==2),4,'b','filled');
    scatter(handles.Wake_Axes,x2(trueStages==3),y2(trueStages==3),4,'g','filled');
    scatter(handles.Wake_Axes,x2(trueStages==1),y2(trueStages==1),4,'r','filled');
    scatter(handles.Wake_Axes,x2(trueStages>3),y2(trueStages>3),4,'k','filled');
else
    scatter(handles.Wake_Axes,xb,yb,4,'b','filled');
    scatter(handles.Wake_Axes,xr,yr,4,'r','filled');
    scatter(handles.Wake_Axes,xg,yg,4,'g','filled');

end
xlabel(handles.Wake_Axes,'EEG Power');
ylabel(handles.Wake_Axes,'Theta^2 / (Delta * EMG Power)');
uistack(handles.Wake_Thresh_Bar,'top');

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'output')
    mouse_action = getappdata(handles.output,'mouse_action');
else
    mouse_action=0;
end

if mouse_action==1
    h_axes = handles.Wake_Axes;
    mouse_pos = get(h_axes,'CurrentPoint');
    ylim = get(h_axes,'YLim');
    slope = getappdata(handles.output,'Slope');
    
    yint = mouse_pos(1,2)- slope*mouse_pos(1,1);
    
    if mouse_pos(1,2)<= ylim(2) && mouse_pos(1,2)>=ylim(1)
        setappdata(handles.output,'Y_Intercept',yint);
        Change_Wake_Thresh(handles);
    end
elseif mouse_action==2
    h_axes = handles.Sleep_Axes;
    h_bar = handles.Sleep_Thresh_Bar;
    mouse_pos = get(h_axes,'CurrentPoint');
    xlim = get(h_axes,'XLim');
    xint = mouse_pos(1,1);
    if xint<= xlim(2) && xint>=xlim(1)
        set(h_bar,'XData',[xint xint]);
        setappdata(handles.output,'Sleep_Thresh',xint);
    end
else
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ma = getappdata(handles.output,'mouse_action');
setappdata(handles.output,'mouse_action',0);


Update_Sleep_Plot(handles);
Update_Wake_Plot(handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
% Determine_Stages(handles);
% set(hObject,'Visible','off')

% --- Executes on button press in Import_Sort_Push.
function Import_Sort_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Import_Sort_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn, p] = uigetfile('*.xlsx');
file = [p fn];
dat = xlsread(file);
stages = dat(:,2)';
setappdata(handles.output,'trueStages',stages);
Update_Wake_Plot(handles);

% --- Executes on button press in Import_Sort_Toggle.
function Import_Sort_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Import_Sort_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Import_Sort_Toggle
if ~isfield(handles,'output')
    set(hObject,'Value',0);
    msgbox('Imported sorting could not load');
    return;
end
if get(hObject,'Value') && ~isfield(getappdata(handles.output),'trueStages')
    [fn, p] = uigetfile('*.xlsx');
    file = [p fn];
    dat = xlsread(file);
    stages = dat(:,2)';
    setappdata(handles.output,'trueStages',stages);
end
Update_Wake_Plot(handles);
Update_Sleep_Plot(handles);


% --- Executes on button press in Contour_Toggle.
function Contour_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Contour_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Contour_Toggle
global EEG_Power EMG_Power Delta_Power Theta_Power;

on = get(hObject,'Value');

if ~isfield(getappdata(hObject),'flag')
    setappdata(hObject,'flag',0);
end

flag = getappdata(hObject,'flag');
if flag && on
   q = questdlg('Do you want to redo the clustering?','Re-draw contours','Yes','No',{'No'});
   if strcmp(q,'Yes')
       flag = 0;
   end
end

x1 = getappdata(handles.output,'x1');
y1 = getappdata(handles.output,'y1');

if ~flag && on
    X = [EEG_Power',EMG_Power',Delta_Power',Theta_Power'];
    weights = inputdlg({'EEG Weight:','EMG Weight:','Delta Weight:','Theta Weight:'},'Set Weighting of Variables for Clustering',1,{'1','1','1','1'});
    weights = cellfun(@(x) str2double(x),weights);

    xLabel = 'EEG Power';
    yLabel = 'EMG Power';
    
    [wContours,nContours,rContours,Kval,Rval] = getClusterContours(X,weights,x1,y1,xLabel,yLabel,40);
    
    setappdata(hObject,'wContours',wContours)
    setappdata(hObject,'rContours',rContours)
    setappdata(hObject,'nContours',nContours)
    setappdata(hObject,'Kval',Kval)
    setappdata(hObject,'Rval',Rval)
    setappdata(hObject,'flag',1)
    
    rColors = [0 100 0;124 252 0;0 255 0]./255;
    wColors = [128 0 0;255 0 0;240 128 128]./255;
    nColors = [0 0 255;30 144 255;0 255 255]./255;
    if ~isempty(rContours)
        Colors = [rColors;wColors;nColors];
        Contours = [rContours,wContours,nContours];
    else
        Colors = [wColors;nColors];
        Contours = [wContours,nContours];
    end
    axes(handles.Sleep_Axes)
    cHandles = zeros(numel(Contours),1);
    for i=1:numel(Contours),
        Loop = Contours{i};
        cHandles(i) = plot(Loop(:,1),Loop(:,2),'Color',Colors(i,:),'LineWidth',2);
    end
    
    setappdata(hObject,'cHandles',cHandles);
    
elseif on
    
    cHandles = getappdata(hObject,'cHandles');
    for i=1:numel(cHandles),
        set(cHandles(i),'Visible','on');
    end
    
else
    
    cHandles = getappdata(hObject,'cHandles');
    for i=1:numel(cHandles),
        set(cHandles(i),'Visible','off');
    end
    
end

Update_Sleep_Plot(handles);


% --- Executes on button press in Auto_Thresh_Push.
function Auto_Thresh_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Thresh_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages;
global EMG_Power Delta_Power Theta_Power EEG_Power EMG_Variance EEG_By_Epoch;

x1 = getappdata(handles.output,'x1');
y2 = getappdata(handles.output,'y2');

net = load('NREM_Neural_Net.mat','NNet');
NNet = net.NNet;
NetType = 3;

% make NREM Neural Net Dataset
%----------------------------------
rest = selectArtifacts(EEG_Power,EMG_Power,{'EEG Power','EMG Power'});
Delta = Delta_Power(rest);
Theta = Theta_Power(rest);
EMG = EMG_Power(rest);
EEG = EEG_Power(rest);
normDelta = (Delta-min(Delta))./(max(Delta)-min(Delta));
normEMG = (EMG-min(EMG))./(max(EMG)-min(EMG));
thetaPerc = Theta./EEG;
DataSet = [normDelta' thetaPerc' normEMG'];
%----------------------------------------

[netStages,T1] = NeuralNetSort(NNet,DataSet,NetType,x1(rest));
if isrow(netStages)
	netStages=netStages';
end

tmpStages = Stages';
tmpStages(rest) = netStages;

%get REM Threshold

%load REM Neural Net
net = load('REM_Neural_Net.mat','NNet');
NNet = net.NNet;
NetType = 11;

%make Neural Net Dataset
%----------------------------
N = numel(rest);

outCols = cell(1,25);
        
outCols{1} = EMG_Power(rest);
outCols{5} = EEG_Power(rest);
outCols{9} = Delta_Power(rest);
outCols{13} = Theta_Power(rest)./EEG_Power(rest);
outCols{17} = EMG_Variance(rest);
outCols{21} = var(EEG_By_Epoch);
outCols{21} = outCols{21}(rest);
        
for i=1:4:21,
    minC = min(outCols{i});
    maxC = max(outCols{i});
    outCols{i} = (outCols{i}-minC)/(maxC-minC);
    outCols{i+1} = ones(1,N)*mean(outCols{i});
    outCols{i+2} = ones(1,N)*median(outCols{i});
	outCols{i+3} = ones(1,N)*var(outCols{i});
end

prevEpoch = tmpStages;

for i=1:numel(tmpStages),
	if i~=1
		checkVal = tmpStages(i-1);
	else
		checkVal = tmpStages(i);
	end
	
	switch checkVal
		case 1
			prevEpoch(i) = -1;
		case 2
			prevEpoch(i) = 0;
		case 3
			prevEpoch(i) = 1;
		case 4
			prevEpoch(i) = -1;
		case 5
			prevEpoch(i) = 0;
		case 6
			prevEpoch(i) = 1;
		case 0
			prevEpoch(i) = -1;
	end
end

outCols{25} = prevEpoch(rest);

netData = zeros(numel(rest),numel(outCols));

for i=1:numel(outCols),
    if isrow(outCols{i})
        outCols{i} = outCols{i}';
    end
    netData(:,i) = outCols{i};
end     
%----------------------------

[netStages,T21] =  NeuralNetREMSort(NNet,netData,tmpStages,rest,1./y2(rest));

T22 = max(1./y2(x1>T1));
stages = Stages';

stages(rest) = netStages;


stages = contSort(stages);

set(handles.Sleep_Thresh_Bar,'XData',[T1 T1]);
setappdata(handles.output,'Sleep_Thresh',T1);
set(handles.Wake_Thresh_Bar,'YData',[1/T21 1/T21]);
setappdata(handles.output,'Y_Intercept',1/T21);
setappdata(handles.output,'netStages',stages);
set(handles.Auto_Sort_Toggle,'Value',1,'Enable','on');

Update_Sleep_Plot(handles);
Update_Wake_Plot(handles);


function Auto_Sort_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Sort_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Update_Sleep_Plot(handles);
Update_Wake_Plot(handles);
