function varargout = Single_Animal_Analysis(varargin)
%SINGLE_ANIMAL_ANALYSIS M-file for Single_Animal_Analysis.fig
%      SINGLE_ANIMAL_ANALYSIS, by itself, creates a new SINGLE_ANIMAL_ANALYSIS or raises the existing
%      singleton*.
%
%      H = SINGLE_ANIMAL_ANALYSIS returns the handle to a new SINGLE_ANIMAL_ANALYSIS or the handle to
%      the existing singleton*.
%
%      SINGLE_ANIMAL_ANALYSIS('Property','Value',...) creates a new SINGLE_ANIMAL_ANALYSIS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Single_Animal_Analysis_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SINGLE_ANIMAL_ANALYSIS('CALLBACK') and SINGLE_ANIMAL_ANALYSIS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SINGLE_ANIMAL_ANALYSIS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Single_Animal_Analysis

% Last Modified by GUIDE v2.5 27-Jan-2015 11:12:18
% written by Roshan Nanu, Jan 2015

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Single_Animal_Analysis_OpeningFcn, ...
    'gui_OutputFcn',  @Single_Animal_Analysis_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before Single_Animal_Analysis is made visible.
function Single_Animal_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Single_Animal_Analysis
handles.output = hObject;

set(handles.Epoch_Dur_Pop,'String',num2cell(1:300),'Value',10);
set(handles.Ep_Start_Pop,'String',num2cell(10:10:600),'Value',3);
set(handles.Ep_Start_Pop,'String',num2cell(10:10:600),'Value',3);
set(handles.Bin_Width_Pop,'String',num2cell(.5:.5:24),'Value',4);
set(handles.Bin_Start_Pop,'String',num2cell(0:10:600),'Value',1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Single_Animal_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Single_Animal_Analysis_OutputFcn(hObject, eventdata, handles)
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
    rmappdata(handles.output,'FitStr')
end

wbar = waitbar(0,'Loading Files...');
CombineOutputs(handles,wbar);

waitbar(.5,wbar,'Creating Episode Analysis...');
makeEpisodeAnalysis(handles);

waitbar(.65,wbar,'Creating Adjusted State...');
makeAdjustedState(handles);

waitbar(.8,wbar,'Creating Norm SWA...');
if get(handles.Type_Pop,'Value')==2
    makeNormSWA_Baseline(handles);
else
    makeNormSWA_SD(handles);
end

waitbar(.95,wbar,'Saving Output...');
SaveSheets(handles);

waitbar(1,wbar,'Done!');
close(wbar)

msgbox('Done!!');
makeFigures(handles);
cellfun(@(x) set(x,'Enable','on'),c);



% --- Executes on button press in TM_File_Push.
function TM_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to TM_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,p] = uigetfile([pwd filesep '*.xlsx'],'Choose TM file:');
if fn==0
    return;
end
setappdata(handles.output,'TM_File',[p fn]);
set(handles.TM_Text,'String',fn);
set(handles.Clear_TM_Push,'Enable','on');


function Mean_Gamma_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Mean_Gamma_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mean_Gamma_Edit as text
%        str2double(get(hObject,'String')) returns contents of Mean_Gamma_Edit as a double
mGamma = str2double(get(hObject,'String'));
if isnan(mGamma) && ~strcmp(get(hObject,'String'),''),
    errordlg('Please input a valid number.');
    set(hObject,'String','');
    if isfield(getappdata(handles.output),'AvgGamma')
        rmappdata(handles.output,'AvgGamma');
    end
else
    setappdata(handles.output,'AvgGamma',mGamma);
end
Check_Fields(handles);


% --- Executes during object creation, after setting all properties.
function Mean_Gamma_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mean_Gamma_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Clear_TM_Push.
function Clear_TM_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_TM_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rmappdata(handles.output,'TM_File');
set(handles.TM_Text,'String','No File');
set(hObject,'Enable','off')


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


% --- Executes on button press in Choose_Files_Push.
function Choose_Files_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_Files_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numFiles = get(handles.Num_Files_Pop,'Value');
[f1,p1] = uigetfile([pwd filesep '*.xlsx'],...
    ['Choose up to ' num2str(numFiles) ' Autoscore Output Files']...
    ,'MultiSelect','on');
if p1==0
    return;
end
if iscell(f1)
    fn = f1;
    p(1:numel(fn)) = cellstr(repmat(p1,numel(fn),1));
else
    fn{1} = f1;
    p{1} = p1;
