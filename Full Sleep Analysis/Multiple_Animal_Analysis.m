function varargout = Multiple_Animal_Analysis(varargin)
% GUIDETEMPLATE0 MATLAB code for guidetemplate0.fig
%      GUIDETEMPLATE0, by itself, creates a new GUIDETEMPLATE0 or raises the existing
%      singleton*.
%
%      H = GUIDETEMPLATE0 returns the handle to a new GUIDETEMPLATE0 or the handle to
%      the existing singleton*.
%
%      GUIDETEMPLATE0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDETEMPLATE0.M with the given input arguments.
%
%      GUIDETEMPLATE0('Property','Value',...) creates a new GUIDETEMPLATE0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guidetemplate0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guidetemplate0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2006 The MathWorks, Inc.

% Edit the above text to modify the response to help guidetemplate0

% Last Modified by GUIDE v2.5 03-Nov-2014 11:29:21
% Written by Roshan Nanu, Jan 2015

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guidetemplate0_OpeningFcn, ...
    'gui_OutputFcn',  @guidetemplate0_OutputFcn, ...
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


% --- Executes just before guidetemplate0 is made visible.
function guidetemplate0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guidetemplate0 (see VARARGIN)

% Choose default command line output for guidetemplate0
handles.output = hObject;
set(handles.Epoch_Dur_Pop,'String',num2cell(1:300),'Value',10);
set(handles.Min_Len_Pop,'String',num2cell(1:10),'Value',5);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guidetemplate0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guidetemplate0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Create_File_Push.
function Create_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Create_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = fieldnames(handles);
b = cellfun(@(x) (~isempty(strfind(x,'Pop')) | ~isempty(strfind(x,'Push'))),a);
c = arrayfun(@(x) getfield(handles,a{x}),find(b),'UniformOutput',false);
c = c(cellfun(@(x) strcmp(get(x,'Enable'),'on'),c));
cellfun(@(x) set(x,'Enable','off'),c);

if isfield(getappdata(handles.output),'FitStr')
    rmappdata(handles.output,'FitStr');
end

wbar = waitbar(0,'Creating Outputs...');
Create_Outputs(handles,wbar);

waitbar(.9,wbar,'Saving Outputs...');
cellfun(@(x) set(x,'Enable','on'),c);
set(handles.Fit_SWA_Push,'Enable','on');
Save_Sheets(handles);
waitbar(1,wbar,'Done!');
close(wbar);
drawnow;
h = msgbox('Done');
waitfor(h);
makeFigures(handles);

% --- Executes on button press in Fit_SWA_Push.
function Fit_SWA_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_SWA_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LnNormD = getappdata(handles.output,'lnNormDelta');
time = getappdata(handles.output,'fitTime');
time(end+1) = time(end)+time(2);
time = time(2:end);
NormDelta = exp(LnNormD);

t1 = 3.5;
t2 = time(fix(end-end/4));
lim_pop = Set_Lim_Popup(t1,t2,time,NormDelta);
waitfor(lim_pop,'Visible','off');
t1 = getappdata(lim_pop,'Limit1');
t2 = getappdata(lim_pop,'Limit2');
delete(lim_pop);
fragStart = find(time>=t1,1,'first');
fragStop = find(time<=t2,1,'last');

y1 = NormDelta(fragStart:fragStop);

%deinfe x1 as time in minutes with start of fragment at t=1/6
x1 = (time(1):time(1):numel(y1)*time(1))';

%fit fragment to y= (y0-plt)*e^(-K*x) + plt to get y0, plt, and K
F = @(c,x)(c(3)-c(1))*exp(-x*c(2)) + c(1);
opts = optimset('Display','off');
c = lsqcurvefit(F,[min(y1) 1 y1(1)],x1,y1,[],[],opts);

%then we put the fragment back into the time frame of the full dataset and
%refit holding K constant to get the plateau and y0
x2 = time(fragStart:fragStop);
y2 = y1(2:end);
x2 = x2(2:end);
F2 = @(k,x)(k(2)-k(1))*exp(-x*c(2)) + k(1);
k = lsqcurvefit(F2,[min(y1) c(3)],x2,y2,[],[],opts);



%transform y2 -> y3 according to y3 = (y2-k(1))/(k(2)-k(1))
%this normalizes the fragment to have a span on 1
y3 = (y2-k(1))/(k(2)-k(1));


