function varargout = Set_Lim_Popup(varargin)
% SET_LIM_POPUP MATLAB code for Set_Lim_Popup.fig
%      SET_LIM_POPUP, by itself, creates a new SET_LIM_POPUP or raises the existing
%      singleton*.
%
%      H = SET_LIM_POPUP returns the handle to a new SET_LIM_POPUP or the handle to
%      the existing singleton*.
%
%      SET_LIM_POPUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SET_LIM_POPUP.M with the given input arguments.
%
%      SET_LIM_POPUP('Property','Value',...) creates a new SET_LIM_POPUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Set_Lim_Popup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Set_Lim_Popup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Set_Lim_Popup

% Last Modified by GUIDE v2.5 24-Jul-2014 12:58:31
% Written by Roshan Nanu, July 2014
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Set_Lim_Popup_OpeningFcn, ...
                   'gui_OutputFcn',  @Set_Lim_Popup_OutputFcn, ...
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


% --- Executes just before Set_Lim_Popup is made visible.
function Set_Lim_Popup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Set_Lim_Popup (see VARARGIN)

% Choose default command line output for Set_Lim_Popup
handles.output = hObject;
l1 = varargin{1};
l2 = varargin{2};
x1 = varargin{3};
y1 = varargin{4};

setappdata(hObject,'mouse_action',0);
plot(handles.axes,x1,y1,'.');
title(handles.axes,'Average SWS Episode SWA');
xlabel(handles.axes,'Time (Sec)');
ylabel(handles.axes,'SWA Power');
set(handles.axes,'XLimMode','Auto','XTickMode','Auto','YLimMode','Auto','YTickMode','Auto');

YLim = get(handles.axes,'YLim');

handles.Lim1 = line([l1 l1],YLim,'Parent',handles.axes,'Tag','Lim1',...
    'LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','on');
set(handles.Lim1,'ButtonDownFcn','Set_Lim_Popup(''Lim1_Callback'',gcbo,''eventdata'',guidata(gcbo))');

handles.Lim2 = line([l2 l2],YLim,'Parent',handles.axes,'Tag','Lim2',...
    'LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','on');
set(handles.Lim2,'ButtonDownFcn','Set_Lim_Popup(''Lim2_Callback'',gcbo,''eventdata'',guidata(gcbo))');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Set_Lim_Popup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Set_Lim_Popup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Select_Push.
function Select_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
L1 = get(handles.Lim1,'Xdata');
L2 = get(handles.Lim2,'Xdata');
lower = min([L1(1),L2(1)]);
upper = max([L1(1),L2(1)]);
setappdata(handles.output,'Limit1',lower);
setappdata(handles.output,'Limit2',upper);
set(handles.output,'Visible','off');


function Lim1_Callback(hObject,eventdata,handles)
setappdata(handles.output,'mouse_action',1)

function Lim2_Callback(hObject,eventdata,handles)
setappdata(handles.output,'mouse_action',2)

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
action = getappdata(handles.output,'mouse_action');
switch action
    case 0
        
    case 1
        h_bar = handles.Lim1;
        h_axes = get(h_bar,'Parent');
        x_lim = get(h_axes,'XLim');
        mouse_pos = get(h_axes,'CurrentPoint');
        if mouse_pos(1,1) <= x_lim(2) & mouse_pos(1,1) >= x_lim(1)
            set(h_bar,'Xdata',[mouse_pos(1,1) mouse_pos(1,1)]);
        end
        guidata(hObject,handles);
        clear h_bar h_axes x_lim mouse_pos;
    case 2
        h_bar = handles.Lim2;
        h_axes = get(h_bar,'Parent');
        x_lim = get(h_axes,'XLim');
        mouse_pos = get(h_axes,'CurrentPoint');
        if mouse_pos(1,1) <= x_lim(2) & mouse_pos(1,1) >= x_lim(1)
            set(h_bar,'Xdata',[mouse_pos(1,1) mouse_pos(1,1)]);
        end
        guidata(hObject,handles);
        clear h_bar h_axes x_lim mouse_pos;
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.output,'mouse_action',0);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