end
i = numel(fn)+1;
while numel(fn)<numFiles,
    [f1,p1] = uigetfile([p{1} '*.xlsx'],...
        ['Choose up to ' num2str(numFiles-numel(fn)) ' Autoscore output Files']...
        ,'MultiSelect','on');
    if p1==0,
        return;
    end
    if iscell(f1)
        if i+numel(f1)-1 > numFiles
            h = msgbox('Too many files selected');
            waitfor(h);
        else
            fn(i:i+numel(f1)-1) = f1;
            p(i:numel(fn)) = cellstr(repmat(p1,numel(f1),1))';
            i = 1+numel(fn);
        end
    else
        fn{i} = f1;
        p{i} = p1;
        i = i+1;
    end
end

set(handles.File_Listbox,'String',fn);
set(handles.Change_File_Push,'Enable','on');
setappdata(handles.output,'Files',fn);
setappdata(handles.output,'Paths',p);
Check_Fields(handles);


% --- Executes on button press in Change_File_Push.
function Change_File_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Change_File_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.File_Listbox,'Value');
fn = getappdata(handles.output,'Files');
p = getappdata(handles.output,'Paths');
[fn{i},p{i}] = uigetfile([p{1} '*.xlsx'],'Choose File:');
if p{i}==0,
    return;
end
setappdata(handles.output,'Files',fn);
setappdata(handles.output,'Paths',p);
set(handles.File_Listbox,'String',fn);
Check_Fields(handles);

% --- Executes during object creation, after setting all properties.
function EMG_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
    else
        set(handles.Change_File_Push,'Enable','on');
    end
end
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


% --- Executes on selection change in Epoch_Dur_Pop.
function Epoch_Dur_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Epoch_Dur_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Epoch_Dur_Pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Epoch_Dur_Pop
dur = get(hObject,'Value');
set(handles.Ep_Start_Pop,'String',num2cell(dur:dur:60*dur),'Value',3);
set(handles.Bin_Start_Pop,'String',num2cell(0:dur:60*dur),'Value',1);


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


% --- Executes during object creation, after setting all properties.
function Ep_Start_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ep_Start_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Bin_Width_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_Width_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Bin_Start_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bin_Start_Pop (see GCBO)
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
    set(handles.SD_Panel,'Visible','on')
    set(handles.Baseline_Panel,'Visible','off')
else
    set(handles.SD_Panel,'Visible','off')
    set(handles.Baseline_Panel,'Visible','on')
end
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


% --------------------------------------------------------------------
function Help_Menu_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Help_Menu_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text = fileread('Single Animal Sleep Analysis Help.txt');
Text_Display(0,'Sleep Analysis Help',text);


%Checks if enough fields are filled in order to create analysis files
function Check_Fields(handles)
flag = 1;
if ~isfield(getappdata(handles.output),'Files')
    flag = 0;
end
if numel(getappdata(handles.output,'Files'))~=get(handles.Num_Files_Pop,'Value')
    flag=0;
end
if get(handles.Type_Pop,'Value')==1
    if ~isfield(getappdata(handles.output),'AvgGamma')
        flag=0;
    end
end
if flag
    set(handles.Create_File_Push,'Enable','on')
else
    set(handles.Create_File_Push,'Enable','off')
end


%Creates combined output sheet
function CombineOutputs(handles,wbar)

nFiles = get(handles.Num_Files_Pop,'Value');
fn = getappdata(handles.output,'Files');
p = getappdata(handles.output,'Paths');
Delta = [];
Gamma = [];
State = [];
TotalEEG = [];

if get(handles.EMG_Pop,'Value')==2
    s = 1;
else
    s = 0;
end


for i=1:numel(fn),
    waitbar(.4*i/nFiles,wbar,['Loading File #' num2str(i) '...']);
    [dataIn{i},header{i}] = xlsread([p{i} fn{i}]);
    Delta = [Delta;dataIn{i}(:,4+s)];
    Gamma = [Gamma;dataIn{i}(:,8+s)];
    TotalEEG = [TotalEEG;dataIn{i}(:,3+s)];
    State = [State;dataIn{i}(:,2)];
end
EpochNum = (1:numel(State))';
head = header{1};
data_out(1,:) = head;
nextRowNum = 2;
for i=1:numel(fn),
    tmp = dataIn{i};
    tmp(:,1) = (nextRowNum-1):(nextRowNum+size(tmp,1)-2);
    data_out(nextRowNum:(nextRowNum+size(tmp,1)-1),:) = num2cell(tmp);
    nextRowNum = (nextRowNum+size(tmp,1));
end
a = cellfun(@(x) x>3,data_out(2:end,2));
Delta(a) = nan;
Gamma(a) = nan;
State(a)=State(a)-3;
a(end+1) = 0;
a = circshift(a,1);
data_out(a,3:end) = {[]};
%revert artifacts to parent state
data_out(a,2) = num2cell(cellfun(@(x) x-3,data_out(a,2)));