%now fit y3 to y3 = exp(-K*x) to get K for a normalized fit
%tau = 1/K with units of minutes
F3 = @(l,x)exp(-l(1)*x);
[l,resnorm] = lsqcurvefit(F3,c(2),x2,y3,[],[],opts);
tau = 1/l;
Rsquared = 1 - resnorm/norm(y3-mean(y3))^2;

%Plot resutls

h = figure;
normSWA = (NormDelta-k(1))/(k(2)-k(1));
plot(time,normSWA,'r.');
hold on
Yfit = exp(-time/tau);
plot(x2,y3,'b.')
plot(time, Yfit,'r-')
legend('Normalized Average SWS episode','Fitted Fragment','Fit','Location','NorthEast')
hold off
title({'SWS Normalized Delta Decay Fit',sprintf('Tau = %0.2f Minutes',tau)});
xlabel('Time (Sec)');
ylabel('Normalized SWA Power');
ylim([min(normSWA) 1]);

%save and display results
Yint = k(2);
plt = k(1);
Kval = 1/tau;
timeStart = time(fragStart);
timeStop = time(fragStop);

output = cell(8,2);
output(:,1) = {'Fit of SWA Decay of SWS episodes';'Fragment Start Time (min)';'Fragment Stop Time (min)';'Tau (min)';'K-Value (1/min)';'Plateau';'Y_0';'R-Squared'};
output(2:end,2) = num2cell([timeStart;timeStop;tau;Kval;plt;Yint;Rsquared]);



outstr = sprintf('Fit of SWA Decay of SWS episodes\n\n\tFragment Start Time (min): %0.2f\n\tFragment Stop Time (min): %0.2f\n\tTau (min): %0.2f\n\tK-Value (1/min): %0.2f\n\tPlateau: %0.2f\n\tY_0: %0.2f\n\tR-Squared: %0.2f',...
    timeStart,timeStop,tau,Kval,plt,Yint,Rsquared);

q = 'Yes';
if ~isfield(getappdata(handles.output),'FitStr')
    msgbox({outstr,'','These fit results have been saved to your SWA decay File.',...
        'If you are not satified with this fit you can click the fit button again.',...
        'Also please take a moment to save the produced figure associated with the fit.'});
else
    prevFit = getappdata(handles.output,'FitStr');
    newOutStr = ['Previous Fit: ' char(10) prevFit char(10) char(10) 'New Fit: ' char(10) outstr char(10) char(10) 'Should the old fit be replaced?'];
    
    q = questdlg(newOutStr,'Keep New Fit?','Yes','No',{'Yes'});
end

if strcmp(q,'Yes')
    if ispc
        status = xlswrite(getappdata(handles.output,'outFile'),output,'SWS Decay Fit');
    else
        outFile = getappdata(handles.output,'outFile');
        status = writeCell2Txt([outFile(1:end-5) ' SWA Decay Fit.txt'],output,1);
    end
    if ~status
        errordlg('Writing fit to excel file failed.')
    end
    setappdata(handles.output,'FitStr',outstr);
end


% --- Executes on button press in Change_File_Push.
function Change_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Change_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.File_Listbox,'Value');
fn = getappdata(handles.output,'Files');
p = getappdata(handles.output,'Paths');
IDs = getappdata(handles.output,'AnimalIDs');

[fn{i},p{i}] = uigetfile([pwd filesep '*.xlsx'],'Select new input file');
if fn{i}==0
    return;
end
setappdata(handles.output,'Files',fn);
setappdata(handles.output,'Paths',p);
set(handles.File_Listbox,'String',fn);

ID = str2double(inputdlg('Animal ID #:','Animal ID Input'));

IDs{i} = ID;
set(handles.ID_Listbox,'String',IDs);
setappdata(handles.output,'AnimalIDs',IDs);


if get(handles.Type_Pop,'Value')==1
    gamma = str2double(inputdlg('Average Baseline Gamma Power:','Baseline Gamma Input'));
    if isnan(gamma)
        gamma = 1;
    end
    gammas = getappdata(handles.output,'AvgGamma');
    gammas{i} = gamma;
    setappdata(handles.output,'AvgGamma',gammas);
    set(handles.Gamma_Listbox,'String',gammas);
end
Check_Fields(handles);

% --- Executes on button press in Change_ID_Push.
function Change_ID_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Change_ID_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.ID_Listbox,'Value');
IDs = getappdata(handles.output,'AnimalIDs');

