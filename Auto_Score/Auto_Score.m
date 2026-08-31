function varargout = Auto_Score(varargin)

% written by Sheng Xu, Oct. 2009
% revised by Roshan Nanu, June 2014


% AUTO_SCORE M-file for Auto_Score.fig
%      AUTO_SCORE, by itself, creates a new AUTO_SCORE or raises the existing
%      singleton*.
%
%      H = AUTO_SCORE returns the handle to a new AUTO_SCORE or the handle to
%      the existing singleton*.
%
%      AUTO_SCORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTO_SCORE.M with the given input arguments.
%
%      AUTO_SCORE('Property','Value',...) creates a new AUTO_SCORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Auto_Score_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Auto_Score_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Auto_Score

% Last Modified by GUIDE v2.5 12-Jul-2014 10:28:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Auto_Score_OpeningFcn, ...
    'gui_OutputFcn',  @Auto_Score_OutputFcn, ...
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

% --- Executes just before Auto_Score is made visible.
function Auto_Score_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Auto_Score (see VARARGIN)
global Ori_EEG Ori_EMG Base_EEG Base_EMG;
global Epoch_Dur;
global Sampling_Rate_EEG Sampling_Rate_EMG File_Name;
global Disp_Start_Freq Disp_End_Freq;
global mouse_action fbar_action;
global EEG EMG;
global epoch_dur_history;

global Last_Epoch_Num;
global EEG_Scale EMG_Scale Current_EEG_Scale Current_EMG_Scale;
global EEG_By_Epoch EMG_By_Epoch;
global EEG_Spectrum EEG_Freq_Axis EMG_Spectrum EMG_Freq_Axis;
global EEG_Power EMG_Power EMG_Variance EMG_Amplitude;
global Freq_Step Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power;
global Para1_Pop Para2_Pop;
global Para1_Type Para2_Type;
global Para1_Extra Para2_Extra;
global Stages;
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global EMG_Band_Start_Freq EMG_Band_End_Freq;

global fbar_click_pos area_start_pos;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;
global Para1_XLim Para2_YLim;
global Area_Epochs Current_Epoch_Num;
global Current_Epoch_Set Epoch_Set_Index;
global Ext_Stage_Change_Flag;
global EEG_fTag EMG_fTag filter_Flag;
global Choose_Subset_Val auto_thres;
global compare_sort;
global Fixed_Points;

Clear_Variables;

File_Type_List{1} = '.txt file';
File_Type_List{2} = '.1eg file';
File_Type_List{3} = 'Raw .mat file';
File_Type_List{4} = 'Separate .txt files';
File_Type_List{5} = 'Autoscore Workspace';
Selected_Type = listdlg('PromptString','Please select the file type:','ListString',File_Type_List,'SelectionMode','Single','Name','File Type Selection','ListSize',[140 120]);