h = handles.output;
setappdata(h,'EpochNum',EpochNum)
setappdata(h,'State',State)
setappdata(h,'Delta',Delta)
setappdata(h,'Gamma',Gamma)
setappdata(h,'CombinedOutput',data_out)
setappdata(h,'TotalEEG',TotalEEG)


%creates episode analysis sheet
function makeEpisodeAnalysis(handles)
h = handles.output;
EpochDur = get(handles.Epoch_Dur_Pop,'Value');
EpochNum = getappdata(h,'EpochNum');
Delta = getappdata(h,'Delta');
State = getappdata(h,'State');
StartCrit = get(handles.Ep_Start_Pop,'Value')*EpochDur;

ret = findEpisodes(State,Delta,[],EpochDur,StartCrit);

EpState = ret(:,1);
EpStart = ret(:,2);
EpLen = ret(:,3);
Incursions = ret(:,4);
Timer = 0:EpochDur:EpochDur*(numel(EpochNum)-1);
TimeStr = datestr(Timer./86400,'HH:MM:SS');
for i=1:size(TimeStr,1),
    hh = str2double(TimeStr(i,1:2));
    hh = hh+floor(Timer(i)./86400)*24;
    if hh<10
        HH = ['0' num2str(hh)];
    else
        HH = num2str(hh);
    end
    TimeStr(i,1:2) = HH;
end

col6 = cell(numel(State),1);
col7 = col6;
row1 = cell(1,size(ret,1));
EpisodeArr = zeros(2+max(EpLen),size(ret,1));
EpisodeArr(1,:) = EpLen';
EpisodeArr(2,:) = Incursions';

for i=1:numel(EpStart),
    ss = getStateStr(EpState(i));
    row1{i} = ss;
    if i>1,
        ss2 = getStateStr(EpState(i-1));
        col6{EpStart(i)-1} = ['End ' ss2];
    end
    col6{EpStart(i)} = ['Begin ' ss];
    col7{EpStart(i)} = EpLen(i);
    epDelta = Delta(EpStart(i):EpStart(i)+EpLen(i)-1);
    EpisodeArr(3:2+EpLen(i),i) = epDelta;
    EpisodeArr(2,i) = EpisodeArr(2,i)+sum(isnan(epDelta));
end
EpisodeArr(EpisodeArr==0) = NaN;
r2 = EpisodeArr(2,:);
r2(isnan(r2)) = 0;
EpisodeArr(2,:) = r2;
outputArr = cell(numel(Delta)+1,numel(EpStart)+9);
outputArr(1,1:4) = {'Epoch #','Timer','Delta','State'};
outputArr(2:end,1) = num2cell(EpochNum);
outputArr(2:end,2) = cellstr(TimeStr);
outputArr(2:end,3) = num2cell(Delta);
outputArr(2:end,4) = num2cell(State);
outputArr(2:end,6) = col6;
outputArr(2:end,7) = col7;

outputArr(1,10:end) = row1;
outputArr(1:3,9) = {'Episode State';'Episode Length';'Incursions'};
cellEpArr = num2cell(EpisodeArr);
cellEpArr(cellfun(@(x) isnan(x),cellEpArr)) = {[]};
outputArr(2:1+size(EpisodeArr,1),10:end) = cellEpArr;
for i=1:numel(outputArr),
    if isnan(outputArr{i})
        outputArr(i) = {[]};
    end
end

setappdata(h,'EpState',EpState);
setappdata(h,'EpStart',EpStart);
setappdata(h,'EpLen',EpLen);
setappdata(h,'Incursions',Incursions);
setappdata(h,'TimeStr',TimeStr);
setappdata(h,'Timer',Timer);
setappdata(h,'EpisodeAnalysisSheet',outputArr);


%creates Adjusted State sheet
function makeAdjustedState(handles)

h= handles.output;
EpStart = getappdata(h,'EpStart');
EpLen = getappdata(h,'EpLen');
EpState = getappdata(h,'EpState');
TimeStr = getappdata(h,'TimeStr');
EpochNum = getappdata(h,'EpochNum');

EpochDur = get(handles.Epoch_Dur_Pop,'Value');
BinWidth = get(handles.Bin_Width_Pop,'Value')*(1800/EpochDur);
BinStart = get(handles.Bin_Start_Pop,'Value');
N = numel(EpochNum);

output = cell(N+1,15);
output(2:end,1) = num2cell(EpochNum);
output(2:end,2) = cellstr(TimeStr);