ID = inputdlg('Animal ID #:','Animal ID Input');
if ~strcmp(ID,'')
    IDs(i) = ID;
    set(handles.ID_Listbox,'String',IDs);
    setappdata(handles.output,'AnimalIDs',IDs);
end
Check_Fields(handles);


% --- Executes on selection change in File_Listbox.
function File_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to File_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns File_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from File_Listbox
val = get(hObject,'Value');
set(handles.ID_Listbox,'Value',val);
set(handles.Gamma_Listbox,'Value',val);


% --- Executes during object creation, after setting all properties.
function File_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to File_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ID_Listbox.
function ID_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ID_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ID_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ID_Listbox
val = get(hObject,'Value');
set(handles.Gamma_Listbox,'Value',val);
set(handles.File_Listbox,'Value',val);


% --- Executes during object creation, after setting all properties.
function ID_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ID_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Gamma_Listbox.
function Gamma_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Gamma_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Gamma_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Gamma_Listbox
val = get(hObject,'Value');
set(handles.ID_Listbox,'Value',val);
set(handles.File_Listbox,'Value',val);


% --- Executes during object creation, after setting all properties.
function Gamma_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gamma_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Change_Gamma_Push.
function Change_Gamma_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Change_Gamma_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.Gamma_Listbox,'Value');
gamma = str2double(inputdlg('Average Baseline Gamma Power:','Baseline Gamma Input'));
if isnan(gamma)
    gamma = 1;
end
gammas = getappdata(handles.output,'AvgGamma');
gammas(i) = gamma;
setappdata(handles.output,'AvgGamma',gammas);
set(handles.Gamma_Listbox,'String',gammas);
Check_Fields(handles);


% --- Executes during object creation, after setting all properties.
function Num_Files_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Num_Files_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Epoch_Dur_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Epoch_Dur_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Type_Pop.
function Type_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Type_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Type_Pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Type_Pop
if get(hObject,'Value')==1
    if isfield(getappdata(handles.output),'Files')
        msgbox('Please input Baseline Gamma Power manually using the Change Gamma button.');
    end
end
Check_Gammas(handles);
Check_Fields(handles);


% --- Executes during object creation, after setting all properties.
function Type_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Choose_Files_Push.
function Choose_Files_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_Files_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = get(handles.Num_Files_Pop,'Value');
[fn{1},p{1}] = uigetfile([pwd filesep '*.xlsx'],['Choose File # ' num2str(1)]);
if p{1} ==0,
    return;
end
for i=2:N,
    [fn{i},p{i}] = uigetfile([p{1} '*.xlsx'],['Choose File # ' num2str(i)]);
    if p{i}==0,
        return;
    end
end

set(handles.File_Listbox,'String',fn);
set(handles.Change_File_Push,'Enable','on');
setappdata(handles.output,'Files',fn);
setappdata(handles.output,'Paths',p);

IDprompt = cellfun(@(x) ['ID# for ' x ':'],fn,'UniformOutput',0);
IDs = inputdlg(IDprompt,'Animal ID input');
IDs(cellfun(@(x) strcmp(x,''),IDs)) = {NaN};
setappdata(handles.output,'AnimalIDs',IDs);
set(handles.ID_Listbox,'String',IDs);
set(handles.Change_ID_Push,'Enable','on');

if get(handles.Type_Pop,'Value')==1
    Gprompt = cellfun(@(x) ['Avg Gamma for ' x ':'],IDs,'UniformOutput',0);
    Gammas = str2double(inputdlg(Gprompt,'Avg Gamma Input'));
    if any(isnan(Gammas))
        msgbox('Please use the Change Gamma button to assign an average baseline gamma to the unassigned files.');
    end
    setappdata(handles.output,'AvgGamma',Gammas);
    set(handles.Gamma_Listbox,'String',num2cell(Gammas));
    set(handles.Change_Gamma_Push,'Enable','on');
else
    if isfield(getappdata(handles.output),'AvgGamma')
        rmappdata(handles.output,'AvgGamma');
    end
    Gammas = repmat('Auto',N,1);
    set(handles.Gamma_Listbox,'String',cellstr(Gammas));
    
end

Check_Fields(handles);

