function varargout = Text_Display(varargin)
%Written by Roshan Nanu, July 2014
% TEXT_DISPLAY MATLAB code for Text_Display.fig
%      TEXT_DISPLAY, by itself, creates a new TEXT_DISPLAY or raises the existing
%      singleton*.
%
%      H = TEXT_DISPLAY returns the handle to a new TEXT_DISPLAY or the handle to
%      the existing singleton*.
%
%      TEXT_DISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEXT_DISPLAY.M with the given input arguments.
%
%      TEXT_DISPLAY('Property','Value',...) creates a new TEXT_DISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Text_Display_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Text_Display_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Text_Display

% Last Modified by GUIDE v2.5 07-Aug-2014 12:50:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Text_Display_OpeningFcn, ...
                   'gui_OutputFcn',  @Text_Display_OutputFcn, ...
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


% --- Executes just before Text_Display is made visible.
function Text_Display_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Text_Display (see VARARGIN)

% Choose default command line output for Text_Display
handles.output = hObject;
global main_text;

if varargin{1}
    set(handles.Save_Push,'Visible','on');
end
title = varargin{2};
main_text = varargin{3};
text = regexprep(main_text,'\t','    ');
set(handles.Title_Text,'String',title);
set(hObject,'Name',title);
set(handles.Edit_Text,'String',text);

% enable horizontal scrolling
hEdit = handles.Edit_Text;
jEdit = findjobj(hEdit);
jEditbox = jEdit.getViewport().getComponent(0);
jEditbox.setWrapping(false);                % turn off word-wrapping
jEditbox.setEditable(false);                % non-editable
set(jEdit,'HorizontalScrollBarPolicy',30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED

% maintain horizontal scrollbar policy which reverts back on component resize 
hjEdit = handle(jEdit,'CallbackProperties');
set(hjEdit, 'ComponentResizedCallback',...
    'set(gcbo,''HorizontalScrollBarPolicy'',30)')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Text_Display wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Text_Display_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Edit_Text_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Text as text
%        str2double(get(hObject,'String')) returns contents of Edit_Text as a double


% --- Executes during object creation, after setting all properties.
function Edit_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global main_text;
clear main_text;
delete(hObject);


% --- Executes on button press in Save_Push.
function Save_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global main_text
[fn p] = uiputfile('*.txt');
fid = fopen([p fn],'w+');
fwrite(fid,main_text);
fclose(fid);