if get(handles.Type_Pop,'Value')==1
    if isfield(getappdata(h),'TM_File')
        TM = xlsread(getappdata(h,'TM_File'));
        I = nan(N,1);
        I(1:size(TM,1)) = TM(:,2);
    else
        I = ones(N,1);
        if BinStart>1
            I(1:BinStart-1) = NaN;
        end
        timer = getappdata(h,'Timer')/3600;
        for i=1:floor(max(timer)),
            si = find(timer>=(6*i - 2),1,'first')+(BinStart-1);
            ei = find(timer<(6*i),1,'last')+(BinStart-1);
            if ei>=length(I)
                I(si:end) = 0;
            else
                I(si:ei) = 0;
            end
        end
    end
    setappdata(h,'TMData',I);
    
    %make bins around TM data
    Bins = nan(N,1);
    for i=1:fix((N-BinStart)/BinWidth),
        Bins(BinStart+(i-1)*BinWidth:BinStart+i*BinWidth-1) = i;
    end
    Bins(BinStart+i*BinWidth:end) = i+1;
    
    Bins(isnan(I)) = NaN;
    for i=unique(Bins(~isnan(Bins)))',
        percOn = sum(I(Bins==i))/sum(Bins==i);
        
        if percOn>0 && percOn<1
            if percOn<.5
                toTrim = 1;
            else
                toTrim = 0;
            end
            %trim beginning
            if i>1
                si = find(Bins==i,1,'first');
                ti = find(I(Bins==i)==(~toTrim),1,'first')-1;
                Bins(si:si+ti-1) = i-1;
            end
            %trim end
            if i<max(unique(Bins(~isnan(Bins)))),
                si = find(Bins==i,1,'first');
                ei = find(Bins==i,1,'last');
                ti = find(I(Bins==i)==(~toTrim),1,'last')+1;
                Bins(si+ti-1:ei) = i+1;
            end
        end
    end
    
    %equalize bins
    for i=1:max(unique(Bins(~isnan(Bins))))-1,
        if I(find(Bins==i,1,'first'))==I(find(Bins==i+1,1,'first')),
            si = find(Bins==i,1,'first');
            ei = find(Bins==i+1,1,'last');
            tN = ei-si+1;
            mi = fix(tN/2);
            Bins(si:si+mi-1)=i;
            Bins(si+mi:ei)=i+1;
        end
    end
    
else
    Bins = nan(N,1);
    for i=1:fix((N-BinStart)/BinWidth),
        Bins(BinStart+(i-1)*BinWidth:BinStart+i*BinWidth-1) = i;
    end
    Bins(BinStart+i*BinWidth:end) = i+1;
end


output(2:end,3) = num2cell(Bins);
output(2:end,13) = num2cell(Bins);

col9 = NaN(N,1);
col15 = zeros(N,1);
col9(EpStart) = EpLen;
col15(EpStart)=EpLen;

EpStateCell = cell(numel(EpochNum),1);
EpStateCell(EpStart) = arrayfun(@(x) ['Begin ' getStateStr(x)],EpState,'UniformOutput',0);
EpStateCell(EpStart(2:end)-1) = arrayfun(@(x) ['End ' getStateStr(x)],EpState(1:end-1),'UniformOutput',0);

AllEpLen = col9;
AllStateCell = EpStateCell;
AdjState = zeros(N,1);

for i=1:numel(EpStart),
    AllEpLen(EpStart(i):EpStart(i)+EpLen(i)-1) = EpLen(i);
    AllStateCell(EpStart(i):EpStart(i)+EpLen(i)-1) = EpStateCell(EpStart(i));
    AdjState(EpStart(i):EpStart(i)+EpLen(i)-1) = EpState(i);
end
AllStateCell(EpStart(2:end)-1) = arrayfun(@(x) ['End ' getStateStr(x)],EpState(1:end-1),'UniformOutput',0);

output(2:end,6) = EpStateCell;
output(2:end,7) = AllStateCell;
output(2:end,9) = num2cell(col9);
output(2:end,10) = num2cell(AllEpLen);
output(2:end,14) = AllStateCell;
output(2:end,15) = num2cell(col15);

output(1,1:2) = {'Epoch #','Timer'};
output(1,[7,14]) = {'Adjusted State'};
output(1,[10,15]) = {'Episode Length'};
output(1,[3 13]) = {'Time Bin'};

for i=1:numel(output),
    if isnan(output{i})
        output(i) = {[]};
    end
end

setappdata(h,'AdjState',AdjState);
setappdata(h,'TimeBins',Bins);
setappdata(h,'AllEpLen',AllEpLen);
setappdata(h,'AdjustedStateSheet',output);


%creates Norm SWA sheet for SD data
function makeNormSWA_SD(handles)
h = handles.output;

A = getappdata(h,'EpochNum');
B = getappdata(h,'TimeStr');
C = getappdata(h,'State');
D = getappdata(h,'Delta');
E = getappdata(h,'AdjState');
F = getappdata(h,'AllEpLen');
mGamma = getappdata(h,'AvgGamma');
G = ones(numel(A),1)*mGamma;
H = NaN(numel(A),1);
H(~isnan(D)) = D(~isnan(D))/mGamma;
J = getappdata(h,'TimeBins');
I = getappdata(h,'TMData');