%Checks to see if gamma values are set correctly
function Check_Gammas(handles)
if isfield(getappdata(handles.output),'Files')
    if get(handles.Type_Pop,'Value') == 1 && ~isfield(getappdata(handles.output),'AvgGamma')
        mGamma = NaN(numel(getappdata(handles.output,'Files')),1);
        set(handles.Change_Gamma_Push,'Enable','on')
        set(handles.Gamma_Listbox,'String',num2cell(mGamma));
        setappdata(handles.output,'AvgGamma',mGamma);
    else
        mGamma = cellstr(repmat('Auto',numel(getappdata(handles.output,'Files')),1));
        set(handles.Change_Gamma_Push,'Enable','off');
        set(handles.Gamma_Listbox,'String',mGamma);
        if isfield(getappdata(handles.output),'AvgGamma')
            rmappdata(handles.output,'AvgGamma');
        end
    end
end

%Checks to see if enough fields are filled to allow for output file
%creation
function Check_Fields(handles)
h = handles.output;
flag =1;
if ~isfield(getappdata(h),'Files')
    flag=0;
end
if numel(getappdata(h,'Files'))~=get(handles.Num_Files_Pop,'Value')
    flag =0;
end
if get(handles.Type_Pop,'Value')==1
    if any(isnan(getappdata(h,'AvgGamma')))
        flag = 0;
    end
end
if isfield(getappdata(h),'AnimalIDs')
    if any(cellfun(@(x) any(isnan(x)),getappdata(h,'AnimalIDs')))
        flag = 0;
    end
else
    flag = 0;
end


if flag
    set(handles.Create_File_Push,'Enable','on');
else
    set(handles.Create_File_Push,'Enable','off');
    set(handles.Fit_SWA_Push,'Enable','off');
end


% --- Executes on selection change in Num_Files_Pop.
function Num_Files_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Num_Files_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Num_Files_Pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Num_Files_Pop
if isfield(getappdata(handles.output),'Files')
    if get(hObject,'Value') ~= numel(getappdata(handles.output,'Files'))
        msgbox('The number you have selected does not match the current file list. Please use the Choose Files button to re-select files.');
        set(handles.Change_File_Push,'Enable','off');
        set(handles.Change_ID_Push,'Enable','off');
        set(handles.Change_Gamma_Push,'Enable','off');
    else
        set(handles.Change_File_Push,'Enable','on');
        set(handles.Change_ID_Push,'Enable','on');
        set(handles.Change_Gamma_Push,'Enable','on');
    end
end
Check_Fields(handles);


function Create_Outputs(handles,wbar)
h = handles.output;
fn = getappdata(h,'Files');
p = getappdata(h,'Paths');
ids = getappdata(h,'AnimalIDs');
EpochDur = get(handles.Epoch_Dur_Pop,'Value');
N = numel(fn);
minLen = get(handles.Min_Len_Pop,'Value')*60/EpochDur;


data = cell(N,1);
epLens = cell(N,1);
headers = cell(N,1);
StateCol = cell(N,1);
StateRow = cell(N,1);
LenCol = cell(N,1);
EpisodeArr = cell(N,1);
maxDur = zeros(N,1);
maxSize = zeros(N,1);
maxTime = 0;
width=0;
flag = (get(handles.Type_Pop,'Value')==1);
if flag
    avgGamma = getappdata(h,'AvgGamma');
else
    avgGamma = NaN(N,1);
end

outputB = cell(N,1);
%read data
for i=1:N,
    waitbar(.6*i/N,wbar,['Loading Data File #' num2str(i) '...'])
    [data{i},headers{i}] = xlsread([p{i} fn{i}],2);
    if ~flag
        normSWA = xlsread([p{i} fn{i}],4);
        avgGamma(i) = normSWA(1,12);
    end
    header = headers{i};
    idx = cellfun(@(x) ~isempty(strfind(x,'Begin NREM')),header(:,6));
    StateCol{i} = header(idx,6);
    LenCol{i} = data{i}(find(idx)-1,7);
    maxDur(i) = max(LenCol{i});
    maxSize(i) = size(LenCol{i},1);
    epLens{i} = data{i}(1,10:end);
    
    epArr = NaN(maxDur(i)+2,sum(LenCol{i}>=minLen)+1);
    idx1 = cellfun(@(x) ~isempty(strfind(x,'NREM')),header(1,:));
    idx2 = data{i}(1,:)>=minLen;
    idx = idx1 & idx2;
    StateRow{i} = header(1,idx);
    [row2,sortOrd] = sort(data{i}(1,idx),'ascend');
    row3 = data{i}(2,idx);
    row3 = row3(sortOrd);
    deltas = data{i}(3:maxDur(i)+2,idx);
    deltas = deltas(:,sortOrd);
    time = EpochDur/60:EpochDur/60:max(row2)*EpochDur/60;
    if numel(time)>numel(maxTime)
        maxTime = time';
    end
    epArr(1,2:end) = row2;
    epArr(2,2:end) = row3;
    epArr(3:end,2:end) = deltas;
    epArr(3:end,1) = time';
    
    EpisodeArr{i} = epArr;
    
    out = cell(numel(time)+3,sum(idx)+1);
    out(1,1) = ids(i);
    out(1,2:end) = StateRow{i};
    out(2:end,:) = num2cell(epArr);
    
    
    for j=1:numel(out),
        if isnan(out{j})
            out(j) = {[]};
        end
    end
    
    outputB{i} = out;
    
    width = width + size(out,2);