if ~isempty(Selected_Type)
    %opening a file requires several variables to be set within this if...else statement
    % Sampling_Rate_EEG (in Hz)
    % Sampling_Rate_EMG (in Hz)
    % File_Name
    % Ori_EEG (Raw data)
    % Ori_EMG (Raw data)
    % also you need to set the string for Epoch_Dur_Edit (in Sec) and the Value of Para2_Listbox
    
    if Selected_Type == 1 %open text file
        if Selected_Type ==1
            Sampling_Rate_EEG = 256;
            Sampling_Rate_EMG = 256;
            % Sampling Rate: 256 Hz
        else
            Sampling_Rate_EEG = 100;
            Sampling_Rate_EMG = 100;
        end
        [name_txt, Path_Str] = uigetfile( '.txt', 'Pick a raw data file');
        if name_txt==0
            return;
        end
        File_Name = strcat( Path_Str, name_txt );
        question1 = questdlg('Is EMG data in the first column?','Data Order','Yes','No',{'Yes'});
        if strcmp(question1,'No')
            [eeg, emg] = textread( File_Name, '%f %f', 'headerlines', 6 );
        else
            [emg, eeg] = textread( File_Name, '%f %f', 'headerlines', 6 );
        end
        Ori_EEG = eeg;
        Ori_EMG = emg;
        set(handles.Para2_Listbox,'Value',4);
        set(handles.Epoch_Dur_Edit,'String','10');
        clear name_txt Path_Str eeg emg;
        
    elseif Selected_Type == 2 %open 1eg file
        
        Sampling_Rate_EEG = 250;
        Sampling_Rate_EMG = 250;
        [name_txt, Path_Str] = uigetfile( '.1eg', 'Pick a raw data file');
        if name_txt==0
            return;
        end
        File_Name = strcat( Path_Str, name_txt );
        set(handles.Epoch_Dur_Edit,'String','10');
        fid_1eg = fopen( File_Name , 'r' );
        if fid_1eg == -1
            errordlg( 'Can not open the file', 'File Open Error');
            return;
        end
        
        % Read 1eg file
        eeg = fread( fid_1eg, inf, '500*int16=>double', 1008);
        fseek( fid_1eg, 1000, 'bof');
        emg = fread( fid_1eg, inf, '500*int16=>double', 1008);
        fseek( fid_1eg, 2000, 'bof');
        fclose(fid_1eg);
        Ori_EEG = eeg;
        Ori_EMG = emg;
        set(handles.Para2_Listbox,'Value',4);
        set(handles.Epoch_Dur_Edit,'String','10');
        
        clear name_txt Path_Str fid_1eg eeg emg;
        
    elseif Selected_Type == 5 % open Autoscore .mat file
        [OpenFile,Path] = uigetfile('*.mat');
        if OpenFile==0
            return;
        end
        load([Path OpenFile]);
        set(handles.Epoch_Dur_Edit,'String',int2str(Epoch_Dur));
        set(handles.Para1_Listbox,'Value',Para1_Type);
        set(handles.Para2_Listbox,'Value',Para2_Type);
        set(handles.File_Name_Text2, 'String', File_Name);
        set(handles.EMG_Start_Freq_Edit,'String',EMG_Band_Start_Freq);
        set(handles.EMG_End_Freq_Edit,'String',EMG_Band_End_Freq);
        set(handles.Start_Freq_Edit,'String',EEG_Band_Start_Freq);
        set(handles.End_Freq_Edit,'String',EEG_Band_End_Freq);
        if exist('Sampling_Rate','var')
            Sampling_Rate_EEG = Sampling_Rate;
            Sampling_Rate_EMG = Sampling_Rate;
            clear Sampling_Rate;
        end
        auto_thres=0;
        
    elseif  Selected_Type == 4 %load txt data when EEG and EMG data are in separate files
        [fn1 p1] = uigetfile('*.txt','Choose EEG File');
        srEEG = inputdlg('What is the EEG Sampling Rate?','EEG Sampling Rate',1,{'256'});
        Sampling_Rate_EEG = str2double(srEEG);
        
        [fn2 p2] = uigetfile('*.txt','Choose EMG File');
        srEMG = inputdlg('What is the EMG Sampling Rate?','EMG Sampling Rate',1,{'256'});
        Sampling_Rate_EMG = str2double(srEMG);
        
        if fn1 == 0
            return;
        end
        if fn2 == 0
            return;
        end
        eeg = textread([p1 fn1],'%f','headerlines',1);
        emg = textread([p2 fn2],'%f','headerlines',1);
        File_Name = [p1 fn1];
        Ori_EEG = eeg;
        Ori_EMG = emg;
        set(handles.Para2_Listbox,'Value',4);
        set(handles.Epoch_Dur_Edit,'String','10');
        clear fn1 fn2 p1 p2 eeg emg;
        
    elseif Selected_Type == 3 %load .mat raw data
    	%the mat file loaded here needs to contain variables:
    	% - EEG
    	% - EMG
    	% - Sampling_Rate OR Sampling_Rate_EEG AND Sampling_Rate_EMG
    	%if sampling rate is missing it is automatically set to 256 Hz for both
    
        [name_txt, Path_Str] = uigetfile( '.mat', 'Pick a data file');
        if name_txt==0
            return;
        end
        File_Name = strcat( Path_Str, name_txt );
        data = load(File_Name);
        if ~isfield(data,'EEG')
            msgbox('.mat File must contain a variable named EEG.');
            return;
        end
        if ~isfield(data,'EMG')
            msgbox('.mat File must contain a variable named EMG.');
            return;
        end
        Ori_EEG = data.EEG;
        Ori_EMG = data.EMG;
        if isfield(data,'Sampling_Rate_EEG')
            Sampling_Rate_EEG = data.Sampling_Rate_EEG;
        elseif isfield(data,'Sampling_Rate')
            Sampling_Rate_EEG = data.Sampling_Rate;
        else
            Sampling_Rate_EEG = 256;
        end
        if isfield(data,'Sampling_Rate_EMG')
            Sampling_Rate_EMG = data.Sampling_Rate_EMG;
        else
            Sampling_Rate_EMG = Sampling_Rate_EEG;
        end
        set(handles.Para2_Listbox,'Value',4);
        set(handles.Epoch_Dur_Edit,'String','10');
    end
    
    set(handles.File_Name_Text2, 'String', File_Name);
    bkg_color = get(handles.figure,'Color');
    set(handles.Freq_Axis,'XLimMode','Manual','XLim',[0 Sampling_Rate_EEG/2]);
    set(handles.Freq_Axis,'YLimMode','Manual','YLim',[0 1],'YTickMode','Manual','YTick',[],'YTickLabel',[]);
    set(handles.Freq_Axis,'XTickMode','Auto');
    x_tick = get(handles.Freq_Axis,'XTick');
    
    if x_tick(1) ~= 0
        x_tick(1) = 0;
    end
    
    if x_tick(end) ~= Sampling_Rate_EEG /2;
        x_tick(end) = Sampling_Rate_EEG /2;
    end
    
    set(handles.Freq_Axis,'XTickMode','Manual','XTick',x_tick,'XTickLabel',x_tick);    
    set(handles.Freq_Axis,'Box','Off');
    set(handles.Freq_Axis,'XAxisLocation','Top','LineWidth',1.2);
    set(handles.Freq_Axis,'YColor',bkg_color,'YDir','Reverse');
    set(handles.Freq_Axis,'Color',bkg_color);
    
    % Create frequency bar and store its handle
    Disp_Start_Freq = 0;
    Disp_End_Freq = 15;
    axes(handles.Freq_Axis);
    handles.Freq_Bar = line([Disp_Start_Freq Disp_End_Freq],[.75 .75],'Parent',handles.Freq_Axis,...
        'Tag','Freq_Bar','LineWidth',4,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Freq_Bar,'ButtonDownFcn','Auto_Score(''Freq_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    
    mouse_action = 0; % 1 = freq bar action, 2 = drag para1 bar, 3 = drag para2 bar1, 4 = drag para1 hist tick, 5 = drag para2 hist tick, 6 = area selection, 7 = drag para2 bar2
    fbar_action = 0; % 1 = user clicked to shift, 2 = user clicked to stretch the left end, 3 = user clicked to stretch the right right
    fbar_click_pos = 0;
    area_start_pos = [0 0];
    epoch_dur_history = 0;

	% if the loaded data isn't an Autoscore .mat file
    if Selected_Type ~=5
        auto_thres=1;
        Base_EMG = Ori_EMG;
        Base_EEG = Ori_EEG;
        EEG_fTag = 'Unfiltered';
        EMG_fTag = 'Unfiltered';
        filter_Flag = 0;
        compare_sort = 0;
    end
    
    set(handles.EEG_Text,'String',['EEG: ' EEG_fTag]);
    set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
    handles.output = hObject;
    Ext_Stage_Change_Flag = 0;
    
    %disable excel export on non-windows conputers
    if ~ispc
        set(handles.Export_Push,'Enable','off');
        set(handles.Export_Xls_Menu,'Enable','off');
    end
    
    guidata(hObject,handles);
    clear bkg_color x_tick;
    
    if Selected_Type == 5 
        Initialize_Mat(handles);
    else
        Epoch_Dur_Edit_Callback(handles.Epoch_Dur_Edit,eventdata, handles);
    end
else
    delete(hObject);
end

clear File_Type_List Selected_Type;

% Executes on program opening to setup program, as well as when epoch
% duration is changed or when new data is loaded (except Autoscore .mat data). This
% function is the progam's slowest step due to the large number of
% functional fourier transforms performed 
function Epoch_Dur_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Epoch_Dur_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Epoch_Dur_Edit as text
%        str2double(get(hObject,'String')) returns contents of Epoch_Dur_Edit as a double

global Ori_EEG Ori_EMG;
global Epoch_Dur Sampling_Rate_EEG Sampling_Rate_EMG;
global EEG EMG;
global Last_Epoch_Num;
global EEG_Scale EMG_Scale Current_EEG_Scale Current_EMG_Scale;
global EEG_By_Epoch EMG_By_Epoch;
global EEG_Spectrum EEG_Freq_Axis EMG_Spectrum EMG_Freq_Axis;
global EEG_Power EMG_Power EMG_Variance EMG_Amplitude;
global Freq_Step Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power;
global Para1_Type Para2_Type;
global Para1_Extra Para2_Extra;
global Stages; 
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global EMG_Band_Start_Freq EMG_Band_End_Freq;
global epoch_dur_history;
global Disp_Start_Freq Disp_End_Freq;
global mouse_action fbar_action;

global fbar_click_pos area_start_pos;
global Para1_Pop Para2_Pop;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;
global Para1_XLim Para2_YLim;
global Current_Epoch_Num;
global Current_Epoch_Set Epoch_Set_Index;
global Choose_Subset_Val auto_thres;
global Fixed_Points;


set(handles.output,'pointer','watch');
drawnow;
Epoch_Dur = str2num(get(handles.Epoch_Dur_Edit,'String'));

max_nonzero = find(Ori_EEG, 1, 'last' );

Last_Epoch_Num = floor( max_nonzero / ( Sampling_Rate_EEG  * Epoch_Dur ) );

EEG = Ori_EEG( 1 : Last_Epoch_Num * Sampling_Rate_EEG  * Epoch_Dur );
EMG = Ori_EMG( 1 : Last_Epoch_Num * Sampling_Rate_EMG  * Epoch_Dur );


eeg_range = max(abs(EEG));
emg_range = max(abs(EMG));

EEG_Scale = [0 Sampling_Rate_EEG  * Epoch_Dur -eeg_range*0.7 eeg_range*0.7];
EMG_Scale = [0 Sampling_Rate_EMG  * Epoch_Dur -emg_range*0.7 emg_range*0.7];

Current_EEG_Scale = EEG_Scale;
Current_EMG_Scale = EMG_Scale;

EEG_By_Epoch = reshape(EEG, Sampling_Rate_EEG  * Epoch_Dur, []);
EMG_By_Epoch = reshape(EMG, Sampling_Rate_EMG  * Epoch_Dur, []);


[EEG_Spectrum, EEG_Freq_Axis] = FFT_Calc(EEG_By_Epoch, Sampling_Rate_EEG );
[EMG_Spectrum, EMG_Freq_Axis] = FFT_Calc(EMG_By_Epoch, Sampling_Rate_EMG );

EEG_Power = sum(EEG_Spectrum);

EMG_Power = sum(EMG_Spectrum);

EMG_Variance = EMG_Var_Calc(EMG, Sampling_Rate_EMG , Epoch_Dur);

%A moving average of 11 width is taken of the absolute value of the EMG
%signal and then the moving averages are averaged to get EMG Amplitude
%values for each epoch
EMG_Amplitude = zeros(1,Last_Epoch_Num);
for i=1:Last_Epoch_Num,
    x = abs(EMG_By_Epoch(:,i));
    k = ones(1,11)/11;
    y = conv(x,k,'same');
    EMG_Amplitude(i) = mean(y);
end

Current_Epoch_Num = 1;
Current_Epoch_Set = 1:Last_Epoch_Num;
Epoch_Set_Index = 1;
Choose_Subset_Val = 1;
set(handles.Choose_Subset_Pop,'Value',Choose_Subset_Val);
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

total_dur = Last_Epoch_Num*Epoch_Dur/3600;
disp_string1 = strcat(num2str(Last_Epoch_Num),' (',num2str(total_dur),' hours)');
set(handles.Epoch_Num_Text3,'String',disp_string1);

Freq_Step = EEG_Freq_Axis(2) - EEG_Freq_Axis(1);

Delta_Power = Band_Power_Calc(EEG_Spectrum,0.5,5,Freq_Step);
Theta_Power = Band_Power_Calc(EEG_Spectrum,6,10,Freq_Step);
Spindle_Power = Band_Power_Calc(EEG_Spectrum,8,16,Freq_Step);
Sigma_Power = Band_Power_Calc(EEG_Spectrum,16,30,Freq_Step);
Gamma_Power = Band_Power_Calc(EEG_Spectrum,30,min([50,Sampling_Rate_EEG /2]),Freq_Step);
Para2_Extra = (Delta_Power.*EMG_Power)./(Theta_Power.^2);
Para1_Extra = EEG_Power;

Para1_Type = get(handles.Para1_Listbox,'Value');
Para2_Type = get(handles.Para2_Listbox,'Value');

if exist('Para1_Extra','var') && Para1_Type ==4
    if numel(Para1_Extra)~= numel(EEG_Power)
        Para1_Type = 1;
        set(handles.Para1_Listbox,'Value',1);
        s1 = get(handles.Para1_Listbox,'String');
        s1 = s1(1:3);
        set(handles.Para1_Listbox,'String',s1);
    end
end
if Para1_Type == 1
    Para1_Pop = EEG_Power;
elseif Para1_Type == 2
    EEG_Band_Start_Freq = str2num(get(handles.Start_Freq_Edit, 'String'));
    
    if EEG_Band_Start_Freq < 0 || EEG_Band_Start_Freq > Sampling_Rate_EEG /2
        errordlg('Invalid EEG start frequency value. Please re-enter.','EEG Start Frequency Error');
        return;
    end
    
    EEG_Band_End_Freq = str2num(get(handles.End_Freq_Edit, 'String'));
    
    if EEG_Band_End_Freq < 0 || EEG_Band_End_Freq > Sampling_Rate_EEG /2
        errordlg('Invalid EEG end frequency value. Please re-enter.','EEG End Frequency Error');
        return;
    end
    
    if EEG_Band_End_Freq <= EEG_Band_Start_Freq
        errordlg('The EEG end frequency has to be bigger than the EEG start frequency. Please re-enter.','EEG Frequency Range Error');
        return;
    end
        
    Para1_Pop = Band_Power_Calc(EEG_Spectrum,EEG_Band_Start_Freq,EEG_Band_End_Freq,Freq_Step);
    
elseif Para1_Type == 3
    Para1_Pop = Delta_Power;
elseif Para1_Type == 4
    Para1_Pop = max(EEG_Spectrum(1:11,:));  
end

if exist('Para2_Extra','var') && Para2_Type == 5
    if numel(Para2_Extra)~=numel(EEG_Power)
        Para2_Type = 4;
        set(handles.Para2_Listbox,'Value',4);
    end
end

if Para2_Type == 1
    Para2_Pop = EMG_Power;
elseif Para2_Type == 2
    Para2_Pop = EMG_Variance;
elseif Para2_Type == 3
    EMG_Band_Start_Freq = str2num(get(handles.EMG_Start_Freq_Edit, 'String'));
    
    if EMG_Band_Start_Freq < 0 || EMG_Band_Start_Freq > Sampling_Rate_EMG /2
        errordlg('Invalid EMG start frequency value. Please re-enter.','EMG Start Frequency Error');
        return;
    end
    
    EMG_Band_End_Freq = str2num(get(handles.EMG_End_Freq_Edit, 'String'));
    
    if EMG_Band_End_Freq < 0 || EMG_Band_End_Freq > Sampling_Rate_EMG /2
        errordlg('Invalid EMG end frequency value. Please re-enter.','EMG End Frequency Error');
        return;
    end
    
    if EMG_Band_End_Freq <= EMG_Band_Start_Freq
        errordlg('The EMG end frequency has to be bigger than the EMG start frequency. Please re-enter.','EMG Frequency Range Error');
        return;
    end
    
    
    Para2_Pop = Band_Power_Calc(EMG_Spectrum,EMG_Band_Start_Freq,EMG_Band_End_Freq,Freq_Step);
elseif Para2_Type == 4
    Para2_Pop = EMG_Power./Theta_Power;
elseif Para2_Type == 5
    Para2_Pop = Para2_Extra;
    
end

Fixed_Points = zeros(1,Last_Epoch_Num);
Stages = zeros(1,Last_Epoch_Num);

if auto_thres
    Para1_Thres = getNREMthresh(Para1_Pop,EMG_Power);
    try
        [Para2_Thres1,Para2_Thres2] = getPara2_Thres(Para1_Pop,Para2_Pop,Para1_Thres);
    catch
        Para2_Thres1 = median(Para2_Pop);
        Para2_Thres2 = mean(Para2_Pop);
    end
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
    if get(handles.Cont_Sort_Push,'Value')
        Stages = contSort(Stages,Fixed_Points);
    end
else
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
    if get(handles.Cont_Sort_Push,'Value')
        Stages = contSort(Stages,Fixed_Points);
    end
end

if epoch_dur_history == 1
    hobj = findobj(handles.Double_Plot_Axis,'Marker','.');
    delete(hobj);
    clear hobj;
    hobj = findobj(handles.Double_Plot_Axis,'Marker','*');
    delete(hobj);
    
    set(handles.Para1_Thres_Bar,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar1,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar2,'XData',[],'YData',[]);
    set(handles.Area_Edge1,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge2,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge3,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge4,'XData',[],'YData',[],'Visible','Off');
    set(handles.Para1_Slider,'Value',1);
    set(handles.Para2_Slider,'Value',1);
    clear hobj;
end

axes(handles.Double_Plot_Axis);
xlabel('Parameter 1');
ylabel('Parameter 2');
for i = 1:Last_Epoch_Num
    
    if Stages(i) == 1
        plot_color = [256 180 180]/256;  %pink
        markersize = 6;
        
    elseif Stages(i) == 2
        plot_color = [128 128 256]/256;  %light blue
        markersize = 6;
        
    elseif Stages(i) == 3
        
        plot_color = [180 256 124]/256;  %light green
        markersize = 6;
        
    elseif Stages(i) == 4
        
        plot_color = [256 128 256]/256; %light purple
        markersize = 6;
        
    elseif Stages(i) == 5
        plot_color = [0.08 0.8 1]; %cyan
        markersize = 6;
        
    elseif Stages(i) == 6
        plot_color = [0.35 0.64 0.4]; %forest green
        markersize = 6;
        
    elseif Stages(i) == 0
        plot_color = [64 64 64]/256;  %grey
        markersize = 12;
        
    elseif Stages(i) == 7
        plot_color = [255 131 47]/256; %light orange
        markersize = 12;
        
    end
    plot(Para1_Pop(i),Para2_Pop(i),'Marker','.','MarkerSize',markersize,'Color',plot_color);
    
    clear plot_color markersize;
    
    
end


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

axes(handles.Double_Plot_Axis);
plot(Para1_Pop(Current_Epoch_Num),Para2_Pop(Current_Epoch_Num),'Marker','*','MarkerSize',12,'LineWidth',1.5,'Color',plot_color2);

set(handles.Double_Plot_Axis,'XLimMode','Auto','XTickMode','Auto','YLimMode','Auto','YTickMode','Auto');


Para1_XLim = get(handles.Double_Plot_Axis,'XLim');
Para1_XTick = get(handles.Double_Plot_Axis,'XTick');
Para1_XTickLabel = get(handles.Double_Plot_Axis,'XTickLabel');

Para2_YLim = get(handles.Double_Plot_Axis,'YLim');
Para2_YTick = get(handles.Double_Plot_Axis,'YTick');
Para2_YTickLabel = get(handles.Double_Plot_Axis,'YTickLabel');



if epoch_dur_history == 1
    set(handles.Para1_Thres_Bar,'XData',[Para1_Thres Para1_Thres],'YData',Para2_YLim);
    set(handles.Para2_Thres_Bar1,'XData',[Para1_XLim(1) Para1_Thres],'YData',[Para2_Thres1 Para2_Thres1]);
    set(handles.Para2_Thres_Bar2,'XData',[Para1_Thres Para1_XLim(2)],'YData',[Para2_Thres2 Para2_Thres2]);
    
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
else
    axes(handles.Double_Plot_Axis);
    handles.Para1_Thres_Bar = line([Para1_Thres Para1_Thres],Para2_YLim,'Parent',handles.Double_Plot_Axis,...
        'Tag','Para1_Thres_Bar','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    handles.Para2_Thres_Bar1 = line([Para1_XLim(1) Para1_Thres], [Para2_Thres1 Para2_Thres1],'Parent',handles.Double_Plot_Axis,...
        'Tag','Para2_Thres_Bar1','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    handles.Para2_Thres_Bar2 = line([Para1_Thres Para1_XLim(2)], [Para2_Thres2 Para2_Thres2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Para2_Thres_Bar2','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    
    handles.Area_Edge1 = line([Para1_XLim(1) Para1_Thres/2],[Para2_YLim(1) Para2_YLim(1)],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge1','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge2 = line([Para1_XLim(1) Para1_Thres/2],[Para2_Thres1/2 Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge2','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge3 = line([Para1_XLim(1) Para1_XLim(1)],[Para2_YLim(1) Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge3','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge4 = line([Para1_Thres/2 Para1_Thres/2],[Para2_YLim(1) Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge4','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
end


Para1_Hist_Divide = 0.7*(Para1_XLim(2) - Para1_XLim(1)) + Para1_XLim(1);
Para2_Hist_Divide = 0.7*(Para2_YLim(2) - Para2_YLim(1)) + Para2_YLim(1);

Para1_Lastbin_Center = (Para1_Hist_Divide + Para1_XLim(2))/2;
Para2_Lastbin_Center = (Para2_Hist_Divide + Para2_YLim(2))/2;



[Para1_N, Para1_X] = Hist_Calc(Para1_Pop,Para1_Hist_Divide,Para1_Lastbin_Center,20);
[Para2_N, Para2_X] = Hist_Calc(Para2_Pop,Para2_Hist_Divide,Para2_Lastbin_Center,20);

if epoch_dur_history == 1
    set(handles.Para1_Hist_Bar,'XData',Para1_X,'YData',Para1_N);
    set(handles.Para1_Thres_Bar_Hist,'XData',[],'YData',[]);
    set(handles.Para1_Hist_Tick,'XData',[],'YData',[]);
    
    set(handles.Para2_Hist_Bar,'XData',Para2_X,'YData',Para2_N);
    set(handles.Para2_Thres_Bar_Hist1,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',[],'YData',[]);
    set(handles.Para2_Hist_Tick,'XData',[],'YData',[]);
    
    
else
    axes(handles.Histogram_Axis1);
    handles.Para1_Hist_Bar = bar(Para1_X,Para1_N);
    set(handles.Para1_Hist_Bar,'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'Parent',handles.Histogram_Axis1);
    ylabel('Epoch Count');
    
    axes(handles.Histogram_Axis2);
    handles.Para2_Hist_Bar = barh(Para2_X,Para2_N);
    set(handles.Para2_Hist_Bar,'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'Parent',handles.Histogram_Axis2);
    set(handles.Histogram_Axis2,'XDir','Reverse');
    xlabel('Epoch Count');
    
end


set(handles.Histogram_Axis1,'XLimMode','Manual','XLim',Para1_XLim,'XTickMode','Manual','XTick',Para1_XTick,'XTickLabel',Para1_XTickLabel);
set(handles.Histogram_Axis1,'YLimMode','Auto','YTickMode','Auto');

Histogram_Axis1_YLim = get(handles.Histogram_Axis1,'YLim');


if epoch_dur_history == 1
    set(handles.Para1_Thres_Bar_Hist,'XData',[Para1_Thres Para1_Thres],'YData',Histogram_Axis1_YLim);
    set(handles.Para1_Hist_Tick,'XData',[Para1_Hist_Divide Para1_Hist_Divide],...
        'YData',[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10]);
    
else
    axes(handles.Histogram_Axis1);
    handles.Para1_Thres_Bar_Hist = line([Para1_Thres Para1_Thres],Histogram_Axis1_YLim,'Parent',handles.Histogram_Axis1,...
        'Tag','Para1_Thres_Bar_Hist','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    
    handles.Para1_Hist_Tick = line([Para1_Hist_Divide Para1_Hist_Divide],[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10],...
        'Parent',handles.Histogram_Axis1,'Tag','Para1_Hist_Tick','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para1_Hist_Tick,'ButtonDownFcn','Auto_Score(''Para1_Hist_Tick_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
end


set(handles.Histogram_Axis2,'YLimMode','Manual','YLim',Para2_YLim,'YTickMode','Manual','YTick',Para2_YTick,'YTickLabel',Para2_YTickLabel);
set(handles.Histogram_Axis2,'XLimMode','Auto','XTickMode','Auto');

Histogram_Axis2_XLim = get(handles.Histogram_Axis2,'XLim');

if epoch_dur_history == 1
    set(handles.Para2_Thres_Bar_Hist1,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres1 Para2_Thres1]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres2 Para2_Thres2]);
    set(handles.Para2_Hist_Tick,'XData',[Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10],...
        'YData',[Para2_Hist_Divide Para2_Hist_Divide]);
else
    
    axes(handles.Histogram_Axis2);
    handles.Para2_Thres_Bar_Hist1 = line(Histogram_Axis2_XLim, [Para2_Thres1 Para2_Thres1],'Parent',handles.Histogram_Axis2,...
        'Tag','Para2_Thres_Bar_Hist1','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    handles.Para2_Thres_Bar_Hist2 = line(Histogram_Axis2_XLim, [Para2_Thres2 Para2_Thres2],'Parent',handles.Histogram_Axis2,...
        'Tag','Para2_Thres_Bar_Hist2','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    
    handles.Para2_Hist_Tick = line([Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10], [Para2_Hist_Divide Para2_Hist_Divide],...
        'Parent',handles.Histogram_Axis2,'Tag','Para2_Hist_Tick','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Hist_Tick,'ButtonDownFcn','Auto_Score(''Para2_Hist_Tick_Callback'',gcbo,''eventdata'',guidata(gcbo))');
end


EEG_to_plot = EEG_By_Epoch(:, Current_Epoch_Num);
EMG_to_plot = EMG_By_Epoch(:, Current_Epoch_Num);

time_start = (Current_Epoch_Num - 1) * Epoch_Dur;
time_end = Current_Epoch_Num * Epoch_Dur;

set(handles.Epoch_Num_Edit,'String',num2str(Current_Epoch_Num));

axes(handles.EEG_Axis);
handles.Current_EEG_Plot = plot(EEG_to_plot,'Color',plot_color2,'Parent',handles.EEG_Axis);
axis(Current_EEG_Scale);
set(handles.EEG_Axis, 'XTickMode', 'Manual', 'XTick', 0:2*Sampling_Rate_EEG :Epoch_Dur*Sampling_Rate_EEG , 'XTickLabel',time_start:2:time_end, 'XGrid', 'on','YGrid','On');
xlabel('Time (Seconds)');


axes(handles.EMG_Axis);
handles.Current_EMG_Plot = plot(EMG_to_plot,'Color',plot_color2,'Parent',handles.EMG_Axis);
axis(Current_EMG_Scale);
set(handles.EMG_Axis, 'XTickMode', 'Manual', 'XTick', 0:2*Sampling_Rate_EMG :Epoch_Dur*Sampling_Rate_EMG , 'XTickLabel', time_start:2:time_end, 'XGrid', 'on','YGrid','On');
xlabel('Time (Seconds)');

if get(handles.Spectrum_Checkbox,'Value') == 1
    
    
    Start_Index = floor(Disp_Start_Freq/Freq_Step + 1);
    End_Index = ceil(Disp_End_Freq/Freq_Step + 1);
    
    EEG_spectrum_to_plot = EEG_Spectrum(Start_Index:End_Index,Current_Epoch_Num);
    
    Freq_Axis = (Start_Index-1)*Freq_Step:Freq_Step:(End_Index-1)*Freq_Step;
    
    
    axes(handles.Spectrum_Axis);
    handles.Current_Spectrum_Plot = plot(Freq_Axis, EEG_spectrum_to_plot,'Color',plot_color2,'LineWidth',2,'Parent',handles.Spectrum_Axis);
    xtick_vector = [Disp_Start_Freq round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)/3)...
        round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)*2/3) Disp_End_Freq];
    set(handles.Spectrum_Axis,'XGrid','On');
    set(handles.Spectrum_Axis,'XLimMode','Manual','XLim',[Disp_Start_Freq Disp_End_Freq],'XTickMode','Manual','XTick',xtick_vector,'XTickLabel',xtick_vector);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    
    clear Start_Index End_Index EEG_spectrum_to_plot Freq_Axis xtick_vector;
end



epoch_dur_history = 1;

mouse_action = 0;
fbar_action = 0;
fbar_click_pos = 0;
area_start_pos = [0 0];
set(handles.output,'pointer','arrow');
set(handles.Point_Selection_Toggle,'Value',0);
set(handles.Point_Epoch_Text,'String','Epoch ##');
set(handles.figure,'WindowButtonDownFcn','');
Update_Stages(hObject,eventdata,handles);

guidata(hObject,handles);

clear max_nonzero;
clear eeg_range emg_range;
clear total_dur disp_string1 disp_string2;
clear stage plot_color2;
clear Para1_XTick Para1_XTickLabel;
clear Para2_YTick Para2_YTickLabel;
clear Para1_Lastbin_Center Para2_Lastbin_Center;
clear Para1_N Para1_X Para2_N Para2_X;
clear Histogram_Axis1_YLim Histogram_Axis2_XLim;
clear EEG_to_plot EMG_to_plot time_start time_end;

%executes when window fcous is gained
function Focus_Gained_Callback(hObject,eventdata,handles)
global Ext_Stage_Change_Flag;
global Choose_Subset_Val;
global Epoch_Set_Index Current_Epoch_Set;
if Choose_Subset_Val ==7
    set(handles.Area_Edge1,'Visible','On');
    set(handles.Area_Edge2,'Visible','On');
    set(handles.Area_Edge3,'Visible','On');
    set(handles.Area_Edge4,'Visible','On');
end
if Ext_Stage_Change_Flag
    Ext_Stage_Change_Flag = 0;
    Epoch_Update2_Callback(hObject,eventdata,handles);
else
    Epoch_Update1_Callback(hObject,eventdata,handles);
end
set(handles.Choose_Subset_Pop,'Value',Choose_Subset_Val)
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

guidata(hObject,handles)

% Frequency Bar Callback (reacts to user)
%--------------------------------------------------------------------------
function Freq_Bar_Callback(hObject,eventdata,handles)

global fbar_click_pos mouse_action fbar_action;

mouse_action = 1;

h_bar = hObject;
h_axes = get(h_bar,'Parent');

click_pos = get(h_axes,'CurrentPoint');

fbar_click_pos = click_pos(1,1);

x_lim = get(h_bar,'Xdata');
x_left_thres = x_lim(1) + (x_lim(2)-x_lim(1))/10;
x_right_thres = x_lim(2) - (x_lim(2)-x_lim(1))/10;

if click_pos(1,1) < x_left_thres %clicked on left end
    fbar_action = 2;
elseif click_pos(1,1) > x_right_thres %clicked on the right end
    fbar_action = 3;
else %clicked on the middle part
    fbar_action = 1; % shift
end


clear h_bar h_axes click_pos x_lim x_left_thres x_right_thres;

% --- Executes on mouse motion over figure - except title and menu.
function figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;


if isempty(mouse_action) || mouse_action == 0
    return;
end

if mouse_action == 1
    if fbar_action == 0
        return;
    end
    h_bar = handles.Freq_Bar;
    h_axes = get(h_bar,'Parent');
    mouse_pos = get(h_axes,'CurrentPoint');
    dist = mouse_pos(1,1) - fbar_click_pos;
    x_bar = get(h_bar,'Xdata');
    x_axes = get(h_axes,'Xlim');
    
    if fbar_action == 1 %shift
        
        if dist + x_bar(2) > x_axes(2) % too far right, condense
            set(h_bar,'Xdata', [round((x_axes(2)-x_bar(2)+x_bar(1))*2)/2,x_axes(2)]);   %round to 0.5Hz
        elseif dist + x_bar(1) < x_axes(1) % too far left, condense
            set(h_bar,'Xdata', [x_axes(1), round((x_axes(1)+x_bar(2)-x_bar(1))*2)/2]);
        else % shift over
            set(h_bar,'Xdata',round((x_bar + dist).*2)/2);
        end
        fbar_click_pos = mouse_pos(1,1); % now that have shifted, want to make this the new reference point for shifts
        
    elseif fbar_action == 2  % stretch of the left end
        if mouse_pos(1,1) < x_bar(1)
            if mouse_pos(1,1) < x_axes(1)
                set(h_bar,'Xdata',[x_axes(1) x_bar(2)]);
            else
                set(h_bar,'Xdata',[round(mouse_pos(1,1)*2)/2 x_bar(2)]);
            end
        else
            if mouse_pos(1,1) <= x_bar(2)
                set(h_bar,'Xdata',[round(mouse_pos(1,1)*2)/2 x_bar(2)]);
            end
        end
    elseif fbar_action == 3 % stretch of the right end
        if mouse_pos(1,1) > x_bar(2)
            if mouse_pos(1,1) > x_axes(2)
                set(h_bar,'Xdata',[x_bar(1) x_axes(2)]);
            else
                set(h_bar,'Xdata',[x_bar(1) round(mouse_pos(1,1)*2)/2]);
            end
        else
            if mouse_pos(1,1) >= x_bar(1)
                set(h_bar,'Xdata',[x_bar(1) round(mouse_pos(1,1)*2)/2]);
            end
        end
    end
    
    guidata(hObject,handles);
    clear h_bar h_axes mouse_pos dist x_bar x_axes;
elseif mouse_action == 2
    h_bar = handles.Para1_Thres_Bar;
    h_axes = get(h_bar,'Parent');
    x_lim = get(h_axes,'XLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    if mouse_pos(1,1) <= x_lim(2) && mouse_pos(1,1) >= x_lim(1)
        set(h_bar,'Xdata',[mouse_pos(1,1) mouse_pos(1,1)]);
        set(handles.Para1_Thres_Bar_Hist,'Xdata',[mouse_pos(1,1) mouse_pos(1,1)]);
        set(handles.Para2_Thres_Bar1,'Xdata',[x_lim(1) mouse_pos(1,1)]);
        set(handles.Para2_Thres_Bar2,'Xdata',[mouse_pos(1,1) x_lim(2)]);
        Para1_Thres = mouse_pos(1,1);
    end
    guidata(hObject,handles);
    clear h_bar h_axes x_lim mouse_pos;
    
elseif mouse_action == 3
    h_bar = handles.Para2_Thres_Bar1;
    h_axes = get(h_bar,'Parent');
    y_lim = get(h_axes,'YLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    if mouse_pos(1,2) <= y_lim(2) && mouse_pos(1,2) >= y_lim(1)
        set(h_bar,'Ydata',[mouse_pos(1,2) mouse_pos(1,2)]);
        set(handles.Para2_Thres_Bar_Hist1,'Ydata',[mouse_pos(1,2) mouse_pos(1,2)]);
        Para2_Thres1 = mouse_pos(1,2);
    end
    guidata(hObject,handles);
    clear h_bar h_axes y_lim mouse_pos;
    
    
elseif mouse_action == 4
    h_bar = handles.Para1_Hist_Tick;
    h_axes = get(h_bar,'Parent');
    x_lim = get(h_axes,'XLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    if mouse_pos(1,1) <= x_lim(2) && mouse_pos(1,1) >= x_lim(1)
        set(h_bar,'Xdata',[mouse_pos(1,1) mouse_pos(1,1)]);
        Para1_Hist_Divide = mouse_pos(1,1);
    end
    guidata(hObject,handles);
    clear h_bar h_axes x_lim mouse_pos;
    
elseif mouse_action == 5
    h_bar = handles.Para2_Hist_Tick;
    h_axes = get(h_bar,'Parent');
    y_lim = get(h_axes,'YLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    if mouse_pos(1,2) <= y_lim(2) && mouse_pos(1,2) >= y_lim(1)
        set(h_bar,'Ydata',[mouse_pos(1,2) mouse_pos(1,2)]);
        Para2_Hist_Divide = mouse_pos(1,2);
    end
    guidata(hObject,handles);
    clear h_bar h_axes y_lim mouse_pos;
    
elseif mouse_action == 6
    h_axes = handles.Double_Plot_Axis;
    x_lim = get(h_axes,'XLim');
    y_lim = get(h_axes,'YLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    x1 = area_start_pos(1);
    y1 = area_start_pos(2);
    x2 = mouse_pos(1,1);
    y2 = mouse_pos(1,2);
    
    final_x2 = max([x_lim(1) x2]);
    final_x2 = min([x_lim(2) final_x2]);
    final_y2 = max([y_lim(1) y2]);
    final_y2 = min([y_lim(2) final_y2]);
    
    set(handles.Area_Edge1,'Xdata',[x1 final_x2],'Ydata',[y1 y1],'Visible','On');
    set(handles.Area_Edge2,'Xdata',[x1 final_x2],'Ydata',[final_y2 final_y2],'Visible','On');
    set(handles.Area_Edge3,'Xdata',[x1 x1],'Ydata',[y1 final_y2],'Visible','On');
    set(handles.Area_Edge4,'Xdata',[final_x2 final_x2],'Ydata',[y1 final_y2],'Visible','On');
    
    guidata(hObject,handles);
    clear final_x2 final_y2;
    
    
    clear h_axes x_lim y_lim mouse_pos x1 y1 x2 y2;
elseif mouse_action == 7
    h_bar = handles.Para2_Thres_Bar2;
    h_axes = get(h_bar,'Parent');
    y_lim = get(h_axes,'YLim');
    mouse_pos = get(h_axes,'CurrentPoint');
    if mouse_pos(1,2) <= y_lim(2) && mouse_pos(1,2) >= y_lim(1)
        set(h_bar,'Ydata',[mouse_pos(1,2) mouse_pos(1,2)]);
        set(handles.Para2_Thres_Bar_Hist2,'Ydata',[mouse_pos(1,2) mouse_pos(1,2)]);
        Para2_Thres2 = mouse_pos(1,2);
    end
    guidata(hObject,handles);
    clear h_bar h_axes y_lim mouse_pos;
    
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Disp_Start_Freq Disp_End_Freq;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;
global Para1_Pop Para2_Pop;
global Stages;
global Para1_XLim Para2_YLim;
global Current_Epoch_Set Epoch_Set_Index Current_Epoch_Num;
global Area_Epochs Fixed_Points Choose_Subset_Val;


if isempty(mouse_action) || mouse_action == 0
    return;
end

if mouse_action == 1
    mouse_action = 0;
    fbar_action = 0;
    fbar_click_pos = 0;
    
    freq_range = get(handles.Freq_Bar,'Xdata');
    Disp_Start_Freq = freq_range(1);
    Disp_End_Freq = freq_range(2);
    
    
    
    xtick_vector = [Disp_Start_Freq round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)/3)...
        round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)*2/3) Disp_End_Freq];
    
    set(handles.Spectrum_Axis,'XLimMode','Manual','XLim',[Disp_Start_Freq Disp_End_Freq],'XTickMode','Manual','XTick',xtick_vector,'XTickLabel',xtick_vector);
    
    guidata(hObject,handles);
    
    clear freq_range xtick_vector;
    
elseif mouse_action == 2
    mouse_action = 0;
    
    para1_thres = get(handles.Para1_Thres_Bar,'Xdata');
    
    Para1_Thres = para1_thres(1);
    
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
    if get(handles.Cont_Sort_Push,'Value')
        Stages = contSort(Stages,Fixed_Points);
    end
    
    if Choose_Subset_Val == 8
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
        if Epoch_Set_Index > numel(Current_Epoch_Set)
            Epoch_Set_Index = numel(Current_Epoch_Set);
        end
    end
    
    Update_Stages(hObject,eventdata,handles);
    
    guidata(hObject,handles);
    Epoch_Update2_Callback(hObject, eventdata, handles);
    clear para1_thres disp_string;
    
elseif mouse_action == 3
    mouse_action = 0;
    
    
    para2_thres1 = get(handles.Para2_Thres_Bar1,'Ydata');
    
    
    Para2_Thres1 = para2_thres1(1);
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
    if get(handles.Cont_Sort_Push,'Value')
        Stages = contSort(Stages,Fixed_Points);
    end
    
    if Choose_Subset_Val == 8
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
        if Epoch_Set_Index > numel(Current_Epoch_Set)
            Epoch_Set_Index = numel(Current_Epoch_Set);
        end
    end
    
    Update_Stages(hObject,eventdata,handles);
    
    guidata(hObject,handles);
    Epoch_Update2_Callback(hObject, eventdata, handles);
    clear para2_thres1 disp_string;
    
    
elseif mouse_action == 4
    mouse_action = 0;
    para1_hist_tick = get(handles.Para1_Hist_Tick,'Xdata');
    
    Para1_Hist_Divide = para1_hist_tick(1);
    
    Para1_Lastbin_Center = (Para1_Hist_Divide + Para1_XLim(2))/2;
    
    [Para1_N, Para1_X] = Hist_Calc(Para1_Pop,Para1_Hist_Divide,Para1_Lastbin_Center,20);
    
    
    set(handles.Para1_Hist_Bar,'XData',Para1_X,'YData',Para1_N);
    set(handles.Para1_Thres_Bar_Hist,'XData',[],'YData',[]);
    set(handles.Para1_Hist_Tick,'XData',[],'YData',[]);
    
    set(handles.Histogram_Axis1,'YLimMode','Auto','YTickMode','Auto');
    
    Histogram_Axis1_YLim = get(handles.Histogram_Axis1,'YLim');
    
    set(handles.Para1_Thres_Bar_Hist,'XData',[Para1_Thres Para1_Thres],'YData',Histogram_Axis1_YLim);
    
    set(handles.Para1_Hist_Tick,'XData',[Para1_Hist_Divide Para1_Hist_Divide],...
        'YData',[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10]);
    
    guidata(hObject,handles);
    clear para1_hist_tick Para1_Lastbin_Center Para1_N Para1_X Histogram_Axis1_YLim;
    
elseif mouse_action == 5
    mouse_action = 0;
    
    para2_hist_tick = get(handles.Para2_Hist_Tick,'Ydata');
    
    Para2_Hist_Divide = para2_hist_tick(1);
    
    Para2_Lastbin_Center = (Para2_Hist_Divide + Para2_YLim(2))/2;
    
    
    [Para2_N, Para2_X] = Hist_Calc(Para2_Pop,Para2_Hist_Divide,Para2_Lastbin_Center,20);
    
    set(handles.Para2_Hist_Bar,'XData',Para2_X,'YData',Para2_N);
    set(handles.Para2_Thres_Bar_Hist1,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',[],'YData',[]);
    set(handles.Para2_Hist_Tick,'XData',[],'YData',[]);
    
    set(handles.Histogram_Axis2,'XLimMode','Auto','XTickMode','Auto');
    
    Histogram_Axis2_XLim = get(handles.Histogram_Axis2,'XLim');
    set(handles.Para2_Thres_Bar_Hist1,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres1 Para2_Thres1]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres2 Para2_Thres2]);
    
    set(handles.Para2_Hist_Tick,'XData',[Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10],...
        'YData',[Para2_Hist_Divide Para2_Hist_Divide]);
    
    
    guidata(hObject,handles);
    clear para2_hist_tick Para2_Lastbin_Center Para2_N Para2_X Histogram_Axis2_XLim;
    
elseif mouse_action == 6
    
    area_start_pos = [0 0];
    mouse_action = 0;
    
    x_range = get(handles.Area_Edge1,'Xdata');
    y_range = get(handles.Area_Edge3,'Ydata');
    x_min = min(x_range);
    x_max = max(x_range);
    y_min = min(y_range);
    y_max = max(y_range);
    
    Current_Epoch_Set = find(Para1_Pop>=x_min & Para1_Pop<=x_max & ...
        Para2_Pop>=y_min & Para2_Pop<=y_max);
    Area_Epochs = Current_Epoch_Set;
    
    total_num = length(Current_Epoch_Set);
    if total_num > 0
        Epoch_Set_Index = 1;
        Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
        
    else
        Epoch_Set_Index = 0;
    end
    set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);
    set(handles.Point_Selection_Toggle,'Value',0);
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.figure,'WindowButtonDownFcn','');
    guidata(hObject,handles);
    Epoch_Update1_Callback(hObject,eventdata,handles);
    
    clear x_range y_range x_min x_max y_min y_max find_index1;
    clear total_num;
elseif mouse_action == 7
    mouse_action = 0;
    
    para2_thres2 = get(handles.Para2_Thres_Bar2,'Ydata');
    
    Para2_Thres2 = para2_thres2(1);
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
    if get(handles.Cont_Sort_Push,'Value')
        Stages = contSort(Stages,Fixed_Points);
    end
    
    Update_Stages(hObject,eventdata,handles);
    
    clear para2_thres2 disp_string;
    
    
end

% --- Executes during object creation, after setting all properties.
function EMG_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function EEG_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EEG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Para1_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Para1_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Para2_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Para2_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Para2_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Para2_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EMG_Start_Freq_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_Start_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function EMG_End_Freq_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_End_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Start_Freq_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function End_Freq_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to End_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Para1_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Para1_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Epoch_Num_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Epoch_Num_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Outputs from this function are returned to the command line.
function varargout = Auto_Score_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;

% --- Executes when user attempts to close figure.
% Clears all variables and deletes object
function figure_CloseRequestFcn(hObject,eventdata,handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Clear_Variables();
delete(hObject);

% Changes the current epoch to the one entered in the epoch num box
function Epoch_Num_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Epoch_Num_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Epoch_Num_Edit as text
%        str2double(get(hObject,'String')) returns contents of Epoch_Num_Edit as a double

global Current_Epoch_Num Last_Epoch_Num;

Current_Epoch_Num = str2num(get(hObject,'String'));

if Current_Epoch_Num < 0 || Current_Epoch_Num > Last_Epoch_Num
    errordlg('Invalid epoch num. Please re-enter.','Epoch Num Error');
    return;
end

Epoch_Update1_Callback(hObject, eventdata, handles);

%Update for when the Current_Epoch_Num is changed
function Epoch_Update1_Callback(hObject, eventdata, handles)

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
set(handles.Point_Epoch_Text,'String', ['Epoch # ' num2str(Current_Epoch_Num)]);

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
guidata(hObject, handles);

clear EEG_to_plot EMG_to_plot time_start time_end;
clear stage plot_color2;
clear x_lim y_lim hobj;

%update for when Stages is changed
function Epoch_Update2_Callback(hObject, eventdata, handles)

global Stages;
global Last_Epoch_Num;
global Para1_Pop Para2_Pop;
global Current_Epoch_Num;

set(handles.output,'pointer','watch');
hobj = findobj(handles.Double_Plot_Axis,'Marker','.');
delete(hobj);
clear hobj;
hobj = findobj(handles.Double_Plot_Axis,'Marker','*');
delete(hobj);
clear hobj;

axes(handles.Double_Plot_Axis);
for i = 1:Last_Epoch_Num
    
    if Stages(i) == 1
        plot_color = [256 180 180]/256;  %pink
        markersize = 6;
        
    elseif Stages(i) == 2
        plot_color = [128 128 256]/256;  %light blue
        markersize = 6;
        
    elseif Stages(i) == 3
        plot_color = [180 256 124]/256;  %light green
        markersize = 6;
        
    elseif Stages(i) == 4
        plot_color = [256 128 256]/256;
        markersize = 6;
    elseif Stages(i) == 5
        plot_color = [0.08 0.8 1];
        markersize = 6;
    elseif Stages(i) == 6
        plot_color = [0.35 0.64 0.4];
        markersize = 6;
    elseif Stages(i) == 0
        plot_color = [64 64 64]/256;  %grey
        markersize = 12;
    elseif Stages(i) == 7
        plot_color = [255 131 47]/256; %light orange
        markersize=12;
    end
    
    plot(Para1_Pop(i),Para2_Pop(i),'Marker','.','MarkerSize',markersize,'Color',plot_color);
    
    clear plot_color markersize;
    
end

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

axes(handles.Double_Plot_Axis);
plot(Para1_Pop(Current_Epoch_Num),Para2_Pop(Current_Epoch_Num),'Marker','*','MarkerSize',12,'LineWidth',1.5,'Color',plot_color2);

set(handles.Current_EEG_Plot,'Color',plot_color2);
set(handles.Current_EMG_Plot,'Color',plot_color2);

if get(handles.Spectrum_Checkbox,'Value') == 1
    
    set(handles.Current_Spectrum_Plot,'Color',plot_color2);
    
end

set(handles.output,'pointer','arrow');
guidata(hObject, handles);


clear stage plot_color2;

%called when the Stage of a single epoch is changed
%changes color of point accordingly and then sets focus to next epoch
function Epoch_Update3_Callback(hObject, eventdata, handles)

global Stages Current_Epoch_Num Last_Epoch_Num;
global Para1_Pop Para2_Pop;
global Choose_Subset_Val Current_Epoch_Set Epoch_Set_Index;

stage = Stages(Current_Epoch_Num);

if stage == 1
    plot_color1 = [256 180 180]/256;
    
elseif stage == 2
    plot_color1 = [128 128 256]/256;
    
elseif stage == 3
    plot_color1 = [180 256 124]/256;
    
elseif stage == 4
    plot_color1 = [256 128 256]/256;
    
elseif stage == 5
    plot_color1 = [0.08 0.8 1];
    
elseif stage == 6
    plot_color1 = [0.35 0.64 0.4];
    
elseif stage == 0
    plot_color1 = [64 64 64]/256;
    
elseif stage == 7
    plot_color1 = [255 131 47]/256;
    
end


hobj = findobj(handles.Double_Plot_Axis,'Marker','.','-and','XData',Para1_Pop(Current_Epoch_Num),'-and','YData',Para2_Pop(Current_Epoch_Num));
if ~isempty(hobj)
    set(hobj,'Color',plot_color1);
else
    axes(handles.Double_Plot_Axis);
    plot(Para1_Pop(Current_Epoch_Num),Para2_Pop(Current_Epoch_Num),'Marker','.','MarkerSize',6,'Color',plot_color1);
end

clear hobj;

readout = get_Readout(Stages);
set(handles.Readout_Num_Text,'String',readout,'Visible','on');
clear readout;

guidata(hObject, handles);

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
end
if ~isempty(Current_Epoch_Set)
    if any(Current_Epoch_Set==Current_Epoch_Num)
        Epoch_Set_Index = find(Current_Epoch_Set==Current_Epoch_Num);
    end
else
    Epoch_Set_Index=0;
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);



Epoch_Update1_Callback(hObject, eventdata, handles);



clear stage plot_color1;

%update for when Para1_Pop or Para2_Pop is changed
function Epoch_Update4_Callback(hObject, eventdata, handles)

global Stages;
global Last_Epoch_Num;
global Para1_Pop Para2_Pop;
global Current_Epoch_Num;
global Para1_XLim Para2_YLim;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;
set(handles.output,'pointer','watch');
hobj = findobj(handles.Double_Plot_Axis,'Marker','.');
delete(hobj);
clear hobj;
hobj = findobj(handles.Double_Plot_Axis,'Marker','*');
delete(hobj);
clear hobj;

set(handles.Para1_Thres_Bar,'XData',[],'YData',[]);
set(handles.Para2_Thres_Bar1,'XData',[],'YData',[]);
set(handles.Para2_Thres_Bar2,'XData',[],'YData',[]);
set(handles.Area_Edge1,'XData',[],'YData',[],'Visible','Off');
set(handles.Area_Edge2,'XData',[],'YData',[],'Visible','Off');
set(handles.Area_Edge3,'XData',[],'YData',[],'Visible','Off');
set(handles.Area_Edge4,'XData',[],'YData',[],'Visible','Off');


axes(handles.Double_Plot_Axis);
for i = 1:Last_Epoch_Num
    
    if Stages(i) == 1
        plot_color = [256 180 180]/256;  %pink
        markersize = 6;
        
    elseif Stages(i) == 2
        plot_color = [128 128 256]/256;  %light blue
        markersize = 6;
        
    elseif Stages(i) == 3
        plot_color = [180 256 124]/256;  %light green
        markersize = 6;
        
    elseif Stages(i) == 4
        plot_color = [256 128 256]/256;
        markersize = 6;
        
    elseif Stages(i) == 5
        plot_color = [0.08 0.8 1];
        markersize = 6;
        
    elseif Stages(i) == 6
        plot_color = [0.35 0.64 0.4];
        markersize = 6;
        
    elseif Stages(i) == 0
        plot_color = [64 64 64]/256;  %grey
        markersize = 12;
        
    elseif Stages(i) == 7
        plot_color = [255 131 47]/256; %light orange
        markersize=12;
    end
    plot(Para1_Pop(i),Para2_Pop(i),'Marker','.','MarkerSize',markersize,'Color',plot_color);
    
    clear plot_color markersize;
    
end


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

axes(handles.Double_Plot_Axis);
plot(Para1_Pop(Current_Epoch_Num),Para2_Pop(Current_Epoch_Num),'Marker','*','MarkerSize',12,'LineWidth',1.5,'Color',plot_color2);


set(handles.Double_Plot_Axis,'XLimMode','Auto','XTickMode','Auto','YLimMode','Auto','YTickMode','Auto');


Para1_XLim = get(handles.Double_Plot_Axis,'XLim');
Para1_XTick = get(handles.Double_Plot_Axis,'XTick');
Para1_XTickLabel = get(handles.Double_Plot_Axis,'XTickLabel');

Para2_YLim = get(handles.Double_Plot_Axis,'YLim');
Para2_YTick = get(handles.Double_Plot_Axis,'YTick');
Para2_YTickLabel = get(handles.Double_Plot_Axis,'YTickLabel');


set(handles.Para1_Thres_Bar,'XData',[Para1_Thres Para1_Thres],'YData',Para2_YLim);
set(handles.Para2_Thres_Bar1,'XData',[Para1_XLim(1) Para1_Thres],'YData',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar2,'XData',[Para1_Thres Para1_XLim(2)],'YData',[Para2_Thres2 Para2_Thres2]);



Para1_Hist_Divide = 0.7*(Para1_XLim(2) - Para1_XLim(1)) + Para1_XLim(1);
Para2_Hist_Divide = 0.7*(Para2_YLim(2) - Para2_YLim(1)) + Para2_YLim(1);

Para1_Lastbin_Center = (Para1_Hist_Divide + Para1_XLim(2))/2;
Para2_Lastbin_Center = (Para2_Hist_Divide + Para2_YLim(2))/2;



[Para1_N, Para1_X] = Hist_Calc(Para1_Pop,Para1_Hist_Divide,Para1_Lastbin_Center,20);
[Para2_N, Para2_X] = Hist_Calc(Para2_Pop,Para2_Hist_Divide,Para2_Lastbin_Center,20);

set(handles.Para1_Hist_Bar,'XData',Para1_X,'YData',Para1_N);
set(handles.Para1_Thres_Bar_Hist,'XData',[],'YData',[]);
set(handles.Para1_Hist_Tick,'XData',[],'YData',[]);

set(handles.Para2_Hist_Bar,'XData',Para2_X,'YData',Para2_N);
set(handles.Para2_Thres_Bar_Hist1,'XData',[],'YData',[]);
set(handles.Para2_Thres_Bar_Hist2,'XData',[],'YData',[]);
set(handles.Para2_Hist_Tick,'XData',[],'YData',[]);

set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');

set(handles.Histogram_Axis1,'XLimMode','Manual','XLim',Para1_XLim,'XTickMode','Manual','XTick',Para1_XTick,'XTickLabel',Para1_XTickLabel);
set(handles.Histogram_Axis1,'YLimMode','Auto','YTickMode','Auto');

Histogram_Axis1_YLim = get(handles.Histogram_Axis1,'YLim');
set(handles.Para1_Thres_Bar_Hist,'XData',[Para1_Thres Para1_Thres],'YData',Histogram_Axis1_YLim);
set(handles.Para1_Hist_Tick,'XData',[Para1_Hist_Divide Para1_Hist_Divide],...
    'YData',[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10]);


set(handles.Histogram_Axis2,'YLimMode','Manual','YLim',Para2_YLim,'YTickMode','Manual','YTick',Para2_YTick,'YTickLabel',Para2_YTickLabel);
set(handles.Histogram_Axis2,'XLimMode','Auto','XTickMode','Auto');


Histogram_Axis2_XLim = get(handles.Histogram_Axis2,'XLim');
set(handles.Para2_Thres_Bar_Hist1,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar_Hist2,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres2 Para2_Thres2]);
set(handles.Para2_Hist_Tick,'XData',[Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10],...
    'YData',[Para2_Hist_Divide Para2_Hist_Divide]);

set(handles.Current_EEG_Plot,'Color',plot_color2);

set(handles.Current_EMG_Plot,'Color',plot_color2);


if get(handles.Spectrum_Checkbox,'Value') == 1
    
    set(handles.Current_Spectrum_Plot,'Color',plot_color2);
    
end
set(handles.output,'pointer','arrow');
guidata(hObject, handles);

clear stage plot_color2;
clear Para1_XTick Para1_XTickLabel;
clear Para2_YTick Para2_YTickLabel;
clear Para1_Lastbin_Center Para2_Lastbin_Center;
clear Para1_N Para1_X Para2_N Para2_X;
clear Histogram_Axis1_YLim Histogram_Axis2_XLim;

% called when the vertical threshold bar is clicked
function Para1_Thres_Bar_Callback(hObject, eventdata, handles)

global mouse_action;
mouse_action = 2;

% called when the threshold bar between waking and REM is clicked
function Para2_Thres_Bar1_Callback(hObject, eventdata, handles)

global mouse_action;
mouse_action = 3;

% called when the threshold bar above NREM is clicked
function Para2_Thres_Bar2_Callback(hObject, eventdata, handles)

global mouse_action;
mouse_action = 7;

% called when the tick mark in the parameter 1 histogram is clicked
function Para1_Hist_Tick_Callback(hObject, eventdata, handles)

global mouse_action;
mouse_action = 4;

% called when the Tick mark in the Parameter 2 histogram is clicked
function Para2_Hist_Tick_Callback(hObject, eventdata, handles)

global mouse_action;
mouse_action = 5;

% --- Executes on slider movement.
% Changes the Y-Scale of the EEG Plot
function EEG_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global EEG_Scale;
global Current_EEG_Scale;

eeg_slider_value = 10 ^ get(hObject, 'Value');

new_EEG_scale = EEG_Scale;

new_EEG_scale(3) = EEG_Scale(3)*eeg_slider_value;
new_EEG_scale(4) = EEG_Scale(4)*eeg_slider_value;

axes(handles.EEG_Axis);
axis(new_EEG_scale);

Current_EEG_Scale = new_EEG_scale;

guidata(hObject,handles);

clear eeg_slider_value new_EEG_scale;

% --- Executes on slider movement.
% Changes the Y-scale of the EMG plot
function EMG_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global EMG_Scale;
global Current_EMG_Scale;


emg_slider_value = 10 ^ (get(hObject, 'Value'));

new_EMG_scale = EMG_Scale;

new_EMG_scale(3) = EMG_Scale(3)*emg_slider_value;
new_EMG_scale(4) = EMG_Scale(4)*emg_slider_value;

axes(handles.EMG_Axis);
axis(new_EMG_scale);
Current_EMG_Scale = new_EMG_scale;

guidata(hObject, handles);

clear emg_slider_value new_EMG_scale;

% --- Executes on button press in Point_Selection_Toggle.
% turns on or off point selection mode 
function Point_Selection_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Point_Selection_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Point_Selection_Toggle

global mouse_action;

h_value = get(hObject,'Value');

if h_value == 1
    mouse_action = 0;
    
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','');
    
    set(handles.figure,'WindowButtonDownFcn','Auto_Score(''Point_Selection_ButtonDown'',gcbo,''eventdata'',guidata(gcbo))');
    
    
    guidata(hObject,handles);
    
    
elseif h_value == 0
    
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.figure,'WindowButtonDownFcn','');
    
    guidata(hObject,handles);
    
end



clear h_value;

% Sets as the mouse button down callback when the point selection toggle is
% on, and allows user to select individual epochs on click
function Point_Selection_ButtonDown(hObject,eventdata,handles)


global Para1_Pop Para2_Pop;
global Current_Epoch_Num;


h_axes = handles.Double_Plot_Axis;
mouse_pos = get(h_axes,'CurrentPoint');


x_lim = get(h_axes,'XLim');
y_lim = get(h_axes,'YLim');


if mouse_pos(1,1) <= x_lim(2) && mouse_pos(1,1) >= x_lim(1) && mouse_pos(1,2) <= y_lim(2) && mouse_pos(1,2) >= y_lim(1)
    
    set(h_axes,'Units','Pixels');
    Pos = get(h_axes,'Position');
    
    set(h_axes,'Units','Normalized');
    x_factor = Pos(3)/(x_lim(2)-x_lim(1));
    y_factor = Pos(4)/(y_lim(2)-y_lim(1));
    
    
    x_dist = (mouse_pos(1,1)-Para1_Pop).*x_factor;  % convert to pixels
    y_dist = (mouse_pos(1,2)-Para2_Pop).*y_factor;  % convert to pixels
    
    dist_vector = sqrt(x_dist.^2 + y_dist.^2);
    [min_dist,min_index] = min(dist_vector);
    if min_dist <= 5  % 5 pixels proximity
        Current_Epoch_Num = min_index;
        disp_string = strcat('Epoch # ',num2str(min_index));
        set(handles.Point_Epoch_Text,'String',disp_string,'Visible','On');
        guidata(hObject, handles);
        Epoch_Update1_Callback(hObject, eventdata, handles);
        
        clear disp_string;
    end
    
    clear Pos x_factor y_factor;
    clear x_dist y_dist dist_vector min_dist min_index;
end

clear h_axes mouse_pos x_lim y_lim;

% Called on Mouse Button Down after Area is selected as the current epoch
% set. Allows creation of an area box. The epochs inside of which are the
% current epoch set. 
function Area_Selection_ButtonDown(hObject,eventdata,handles)

global area_start_pos mouse_action;

h_axes = handles.Double_Plot_Axis;
x_lim = get(h_axes,'XLim');
y_lim = get(h_axes,'YLim');

mouse_pos = get(h_axes,'CurrentPoint');
if mouse_pos(1,1) <= x_lim(2) && mouse_pos(1,1) >= x_lim(1) && mouse_pos(1,2) <= y_lim(2) && mouse_pos(1,2) >= y_lim(1)
    area_start_pos = [mouse_pos(1,1) mouse_pos(1,2)];
    mouse_action = 6;
    
end

clear h_axes x_lim y_lim mouse_pos;

% --- Executes on button press in Next_Push.
% steps 1 epoch forward
function Next_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Next_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Current_Epoch_Num Last_Epoch_Num;

if Current_Epoch_Num < Last_Epoch_Num
    Current_Epoch_Num = Current_Epoch_Num + 1;
    
    Epoch_Update1_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in Prev_Push.
% Steps 1 epoch back
function Prev_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num;

if Current_Epoch_Num > 1
    Current_Epoch_Num = Current_Epoch_Num - 1;
    
    Epoch_Update1_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in Wake_Push.
% Changes the state of the current epoch to Wake (1)
function Wake_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 1;

guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on button press in NREM_Push.
% Changes the state of the current epoch to NREM (2)
function NREM_Push_Callback(hObject, eventdata, handles)
% hObject    handle to NREM_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 2;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on button press in REM_Push.
% Changes the state of the current epoch to REM (3)
function REM_Push_Callback(hObject, eventdata, handles)
% hObject    handle to REM_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 3;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on button press in Wake_Artifact_Push.
% Changes the state of the current epoch to Waking with an Artifact (4)
function Wake_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Wake_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 4;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on button press in NREM_Artifact_Push.
% Changes the state of the current epoch to NREM with an Artifact (5)
function NREM_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to NREM_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 5;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on button press in REM_Artifact_Push.
% Changes the state of the current epoch to REM with an Artifact (6)
function REM_Artifact_Push_Callback(hObject, eventdata, handles)
% hObject    handle to REM_Artifact_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;
Stages(Current_Epoch_Num) = 6;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% Changes the state of the Current Epoch to that of a non-classified
% Artifact (7)
function Artifact_Push_Callback(hObject,eventdata,handles)
global Stages Current_Epoch_Num;
global Fixed_Points;
Fixed_Points(Current_Epoch_Num) = 1;

Stages(Current_Epoch_Num) = 7;
guidata(hObject,handles);
Epoch_Update3_Callback(hObject,eventdata,handles);

% --- Executes on selection change in Para1_Listbox.
% changes which variable is plotted as parameter 1
function Para1_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Para1_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Para1_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Para1_Listbox

global Para1_Pop Para2_Pop EMG_Power;
global EEG_Power EEG_Spectrum Delta_Power;
global Freq_Step;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global fbar_click_pos area_start_pos;
global epoch_dur_history;
global Para1_Type;
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global Sampling_Rate_EEG Sampling_Rate_EMG;
global mouse_action fbar_action;
global Para1_Extra Fixed_Points;


if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end


h_value = get(hObject,'Value');
if h_value == 1
    set(handles.Band_Spectrum_Text1,'Visible','Off');
    set(handles.Band_Spectrum_Text2,'Visible','Off');
    set(handles.Band_Spectrum_Text3,'Visible','Off');
    set(handles.Start_Freq_Edit,'Visible','Off');
    set(handles.End_Freq_Edit,'Visible','Off');
elseif h_value == 2
    set(handles.Band_Spectrum_Text1,'Visible','On');
    set(handles.Band_Spectrum_Text2,'Visible','On');
    set(handles.Band_Spectrum_Text3,'Visible','On');
    set(handles.Start_Freq_Edit,'Visible','On');
    set(handles.End_Freq_Edit,'Visible','On');
end

if h_value ~= Para1_Type
    
    Para1_Type = h_value;
    
    
    if Para1_Type == 1
        Para1_Pop = EEG_Power;
    elseif Para1_Type == 2
        EEG_Band_Start_Freq = str2num(get(handles.Start_Freq_Edit, 'String'));
        
        if EEG_Band_Start_Freq < 0 || EEG_Band_Start_Freq > Sampling_Rate_EEG /2
            errordlg('Invalid EEG start frequency value. Please re-enter.','EEG Start Frequency Error');
            return;
        end
        
        EEG_Band_End_Freq = str2num(get(handles.End_Freq_Edit, 'String'));
        
        if EEG_Band_End_Freq < 0 || EEG_Band_End_Freq > Sampling_Rate_EEG /2
            errordlg('Invalid EEG end frequency value. Please re-enter.','EEG End Frequency Error');
            return;
        end
        
        if EEG_Band_End_Freq <= EEG_Band_Start_Freq
            errordlg('The EEG end frequency has to be bigger than the EEG start frequency. Please re-enter.','EEG Frequency Range Error');
            return;
        end
        
        
        Para1_Pop = Band_Power_Calc(EEG_Spectrum,EEG_Band_Start_Freq,EEG_Band_End_Freq,Freq_Step);
        
    elseif Para1_Type == 3
        Para1_Pop = Delta_Power;
    elseif Para1_Type == 4
        Para1_Pop = max(EEG_Spectrum(1:11,:));
        
    end
    
    
    Para1_Thres = getNREMthresh(Para1_Pop,EMG_Power);
%     tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
%     Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
%     if get(handles.Cont_Sort_Push,'Value')
%         Stages = contSort(Stages,Fixed_Points);
%     end
%     Update_Stages(hObject,eventdata,handles);
    
    set(handles.Para1_Slider,'Value',1);
    set(handles.Para2_Slider,'Value',1);
    
    mouse_action = 0;
    fbar_action = 0;
    
    fbar_click_pos = 0;
    area_start_pos = [0 0];
    
    set(handles.Point_Selection_Toggle,'Value',0);
    set(handles.Point_Epoch_Text,'String','Epoch ##');
    set(handles.figure,'WindowButtonDownFcn','');
    
    
    guidata(hObject,handles);
    Epoch_Update4_Callback(hObject, eventdata, handles);
    
    
    
    
    clear disp_string;
    
    
end

guidata(hObject,handles);
clear h_value;

% calls when the start frequency for the Parameter 1 Frequency band option 
% is changed
function Start_Freq_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Start_Freq_Edit as text
%        str2double(get(hObject,'String')) returns contents of Start_Freq_Edit as a double

global epoch_dur_history;
global Sampling_Rate_EEG;
global Para1_Pop Para2_Pop EMG_Power;
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global Para1_Type;
global EEG_Spectrum Freq_Step;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Fixed_Points;

if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end

Start_Freq = str2num(get(hObject, 'String'));

if Start_Freq < 0 || Start_Freq > Sampling_Rate_EEG /2
    errordlg('Invalid EEG start frequency value. Please re-enter.','EEG Start Frequency Error');
    return;
end

if EEG_Band_Start_Freq ~= Start_Freq
    EEG_Band_Start_Freq = Start_Freq;
    
    if Para1_Type == 2
        Para1_Pop = Band_Power_Calc(EEG_Spectrum,EEG_Band_Start_Freq,EEG_Band_End_Freq,Freq_Step);
        
        Para1_Thres = getNREMthresh(Para1_Pop,EMG_Power);
        tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
        Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
        if get(handles.Cont_Sort_Push,'Value')
            Stages = contSort(Stages,Fixed_Points);
        end
        Update_Stages(hObject,eventdata,handles);
        
        set(handles.Para1_Slider,'Value',1);
        set(handles.Para2_Slider,'Value',1);
        
        
        mouse_action = 0;
        fbar_action = 0;
        fbar_click_pos = 0;
        
        area_start_pos = [0 0];
        
        set(handles.Point_Selection_Toggle,'Value',0);
        set(handles.Point_Epoch_Text,'String','Epoch ##');
        set(handles.figure,'WindowButtonDownFcn','');
        
        
        guidata(hObject,handles);
        Epoch_Update4_Callback(hObject, eventdata, handles);
        
        
        
        
        clear disp_string;
        
    end
end


clear Start_Freq;

% calls when the end frequency for the Parameter 1 Frequency band option 
% is changed
function End_Freq_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to End_Freq_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of End_Freq_Edit as text
%        str2double(get(hObject,'String')) returns contents of End_Freq_Edit as a double

global epoch_dur_history;
global Sampling_Rate_EEG;
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global Para1_Pop Para2_Pop;
global EEG_Spectrum Freq_Step EMG_Power;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Para1_Type Fixed_Points;

if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end


End_Freq = str2num(get(hObject, 'String'));

if End_Freq < 0 || End_Freq > Sampling_Rate_EEG /2
    errordlg('Invalid EEG end frequency value. Please re-enter.','EEG End Frequency Error');
    return;
end

if End_Freq <= EEG_Band_Start_Freq
    errordlg('The EEG end frequency has to be bigger than the EEG start frequency. Please re-enter.','EEG Frequency Range Error');
    return;
end


if EEG_Band_End_Freq ~= End_Freq
    EEG_Band_End_Freq = End_Freq;
    
    if Para1_Type == 2
        Para1_Pop = Band_Power_Calc(EEG_Spectrum,EEG_Band_Start_Freq,EEG_Band_End_Freq,Freq_Step);
        Para1_Thres = getNREMthresh(Para1_Pop,EMG_Power);
        tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
        Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
        if get(handles.Cont_Sort_Push,'Value')
            Stages = contSort(Stages,Fixed_Points);
        end
        Update_Stages(hObject,eventdata,handles);
        
        set(handles.Para1_Slider,'Value',1);
        set(handles.Para2_Slider,'Value',1);
        
        mouse_action = 0;
        fbar_action = 0;
        fbar_click_pos = 0;
        
        area_start_pos = [0 0];
        
        set(handles.Point_Selection_Toggle,'Value',0);
        set(handles.Point_Epoch_Text,'String','Epoch ##');
        set(handles.figure,'WindowButtonDownFcn','');
        
        
        guidata(hObject,handles);
        Epoch_Update4_Callback(hObject, eventdata, handles);
        
        
        
        
        clear disp_string;
        
        
    end
end


clear End_Freq;

% --- Executes on selection change in Para2_Listbox.
% changes which variable is plotted as parameter 2
function Para2_Listbox_Callback(hObject, eventdata, handles)
global epoch_dur_history;
global Sampling_Rate_EMG;
global Para2_Type;

global EMG_Band_Start_Freq EMG_Band_End_Freq;

global Para1_Pop Para2_Pop Para2_Extra;
global EMG_Power EMG_Variance EMG_Amplitude Freq_Step;
global EMG_Spectrum;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Theta_Power Delta_Power;
global Fixed_Points;

if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end


h_value = get(hObject,'Value');

if h_value == 3
    set(handles.EMG_Band_Text1,'Visible','On');
    set(handles.EMG_Band_Text2,'Visible','On');
    set(handles.EMG_Band_Text3,'Visible','On');
    set(handles.EMG_Band_Text4,'Visible','On');
    set(handles.EMG_Start_Freq_Edit,'Visible','On');
    set(handles.EMG_End_Freq_Edit,'Visible','On');
else
    set(handles.EMG_Band_Text1,'Visible','Off');
    set(handles.EMG_Band_Text2,'Visible','Off');
    set(handles.EMG_Band_Text3,'Visible','Off');
    set(handles.EMG_Band_Text4,'Visible','Off');
    set(handles.EMG_Start_Freq_Edit,'Visible','Off');
    set(handles.EMG_End_Freq_Edit,'Visible','Off');
end


if h_value ~= Para2_Type
    
    Para2_Type = h_value;
    
    if Para2_Type == 1
        Para2_Pop = EMG_Power;
    elseif Para2_Type == 2
        Para2_Pop = EMG_Variance;
    elseif Para2_Type == 3
        EMG_Band_Start_Freq = str2num(get(handles.EMG_Start_Freq_Edit, 'String'));
        
        if EMG_Band_Start_Freq < 0 || EMG_Band_Start_Freq > Sampling_Rate_EMG/2
            errordlg('Invalid EMG start frequency value. Please re-enter.','EMG Start Frequency Error');
            return;
        end
        
        EMG_Band_End_Freq = str2num(get(handles.EMG_End_Freq_Edit, 'String'));
        
        if EMG_Band_End_Freq < 0 || EMG_Band_End_Freq > Sampling_Rate_EMG/2
            errordlg('Invalid EMG end frequency value. Please re-enter.','EMG End Frequency Error');
            return;
        end
        
        if EMG_Band_End_Freq <= EMG_Band_Start_Freq
            errordlg('The EMG end frequency has to be bigger than the EMG start frequency. Please re-enter.','EMG Frequency Range Error');
            return;
        end
        
        
        Para2_Pop = Band_Power_Calc(EMG_Spectrum,EMG_Band_Start_Freq,EMG_Band_End_Freq,Freq_Step);
    elseif Para2_Type == 4
        Para2_Pop=EMG_Power./Theta_Power;
    elseif Para2_Type == 5
        Para2_Pop = Para2_Extra;
        
    end
    
    [Para2_Thres1,Para2_Thres2] = getPara2_Thres(Para1_Pop,Para2_Pop,Para1_Thres);
%     tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
%     Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
%     if get(handles.Cont_Sort_Push,'Value')
%         Stages = contSort(Stages,Fixed_Points);
%     end
%     Update_Stages(hObject,eventdata,handles);
    
    set(handles.Para1_Slider,'Value',1);
    set(handles.Para2_Slider,'Value',1);
   
    mouse_action = 0;
    fbar_action = 0;
    fbar_click_pos = 0;
    
    area_start_pos = [0 0];
    
    set(handles.Point_Selection_Toggle,'Value',0);
    set(handles.Point_Epoch_Text,'String','Epoch ##');
    set(handles.figure,'WindowButtonDownFcn','');
    
    
    guidata(hObject,handles);
    Epoch_Update4_Callback(hObject, eventdata, handles);
    
    
    
    
    clear disp_string;
    
    
    
end

guidata(hObject,handles);
clear h_value;

% --- Executes on button press in Export_Push.
% exports the scoring to a .xlsx output file containing the state fo each
% epoch as well as the EEG power for various bandwidths
function Export_Push_Callback(hObject, eventdata, handles)
global File_Name;
global Last_Epoch_Num Stages;
global Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power EEG_Power;
global EEG_Spectrum Freq_Step Sampling_Rate_EEG Sampling_Rate_EMG EMG_Power;

[File_Path, Filename_Common, Ext] = fileparts(File_Name);
if ~exist(File_Path,'dir')
    File_Path = pwd;
end
Save_Filename = strcat(File_Path, filesep, Filename_Common, '_Sorted.xlsx' );

data_out = [(1:Last_Epoch_Num)' (Stages)' (EMG_Power)' (EEG_Power)' (Delta_Power)' (Theta_Power)' (Spindle_Power)' (Sigma_Power)' (Gamma_Power)'];
data_out_header = {'Epoch #', 'State','EMG Power','EEG Power', 'Delta', 'Theta', 'Spindle', 'Sigma', 'Gamma'};

% begin Mi

for i = 0:min([100,Sampling_Rate_EEG/2])-1
    data_out_header(i+10) = {strcat(int2str(i), '-', int2str(i+1), 'Hz')};
    Freq_Power = Band_Power_Calc(EEG_Spectrum,i,i+.5,Freq_Step);
    data_out(:,i+10) = (Freq_Power');
end


% end Mi

data_out_final(1,:) = data_out_header;
data_out_final(2:1+Last_Epoch_Num,:) = num2cell(data_out);
status = xlswrite(Save_Filename,data_out_final);

if status == 0
    errordlg('The output file has not been generated successfully.','Output File Failure');
    return;
end

clear File_Path Filename_Common Ext Save_Filename;
clear data_out data_out_header data_out_final status

% --- Executes on slider movement.
% changes the scale of the Parameter 1 histogram and Parameter 1 Axis on
% the plot
function Para1_Slider_Callback(hObject, eventdata, handles)
global Para1_XLim;

h_value = get(hObject,'Value');
if h_value == 0
    h_value = 0.005;
end
new_xlim(1) = Para1_XLim(1);
new_xlim(2) = h_value*(Para1_XLim(2)-Para1_XLim(1)) + Para1_XLim(1);
set(handles.Double_Plot_Axis,'XLimMode','Manual','XLim',new_xlim,'XTickMode','Auto');
x_tick = get(handles.Double_Plot_Axis,'XTick');
x_ticklabel = get(handles.Double_Plot_Axis,'XTickLabel');

set(handles.Histogram_Axis1,'XLimMode','Manual','XLim',new_xlim,'XTickMode','Manual','XTick',x_tick,'XTickLabel',x_ticklabel);

guidata(hObject,handles);
clear h_value new_xlim x_tick x_ticklabel;

% --- Executes on slider movement.
% changes the scale of the Parameter 2 histogram and Parameter 2 Axis on
% the plot
function Para2_Slider_Callback(hObject, eventdata, handles)
global Para2_YLim;

h_value = get(hObject,'Value');
if h_value == 0
    h_value = 0.005;
end
new_ylim(1) = Para2_YLim(1);
new_ylim(2) = h_value*(Para2_YLim(2)-Para2_YLim(1)) + Para2_YLim(1);
set(handles.Double_Plot_Axis,'YLimMode','Manual','YLim',new_ylim,'YTickMode','Auto');
y_tick = get(handles.Double_Plot_Axis,'YTick');
y_ticklabel = get(handles.Double_Plot_Axis,'YTickLabel');
set(handles.Histogram_Axis2,'YLimMode','Manual','YLim',new_ylim,'YTickMode','Manual','YTick',y_tick,'YTickLabel',y_ticklabel);

guidata(hObject,handles);
clear h_value new_ylim y_tick y_ticklabel;

% calls when the start frequency for the Parameter 2 Frequency band option is
% changed
function EMG_Start_Freq_Edit_Callback(hObject, eventdata, handles)
global epoch_dur_history;
global Para2_Type;
global EMG_Band_Start_Freq EMG_Band_End_Freq;
global Sampling_Rate_EMG;
global Para1_Pop Para2_Pop;
global EMG_Spectrum Freq_Step;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Fixed_Points;


if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end

Start_Freq = str2num(get(hObject, 'String'));

if Start_Freq < 0 || Start_Freq > Sampling_Rate_EMG/2
    errordlg('Invalid EMG start frequency value. Please re-enter.','EMG Start Frequency Error');
    return;
end

if EMG_Band_Start_Freq ~= Start_Freq
    EMG_Band_Start_Freq = Start_Freq;
    
    if Para2_Type == 3
        Para2_Pop = Band_Power_Calc(EMG_Spectrum,EMG_Band_Start_Freq,EMG_Band_End_Freq,Freq_Step);
        
        [Para2_Thres1,Para2_Thres2] = getPara2_Thres(Para1_Pop,Para2_Pop,Para1_Thres);
        tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
        Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
        if get(handles.Cont_Sort_Push,'Value')
            Stages = contSort(Stages,Fixed_Points);
        end
        Update_Stages(hObject,eventdata,handles);
        
        set(handles.Para1_Slider,'Value',1);
        set(handles.Para2_Slider,'Value',1);
         
        mouse_action = 0;
        fbar_action = 0;
        fbar_click_pos = 0;
        
        area_start_pos = [0 0];
        
        set(handles.Point_Selection_Toggle,'Value',0);
        set(handles.Point_Epoch_Text,'String','Epoch ##');
        set(handles.figure,'WindowButtonDownFcn','');
        
        guidata(hObject,handles);
        Epoch_Update4_Callback(hObject, eventdata, handles);
        
        clear disp_string;
        
    end
end


clear Start_Freq;

% calls when the end frequency for the Parameter 2 Frequency band option is
% changed
function EMG_End_Freq_Edit_Callback(hObject, eventdata, handles)
global epoch_dur_history;
global Sampling_Rate_EMG;
global Para2_Type;
global EMG_Band_Start_Freq EMG_Band_End_Freq;
global Para1_Pop Para2_Pop;
global EMG_Spectrum Freq_Step;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Stages;
global mouse_action fbar_action;
global fbar_click_pos area_start_pos;
global Fixed_Points;

if epoch_dur_history == 0
    errordlg('Please enter the epoch duration first.','Unspecified Epoch Duration Error');
    return;
end

End_Freq = str2num(get(hObject, 'String'));

if End_Freq < 0 || End_Freq > Sampling_Rate_EMG/2
    errordlg('Invalid EMG end frequency value. Please re-enter.','EMG End Frequency Error');
    return;
end

if End_Freq <= EMG_Band_Start_Freq
    errordlg('The EMG end frequency has to be bigger than the EMG start frequency. Please re-enter.','EMG Frequency Range Error');
    return;
end

if EMG_Band_End_Freq ~= End_Freq
    EMG_Band_End_Freq = End_Freq;    
    if Para2_Type == 3
        Para2_Pop = Band_Power_Calc(EMG_Spectrum,EMG_Band_Start_Freq,EMG_Band_End_Freq,Freq_Step);
        [Para2_Thres1,Para2_Thres2] = getPara2_Thres(Para1_Pop,Para2_Pop,Para1_Thres);
        tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
        Stages(~Fixed_Points) = tmpStages(~Fixed_Points);
        if get(handles.Cont_Sort_Push,'Value')
            Stages = contSort(Stages,Fixed_Points);
        end
        Update_Stages(hObject,eventdata,handles);
        set(handles.Para1_Slider,'Value',1);
        set(handles.Para2_Slider,'Value',1);        
        mouse_action = 0;
        fbar_action = 0;
        fbar_click_pos = 0;        
        area_start_pos = [0 0];        
        set(handles.Point_Selection_Toggle,'Value',0);
        set(handles.Point_Epoch_Text,'String','Epoch ##');
        set(handles.figure,'WindowButtonDownFcn','');
        guidata(hObject,handles);
        Epoch_Update4_Callback(hObject, eventdata, handles);        
        clear disp_string;                
    end
end
clear End_Freq;

% --- Executes on button press in Spectrum_Checkbox.
function Spectrum_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Spectrum_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Spectrum_Checkbox

global Freq_Step;
global Disp_Start_Freq Disp_End_Freq;
global EEG_Spectrum Current_Epoch_Num;

h_value = get(hObject,'Value');
if h_value == 0
    delete(handles.Current_Spectrum_Plot);
elseif h_value == 1
    
    plot_color = get(handles.Current_EEG_Plot,'Color');
    
    Start_Index = floor(Disp_Start_Freq/Freq_Step + 1);
    End_Index = ceil(Disp_End_Freq/Freq_Step + 1);
    
    EEG_spectrum_to_plot = EEG_Spectrum(Start_Index:End_Index,Current_Epoch_Num);
    
    Freq_Axis = (Start_Index-1)*Freq_Step:Freq_Step:(End_Index-1)*Freq_Step;
    
    axes(handles.Spectrum_Axis);
    handles.Current_Spectrum_Plot = plot(Freq_Axis, EEG_spectrum_to_plot,'Color',plot_color,'LineWidth',2,'Parent',handles.Spectrum_Axis);
    xtick_vector = [Disp_Start_Freq round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)/3)...
        round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)*2/3) Disp_End_Freq];
    set(handles.Spectrum_Axis,'XGrid','On');
    set(handles.Spectrum_Axis,'XLimMode','Manual','XLim',[Disp_Start_Freq Disp_End_Freq],'XTickMode','Manual','XTick',xtick_vector,'XTickLabel',xtick_vector);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    
    clear plot_color Start_Index End_Index EEG_spectrum_to_plot Freq_Axis xtick_vector;
    
end

guidata(hObject,handles);

clear h_value;

% --- Executes on key press with focus on figure or any of its controls.
function figure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global Current_Epoch_Num Last_Epoch_Num;

if isempty(Current_Epoch_Num)
    return;
end

if strcmp(eventdata.Key,'leftarrow') == 1
    if Current_Epoch_Num > 1
        Current_Epoch_Num = Current_Epoch_Num - 1;
        
        Epoch_Update1_Callback(hObject, eventdata, handles);
    end
elseif strcmp(eventdata.Key,'rightarrow') == 1
    if Current_Epoch_Num < Last_Epoch_Num
        Current_Epoch_Num = Current_Epoch_Num + 1;
        
        Epoch_Update1_Callback(hObject, eventdata, handles);
    end
    
end

%---Executes whenever Stages is changed.
% this produces the text for the Epoch statistics readout box
function [readout] = get_Readout(Stages)

vals = [length(Stages), sum(Stages==1), sum(Stages==2), sum(Stages==3),...
    sum(Stages==0),sum(Stages==4), sum(Stages==5), sum(Stages==6), sum(Stages==7)]';
strVals = int2str(vals);
strVals = strjust(strVals,'left');
readout = char(strVals(1,:),strVals(2,:),strVals(3,:),strVals(4,:),...
    strVals(5,:),' ',strVals(6,:),' ',strVals(7,:),' ',strVals(8,:),' ',strVals(9,:));

% this produces two plots. One containing the average EMG spectra for each
% State and one containig the average EEG spectra for each State. (REM,
% Waking, NREM and Artifacts).
function Show_Spectra_Push_Callback(hObject,eventdata,handles)
global Stages EEG_fTag EMG_fTag File_Name;
global EEG_Spectrum EMG_Spectrum EEG_Freq_Axis EMG_Freq_Axis;
file = File_Name(find(File_Name==filesep,1,'last')+1:find(File_Name=='.',1,'last')-1);
q = questdlg('Would you like the mean spectra or the sum spectra?','Spectra Type','Mean','Sum',{'Sum'});
if strcmp(q,'Mean')
    h1 = figure(1);
    artifacts = find((Stages>3)+(Stages==0));
    wake = find(Stages==1);
    REM = find(Stages==3);
    NREM = find(Stages==2);
    plot(EMG_Freq_Axis,mean(EMG_Spectrum(:,artifacts),2),'k')
    hold on
    plot(EMG_Freq_Axis,mean(EMG_Spectrum(:,wake),2),'r')
    plot(EMG_Freq_Axis,mean(EMG_Spectrum(:,NREM),2),'b')
    plot(EMG_Freq_Axis,mean(EMG_Spectrum(:,REM),2),'g')
    xlabel('Frequency (Hz)')
    ylabel('EMG Power')
    title({'Mean EMG Power Spectrum for each state',EMG_fTag,file})
    legend('Artifacts','Waking','NREM','REM');
    hold off
    
    h2 = figure(2);
    plot(EEG_Freq_Axis,mean(EEG_Spectrum(:,artifacts),2),'k')
    hold on
    plot(EEG_Freq_Axis,mean(EEG_Spectrum(:,wake),2),'r')
    plot(EEG_Freq_Axis,mean(EEG_Spectrum(:,NREM),2),'b')
    plot(EEG_Freq_Axis,mean(EEG_Spectrum(:,REM),2),'g')
    xlabel('Frequency (Hz)')
    ylabel('EEG Power')
    title({'Mean EEG Power Spectrum for each state',EEG_fTag,file})
    legend('Artifacts','Waking','NREM','REM');
    xlim([0 65])
    hold off

elseif strcmp(q,'Sum')
    h1 = figure(1);
    artifacts = find((Stages>3)+(Stages==0));
    wake = find(Stages==1);
    REM = find(Stages==3);
    NREM = find(Stages==2);
    plot(EMG_Freq_Axis,sum(EMG_Spectrum(:,artifacts),2),'k')
    hold on
    plot(EMG_Freq_Axis,sum(EMG_Spectrum(:,wake),2),'r')
    plot(EMG_Freq_Axis,sum(EMG_Spectrum(:,NREM),2),'b')
    plot(EMG_Freq_Axis,sum(EMG_Spectrum(:,REM),2),'g')
    plot(EMG_Freq_Axis,sum(EMG_Spectrum,2),'c')
    xlabel('Frequency (Hz)')
    ylabel('EMG Power')
    title({'Cumulative EMG Power Spectrum for each state',EMG_fTag,file})
    legend('Artifacts','Waking','NREM','REM','All');
    hold off
    
    h2 = figure(2);
    plot(EEG_Freq_Axis,sum(EEG_Spectrum(:,artifacts),2),'k')
    hold on
    plot(EEG_Freq_Axis,sum(EEG_Spectrum(:,wake),2),'r')
    plot(EEG_Freq_Axis,sum(EEG_Spectrum(:,NREM),2),'b')
    plot(EEG_Freq_Axis,sum(EEG_Spectrum(:,REM),2),'g')
    plot(EEG_Freq_Axis,sum(EEG_Spectrum,2),'c')
    xlabel('Frequency (Hz)')
    ylabel('EEG Power')
    title({'Cumulative EEG Power Spectrum for each state',EEG_fTag,file})
    legend('Artifacts','Waking','NREM','REM','All');
    xlim([0 65])
    hold off
else
    return;
end
% this allows you to notch or high-pass filter either the EMG or EEG data
% at any frequency you want. 
function Filter_Data_Push_Callback(hObject,eventdata,handles)
global Ori_EMG Ori_EEG Sampling_Rate_EEG Sampling_Rate_EMG;
global EEG_fTag EMG_fTag auto_thres;
set(hObject,'String','Busy...','Enable','off');
guidata(hObject,handles);
c1 = questdlg('Filter EMG or EEG Data?','Choose Data to Filter','EMG','EEG','Cancel','Cancel');
switch c1
    case 'Cancel'
        set(hObject,'String','Filter Data','Enable','on');
        guidata(hObject,handles);
        return
    case 'EMG'
        fdat = Ori_EMG;
        srate = Sampling_Rate_EMG;
    case 'EEG'
        fdat = Ori_EEG;
        srate = Sampling_Rate_EEG;
end
c2 = questdlg('Filter Type?','Choose Filter Type','High-Pass','Notch','Cancel','Cancel');
set(handles.output,'pointer','watch');
if strcmp(c2,'Cancel')
    set(hObject,'String','Filter Data','Enable','on');
    guidata(hObject,handles);
    return
end
if strcmp(c2,'High-Pass')
    x = inputdlg('Cutoff Frequency (Hz): ','High-Pass Filter');
    w0 = str2num(x{:});
    outDat = hpf(fdat,srate,w0);
    tag = sprintf('HPF: %g Hz; ',w0);
    clear x w0;
    
else
    x = inputdlg({'Lower Cutoff (Hz):','Upper Cutoff (Hz):'},'Notch Filter Bounds');
    w1 = str2num(x{1});
    w2 = str2num(x{2});
    outDat = notchFilter(fdat,srate,w1,w2);
    tag = sprintf('Notch: %g-%g Hz; ',w1,w2);
    clear x w1 w2;
end
switch c1
    case 'EMG'
        Ori_EMG = outDat;
        if strcmp(EMG_fTag,'Unfiltered')
            EMG_fTag = tag;
        else
            EMG_fTag = [EMG_fTag tag];
        end
    case 'EEG'
        Ori_EEG = outDat;
        if strcmp(EEG_fTag,'Unfiltered')
            EEG_fTag = tag;
        else
            EEG_fTag = [EEG_fTag tag];
        end
end
clear c1 c2 outDat fDat tag;
set(handles.output,'pointer','arrow');
set(handles.EEG_Text,'String',['EEG: ' EEG_fTag]);
set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
auto_thres = 0;
Epoch_Dur_Edit_Callback(handles.Epoch_Dur_Edit,eventdata, handles);
set(hObject,'String','Filter Data','Enable','on');

% This restores the data to the original data from the initial .txt or .1eg
% file. 
function Restore_Data_Push_Callback(hObject,eventdata,handles)
global Ori_EEG Ori_EMG Base_EEG Base_EMG;
global EEG_fTag EMG_fTag;

set(hObject,'String','Busy...','Enable','off');
guidata(hObject,handles);

c1 = questdlg('Restore Original Data?','Restore Data','EEG','EMG','Cancel','Cancel');
switch c1
    case 'Cancel'
        set(hObject,'String','Restore Data','Enable','on');
        guidata(hObject,handles);
        return;
    case 'EEG'
        Ori_EEG = Base_EEG;
        EEG_fTag = 'Unfiltered';
    case 'EMG'
        Ori_EMG = Base_EMG;
        EMG_fTag = 'Unfiltered';
end

set(handles.EEG_Text,'String',['EEG: ' EEG_fTag]);
set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
Epoch_Dur_Edit_Callback(handles.Epoch_Dur_Edit,eventdata, handles);
set(hObject,'String','Restore Data','Enable','on');

% this executes a rudimentary function to identify the spikes in EMG data
% in the current epoch that are most likely due to EKG interference, and
% then determine the frequency of these spikes and remove all sample points
% most likely containing significant EKG contamination from the data. This
% algorithm currently does not work well and results in a significant loss
% of data. 
function Analyze_EKG_Push_Callback(hObject,eventdata,handles)
global Current_Epoch_Num Ori_EMG EMG_By_Epoch;
global Sampling_Rate_EEG Sampling_Rate_EMG Epoch_Dur File_Name;
global Last_Epoch_Num EMG_Freq_Axis EMG_Spectrum Stages;
global EEG_Power EMG_Power EMG_fTag;
global auto_thres;

set(hObject,'String','Busy...','Enable','off');

file = File_Name(find(File_Name==filesep,1,'last')+1:find(File_Name=='.',1,'last')-1);
c = questdlg('Is the currently selected Epoch the one you want to base your EKG on?');

switch c
    case 'Cancel'
        set(hObject,'String','Analyze EKG','Enable','on');
        guidata(hObject,handles);
        return;
    case 'No'
        msgbox('Please use "Select a Point" to choose the correct Epoch.');
        set(hObject,'String','Analyze EKG','Enable','on');
        guidata(hObject,handles);
        return;
    case 'Yes'
        x1 = EMG_By_Epoch(:,Current_Epoch_Num);
end
guidata(hObject,handles);

fig1 = figure;
time = 1:1/Sampling_Rate_EMG:11;
time = time(2:end);
plot(time,x1)
xlabel('Time (Sec)')
ylabel('Amplitude')
title({'EMG: 2 Second Window',sprintf('Epoch #%i',Current_Epoch_Num),file})
grid on
xlim([2 4])
thresh = inputdlg('Enter Threshold for R-Peaks:','Choose peak threshold');
thresh = str2num(thresh{:});
close(fig1);

set(handles.output,'pointer','watch');

EKG = extrapolateEKG(Ori_EMG,x1,thresh,Current_Epoch_Num,Sampling_Rate_EMG,Epoch_Dur);


EMG2 = Ori_EMG-EKG;
EMG2 = EMG2( 1 : Last_Epoch_Num * Sampling_Rate_EMG * Epoch_Dur );
EMG2_By_Epoch = reshape(EMG2, Sampling_Rate_EMG * Epoch_Dur, []);
[EMG2_Spectrum, EMG2_Freq_Axis] = FFT_Calc(EMG2_By_Epoch, Sampling_Rate_EMG);
EMG2_Power = sum(EMG2_Spectrum);

P1T = getNREMthresh(EEG_Power,EMG_Power);
[P2T1,P2T2] = getPara2_Thres(EEG_Power,EMG2_Power,P1T);
Stages2 = Sorting(EEG_Power,EMG2_Power,P1T,P2T1,P2T2);
[EKG_Spec EKG_Freq] = FFT_Calc(EKG,Sampling_Rate_EMG);
set(handles.output,'pointer','arrow');

figure
time = (1:length(EKG))/Sampling_Rate_EMG;
plot(time,EKG)
xlim([4 10])
title({'Extrapolated EKG',file})
xlabel('Time (Sec)')
ylabel('Amplitude')

figure
plot(EKG_Freq,EKG_Spec)
title({'EKG Power Spectrum',file})
xlabel('Frequency (Hz)')
ylabel('Power')

figure
plot(EMG_Freq_Axis,mean(EMG_Spectrum,2),'r')
hold on
plot(EMG2_Freq_Axis,mean(EMG2_Spectrum,2),'g')
legend('EMG + EKG','EMG w/o EKG')
hold off
title({'Mean EMG Spectrum with and without EKG','Iowa1'})
xlabel('Frequency (Hz)')
ylabel('Power')

Ori_EMG = Ori_EMG-EKG;
if ~strcmp(EMG_fTag,'Unfiltered');
    EMG_fTag = [EMG_fTag 'EKG Removed; '];
else
    EMG_fTag = 'EKG Removed; ';
end

set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
auto_thres = 0;
Epoch_Dur_Edit_Callback(handles.Epoch_Dur_Edit,eventdata, handles);

set(hObject,'String','Analyze EKG','Enable','On');

% --- Executes on button press in Expand_View_Push.
% this creates a pop-up that displays the EEG and EMG for the current epoch
% as well the epochs to either side. While in this pop-up, you can scroll
% through epochs and score them, and even change the view to view only a
% single epoch.
function Expand_View_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Expand_View_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global EEG EMG Stages Epoch_Dur Sampling_Rate Current_Epoch_Num

set(hObject,'Enable','off');
try
    h = expandedEpochPlot(handles.output,get(handles.Validate_Sorting_Toggle,'Value'));
    handles.Expanded_Window = h;
    waitfor(h);
catch exc
    disp(getReport(exc));
end
set(hObject,'Enable','on');
guidata(hObject,handles);
Focus_Gained_Callback(hObject,eventdata,handles);

% This controls the continuity sort toggle. The toggle is generally on and
% makes it so that continuity rules are applied to all sorting (movement of
% threshold bars, etc.). When the toggle is off, the continuity sort is no
% longer applied.
function Cont_Sort_Push_Callback(hObject,eventdata,handles)
global Stages Fixed_Points;
val = get(hObject,'Value');
if val
    Stages = contSort(Stages,Fixed_Points);
    Update_Stages(hObject,eventdata,handles);
end

% --- Executes during object creation, after setting all properties.
function Epoch_Dur_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Epoch_Dur_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% this uses a number of markers to determine which epochs are most likely
% to contain artifacts. This marks about 10% of the epochs as artifacts
function Find_EEG_Artifacts_Push_Callback(hObject,eventdata,handles)
global Stages EEG_By_Epoch Sampling_Rate_EEG Sampling_Rate_EMG;
set(handles.Find_EEG_Artifacts_Push,'Enable','off','String','Busy...');
set(handles.output,'pointer','watch');
p=0.05;
%p is criteria for the artifact removal algorithm that determines the
%percent of epochs to mark as artifacts.
%a p of 0.05 returns just under 10% of the total epochs as artifacts
%this subset includes almost all EEG Artifacts but can have many false
%positives and must be checked by human inspection.
%with P=0.05, The current algorithm returns the top 5% of points most
%likely to have artifacts characterized by variance, and the top 5% of
%points most likely to have artifacts charactized by large range.
[ret Stages] = markEEGArtifacts(EEG_By_Epoch,Stages,1,p,Sampling_Rate_EEG);

set(handles.Find_EEG_Artifacts_Push,'Enable','on','String','Find EEG Artifacts');
set(handles.output,'pointer','arrow');
Update_Stages(hObject,eventdata,handles);

% this sorts the data simply based on the threshold bars without applying
% any continuity rules, Everything in the bottom-left is REM, top-left is
% wake, bottom- right is NREM and top-right is unsorted
function Simple_Sort_Push_Callback(hObject,eventdata,handles)
global Stages Para1_Pop Para2_Pop Para1_Thres Para2_Thres1 Para2_Thres2;
global Fixed_Points;

Stages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
Fixed_Points = Stages*0;
set(handles.Cont_Sort_Push,'Value',0);
Update_Stages(hObject,eventdata,handles);

%called every time stages is changed, this carries out anything that needs
%to be done before Epoch_Update2_Callback is called
function Update_Stages(hObject,eventdata,handles)
global Stages Choose_Subset_Val Epoch_Set_Index Current_Epoch_Set;

readout = get_Readout(Stages);
set(handles.Readout_Num_Text,'String',readout,'Visible','on');
clear readout;
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
end
if ~isempty(Current_Epoch_Set)
    Epoch_Set_Index = 1;
else
    Epoch_Set_Index = 0;
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

if ~isrow(Stages)
    Stages = Stages';
end

Epoch_Update2_Callback(hObject,eventdata,handles);
guidata(hObject,handles);

% Uses simple local minima finding algorithms to automatically adjust the
% threshold bars. This is not very accurate but can help give some idea
% where to set the thresholds
function Auto_Adjust_Thres_Push_Callback(hObject,eventdata,handles)
global Stages Para1_Pop Para2_Pop Para1_Thres Para2_Thres1 Para2_Thres2;
global EMG_Power Delta_Power Theta_Power EEG_Power EMG_Variance EEG_By_Epoch;
global Para1_Type Para2_Type Fixed_Points;

sortQuest = questdlg('Would you like the Neural Network to sort the epochs or just set the thresholds?','Neural Net Sort','Sort','Set Thresholds',{'Sort'});


set(handles.Para1_Listbox,'Value',1);
set(handles.Para2_Listbox,'Value',5);
Para1_Type = 1;
Para2_Type = 5;
Para1_Pop = EEG_Power;
Para2_Pop = (Delta_Power.*EMG_Power)./(Theta_Power.^2);
% y2 = 1./Para2_Pop;

% load NREM neural net
net = load('NREM_Neural_Net.mat','NNet');
NNet = net.NNet;
NetType = 3;

% make NREM Neural Net Dataset
%----------------------------------
% rest = find(Stages>0 & Stages<=3);
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

[netStages,thresh] = NeuralNetSort(NNet,DataSet,NetType,Para1_Pop(rest));
if isrow(netStages)
	netStages=netStages';
end
Para1_Thres = thresh;

tmpStages = Stages';
tmpStages(rest) = netStages;
arts = find(Stages==0 | Stages>3);
%tmpStages(arts) = tmpStages(arts)-3;
%tmpStages(tmpStages<0) = 0;

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

[netStages,Para2_Thres1] =  NeuralNetREMSort(NNet,netData,tmpStages,rest,Para2_Pop(rest));

Para2_Thres2 = max(Para2_Pop(rest(netStages==2)));

if strcmp(sortQuest,'Sort')
    Stages(rest) = netStages;
else
    tmpStages = Sorting(Para1_Pop,Para2_Pop,Para1_Thres,Para2_Thres1,Para2_Thres2);
    Stages(intersect(find(~Fixed_Points),rest)) = tmpStages(intersect(find(~Fixed_Points),rest));
end


if get(handles.Cont_Sort_Push,'Value')
    Stages = contSort(Stages,Fixed_Points);
end

h_bar = handles.Para1_Thres_Bar;
h_axes = get(h_bar,'Parent');
x_lim = get(h_axes,'XLim');
set(handles.Para1_Thres_Bar,'Xdata',[Para1_Thres Para1_Thres]);
set(handles.Para1_Thres_Bar_Hist,'Xdata',[Para1_Thres Para1_Thres]);
set(handles.Para2_Thres_Bar1,'Xdata',[x_lim(1) Para1_Thres]);
set(handles.Para2_Thres_Bar2,'Xdata',[Para1_Thres x_lim(2)]);

h_bar = handles.Para2_Thres_Bar1;
h_axes = get(h_bar,'Parent');
y_lim = get(h_axes,'YLim');
set(handles.Para2_Thres_Bar1,'Ydata',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar_Hist1,'Ydata',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar2,'Ydata',[Para2_Thres2 Para2_Thres2]);
set(handles.Para2_Thres_Bar_Hist2,'Ydata',[Para2_Thres2 Para2_Thres2])

readout = get_Readout(Stages);
set(handles.Readout_Num_Text,'String',readout,'Visible','on');
clear readout;
guidata(hObject,handles);
Epoch_Update4_Callback(hObject,eventdata,handles);

% --- Executes on button press in Next_Push.
%steps on forward in the current set of epochs
function Next_Set_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Next_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num Epoch_Set_Index Current_Epoch_Set;

if Epoch_Set_Index<length(Current_Epoch_Set)
    Epoch_Set_Index = Epoch_Set_Index+1;
end
if ~isempty(Current_Epoch_Set)
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
else
    Epoch_Set_Index = 0;
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);
Epoch_Update1_Callback(hObject,eventdata,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');

% --- Executes on button press in Prev_Push.
%steps one epoch back in the current set of epochs
function Prev_Set_Push_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_Push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Current_Epoch_Num Epoch_Set_Index Current_Epoch_Set;
if Epoch_Set_Index>1
    Epoch_Set_Index = Epoch_Set_Index-1;
end
if ~isempty(Current_Epoch_Set)
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
else
    Epoch_Set_Index = 0;
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

Epoch_Update1_Callback(hObject,eventdata,handles);
set(hObject,'Enable','off');
drawnow;
set(hObject,'Enable','on');

% --- Executes on selection change in Choose_Subset_Pop.
%handles changing of the current iterable set of epochs
function Choose_Subset_Pop_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_Subset_Pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% contents = cellstr(get(hObject,'String'));% returns Choose_Subset_Pop contents as cell array
% val = contents{get(hObject,'Value')};% returns selected item from Choose_Subset_Pop
global Current_Epoch_Set Epoch_Set_Index Stages Current_Epoch_Num;
global Choose_Subset_Val mouse_action;
global Area_Epochs Para1_Pop Para2_Pop Para1_Thres Para2_Thres1;

choice = get(hObject,'Value');

if Choose_Subset_Val == 7
    set(handles.Area_Edge1,'Visible','Off');
    set(handles.Area_Edge2,'Visible','Off');
    set(handles.Area_Edge3,'Visible','Off');
    set(handles.Area_Edge4,'Visible','Off');
end
if Choose_Subset_Val == 9 && choice~=9
    c1 = get(hObject,'String');
    c1 = c1(1:8);
    set(hObject,'String',c1);
end


switch choice
    case 1 %All
        Current_Epoch_Set = 1:length(Stages);
        Choose_Subset_Val = choice;
        
    case 2 %Wake
        Current_Epoch_Set = find(Stages==1);
        Choose_Subset_Val = choice;
        
    case 3 %NREM
        Current_Epoch_Set = find(Stages==3);
        Choose_Subset_Val = choice;
        
    case 4 %REM
        Current_Epoch_Set = find(Stages==2);
        Choose_Subset_Val = choice;
        
    case 5 %all artifacts
        Current_Epoch_Set = find(Stages>3 | Stages==0);
        Choose_Subset_Val = choice;
        
    case 6 %unsorted
        Current_Epoch_Set = find(Stages==0);
        Choose_Subset_Val = choice;
        
    case 7 %area select
        if ~isempty(Area_Epochs)
            c2 = questdlg('Select New Area?');
            switch c2
                case 'Yes'
                    set(handles.Point_Selection_Toggle,'Value',0);
                    set(handles.Para1_Thres_Bar,'ButtonDownFcn','');
                    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','');
                    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','');
                    set(handles.figure,'WindowButtonDownFcn','Auto_Score(''Area_Selection_ButtonDown'',gcbo,''eventdata'',guidata(gcbo))');
                    guidata(hObject,handles);
                    Choose_Subset_Val = choice;
                    set(hObject,'Enable','off');
                    drawnow;
                    set(hObject,'Enable','on');
                    return;
                case 'No'
                    Current_Epoch_Set = Area_Epochs;
                    Choose_Subset_Val = choice;
                    set(handles.Area_Edge1,'Visible','On');
                    set(handles.Area_Edge2,'Visible','On');
                    set(handles.Area_Edge3,'Visible','On');
                    set(handles.Area_Edge4,'Visible','On');
                    
                case 'Cancel'
                    Choose_Subset_Val = 1;
                    Current_Epoch_Set = 1:length(Stages);
                    set(handles.Choose_Subset_Pop,'Value',1);
                    
            end
        else
            set(handles.Point_Selection_Toggle,'Value',0);
            set(handles.Para1_Thres_Bar,'ButtonDownFcn','');
            set(handles.Para2_Thres_Bar1,'ButtonDownFcn','');
            set(handles.Para2_Thres_Bar2,'ButtonDownFcn','');
            set(handles.figure,'WindowButtonDownFcn','Auto_Score(''Area_Selection_ButtonDown'',gcbo,''eventdata'',guidata(gcbo))');
            guidata(hObject,handles);
            Choose_Subset_Val = choice;
            set(hObject,'Enable','off');
            drawnow;
            set(hObject,'Enable','on');
            return;
        end
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
if isempty(Current_Epoch_Set)
    Epoch_Set_Index = 0;
else
    Epoch_Set_Index=1;
    Current_Epoch_Num = Current_Epoch_Set(Epoch_Set_Index);
end
set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);

Epoch_Update1_Callback(hObject,eventdata,handles);
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

%opens .txt data file (containing a single EEG channel and single EMG
%channel) and loads it into the program for scoring
function Open_Txt_Menu_Callback(hObject,eventdata,handles)
global Sampling_Rate_EEG Sampling_Rate_EMG Ori_EEG Ori_EMG File_Name ;
global auto_thres;
Clear_Variables();
if hObject==handles.Open_Txt_Menu
    Sampling_Rate_EEG = 256;   % Sampling Rate: 256 Hz
    Sampling_Rate_EMG = 256;
else
    Sampling_Rate_EEG = 100;
    Sampling_Rate_EMG = 100;
end

[name_txt, Path_Str] = uigetfile( '.txt', 'Pick a raw data file');
if name_txt==0
    return;
end

File_Name = strcat( Path_Str, name_txt );

[eeg emg] = textread( File_Name, '%f %f', 'headerlines', 6 );
Ori_EEG = eeg;
Ori_EMG = emg;

auto_thres = 1;
load_Raw_Data(hObject,eventdata,handles);

clear name_txt Path_Str eeg emg;

%opens a .1eg data file and loads it into the program for scoring
function Open_1eg_Menu_Callback(hObject,eventdata,handles)
global Sampling_Rate_EEG Sampling_Rate_EMG Ori_EEG Ori_EMG File_Name ;
Clear_Variables();

Sampling_Rate_EEG = 250;
Sampling_Rate_EMG = 250;

[name_txt, Path_Str] = uigetfile( '.1eg', 'Pick a raw data file');
if name_txt==0
    return;
end

File_Name = strcat( Path_Str, name_txt );

fid_1eg = fopen( File_Name , 'r' );

if fid_1eg == -1
    errordlg( 'Can not open the file', 'File Open Error');
    return;
end

% Read 1eg file

eeg = fread( fid_1eg, inf, '500*int16=>double', 1008);
fseek( fid_1eg, 1000, 'bof');
emg = fread( fid_1eg, inf, '500*int16=>double', 1008);
fseek( fid_1eg, 2000, 'bof');

fclose(fid_1eg);
Ori_EEG = eeg;
Ori_EMG = emg;
load_Raw_Data(hObject,eventdata,handles);

clear name_txt Path_Str fid_1eg eeg emg;

%opens and loads a .mat workspace file into the autoscore program. the file
%must have been saved by the program
function Open_Mat_Menu_Callback(hObject,eventdata,handles)

globalVars = who('global');

for i=1:numel(globalVars)
    eval(sprintf('global %s;',globalVars{i},globalVars{i}));
end


Clear_Variables();
[OpenFile Path] = uigetfile('*.mat');
if OpenFile==0
    return;
end
load([Path OpenFile]);
set(handles.Epoch_Dur_Edit,'String',int2str(Epoch_Dur));
set(handles.Para1_Listbox,'Value',Para1_Type);
set(handles.Para2_Listbox,'Value',Para2_Type);
set(handles.File_Name_Text2, 'String', File_Name);
set(handles.EMG_Start_Freq_Edit,'String',EMG_Band_Start_Freq);
set(handles.EMG_End_Freq_Edit,'String',EMG_Band_End_Freq);
set(handles.Start_Freq_Edit,'String',EEG_Band_Start_Freq);
set(handles.End_Freq_Edit,'String',EEG_Band_End_Freq);

mouse_action = 0;
fbar_action = 0;
fbar_click_pos = 0;

area_start_pos = [0 0];

epoch_dur_history = 1;

set(handles.EEG_Text,'String',['EEG: ' EEG_fTag]);
set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
filter_Flag = 0;
set(handles.Epoch_Dur_Edit,'String','10');
compare_sort = 0;
auto_thres=0;
Ext_Stage_Change_Flag = 0;

Initialize_Mat(handles);

%initialization code for the program when loading a .mat workspace file 
function Initialize_Mat(handles)
globalVars = who('global');

for i=1:numel(globalVars)
    eval(sprintf('global %s;',globalVars{i},globalVars{i}));
end
global Fixed_Points;

set(handles.output,'pointer','watch');
if isempty(Fixed_Points) || numel(Fixed_Points)~=Last_Epoch_Num
    Fixed_Points = zeros(1,Last_Epoch_Num);
end

total_dur = Last_Epoch_Num*Epoch_Dur/3600;
disp_string1 = strcat(num2str(Last_Epoch_Num),' (',num2str(total_dur),' hours)');
set(handles.Epoch_Num_Text3,'String',disp_string1);

if epoch_dur_history == 1
    hobj = findobj(handles.Double_Plot_Axis,'Marker','.');
    delete(hobj);
    clear hobj;
    hobj = findobj(handles.Double_Plot_Axis,'Marker','*');
    delete(hobj);
    
    set(handles.Para1_Thres_Bar,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar1,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar2,'XData',[],'YData',[]);
    set(handles.Area_Edge1,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge2,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge3,'XData',[],'YData',[],'Visible','Off');
    set(handles.Area_Edge4,'XData',[],'YData',[],'Visible','Off');
    set(handles.Para1_Slider,'Value',1);
    set(handles.Para2_Slider,'Value',1);
    clear hobj;
end

axes(handles.Double_Plot_Axis);
xlabel('Parameter 1');
ylabel('Parameter 2');
for i = 1:Last_Epoch_Num
    
    if Stages(i) == 1
        plot_color = [256 180 180]/256;  %pink
        markersize = 6;
        
    elseif Stages(i) == 2
        plot_color = [128 128 256]/256;  %light blue
        markersize = 6;
        
    elseif Stages(i) == 3
        
        plot_color = [180 256 124]/256;  %light green
        markersize = 6;
        
    elseif Stages(i) == 4
        
        plot_color = [256 128 256]/256; %light purple
        markersize = 6;
        
    elseif Stages(i) == 5
        plot_color = [0.08 0.8 1]; %cyan
        markersize = 6;
        
    elseif Stages(i) == 6
        plot_color = [0.35 0.64 0.4]; %forest green
        markersize = 6;
        
    elseif Stages(i) == 0
        plot_color = [64 64 64]/256;  %grey
        markersize = 12;
        
    elseif Stages(i) == 7
        plot_color = [255 131 47]/256; %light orange
        markersize = 12;
        
    end
    plot(Para1_Pop(i),Para2_Pop(i),'Marker','.','MarkerSize',markersize,'Color',plot_color);
    
    clear plot_color markersize;
    
    
end


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

axes(handles.Double_Plot_Axis);
plot(Para1_Pop(Current_Epoch_Num),Para2_Pop(Current_Epoch_Num),'Marker','*','MarkerSize',12,'LineWidth',1.5,'Color',plot_color2);

set(handles.Double_Plot_Axis,'XLimMode','Auto','XTickMode','Auto','YLimMode','Auto','YTickMode','Auto');


Para1_XLim = get(handles.Double_Plot_Axis,'XLim');
Para1_XTick = get(handles.Double_Plot_Axis,'XTick');
Para1_XTickLabel = get(handles.Double_Plot_Axis,'XTickLabel');

Para2_YLim = get(handles.Double_Plot_Axis,'YLim');
Para2_YTick = get(handles.Double_Plot_Axis,'YTick');
Para2_YTickLabel = get(handles.Double_Plot_Axis,'YTickLabel');



if epoch_dur_history == 1
    set(handles.Para1_Thres_Bar,'XData',[Para1_Thres Para1_Thres],'YData',Para2_YLim);
    set(handles.Para2_Thres_Bar1,'XData',[Para1_XLim(1) Para1_Thres],'YData',[Para2_Thres1 Para2_Thres1]);
    set(handles.Para2_Thres_Bar2,'XData',[Para1_Thres Para1_XLim(2)],'YData',[Para2_Thres2 Para2_Thres2]);
    
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
else
    axes(handles.Double_Plot_Axis);
    handles.Para1_Thres_Bar = line([Para1_Thres Para1_Thres],Para2_YLim,'Parent',handles.Double_Plot_Axis,...
        'Tag','Para1_Thres_Bar','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para1_Thres_Bar,'ButtonDownFcn','Auto_Score(''Para1_Thres_Bar_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    handles.Para2_Thres_Bar1 = line([Para1_XLim(1) Para1_Thres], [Para2_Thres1 Para2_Thres1],'Parent',handles.Double_Plot_Axis,...
        'Tag','Para2_Thres_Bar1','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Thres_Bar1,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar1_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    handles.Para2_Thres_Bar2 = line([Para1_Thres Para1_XLim(2)], [Para2_Thres2 Para2_Thres2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Para2_Thres_Bar2','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Thres_Bar2,'ButtonDownFcn','Auto_Score(''Para2_Thres_Bar2_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
    
    handles.Area_Edge1 = line([Para1_XLim(1) Para1_Thres/2],[Para2_YLim(1) Para2_YLim(1)],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge1','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge2 = line([Para1_XLim(1) Para1_Thres/2],[Para2_Thres1/2 Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge2','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge3 = line([Para1_XLim(1) Para1_XLim(1)],[Para2_YLim(1) Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge3','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
    handles.Area_Edge4 = line([Para1_Thres/2 Para1_Thres/2],[Para2_YLim(1) Para2_Thres1/2],'Parent',handles.Double_Plot_Axis,...
        'Tag','Area_Edge4','LineWidth',1.2,'Color',[0 0 0],'LineStyle','--','Visible','Off');
end


Para1_Hist_Divide = 0.7*(Para1_XLim(2) - Para1_XLim(1)) + Para1_XLim(1);
Para2_Hist_Divide = 0.7*(Para2_YLim(2) - Para2_YLim(1)) + Para2_YLim(1);

Para1_Lastbin_Center = (Para1_Hist_Divide + Para1_XLim(2))/2;
Para2_Lastbin_Center = (Para2_Hist_Divide + Para2_YLim(2))/2;



[Para1_N, Para1_X] = Hist_Calc(Para1_Pop,Para1_Hist_Divide,Para1_Lastbin_Center,20);
[Para2_N, Para2_X] = Hist_Calc(Para2_Pop,Para2_Hist_Divide,Para2_Lastbin_Center,20);

if epoch_dur_history == 1
    set(handles.Para1_Hist_Bar,'XData',Para1_X,'YData',Para1_N);
    set(handles.Para1_Thres_Bar_Hist,'XData',[],'YData',[]);
    set(handles.Para1_Hist_Tick,'XData',[],'YData',[]);
    
    set(handles.Para2_Hist_Bar,'XData',Para2_X,'YData',Para2_N);
    set(handles.Para2_Thres_Bar_Hist1,'XData',[],'YData',[]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',[],'YData',[]);
    set(handles.Para2_Hist_Tick,'XData',[],'YData',[]);
    
    
else
    axes(handles.Histogram_Axis1);
    handles.Para1_Hist_Bar = bar(Para1_X,Para1_N);
    set(handles.Para1_Hist_Bar,'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'Parent',handles.Histogram_Axis1);
    ylabel('Epoch Count');
    
    axes(handles.Histogram_Axis2);
    handles.Para2_Hist_Bar = barh(Para2_X,Para2_N);
    set(handles.Para2_Hist_Bar,'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'Parent',handles.Histogram_Axis2);
    set(handles.Histogram_Axis2,'XDir','Reverse');
    xlabel('Epoch Count');
    
end


set(handles.Histogram_Axis1,'XLimMode','Manual','XLim',Para1_XLim,'XTickMode','Manual','XTick',Para1_XTick,'XTickLabel',Para1_XTickLabel);
set(handles.Histogram_Axis1,'YLimMode','Auto','YTickMode','Auto');

Histogram_Axis1_YLim = get(handles.Histogram_Axis1,'YLim');


if epoch_dur_history == 1
    set(handles.Para1_Thres_Bar_Hist,'XData',[Para1_Thres Para1_Thres],'YData',Histogram_Axis1_YLim);
    set(handles.Para1_Hist_Tick,'XData',[Para1_Hist_Divide Para1_Hist_Divide],...
        'YData',[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10]);
    
else
    axes(handles.Histogram_Axis1);
    handles.Para1_Thres_Bar_Hist = line([Para1_Thres Para1_Thres],Histogram_Axis1_YLim,'Parent',handles.Histogram_Axis1,...
        'Tag','Para1_Thres_Bar_Hist','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    
    handles.Para1_Hist_Tick = line([Para1_Hist_Divide Para1_Hist_Divide],[Histogram_Axis1_YLim(2) Histogram_Axis1_YLim(2) - (Histogram_Axis1_YLim(2)-Histogram_Axis1_YLim(1))/10],...
        'Parent',handles.Histogram_Axis1,'Tag','Para1_Hist_Tick','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para1_Hist_Tick,'ButtonDownFcn','Auto_Score(''Para1_Hist_Tick_Callback'',gcbo,''eventdata'',guidata(gcbo))');
    
end


set(handles.Histogram_Axis2,'YLimMode','Manual','YLim',Para2_YLim,'YTickMode','Manual','YTick',Para2_YTick,'YTickLabel',Para2_YTickLabel);
set(handles.Histogram_Axis2,'XLimMode','Auto','XTickMode','Auto');

Histogram_Axis2_XLim = get(handles.Histogram_Axis2,'XLim');

if epoch_dur_history == 1
    set(handles.Para2_Thres_Bar_Hist1,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres1 Para2_Thres1]);
    set(handles.Para2_Thres_Bar_Hist2,'XData',Histogram_Axis2_XLim,'YData',[Para2_Thres2 Para2_Thres2]);
    set(handles.Para2_Hist_Tick,'XData',[Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10],...
        'YData',[Para2_Hist_Divide Para2_Hist_Divide]);
else
    
    axes(handles.Histogram_Axis2);
    handles.Para2_Thres_Bar_Hist1 = line(Histogram_Axis2_XLim, [Para2_Thres1 Para2_Thres1],'Parent',handles.Histogram_Axis2,...
        'Tag','Para2_Thres_Bar_Hist1','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    handles.Para2_Thres_Bar_Hist2 = line(Histogram_Axis2_XLim, [Para2_Thres2 Para2_Thres2],'Parent',handles.Histogram_Axis2,...
        'Tag','Para2_Thres_Bar_Hist2','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    
    handles.Para2_Hist_Tick = line([Histogram_Axis2_XLim(2) Histogram_Axis2_XLim(2) - (Histogram_Axis2_XLim(2)-Histogram_Axis2_XLim(1))/10], [Para2_Hist_Divide Para2_Hist_Divide],...
        'Parent',handles.Histogram_Axis2,'Tag','Para2_Hist_Tick','LineWidth',3,'Color',[0 0 0],'LineStyle','-','Visible','On');
    set(handles.Para2_Hist_Tick,'ButtonDownFcn','Auto_Score(''Para2_Hist_Tick_Callback'',gcbo,''eventdata'',guidata(gcbo))');
end


EEG_to_plot = EEG_By_Epoch(:, Current_Epoch_Num);
EMG_to_plot = EMG_By_Epoch(:, Current_Epoch_Num);

time_start = (Current_Epoch_Num - 1) * Epoch_Dur;
time_end = Current_Epoch_Num * Epoch_Dur;

set(handles.Epoch_Num_Edit,'String',num2str(Current_Epoch_Num));

axes(handles.EEG_Axis);
handles.Current_EEG_Plot = plot(EEG_to_plot,'Color',plot_color2,'Parent',handles.EEG_Axis);
axis(Current_EEG_Scale);
set(handles.EEG_Axis, 'XTickMode', 'Manual', 'XTick', 0:2*Sampling_Rate_EEG:Epoch_Dur*Sampling_Rate_EEG, 'XTickLabel',time_start:2:time_end, 'XGrid', 'on','YGrid','On');
xlabel('Time (Seconds)');


axes(handles.EMG_Axis);
handles.Current_EMG_Plot = plot(EMG_to_plot,'Color',plot_color2,'Parent',handles.EMG_Axis);
axis(Current_EMG_Scale);
set(handles.EMG_Axis, 'XTickMode', 'Manual', 'XTick', 0:2*Sampling_Rate_EMG:Epoch_Dur*Sampling_Rate_EMG, 'XTickLabel', time_start:2:time_end, 'XGrid', 'on','YGrid','On');
xlabel('Time (Seconds)');

if get(handles.Spectrum_Checkbox,'Value') == 1
    
    
    Start_Index = floor(Disp_Start_Freq/Freq_Step + 1);
    End_Index = ceil(Disp_End_Freq/Freq_Step + 1);
    
    EEG_spectrum_to_plot = EEG_Spectrum(Start_Index:End_Index,Current_Epoch_Num);
    
    Freq_Axis = (Start_Index-1)*Freq_Step:Freq_Step:(End_Index-1)*Freq_Step;
    
    
    axes(handles.Spectrum_Axis);
    handles.Current_Spectrum_Plot = plot(Freq_Axis, EEG_spectrum_to_plot,'Color',plot_color2,'LineWidth',2,'Parent',handles.Spectrum_Axis);
    xtick_vector = [Disp_Start_Freq round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)/3)...
        round(Disp_Start_Freq + (Disp_End_Freq - Disp_Start_Freq)*2/3) Disp_End_Freq];
    set(handles.Spectrum_Axis,'XGrid','On');
    set(handles.Spectrum_Axis,'XLimMode','Manual','XLim',[Disp_Start_Freq Disp_End_Freq],'XTickMode','Manual','XTick',xtick_vector,'XTickLabel',xtick_vector);
    xlabel('Frequency (Hz)');
    ylabel('Power');
    
    clear Start_Index End_Index EEG_spectrum_to_plot Freq_Axis xtick_vector;
end



epoch_dur_history = 1;

mouse_action = 0;
fbar_action = 0;
fbar_click_pos = 0;
area_start_pos = [0 0];
set(handles.output,'pointer','arrow');
set(handles.Point_Selection_Toggle,'Value',0);
set(handles.Point_Epoch_Text,'String','Epoch ##');
set(handles.figure,'WindowButtonDownFcn','');
Update_Stages(handles.output,[],handles);

%saves all data to a .mat file that can be quickly loaded in the program
%this file retains all aspects of the program when the save occurs
%including sorting, threshold values and variables used for parameter 1 and
%parameter 2
function Save_Mat_Menu_Callback(hObject,eventdata,handles,outFile)
globalVars = who('global');
evalStr = '';
for i=1:numel(globalVars)
    eval(sprintf('global %s;',globalVars{i},globalVars{i}));
    evalStr = [evalStr ',''' globalVars{i} ''''];
end
set(handles.output,'pointer','watch');
drawnow;

evalStr = ['save(outFile' evalStr ');'];

if ~exist('outFile','var')
    SaveFile = [File_Name(1:find(File_Name=='.')-1) '.mat'];
    [SaveFile,Path] = uiputfile(SaveFile);
    if SaveFile==0
        return;
    end
    outFile = [Path SaveFile];
end
eval(evalStr);
set(handles.output,'pointer','arrow');

%imports the sorting from a .xlsx output file and applies it to the epochs
%on screen
function Import_Xls_Menu_Callback(hObject,eventdata,handles)
global Stages Last_Epoch_Num compare_sort;
global Old_Stages;
[fn,path] = uigetfile('*.xlsx');
if fn==0
    return;
end
file = [path fn];
outputDat = xlsread(file);
if length(outputDat(:,2))~=Last_Epoch_Num
    val = questdlg({'Spreadsheet uses different epoch duration!',...
        'You won''t be able to compare your current sorting',...
        'Do you want to continue?'});
    switch val
        case 'Yes'
            compare_sort = 0;
        case 'No'
            return;
        case 'Cancel'
            return;
    end
else
    compare_sort = 1;
end
Old_Stages = Stages;
Stages = outputDat(:,2)';

Update_Stages(hObject,eventdata,handles);

%imports the sorting from a .txt output file and applies it to the epochs
%on screen
function Import_Txt_Menu_Callback(hObject,eventdata,handles)
global Stages Last_Epoch_Num compare_sort;
global Old_Stages;
[fn,p] = uigetfile('*.txt');
if fn==0
    return;
end
format = '%*f %f ';
for i=1:107,
    format = [format '%*f '];
end
[Stages] = textread([p fn],format,'headerlines',1)';
Update_Stages(hObject,eventdata,handles);

%exports sorting to a .xlsx output file that includes the stage of each
%epoch as well as the EEG power of various bandwidths
function Export_Xls_Menu_Callback(hObject,eventdata,handles)
global File_Name;
global Last_Epoch_Num Stages;
global Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power EEG_Power;
global EEG_Spectrum Freq_Step Sampling_Rate_EEG Sampling_Rate_EMG EMG_Power;

SaveFile = File_Name(1:find(File_Name=='.')-1);
[Save_Filename Path] = uiputfile([SaveFile '_Sorted.xlsx']);
if Save_Filename==0
    return;
end
Save_Filename = [Path Save_Filename];

data_out = [(1:Last_Epoch_Num)' (Stages)' (EMG_Power)' (EEG_Power)' (Delta_Power)' (Theta_Power)' (Spindle_Power)' (Sigma_Power)' (Gamma_Power)'];
data_out_header = {'Epoch #', 'State', 'EMG Power','EEG Power', 'Delta', 'Theta', 'Spindle', 'Sigma', 'Gamma'};

% begin Mi
for i = 0:min([100,Sampling_Rate_EEG/2])-1
    data_out_header(i+10) = {strcat(int2str(i), '-', int2str(i+1), 'Hz')};
    Freq_Power = Band_Power_Calc(EEG_Spectrum,i,i+.5,Freq_Step);
    data_out(:,i+10) = (Freq_Power');
end
% end Mi

data_out_final(1,:) = data_out_header;
data_out_final(2:1+Last_Epoch_Num,:) = num2cell(data_out);
status = xlswrite(Save_Filename,data_out_final);

if status == 0
    errordlg('The output file has not been generated successfully.','Output File Failure');
    return;
end

clear File_Path Filename_Common Ext Save_Filename;
clear data_out data_out_header data_out_final status;

%exports sorting to .txt output file that includes the stage of each epoch
%as well as the EEG power for various bandwidths
function Export_Txt_Menu_Callback(hObject,eventdata,handles,Save_Filename)
global File_Name;
global Last_Epoch_Num Stages;
global Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power EEG_Power;
global EEG_Spectrum Freq_Step Sampling_Rate_EEG Sampling_Rate_EMG EMG_Power;

if ~exist('Save_Filename','var')
    SaveFile = File_Name(1:find(File_Name=='.')-1);
    [Save_Filename Path] = uiputfile([SaveFile '_Sorted.txt']);
    if Save_Filename==0
        return;
    end
    Save_Filename = [Path Save_Filename];
end

data_out = [(1:Last_Epoch_Num)' (Stages)' (EMG_Power)' (EEG_Power)' (Delta_Power)' (Theta_Power)' (Spindle_Power)' (Sigma_Power)' (Gamma_Power)'];
data_out_header = {'Epoch #', 'State','EMG Power','EEG Power', 'Delta', 'Theta', 'Spindle', 'Sigma', 'Gamma'};

% begin Mi
for i = 0:min([100,Sampling_Rate_EEG/2])-1
    data_out_header(i+10) = {strcat(int2str(i), '-', int2str(i+1), 'Hz')};
    Freq_Power = Band_Power_Calc(EEG_Spectrum,i,i+.5,Freq_Step);
    data_out(:,i+10) = (Freq_Power');
end
% end Mi

for i=1:length(data_out(1,:)),
    txtCell(:,i) = cellstr(strjust(char(char(data_out_header(i)),num2str(data_out(:,i))),'right'));
end

txtDat = '';
for i=1:length(txtCell(:,1)),
    txtRow = '';
    for j=1:length(txtCell(1,:)),
        txtRow = [txtRow char(txtCell(i,j)) char(9)];
    end
    txtDat = [txtDat txtRow char(10)];
end

fid = fopen(Save_Filename,'w+');
fwrite(fid,txtDat);
fclose(fid);

%displays the program help file outlining details on how to use the program
function Help_Details_Menu_Callback(hObject,eventdata,handles)
text = fileread('Auto_Score_Help.txt');
Text_Display(0,'Software Details',text);

%called to initialize .txt and .1eg data loaded once the program is already
%running
function load_Raw_Data(hObject,eventdata,handles)

global Ori_EEG Ori_EMG Base_EEG Base_EMG;
global Epoch_Dur;
global Sampling_Rate_EEG Sampling_Rate_EMG File_Name;
global Disp_Start_Freq Disp_End_Freq;
global mouse_action fbar_action;
global EEG EMG;
global epoch_dur_history;

global Last_Epoch_Num;
global EEG_Scale EMG_Scale Current_EEG_Scale Current_EMG_Scale;
global EEG_By_Epoch EMG_By_Epoch;
global EEG_Spectrum EEG_Freq_Axis EMG_Spectrum EMG_Freq_Axis;
global EEG_Power EMG_Power EMG_Variance EMG_Amplitude;
global Freq_Step Delta_Power Theta_Power Spindle_Power Sigma_Power Gamma_Power;
global Para1_Pop Para2_Pop;
global Para1_Type Para2_Type;
global Stages; % Grey_Epochs Grey_Epoch_Index;
global EEG_Band_Start_Freq EEG_Band_End_Freq;
global EMG_Band_Start_Freq EMG_Band_End_Freq;

global fbar_click_pos area_start_pos;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Hist_Divide Para2_Hist_Divide;
global Para1_XLim Para2_YLim;
global Current_Epoch_Num;
global Current_Epoch_Set Epoch_Set_Index;
global Ext_Stage_Change_Flag
global EEG_fTag EMG_fTag filter_Flag;
global Choose_Subset_Val auto_thres;
global compare_sort;

Base_EMG = Ori_EMG;
Base_EEG = Ori_EEG;

set(handles.File_Name_Text2, 'String', File_Name);

mouse_action = 0;
fbar_action = 0;
fbar_click_pos = 0;
area_start_pos = [0 0];
epoch_dur_history = 1;
EEG_fTag = 'Unfiltered';
EMG_fTag = 'Unfiltered';
filter_Flag = 0;
auto_thres=1;
set(handles.Epoch_Dur_Edit,'String','10');
set(handles.EEG_Text,'String',['EEG: ' EEG_fTag]);
set(handles.EMG_Text,'String',['EMG: ' EMG_fTag]);
set(handles.Para1_Listbox,'Value',1);
set(handles.Para2_Listbox,'Value',4);
Epoch_Dur = 10;
Ext_Stage_Change_Flag = 0;
compare_sort = 0;

guidata(hObject,handles);
% clear bkg_color x_tick;

Epoch_Dur_Edit_Callback(handles.Epoch_Dur_Edit,eventdata, handles);

%creates and displays the episode breakdown of the sorting
function Episode_Analysis_Menu_Callback(hObject,eventdata,handles,outFile)
global Stages Delta_Power File_Name Epoch_Dur Theta_Power;
fn = File_Name(find(File_Name==filesep,1,'last')+1:find(File_Name=='.',1,'last')-1);
states = char('Wake','NREM','REM','Artifacts','Artifacts','Artifacts','Artifacts');
episodes = findEpisodes(Stages,Delta_Power,Theta_Power,Epoch_Dur);
ep_state = strjust(char('State',states(episodes(:,1),:)),'center');
ep_start = strjust(char('Start Epoch',num2str(episodes(:,2))),'center');
ep_len = strjust(char('Length',num2str(episodes(:,3))),'center');
incursions = strjust(char('Incursions',num2str(episodes(:,4))),'center');
dpow = strjust(char('Mean Delta Power',num2str(episodes(:,5))),'center');
tpow = strjust(char('Mean Theta Power',num2str(episodes(:,6))),'center');
text = '';
for i=1:length(ep_state(:,1)),
    text = char(text,[ep_state(i,:) char(9) ep_start(i,:) char(9) ep_len(i,:) char(9)...
        incursions(i,:) char(9) dpow(i,:) char(9) tpow(i,:)]);
end
out = '';
for i=1:length(text(:,1)),
    out = [out char(10) text(i,:)];
end

wake = find(episodes(:,1)==1);
nrem = find(episodes(:,1)==2);
rem = find(episodes(:,1)==3);
header = char(sprintf('Sleep Episode Analysis for %s',fn),...
    sprintf('Total Number of Epochs: %i',numel(Stages)),...
    sprintf('Epoch Duration: %g seconds',Epoch_Dur));


head = '';
for i=1:length(header(:,1)),
    head = [head char(10) header(i,:)];
end


State = strjust(char('State','Wake','NREM','REM'),'center');
numEp = strjust(char('# of Episodes',num2str(numel(wake)),...
    num2str(numel(nrem)),num2str(numel(rem))),'center');
avgLen = strjust(char('Avg. Ep. Length (Epochs)',...
    num2str(mean(episodes(wake,3))), num2str(mean(episodes(nrem,3))),...
    num2str(mean(episodes(rem,3)))),'center');
avgD = strjust(char('Avg. Delta Power',...
    num2str(mean(episodes(wake,5))), num2str(mean(episodes(nrem,5))),...
    num2str(mean(episodes(rem,5)))),'center');
avgT = strjust(char('Avg. Theta Power',...
    num2str(mean(episodes(wake,6))), num2str(mean(episodes(nrem,6))),...
    num2str(mean(episodes(rem,6)))),'center');

hTable = '';
for i=1:length(State(:,1)),
    hTable = char(hTable,[State(i,:) char(9) numEp(i,:) char(9) ...
        avgLen(i,:) char(9) avgD(i,:) char(9) avgT(i,:)]);
end
hT = '';
for i=1:length(hTable(:,1)),
    hT = [hT char(10) hTable(i,:)];
end


out = [head(2:end) hT out];

if ~exist('outFile','var')
    Text_Display(1,'Sleep Episode Breakdown',out);
else
    fid = fopen(outFile,'w+');
    fwrite(fid,out);
    fclose(fid);
end

%clears all global variables
function Clear_Variables()

globalVars = who('global');
for i=1:numel(globalVars)
    eval(sprintf('global %s; clear %s',globalVars{i},globalVars{i}));
end

%allows you to compare to the current sorting to an existing sorting to
%check accuracy of your sorting.
function Compare_Sort_Menu_Callback(hObject,eventdata,handles,outFile)
global Stages Last_Epoch_Num File_Name;

[fn,p] = uigetfile('*.xlsx', 'Choose file to compare sort to:');
if fn==0
    return;
end
file = [p fn];
outputDat = xlsread(file);
if length(outputDat(:,2))~=Last_Epoch_Num
    val = msgbox({'Spreadsheet uses different epoch duration!',...
        'Cannot compare sorting'});
    return;
end
compStages = outputDat(:,2)';

wake = find(Stages==1);
nrem = find(Stages==2);
rem = find(Stages==3);
arts = find(Stages>3);
correct = (Stages == compStages);

wAcc = sum(correct(wake))/numel(wake)*100;
nAcc = sum(correct(nrem))/numel(nrem)*100;
rAcc = sum(correct(rem))/numel(rem)*100;
aAcc = sum(correct(arts))/numel(arts)*100;
wAcc2 = sum(correct(wake))/numel(find(compStages==1))*100;
nAcc2 = sum(correct(nrem))/numel(find(compStages==2))*100;
rAcc2 = sum(correct(rem))/numel(find(compStages==3))*100;
aAcc2 = sum(correct(arts))/numel(find(compStages>3))*100;

%make output text
spacer = [char(9);char(9);char(9);char(9);char(9)];
col1 = char('','Waking:', 'NREM Sleep:', 'REM Sleep:', 'Artifacts:');
col2 = char('# of Epochs (this vs ref)',...
    sprintf('%i --- %i',numel(wake),numel(find(compStages==1))),...
    sprintf('%i --- %i',numel(nrem),numel(find(compStages==2))),...
    sprintf('%i --- %i',numel(rem),numel(find(compStages==3))),...
    sprintf('%i --- %i',numel(arts),numel(find(compStages>3))));
col3 = strjust(char('Accuracy',[num2str(wAcc) '% --- ' num2str(wAcc2) '%'],...
    [num2str(nAcc) '% --- ' num2str(nAcc2) '%'], [num2str(rAcc) '% --- ' num2str(rAcc2) '%'],...
    [num2str(aAcc) '% --- ' num2str(aAcc2) '%']),'Center');
head = sprintf('Accuracy comparison between this sorting and %s\n',fn);
out = char(head, [col1 spacer col2 spacer col3]);

output='';
for i=1:length(out(:,1)),
    output = [output char(10) out(i,:)];
end
if ~exist('outFile','var')
    Text_Display(1,'Sorting Accuracy Comparison',output);
else
    fid = fopen(outFile,'w+');
    fwrite(fid,output);
    fclose(fid);
end

% creates a pop-up that allows you to the score the data using a 2-step
% process. First NREM is separated from Waking and REM by viewing a plot of
% EMG Power vs EEG Power and setting a threshold along EEG Power to isolate
% NREM. Then the non-NREM points are displayed in the second plot which
% plots (Theta Power)^2 / (Delta Power * EMG Power) vs EEG Power. In this
% plot you set a threshold along the Y-Axis to separate REM from Waking.
% The nature of the these varaibles makes it easier to identify REM points
% are they will have high Y values in the second plot and waking will have
% very low Y-values in the second plot. 
% once done sorting using the pop-up, the pop-ups variables are plotted on
% the double_axis_plot and the threshold bars are set to match. 
function BHSort_Push_Callback(hObject,eventdata,handles)
global Stages EMG_Power EEG_Power;
global EEG_Spectrum Freq_Step;
global Para1_Extra Para2_Extra;
global mouse_action fbar_action area_start_pos fbar_click_pos;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Para1_Pop Para2_Pop Para2_Type Para1_Type;
global Theta_Power Delta_Power Fixed_Points;

h = msgbox({'Instructions:','','This sort allows you to separate out the various behavioral states based on a two step process using first EMG Power vs EEG Power. Then using Theta Power^2 / (Delta Power * EMG Power) vs EEG Power',...
    '','To do this you will see two plots. The top one is will allow you to separate NREM from the rest of the epochs by allowing you to set a threshold along total EEG Power above which will be considered NREM. These points will be blue on the bottom plot.',...
    '','In the bottom plot, you can separate REM from waking by adjusting the threshold. REM will be all non-NREM points above the threshold and waking will be below. Both plots will be colored accoring to the sorting, and at all times continuity rules are applied.',...
    '','Waking epochs will be red, REM will be green and NREM will be blue.','',...
    'By clicking the Neural Net Thresh button, the NREM threshold will be automatically set by running the points through a Neural Network.',...
    'To ensure this works well you should have the extreme artifacts marked as artifacts or unsorted before opening this window. So if you have not done this just close the 2-step window and reopen it after the extreme epochs are marked.'});

waitfor(h);

x1 = EEG_Power;
y1 = EMG_Power;
x2 = EEG_Power;
y2 = (Theta_Power.^2)./(Delta_Power.*EMG_Power);
h = BH_Scoring(x1,y1,x2,y2,Stages);
waitfor(h,'Visible','off');
stages = getappdata(h,'stages');
thresh1 = getappdata(h,'Sleep_Thresh');
thresh2 = getappdata(h,'Y_Intercept');

Para1_Extra = x1;
Para2_Extra = 1./y2;
s1 = get(handles.Para1_Listbox,'String');
s2 = get(handles.Para2_Listbox,'String');
s2{5} = 'Delta x EMG / Theta^2';

set(handles.Para1_Listbox,'String',s1,'Value',1);
set(handles.Para2_Listbox,'String',s2,'Value',5);
Para1_Type = 1;
Para2_Type = 5;
set(handles.Para1_Slider,'Value',1);
set(handles.Para2_Slider,'Value',1);
Para1_Pop = Para1_Extra;
Para2_Pop = Para2_Extra;

Stages = contSort(stages,Fixed_Points);
Update_Stages(hObject,eventdata,handles);

mouse_action = 0;
fbar_action = 0;

fbar_click_pos = 0;
area_start_pos = [0 0];

set(handles.Point_Selection_Toggle,'Value',0);
set(handles.Point_Epoch_Text,'String','Epoch ##');
set(handles.figure,'WindowButtonDownFcn','');


guidata(hObject,handles);
Epoch_Update4_Callback(hObject, eventdata, handles);

Para1_Thres = thresh1;
Para2_Thres1 = 1/thresh2;
Para2_Thres2 = max(Para2_Extra(find(Stages==2)))+1;
h_bar = handles.Para1_Thres_Bar;
h_axes = get(h_bar,'Parent');
x_lim = get(h_axes,'XLim');
set(handles.Para1_Thres_Bar,'Xdata',[Para1_Thres Para1_Thres]);
set(handles.Para1_Thres_Bar_Hist,'Xdata',[Para1_Thres Para1_Thres]);
set(handles.Para2_Thres_Bar1,'Xdata',[x_lim(1) Para1_Thres]);
set(handles.Para2_Thres_Bar2,'Xdata',[Para1_Thres x_lim(2)]);

h_bar = handles.Para2_Thres_Bar1;
h_axes = get(h_bar,'Parent');
y_lim = get(h_axes,'YLim');
set(handles.Para2_Thres_Bar1,'Ydata',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar_Hist1,'Ydata',[Para2_Thres1 Para2_Thres1]);
set(handles.Para2_Thres_Bar2,'Ydata',[Para2_Thres2 Para2_Thres2]);
set(handles.Para2_Thres_Bar_Hist2,'Ydata',[Para2_Thres2 Para2_Thres2])


delete(h);

%when toggled this will send the program into validation mode where 5% of
%the epochs are presented to the user to check accuracy of sorting
function Validate_Sorting_Toggle_Callback(hObject,eventdata,handles)
global Stages Para1_Pop Para2_Pop;
global Para1_Thres Para2_Thres1 Para2_Thres2;
global Current_Epoch_Num;
global Choose_Subset_Val Current_Epoch_Set Epoch_Set_Index;

val = get(hObject,'Value');

if val
    %get 5% of points on either side of separation thresholds
    q= questdlg(['What percent of points do you want to include in the validation?' char(10) 'Half will be from border regions and half will be from rest of the file.'],'Choose Points','5%','10%','15%',{'5%'});
    if strcmp(q,'5%')
        perc = .05;
    elseif strcmp(q,'10%')
        perc=.1;
    else
        perc=.15;
    end
    pts = fix(perc*numel(Stages));
    [p1 ip1] = sort(Para1_Pop,'ascend');
    nonsws = find(Para1_Pop<=Para1_Thres);
    [p2 ip2] = sort(Para2_Pop(nonsws),'ascend');
    t1 = find(p1<=Para1_Thres,1,'last');
    t2 = find(p2<=Para2_Thres1,1,'last');
    z1 = ip1(max([1 t1-pts]):min([t1+pts length(ip1)]));
    z2 = ip2(max([1 t2-pts]):min([t2+pts length(ip2)]));
    z2 = nonsws(z2);
    tSet = union(z1,z2);
    threshSet = tSet(randperm(numel(tSet),fix(pts/2)));
    setappdata(handles.Validate_Sorting_Toggle,'ThreshSet',threshSet);
    rest = 1:length(Stages);
    rest(threshSet) = [];
    pts = pts-numel(threshSet);
    restSet = rest(randperm(numel(rest),pts));
%     setappdata(handles.Validate_Sorting_Toggle,'RestSet',restSet);
    validateSet = union(threshSet,restSet);
    
    %start validation process
    h = msgbox({['You will now be presented ' num2str(fix(perc*100)) '% of the epochs and should verify whether they are correctly scored or not'],...
        'During this time you will not be able to change the scoring or the threshold bars in any way.','',...
        'You can scroll through epochs but must select yes or no for whether the presented epoch is correct.',...
        'If you choose cancel or toggle off the Validate Sorting button, the process will be cancelled.'});
    waitfor(h);
    
    setappdata(hObject,'vset',validateSet);
    setappdata(hObject,'index',1);
    setappdata(hObject,'correct',0);
    setappdata(hObject,'tCorrect',0);
    setappdata(hObject,'incorrect',[]);
    %hide excess stuff
    set(handles.Change_Epoch_Panel,'Visible','off');
    set(handles.Para2_Listbox,'Enable','off');
    set(handles.Para1_Listbox,'Enable','off');
    set(handles.Sorting_Panel,'Visible','off');
    set(handles.BHSort_Push,'Visible','off');
    set(handles.Filter_Data_Push,'Visible','off');
    set(handles.Analyze_EKG_Push,'Visible','off');
    set(handles.Restore_Data_Push,'Visible','off');
    
    set(handles.Epoch_Dur_Edit,'Enable','off');
    
    set(handles.Validate_Sorting_Panel,'Visible','on');
    
    set(handles.Validate_Sorting_Text,'String',sprintf('Is Epoch #%i correctly scored?     1/%i',validateSet(1),numel(validateSet)));
    Current_Epoch_Num = validateSet(1);
    Epoch_Update1_Callback(hObject,eventdata,handles);
else
    %end process
    vset = getappdata(handles.Validate_Sorting_Toggle,'vset');
    idx = getappdata(handles.Validate_Sorting_Toggle,'index');
    correct = getappdata(handles.Validate_Sorting_Toggle,'correct');
    incorrect = getappdata(handles.Validate_Sorting_Toggle,'incorrect');
    tCorrect = getappdata(handles.Validate_Sorting_Toggle,'tCorrect');
    tSet = getappdata(handles.Validate_Sorting_Toggle,'ThreshSet');
    
    if idx>numel(vset),
        score = correct/numel(vset)*100;
        tScore = tCorrect/numel(tSet)*100;
        rScore = (correct-tCorrect)/(numel(vset)-numel(tSet)) *100;
        h = msgbox({sprintf('%0.1f%% of the %i epochs presented were correctly scored.',score,numel(vset)),...
            sprintf('%0.1f%% of the %i border epochs presented were correctly scored.',tScore,numel(tSet)),...
            sprintf('%0.1f%% of the %i other of the epochs presented were correctly scored.',rScore,numel(vset)-numel(tSet)),...
            'Please use this value to determine whether or not to manually score the entire dataset.'});
        waitfor(h);
        q = questdlg(sprintf('You said %i points where scored incorrectly.\nWould you like to correct them now?',numel(incorrect)));
        if strcmp(q,'Yes')
            Current_Epoch_Set = incorrect;
            Epoch_Set_Index = 1;
            Choose_Subset_Val = 9;
            c1 = get(handles.Choose_Subset_Pop,'String');
            c1{9} = 'Incorrect';
            set(handles.Choose_Subset_Pop,'String',c1,'Value',9);
            h = msgbox({'The points you marked as incorrect have been set as the current set of iterable epochs.',...
                'You may use the arrow buttons in the navigation box next to the drop-down menu to move through the set.'});
            waitfor(h);
            set(handles.Subset_Epochs_Text,'String',[int2str(Epoch_Set_Index) ' / ' int2str(length(Current_Epoch_Set)) ' in set']);
            Current_Epoch_Num = incorrect(1);
            Epoch_Update1_Callback(hObject,eventdata,handles);
            
        end
    else
        %if cancelled prematurely
    end
    
    %unhide stuff
    set(handles.Change_Epoch_Panel,'Visible','on');
    set(handles.Para2_Listbox,'Enable','on');
    set(handles.Para1_Listbox,'Enable','on');
    set(handles.Sorting_Panel,'Visible','on');
    set(handles.BHSort_Push,'Visible','on');
    set(handles.Filter_Data_Push,'Visible','on');
    set(handles.Analyze_EKG_Push,'Visible','on');
    set(handles.Restore_Data_Push,'Visible','on');
    
    set(handles.Epoch_Dur_Edit,'Enable','on');
    
    

end

%called when the yes button is clicked in validation mode
function Validate_Yes_Callback(hObject,eventdata,handles)
global Current_Epoch_Num;
vset = getappdata(handles.Validate_Sorting_Toggle,'vset');
idx = getappdata(handles.Validate_Sorting_Toggle,'index');
correct = getappdata(handles.Validate_Sorting_Toggle,'correct');
tCorrect = getappdata(handles.Validate_Sorting_Toggle,'tCorrect');
tSet = getappdata(handles.Validate_Sorting_Toggle,'ThreshSet');
if any(tSet==vset(idx))
    tCorrect = tCorrect+1;
end

correct = correct+1;
idx = idx+1;

setappdata(handles.Validate_Sorting_Toggle,'index',idx);
setappdata(handles.Validate_Sorting_Toggle,'correct',correct);
setappdata(handles.Validate_Sorting_Toggle,'tCorrect',tCorrect);

if idx>numel(vset)
    set(handles.Validate_Sorting_Toggle,'Value',0);
    set(handles.Validate_Sorting_Panel,'Visible','off');
    Validate_Sorting_Toggle_Callback(handles.Validate_Sorting_Toggle,eventdata,handles);
else
    set(handles.Validate_Sorting_Text,'String',sprintf('Is Epoch #%i correctly scored?     %i/%i',vset(idx),idx,numel(vset)));
    Current_Epoch_Num = vset(idx);
    Epoch_Update1_Callback(hObject,eventdata,handles);
end

%called when the no button is clicked in validation mode
function Validate_No_Callback(hObject,eventdata,handles)
global Current_Epoch_Num;
vset = getappdata(handles.Validate_Sorting_Toggle,'vset');
idx = getappdata(handles.Validate_Sorting_Toggle,'index');
wrong = getappdata(handles.Validate_Sorting_Toggle,'incorrect');
wrong = [wrong vset(idx)];
idx = idx+1;
setappdata(handles.Validate_Sorting_Toggle,'incorrect',wrong);
setappdata(handles.Validate_Sorting_Toggle,'index',idx);

if idx>numel(vset)
    set(handles.Validate_Sorting_Toggle,'Value',0);
    set(handles.Validate_Sorting_Panel,'Visible','off');
    Validate_Sorting_Toggle_Callback(handles.Validate_Sorting_Toggle,eventdata,handles);
else
    set(handles.Validate_Sorting_Text,'String',sprintf('Is Epoch #%i correctly scored?     %i/%i',vset(idx),idx,numel(vset)));
    Current_Epoch_Num = vset(idx);
    Epoch_Update1_Callback(hObject,eventdata,handles);
end

%called when the cancel button is clicked in validation mode
function Validate_Cancel_Callback(hObject,eventdata,handles)

set(handles.Validate_Sorting_Toggle,'Value',0);
set(handles.Validate_Sorting_Panel,'Visible','off');
Validate_Sorting_Toggle_Callback(handles.Validate_Sorting_Toggle,eventdata,handles);

%Asks for a file name stem and destination directory then saves the
%Workspace (.mat), sorting output (.txt), Episode Breakdown (.txt) and
%Accuracy Comparison to another sorting (.txt)
function Save_All_Menu_Callback(hObject,eventdata,handles)
global File_Name;
p = uigetdir(fileparts(File_Name));
filestem = inputdlg('Enter File Name Stem for output files:');
filestem = filestem{1};

fnA = [p filesep filestem ' Accuracy.txt'];
fnW = [p filesep filestem ' Workspace.mat'];
fnO = [p filesep filestem ' Sorted.txt'];
fnB = [p filesep filestem ' Breakdown.txt'];

q = questdlg('Save Workspace?');
if strcmp(q,'Yes')
Save_Mat_Menu_Callback(hObject,eventdata,handles,fnW);
end
Export_Txt_Menu_Callback(hObject,eventdata,handles,fnO);
Episode_Analysis_Menu_Callback(hObject,eventdata,handles,fnB);
Compare_Sort_Menu_Callback(hObject,eventdata,handles,fnA);

% when in validation mode this changes the current epoch to the one being
% checked for validation
function GoTo_Validation_Push_Callback(hObject,eventdata,handles)
global Current_Epoch_Num;

vset = getappdata(handles.Validate_Sorting_Toggle,'vset');
idx = getappdata(handles.Validate_Sorting_Toggle,'index');
Current_Epoch_Num = vset(idx);
Epoch_Update1_Callback(hObject,eventdata,handles);

% changes all points to unfixed points so that they can be altered by
% auto sorting
function Unfix_Push_Callback(~,~,~)
global Last_Epoch_Num Fixed_Points;

Fixed_Points = zeros(1,Last_Epoch_Num);

% loads raw .mat data into autoscore program. this data should have the
% variables EEG, EMG and either Sampling_Rate or Sampling_Rate_EEG and
% Sampling_Rate_EMG
function Open_Raw_Mat_Menu_Callback(hObject,eventdata,handles)
global Sampling_Rate_EEG Sampling_Rate_EMG Ori_EEG Ori_EMG File_Name ;
global auto_thres;
Clear_Variables();
[name_txt, Path_Str] = uigetfile( '.mat', 'Pick a data file');
if name_txt==0
    return;
end

File_Name = strcat( Path_Str, name_txt );

data = load(File_Name);
if ~isfield(data,'EEG')
    msgbox('.mat File must contain a variable named EEG.');
    return;
end
if ~isfield(data,'EMG')
    msgbox('.mat File must contain a variable named EMG.');
    return;
end
Ori_EEG = data.EEG;
Ori_EMG = data.EMG;

if isfield(data,'Sampling_Rate_EEG')
    Sampling_Rate_EEG = data.Sampling_Rate_EEG;
elseif isfield(data,'Sampling_Rate')
    Sampling_Rate_EEG = data.Sampling_Rate;
else
    Sampling_Rate_EEG = 256;
end
if isfield(data,'Sampling_Rate_EMG')
    Sampling_Rate_EMG = data.Sampling_Rate_EMG;
else
    Sampling_Rate_EMG = Sampling_Rate_EEG;
end

auto_thres = 1;
load_Raw_Data(hObject,eventdata,handles);

clear name_txt Path_Str eeg emg;

% Finds and counts spindles in the EEG data
function Find_Spindles_Menu_Callback(~,~,handles)
global Base_EEG Stages EEG_By_Epoch Sampling_Rate_EEG File_Name
set(handles.output,'pointer','watch');
drawnow;
fn = File_Name;
fn = fn(find(fn==filesep,1,'last')+1:end);
[Spindles,out] = findSpindles(Base_EEG,EEG_By_Epoch,Stages,Sampling_Rate_EEG);
set(handles.output,'pointer','arrow');
out(1,1) = {['Spindle Counting for ' fn]};
outStr = writeCell2Txt([],out,6);
Text_Display(1,'Spindle Finding',outStr)