EpStart = getappdata(h,'EpStart');
Q = J(EpStart);
R = getappdata(h,'EpState');
S = getappdata(h,'EpLen');

n = numel(unique(J));

Ntable = zeros(n,4);
AC1 = zeros(n,4);
AC2 = zeros(n,4);
AC3 = zeros(n,5);
AC4 = zeros(n,5);

Ntable(:,1) = (1:n)';
AC1(:,1) = (1:n)';
AC2(:,1) = (1:n)';
AC3(:,1) = (1:n)';
AC4(:,1) = (1:n)';

for i=1:n,
    Ntable(i,2) = mean(H(~isnan(H) & J==i));
    Ntable(i,3) = mean(H(J==i & E==2 & ~isnan(H)));
    Ntable(i,4) = mean(H(J==i & E==1 & ~isnan(H)));
    
    AC1(i,2) = mean(S(Q==i & R==1));
    AC1(i,3) = mean(S(Q==i & R==2));
    AC1(i,4) = mean(S(Q==i & R==3));
    
    AC2(i,2) = sum(Q==i & R==1);
    AC2(i,3) = sum(Q==i & R==2);
    AC2(i,4) = sum(Q==i & R==3);
    
    AC3(i,2) = sum(J==i & E==1);
    AC3(i,3) = sum(J==i & E==2);
    AC3(i,4) = sum(J==i & E==3);
    AC3(i,5) = sum(AC3(i,2:4));
    
    AC4(i,2) = AC3(i,2)*100/AC3(i,5);
    AC4(i,3) = AC3(i,3)*100/AC3(i,5);
    AC4(i,4) = AC3(i,4)*100/AC3(i,5);
    AC4(i,5) = sum(AC4(i,2:4));
end
Ntable(isnan(Ntable)) = 0;
AC1(isnan(AC1))=0;
AC2(isnan(AC2))=0;
AC3(isnan(AC3))=0;
AC4(isnan(AC4))=0;

output = cell(size(A,1)+1,25);

output(2:end,1) = num2cell(A);
output(2:end,2) = cellstr(B);
output(2:end,3) = num2cell(C);
output(2:end,4) = num2cell(D);
output(2:end,5) = num2cell(E);
output(2:end,6) = num2cell(F);
output(2:end,7) = num2cell(G);
output(2:end,8) = num2cell(H);
output(2:end,9) = num2cell(I);
output(2:end,10) = num2cell(J);

output(3:n+2,12:15) = num2cell(Ntable);

output(2:size(Q,1)+1,17) = num2cell(Q);
output(2:size(Q,1)+1,18) = num2cell(R);
output(2:size(Q,1)+1,19) = num2cell(S);

output(3:n+2,21:24) = num2cell(AC1);
output(6+n:2*n+5,21:24) = num2cell(AC2);
output(9+2*n:3*n+8,21:25) = num2cell(AC3);
output(12+3*n:4*n+11,21:25) = num2cell(AC4);
output(1,11) = {'Normalization Factor'};
output(2,11) = {mGamma};
output(1,1:10) = {'Epoch #','Timer','State','Delta','Adjusted State','Episode Length','Baseline Normalization Factor','Norm Delta to Gamma' ,'TM on/off','Time Bin'};
output(2,13:15) = {'Avg. SWA','Avg. SWS SWA','Avg Wake SWA'};
output(1,14) = {'norm SWA to gamma'};
output(1,17:19) = {'Bin','Adjusted State','Episode Length'};

output(2,21:24) = {'bin','Avg. Duration Wake','Avg. Duration NREM','Avg. Duration REM'};
output(5+n,21:24) = {'bin','# Wake Bouts','# NREM bouts','# REM bouts'};
output(8+2*n,21:25) = {'bin','count Waking','count NREM','count REM','sum'};
output(11+3*n,21:25) = {'bin','% Waking','% NREM','% REM','% Total'};

for i=1:numel(output),
    if isnan(output{i})
        output(i) = {[]};
    end
end

setappdata(h,'NormSWASheet',output);


%creates Norm SWA sheet for Baseline data
function makeNormSWA_Baseline(handles)
h = handles.output;

A = getappdata(h,'EpochNum');
B = getappdata(h,'TimeStr');
C = getappdata(h,'State');
D = getappdata(h,'Delta');
E = getappdata(h,'Gamma');
F = getappdata(h,'AdjState');
G = getappdata(h,'AllEpLen');