end
waitbar(.6,wbar,'Creating Cumulative SWS sheet...')
outputA = makeCumulativeSWS(StateCol,LenCol,maxDur,maxSize,N,ids);
waitbar(.75,wbar,'Create Ln Norm SWA Sheet...');

maxTime(2:end) = maxTime(1:end-1);
maxTime(1) = 0;
outputC = cell(numel(maxTime)+1,width+5+2*N);
outputC(2:end,1) = num2cell(maxTime);
outputC(1,1) = {'Time (min)'};
startCol = 1;

for i=1:N,
    out = outputB{i}(4:end,2:end);
    dataOut = NaN(size(out,1),size(out,2));
    for j=1:numel(out),
        if ~isempty(out{j}),
            dataOut(j) = log(out{j}/avgGamma(i));
        end
    end
    lastRow = 1;
    for j=1:size(dataOut,1),
        if sum(~isnan(dataOut(j,:)))>=5,
            lastRow = j;
        end
    end
    avg = zeros(lastRow,1);
    for j=1:lastRow,
        avg(j) = mean(dataOut(j,~isnan(dataOut(j,:))));
    end
    outputC(1,startCol+1) = ids(i);
    outputC(2:size(dataOut,1)+1,startCol+1:size(dataOut,2)+startCol) = num2cell(dataOut);
    outputC(1,startCol+size(dataOut,2)+1) = {'Avg'};
    outputC(2:size(avg,1)+1,startCol+size(dataOut,2)+1) = num2cell(avg);
    startCol = startCol+size(dataOut,2)+2;
    Avgs{i} = avg;
end
startCol = startCol+3;
outputC(2:end,startCol) = num2cell(maxTime);
outputC(1,startCol) = {'Time (min)'};
avgL = min(cellfun(@(x) size(x,1),Avgs));
AvgArr = [];
for i=1:N,
    AvgArr = [AvgArr Avgs{i}(1:avgL)];
    outputC(1,startCol+i) = ids(i);
    outputC(2:size(Avgs{i},1)+1,startCol+i) = num2cell(Avgs{i});
end
startCol = startCol+N+1 ;
outputC(1,startCol) = {'Group Avg'};
outputC(2:avgL+1,startCol) = num2cell(mean(AvgArr,2));
for i=1:numel(outputC),
    if isnan(outputC{j})
        outputC(j) = {[]};
    end
end
setappdata(handles.output,'fitTime',maxTime(1:avgL));
setappdata(handles.output,'lnNormDelta',mean(AvgArr,2));
setappdata(handles.output,'outputA',outputA);
setappdata(handles.output,'outputB',outputB);
setappdata(handles.output,'outputC',outputC);
setappdata(handles.output,'EpLens',epLens);
waitbar(.9,wbar,'Saving Outputs')


function [output] = makeCumulativeSWS(State,Len,maxDur,maxSize,N,ids)
%all calculations
bins = 8:4:max(maxDur)+4;
freqs = cell(N,1);
sumP = cell(N,1);
cumulP = cell(N,1);
for i=1:N,
    freq = zeros(numel(bins),1);
    lens = Len{i};
    lastBin = 0;
    for j=1:numel(bins),
        freq(j) = sum(lens<=bins(j) & lens>lastBin);
        lastBin = bins(j);
    end
    freqs{i} = freq;
    sumP{i} = freq./sum(freq) * 100;
    cumulP{i} = cumsum(sumP{i});
end

%create output
output = cell(max(maxSize),9*N+10);