switch get(handles.Norm_Factor_Pop,'Value')
    case 1
        normFactor = mean(E(~isnan(E)));
    case 2
        normFactor = mean(D(~isnan(D) & F==1));
    case 3
        totalEEG = getappdata(h,'TotalEEG');
        normFactor = mean(totalEEG(~isnan(totalEEG)));
end
H = ones(numel(A),1)*normFactor;
I = NaN(numel(A),1);
I(~isnan(D)) = D(~isnan(D))/normFactor;
J = getappdata(h,'TimeBins');

L2 = normFactor;
L6 = mean(D(C==2 & ~isnan(D)));

EpStart = getappdata(h,'EpStart');
Y = J(EpStart);
Z = getappdata(h,'EpState');
AA = getappdata(h,'EpLen');

n = numel(unique(J));

Ntable = zeros(n,4);
Stable = zeros(n,4);
AC1 = zeros(n,4);
AC2 = zeros(n,4);
AC3 = zeros(n,5);
AC4 = zeros(n,5);

Ntable(:,1) = (1:n)';
Stable(:,1) = (1:n)';
AC1(:,1) = (1:n)';
AC2(:,1) = (1:n)';
AC3(:,1) = (1:n)';
AC4(:,1) = (1:n)';

for i=1:n,
    Ntable(i,2) = mean(I(~isnan(I) & J==i));
    Ntable(i,3) = mean(I(J==i & F==2 & ~isnan(I)));
    Ntable(i,4) = mean(I(J==i & F==1 & ~isnan(I)));
    
    Stable(i,2) = mean(D(~isnan(D) & J==i & F==2));
    Stable(i,3) = L6;
    Stable(i,4) = Stable(i,2)*100/L6;
    
    AC1(i,2) = mean(AA(Y==i & Z==1));
    AC1(i,3) = mean(AA(Y==i & Z==2));
    AC1(i,4) = mean(AA(Y==i & Z==3));
    
    AC2(i,2) = sum(Y==i & Z==1);
    AC2(i,3) = sum(Y==i & Z==2);
    AC2(i,4) = sum(Y==i & Z==3);
    
    AC3(i,2) = sum(J==i & F==1);
    AC3(i,3) = sum(J==i & F==2);
    AC3(i,4) = sum(J==i & F==3);
    AC3(i,5) = sum(AC3(i,2:4));
    
    AC4(i,2) = AC3(i,2)*100/AC3(i,5);
    AC4(i,3) = AC3(i,3)*100/AC3(i,5);
    AC4(i,4) = AC3(i,4)*100/AC3(i,5);
    AC4(i,5) = sum(AC4(i,2:4));
end
AC1(isnan(AC1))=0;
AC2(isnan(AC2))=0;
AC3(isnan(AC3))=0;
AC4(isnan(AC4))=0;

output = cell(size(A,1)+1,33);

output(2:end,1) = num2cell(A);
output(2:end,2) = cellstr(B);
output(2:end,3) = num2cell(C);
output(2:end,4) = num2cell(D);
output(2:end,5) = num2cell(E);
output(2:end,6) = num2cell(F);
output(2:end,7) = num2cell(G);
output(2:end,8) = num2cell(H);
output(2:end,9) = num2cell(I);
output(2:end,10) = num2cell(J);

output(2,12) = num2cell(L2);
output(6,12) = num2cell(L6);

output(3:n+2,14:17) = num2cell(Ntable);
output(3:n+2,19:22) = num2cell(Stable);

output(2:size(Y,1)+1,25) = num2cell(Y);
output(2:size(Y,1)+1,26) = num2cell(Z);
output(2:size(Y,1)+1,27) = num2cell(AA);

output(3:n+2,29:32) = num2cell(AC1);
output(6+n:2*n+5,29:32) = num2cell(AC2);
output(9+2*n:3*n+8,29:33) = num2cell(AC3);
output(12+3*n:4*n+11,29:33) = num2cell(AC4);

normStr = get(handles.Norm_Factor_Pop,'String');
normStr = strtrim(normStr(get(handles.Norm_Factor_Pop,'Value'),:));
output(1,12) = {normStr};
output(5,12) = {'Avg SWS SWA'};
output(1,1:10) = {'Epoch #','Timer','State','Delta','Gamma','Adjusted State','Episode Length',normStr, 'Norm SWA','Time Bin'};
output(2,15:17) = {'Avg. SWA','Avg. SWS SWA','Avg Wake SWA'};
output(1,16) = {'norm SWA'};
output(2,20:22) = {'Avg. Raw SWS SWA','24hr avg. SWS SWA','% SWS SWA'};
output(1,25:27) = {'Bin','Adjusted State','Episode Length'};

output(2,29:32) = {'bin','Avg. Duration Wake','Avg. Duration NREM','Avg. Duration REM'};
output(5+n,29:32) = {'bin','# Wake Bouts','# NREM bouts','# REM bouts'};
output(8+2*n,29:33) = {'bin','count Waking','count NREM','count REM','sum'};
output(11+3*n,29:33) = {'bin','% Waking','% NREM','% REM','% Total'};

for i=1:numel(output),
    if isnan(output{i})
        output(i) = {[]};
    end
end

setappdata(h,'NormSWASheet',output);
setappdata(h,'NormFactor',normFactor);


%saves sheeets to single xlsx
function SaveSheets(handles)
[fn,p] = uiputfile([pwd filesep '*.xlsx'],'Choose Output file');
h = handles.output;
CombOut = getappdata(h,'CombinedOutput');
EpA = getappdata(h,'EpisodeAnalysisSheet');
AdjState = getappdata(h,'AdjustedStateSheet');
NormSWA = getappdata(h,'NormSWASheet');

if ispc
    status = xlswrite([p fn],CombOut,1);
else
    status = writeCell2Txt([p fn(1:end-5) ' Combined Output.txt'],CombOut,0);
end

if ~status
    errordlg('Combined Output write failed.');
    return;
end
if ispc
    status = xlswrite([p fn],EpA,2);
else
    status = writeCell2Txt([p fn(1:end-5) ' Episode Analysis.txt'],EpA,0);
end

if ~status
    errordlg('Episode Analysis write failed.');
    return;
end

if ispc
    status = xlswrite([p fn],AdjState,3);
else
    status = writeCell2Txt([p fn(1:end-5) ' Adjusted State.txt'],AdjState,0);
end
if ~status
    errordlg('Adjusted State write failed.');
    return;
end
if ispc
    status = xlswrite([p fn],NormSWA,4);
else
    status = writeCell2Txt([p fn(1:end-5) ' Normalized SWA.txt'],NormSWA,0);
end
if ~status
    errordlg('Norm SWA write failed.');
    return;
end

setappdata(h,'outFile',[p fn]);
set(handles.Fit_SWA_Push,'Enable','on');

%takes a state number and outputs the associated string title i.e. 1->
%Wake, 2->NREM, 3->REM, and any other number -> Artifacts
function [out] = getStateStr(i)

out = 'Artifacts';

switch i
    case 1
        out = 'Wake';
    case 2
        out = 'NREM';
    case 3 
        out = 'REM';
end


% --- Executes on selection change in Norm_Factor_Pop.
function Norm_Factor_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Norm_Factor_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Norm_Factor_Pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Norm_Factor_Pop


% --- Executes during object creation, after setting all properties.
function Norm_Factor_Pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Norm_Factor_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function makeLnNormSWA(handles)
h= handles.output;
EpStart = getappdata(h,'EpStart');
EpLen = getappdata(h,'EpLen');
EpState = getappdata(h,'EpState');
EpochDur = get(handles.Epoch_Dur_Pop,'Value');
Delta = getappdata(h,'Delta');
minLen = 5/(EpochDur/60);

nremEp = EpStart(EpState==2);
nremDurs = EpLen(EpState==2);
[nremDurs,a] = sort(nremDurs,'Ascend');
nremEp = nremEp(a);
nremEp = nremEp(nremDurs>=minLen);
nremDurs = nremDurs(nremDurs>=minLen);

DeltaArr = nan(max(nremDurs),numel(nremEp));
Timer = 0:EpochDur/60:(max(nremDurs)-1)*EpochDur/60;

for i=1:numel(nremEp),
    DeltaArr(1:nremDurs(i),i) = Delta(nremEp(i):nremEp(i)+nremDurs(i)-1);
end
DeltaArr = log(DeltaArr/getappdata(h,'NormFactor'));
AvgEp = zeros(nremDurs(end-4),1);
for i=1:numel(AvgEp),
    AvgEp(i) = mean(DeltaArr(i,~isnan(DeltaArr(i,:))));
end

lnNormSWA = cell(size(DeltaArr,1)+1,size(DeltaArr,2)+7);
w = size(DeltaArr,2);
lnNormSWA(1,[1,w+6]) = {'Time (min)'};
lnNormSWA(2:end,1) = num2cell(Timer);
lnNormSWA(2:end,2:w+1) = num2cell(DeltaArr);
lnNormSWA(2:numel(AvgEp)+1,w+2) = num2cell(AvgEp);
lnNormSWA(1,[w+2,w+7]) = {'Avg Ln Norm SWA'};
lnNormSWA(2:end,w+6) = num2cell(Timer);
lnNormSWA(2:numel(AvgEp)+1,w+7) = num2cell(AvgEp);

for i=1:numel(lnNormSWA),
    if isnan(lnNormSWA{i})
        lnNormSWA(i) = {[]};
    end
end