for i=1:N,
    freq = freqs{i};
    pSum = sumP{i};
    cumP = cumulP{i};
    lens = Len{i};
    states = State{i};
    mouseID = ids{i};
    
    output(2:numel(states)+1,3*i-2)= states;
    output(1,3*i-2) = {mouseID};
    output(2:numel(lens)+1,3*i-1) = num2cell(lens);
    
    
    output(2:numel(lens)+1,3*N+2+i) = num2cell(lens);
    output(1,3*N+2+i) = {mouseID};
    output(2:numel(bins)+1,3*N+2) = num2cell(bins);
    
    
    output(3:numel(bins)+2,4*N+3+2*i) = num2cell(bins);
    output(3:numel(freq)+2,4*N+4+2*i) = num2cell(freq);
    output(1,4*N+4+2*i) = {mouseID};
    output(2,4*N+3+2*i) = {'Bin'};
    output(2,4*N+4+2*i) = {'Frequency'};
    
    output(3:numel(freq)+3,6*N+6+i) = num2cell([freq;sum(freq)]);
    output(1,6*N+6+i) = {mouseID};
    output(2,6*N+6+i) = {'Frequency'};
    
    output(3:numel(pSum)+2,7*N+8+i) = num2cell(pSum);
    output(1,7*N+8+i) = {mouseID};
    output(2,7*N+8+i) = {'% of sum'};
    
    output(3:numel(cumP)+2,8*N+10+i) = num2cell(cumP);
    output(1,8*N+10+i) = {mouseID};
    output(2,8*N+10+i) = {'cumul'};
end

output(numel(freq)+3,6*N+6) = {'Sum'};

function Save_Sheets(handles)
h = handles.output;
s1 = getappdata(h,'outputA');
s2 = getappdata(h,'outputB');
s3 = getappdata(h,'outputC');
ids = getappdata(h,'AnimalIDs');

[fn,p] = uiputfile([pwd filesep '*.xlsx'],'Choose output file');

if fn==0
    return;
end

setappdata(h,'outFile',[p fn]);

if ispc
    status = xlswrite([p fn],s1,1);
else
    for j=1:numel(s1),
        if isnan(s1{j})
            s1(j) = {[]};
        end
    end
    status = writeCell2Txt([p fn(1:end-5) ' Cumulative SWS Distribution.txt'],s1,0);
end
if ~status
    errordlg('xls write failed.');
    return;
end

for i=1:numel(s2),
    if ispc
        status = xlswrite([p fn],s2{i},i+1);
    else
        s = s2{i};
        for j=1:numel(s),
        if isnan(s{j})
            s(j) = {[]};
        end
    end
        status = writeCell2Txt([p fn(1:end-5) ' SWA for animal ' ids{i} '.txt'],s,0);
    end
    if ~status
        errordlg('xls write failed.');
        return;
    end
end
if ispc
    status = xlswrite([p fn],s3,'Ln Norm SWA');
else
    for j=1:numel(s3),
        if isnan(s3{j})
            s3(j) = {[]};
        end
    end
    status = writeCell2Txt([p fn(1:end-5) ' Ln Norm SWA.txt'],s3,0);
end
if ~status
    errordlg('xls write failed.');
    return;
end


% --- Executes during object creation, after setting all properties.
function Min_Len_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min_Len_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Help_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Help_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text = fileread('Multiple Animal Sleep Analysis Help.txt');
Text_Display(0,'Sleep Analysis Help',text);

function makeFigures(handles)
EpLens = getappdata(handles.output,'EpLens');
EpochDur = get(handles.Epoch_Dur_Pop,'Value'); 
IDs = getappdata(handles.output,'AnimalIDs');

MarkerEdgeColors=lines(numel(EpLens)); 
Markers=['o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*','o','x','^','<','h','.','>','p','s','d','v',...
'o','x','+','*','s','d','v','^','<','>','p','h','.'];

figure
hold on
for i=1:numel(EpLens),
    [vals,bins] = hist(EpLens{i}*EpochDur/60,50);
    plot(bins,cumsum(vals)*100/sum(vals),['-' Markers(i)],'Color',MarkerEdgeColors(i,:))
%     hold on
%     plot(bins,cumsum(vals)*100/sum(vals),'ko')
end
legend(IDs);
xlabel('Episode Duration (min)')
ylabel('Cumulative Percent of Episodes')
title('Cumulative Histogram of Episode Durations')