setappdata(h,'LnNormSWASheet',lnNormSWA);
setappdata(h,'lnNormDelta',AvgEp);
setappdata(h,'fitTime',Timer(1:numel(AvgEp)));

% --- Executes on button press in Fit_SWA_Push.
function Fit_SWA_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_SWA_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeLnNormSWA(handles);

LnNormD = getappdata(handles.output,'lnNormDelta');
time = getappdata(handles.output,'fitTime');
time = time';
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
%     lnNormSWASheet = getappdata(h,'LnNormSWASheet');
%     outFile = getappdata(handles.output,'outFile');
%     if ispc
%         status = xlswrite(outFile,lnNormSWASheet,'Ln Norm SWA');
%     else
%         status = writeCell2Txt([outFile(1:end-5) ' Ln Norm SWA.txt'],lnNormSWASheet,0);
%     end
%     if ~status
%         errordlg('Writing Ln Norm SWA to excel file failed.')
%     end
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
    
    setappdata(handles.output,'FitStr',outstr);
end


function makeFigures(handles)
h = handles.output;
Delta = getappdata(h,'Delta');
State = getappdata(h,'State');
AdjState = getappdata(h,'AdjState');
EpLen = getappdata(h,'EpLen');
EpStart = getappdata(h,'EpStart');
EpochDur = get(handles.Epoch_Dur_Pop,'Value');
normFactor = getappdata(h,'NormFactor');
Colors = {[.8 0 0];[0 0 1];[0 .5 0]};
Time = (1:numel(State))*EpochDur/60;
EpState = getappdata(h,'EpState');
Delta = Delta/normFactor;
AdjState(AdjState==0) = 1;
AdjState(AdjState>3) = AdjState(AdjState>3)-3;
normStr = get(handles.Norm_Factor_Pop,'String');
normStr = strtrim(normStr(get(handles.Norm_Factor_Pop,'Value'),:));

if get(handles.Type_Pop,'Value')==1
    normStr = 'Custom Normalization Factor';
end

%cumulative histogram
[vals,bins] = hist(EpLen*EpochDur/60,50);
figure
plot(bins,cumsum(vals)*100/sum(vals),'k-')
hold on
plot(bins,cumsum(vals)*100/sum(vals),'ko')
xlabel('Episode Duration (min)')
ylabel('Cumulative Percent of Episodes')
title('Cumulative Histogram of Episode Durations')


%SWA Bar plot and hypnogram
figure
subplot(2,1,1)
hold on
bar(Time,Delta);
title('SWA Activity for each Epoch')
ylabel('Slow Wave Activity')
xlabel('Time (min)')

HypnoState = AdjState;
HypnoState(AdjState==1) = 3;
HypnoState(AdjState==2) = 1;
HypnoState(AdjState==3) = 2;

subplot(2,1,2)
plot(Time,HypnoState,'k','LineWidth',1)
hold on
for i=1:numel(EpStart),
    start = EpStart(i);
    fin = min([EpStart(i)+EpLen(i) numel(Time)])-1;
    color = Colors{EpState(i)};
    plot(Time(start:fin),HypnoState(start:fin),'Color',color,'LineWidth',10)
end
ylim([0 4])
ylabel('State')
set(gca,'YTick',[1,2,3],'YTickLabels',{'NREM','REM','Wake'})
xlabel('Time (min)')

%avg SWA bar for each state
figure
avgSWA = [mean(Delta(~isnan(Delta) & AdjState==1)) mean(Delta(~isnan(Delta) & AdjState==2)) mean(Delta(~isnan(Delta) & AdjState==3))];
stdSWA = [std(Delta(~isnan(Delta) & AdjState==1)) std(Delta(~isnan(Delta) & AdjState==2)) std(Delta(~isnan(Delta) & AdjState==3))];
hBar = bar(1:3,diag(avgSWA),'stacked');
hold on
for i=1:3,
    set(hBar(i),'FaceColor',Colors{i});
    line([i i],[avgSWA(i)-stdSWA(i) avgSWA(i)+stdSWA(i)],'Color',[0 0 0]);
end
title({'Average SWA in each State',['Normalized to ' normStr]})
set(gca,'XTick',[1,2,3],'XTickLabels',{'Wake','NREM','REM'})
ylabel('Average SWA')
ylim([0 max(avgSWA)+2*(max(stdSWA))])
textX = [.75,1.75,2.75];
textY = avgSWA+1.2*stdSWA;
textStrs = {sprintf('%0.2f +- %0.2f',avgSWA(1),stdSWA(1));...
    sprintf('%0.2f +- %0.2f',avgSWA(2),stdSWA(2));...
    sprintf('%0.2f +- %0.2f',avgSWA(3),stdSWA(3))};
text(textX,textY,textStrs);
