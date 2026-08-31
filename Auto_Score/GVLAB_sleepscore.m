%This user interface function provides the framework for sleep scoring
%The data is expected to be in a matlab file containing the following
%variables
%EEG - EEG signal 
%EMG- EMG signal 
%Sampling_Rate the sampling rate for both the EEG and EMG data

%Optionally a scorevector if the data has been (partially) scored before

function GVLAB_sleepscore()
    %Clear the command window
    clc
    %Start a parrallel pool
    gcp;
    %Global Vairables-----------------------------------------
    %Variables related to file handling
    global FOLDERNAME                                         %Holds a string for the folder in which we are working if we are loading a file
    global BASEFOLDERNAME
    BASEFOLDERNAME='/home/kaspar/Documents/SleepRecAbby';     %Set this to the folder where your data is most likely located
    global LOADINGFILE
    LOADINGFILE=1;                                            %Boolean variable (1 or 0) whether we should be working in the base workspace or loading data from a file 
    global MFILENAME                                          %Sting containing the name (without folder) of the *.mat file to load or loaded
    global TXTFILENAME                                        %String containing the name (without folder) of the *.mat file to load or loaded
    global PFILENAME                                          %String containing the name of the parameter file    
    global PFILE                                              %String containing the name and folder for the parameter file
    global MATFILE                                            %String containing the full name of the *.mat file to load incl. folder name
    global TXTFILE                                            %String containing the full name of the *.txt file to load incl.folder name
    global BASEVARIABLES                                      %Cell array with strings containing the base workspace variables
    global TXTEEGFIRST                                        %If a *.txt file is loaded is the first column EEG data (default) otherwise it is EMG
    TXTEEGFIRST=1;
    global FILETYPE                                           %three letter indicator for the file type to load (at the moment 'txt' and 'mat' are supported)
    global SAMPLINGRATE_EEG
    global SAMPLINGRATE_EMG
    SAMPLINGRATE_EEG=256;                                       %Be careful with this default!
    SAMPLINGRATE_EMG=256;                                       %Be careful with this default
   
    %Variables related to scoring
    global SCORESEC
    SCORESEC=10;                                                %The scoring interval in seconds (10 is typical)
    global SCORELENGTH
    SCORELENGTH=SCORESEC*SAMPLINGRATE_EEG;                      %the size of the scoring window (in datapoints)
    global NUMBEROFEPOCHS
    NUMBEROFEPOCHS=1;                                           %The number of epochs in the recording
    global EPOCHNUMBER
    EPOCHNUMBER=1;                                              %The epoch we are currently working on

    %Variables related to the user interface
    %get the screen size of the root screen
    global SCSIZE
    SCSIZE=get(0, 'screensize');
    global WINDOWWIDTH
    global WINDOWHEIGHT
    WINDOWWIDTH=1500;
    WINDOWHEIGHT=950;
    
    global DISPLAYWINDOWBEGIN
    DISPLAYWINDOWBEGIN=0;                                       %EEG, and EMG will be displayed in epoch length
    global DISPLAYWINDOWDURATION
    DISPLAYWINDOWDURATION=SCORELENGTH;                          %the data within these epochs can be stretched to view data more closely
    global SCROLLFACTOR
    SCROLLFACTOR=0.5;                                           %The amount of window displacement when pressing the forward or backward frame movement button
    
    global AUTOADVANCE
    AUTOADVANCE=1;                                              %Boolean variable that controls, whether the next epoch should be displayed when an epoch has been scored
    global DRAWBIG
    DRAWBIG=1;                                                  %Boolean variable that controls whether the larger 3 epoch display should be shown (can be hidden to improve speed)
    global DRAWDONE
    DRAWDONE=0;                                                 %Set to 0 when activelz drawing and to 1 when done drawing (to avoid scroll wheel overload..)
    
    global SCORESTRUCT                                          %Holds the letter code for sleep score (w=waking, n=nrem, r=rem, other letters are for unscored (u) or not scoreable (o)
    global SCOREVECTOR                                          %Numerical code for the sleep score (0=unscoreable, 1=w, 2=n, 3=r, 4=unscored)
    
    %Global variables related to the data to be analyzed
    global EEG
    global EEGRAW   %Copy of the raw unfiltered EEG
    global EEG3S
    global EEGSCALE
    EEGSCALE=0;
    global EEG_EPOCH
    global EEG_BIGEPOCH 
    global EEG_FDAQ
    EEG_FDAQ=SAMPLINGRATE_EEG;                                    %The sampling frequency for the EEG data (legacy) rely on SAMPLINGRATE_EEG
    global EEG_FFT
    global EEG_FAXIS
    global FFTLENGTH
    global FFTZOOM
    FFTZOOM=1;
    global EMG
    global EMGRAW   %Copy of the raw unfiltered EMG
    global EMG3S
    global EMGSCALE
    EMGSCALE=0;
    global EMG_EPOCH
    global EMG_BIGEPOCH
   
    %Epoch related
    global EPOCH_TIME                                           %Time of epoch in s since the recording began 
    global SCORETIMEVEC                                         %Timepoint for each scoring epoch in a resolution of seconds (used for plotting)
    SCORETIMEVEC=[];
    global RECORDSTARTSTRING
    RECORDSTARTSTRING='00:00:00';
    global RECORDSTARTSEC
    RECORDSTARTSEC=0;
    global ZTZEROSTRING
    ZTZEROSTRING='00:00:00';
    global ZTZEROSEC
    ZTZEROSEC=0;
    global ZTVECTOR
    
    global AUTOPROTECT
    AUTOPROTECT=1;                  %1 if manually scored epochs are automatically set the AutoScoreAllow to 0 to prevent overwriting
    %AutoScore related
    global AUTOSCORESTRUCT
    %Make the empty AUTOSCORESTRUCT
    %All values are per epoch
    name1='Epoch';                  %The epoch number - a bit redundant...
    name2='EpochTime';              %The time (in seconds after the start of the recording) of the epoch beginning
    name3='EpochZT';                %The zeitgeber time of the epoch in seconds after ZT0 (negative for times before ZT)
    name4='State';                  %The assigned state (numerical 0=not classifiable, 1=wake, 2=nrem, 3=rem, 4=unclassified)
    name5='StateColor';             %Three element vector to hold the color [r,g,b] with which the state is drawn    
    name6='StateType';              %0=automatically scored, 1=manually scored
    name7='AutoScoreAllow';         %0=autoscoring can not overwrite score, 1=autoscoring can overwrite score
    name8='EEGArtefact';            %0 no artefact, 1 artefact
    name9='EMGArtefact';            %0 no artefact, 1 artefact
    name10='WarnFlag';              %Warning flag if autiscoring has discovered a problematic case
    name11='EEGTotalP';             %Total EEG power 
    name12='EEGDeltaP';             %EEG power in the 0.5 to 4 Hz band
    name13='EEGThetaP';             %EEG power in the 6 to 10 Hz band
    name14='EEGGammaP';             %EEG power in the gamma 30-80 Hz band
    name15='EEGDeltaThetaRatio';    %Ratio of delta to theta power in the EEG
    name16='EEGDeltaGammaRatio';    %Ratio of delta to gamma power in the EEG
    name17='EEGMaxPeak';            %Peak Amplitude of the EEG in this epoch
    name18='EEGBandBorder';         %Two element vector with the lower and upper bounds in HZ of a specially defined EEG band
    name19='EEGBandPower';          %Power in this specially defined EEG band
    name20='EMGPower';              %Total EMG power in this epoch (0.5 Hz to SAMPLINGRATE_EMG/2)
    name21='EMGIntegral';           %Sum of the absolute EMG values for the epoch
    name22='EMGVariance';           %Variance of the EMG in this Epoch
    name23='EMGBAndBorder';         %Two element vector with the lower and upper bounds in Hz of a specially defined EMG band
    name24='EMGBandPower';          %Power in this speciallz defined EMG band
    name25='EMGP_over_Theta';       %EMG total power divided by EEG theta power
    name26='EMGComplex';            %Measure of EMG total power times EEG delta power divided by (EEG theta power)^2
    name27='EEGSpecP';              %Power values for the EEG spectrum
    name28='EEGSpecF';              %Corresponding frequency values for the EEG spectrum

    value1=1;
    value2=0;
    value3=0;
    value4=4;
    value5=[0,0,0];
    value6=1;
    value7=0;
    value8=0;     
    value9=0;         
    value10=0;
    value11=0;
    value12=0;
    value13=0;
    value14=0;
    value15=0;
    value16=0;
    value17=0;
    value18=[10,15];
    value19=0;
    value20=0;
    value21=0;
    value22=0;
    value23=[80,100];
    value24=0;
    value25=0;
    value26=0;
    value27=[];
    value28=[];
    
    AUTOSCORESTRUCT=struct(name1, value1, ...
                             name2, value2, ...
                             name3, value3, ...
                             name4, value4, ...
                             name5, value5, ...
                             name6, value6, ...
                             name7, value7, ...
                             name8, value8, ...
                             name9, value9, ...
                             name10, value10, ...
                             name11, value11, ...
                             name12, value12, ...
                             name13, value13, ...
                             name14, value14, ...
                             name15, value15, ...
                             name16, value16, ...
                             name17, value17, ...
                             name18, value18, ...
                             name19, value19, ...
                             name20, value20, ...
                             name21, value21, ...
                             name22, value22, ...
                             name23, value23, ...
                             name24, value24, ...
                             name25, value25, ...
                             name26, value26, ...
                             name27, value27, ...
                             name28, value28);
                         
    %AUTOSCORESTRUCT skeleton done
    %These variables will always have a two value vector associated 
    %value(1) is lower bound, value(2) is upper bound NaN means not yet set
    global SCOREPARAMETERSTRUCT
    sname1='EEGTotalP';
    sname2='EEGDeltaP';
    sname3='EEGThetaP';
    sname4='EEGGammaP';
    sname5='EEGDeltaThetaRatio';
    sname6='EEGDeltaGammaRatio';
    sname7='EEGMaxPeak';
    sname8='EEGBandPower';
    sname9='EMGPower'; 
    sname10='EMGIntegral';
    sname11='EMGVariance';
    sname12='EMGBandPower';
    sname13='EMGP_over_Theta';
    sname14='EMGComplex';
    svalue1=[NaN, NaN];
    svalue2=[NaN, NaN];
    svalue3=[NaN, NaN];
    svalue4=[NaN, NaN];
    svalue5=[NaN, NaN];
    svalue6=[NaN, NaN];
    svalue7=[NaN, NaN];
    svalue8=[NaN, NaN];
    svalue9=[NaN, NaN];
    svalue10=[NaN, NaN];
    svalue11=[NaN, NaN];
    svalue12=[NaN, NaN];
    svalue13=[NaN, NaN];
    svalue14=[NaN, NaN];
     
    SCOREPARAMETERSTRUCT=struct(sname1, svalue1, ...
                             sname2, svalue2, ...
                             sname3, svalue3, ...
                             sname4, svalue4, ...
                             sname5, svalue5, ...
                             sname6, svalue6, ...
                             sname7, svalue7, ...
                             sname8, svalue8, ...
                             sname9, svalue9, ...
                             sname10, svalue10, ...
                             sname11, svalue11, ...
                             sname12, svalue12, ...
                             sname13, svalue13, ...
                             sname14, svalue14);
    %SCOREPARAMETERSTRUCT done
    
    global XPARAMETERNAME
    XPARAMETERNAME='EEGTotalP';
    global YPARAMETERNAME
    YPARAMETERNAME='EMGIntegral';
    global XPARAMETER
    XPARAMETER=[];
    global YPARAMETER
    YPARAMETER=[];
    
    
    
    %Begin UI code------------------------------------
    %Put up the main program window
    %All of the user input and the output will happen
    %in this window
    f_scoregui=figure('Visible','on', 'ToolBar', 'none','MenuBar', 'none', 'Name', 'GV LAB AUTOSCORE GUI', 'NumberTitle', 'off', 'Position',[10,SCSIZE(4)-(WINDOWHEIGHT+60),WINDOWWIDTH,WINDOWHEIGHT], 'Resize','off', 'WindowKeyPressFcn', @keyPress, 'WindowScrollWheelFcn', @mouseScroll);
    f_scoregui=handle(f_scoregui);
    %Title string and copyright notice
    t_title=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'center', 'FontSize', 18, 'String', 'WPI-IIIS GV Sleep Scoring', 'Position', [950, WINDOWHEIGHT-30,350,30]);
    t_copyright=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'center', 'FontSize', 10,'String', 'Kaspar Vogt', 'Position', [950, WINDOWHEIGHT-48,350,18]);
    %The user is initally asked to choose either to load a file or to work
    %with base workspace variables.
    %b_select_base_workspace=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Select Base Workspace', 'Position', [710, WINDOWHEIGHT-30,140,20], 'Callback', @select_base_workspace);
    %Add the controls and displays
    %Button to select the data folder
    b_select_folder=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Select Folder', 'Position', [10, WINDOWHEIGHT-30,100,20], 'Callback', @select_folder);
    b_select_folder=handle(b_select_folder);
    %Display the chosen folder
    t_folder_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String', '....', 'Position', [150, WINDOWHEIGHT-30,500,20], 'BackgroundColor', [1,1,1]);
    t_folder_display=handle(t_folder_display);
    
    %Add a pulldown menu for the *.mat or *.txt file to load
    p_file_name_select=uicontrol('Parent', f_scoregui,'Style', 'popupmenu', 'String', {'*.mat or *.txt files'}, 'Position', [10, WINDOWHEIGHT-60, 250, 20], 'Callback', @file_name_select);
    p_file_name_select=handle(p_file_name_select);
    t_file_name_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','...', 'Position', [270, WINDOWHEIGHT-60, 250, 20]);
    t_file_name_display=handle(t_file_name_display);
    b_file_load=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Load File', 'Position', [600, WINDOWHEIGHT-60,100,20], 'Callback', @file_load);
    %Add checkbox button to select EEG or EMG first column in txt file
    %autoscoring
    c_eegfirst=uicontrol('Parent', f_scoregui, 'Style', 'checkbox', 'String', 'EEG first in *.txt file', 'Value', TXTEEGFIRST, 'Position', [800, WINDOWHEIGHT-60, 180,20], 'Callback', @check_eegfirst);
    
    %An overview of the somnogram
    somnoaxes=axes('Parent', f_scoregui, 'box', 'off', 'Units', 'pixels', 'Position', [60,WINDOWHEIGHT-140, 740, 40], 'ButtonDownFcn',@click_epoch);
    somnoaxes=handle(somnoaxes);
    somnoaxes.XLim=[1,2];
    %The top axis here is going to be in ZT units
    somnotopaxes=axes('Parent', f_scoregui, 'box', 'off', 'Units', 'pixels', 'Position', [60,WINDOWHEIGHT-140, 740, 40], 'XAxisLocation','top', 'YaxisLocation', 'right');
    somnotopaxes=handle(somnotopaxes);
    somnoplothandle=gobjects(1,1);
    markerplothandle=gobjects(1,1);
    
    %Add a button for data filtering - this will open a new window to set
    %the parameters and do the filtering
    b_get_filterwindow=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Filter Data', 'Position', [850, WINDOWHEIGHT-90,150,20], 'Callback', @get_filterwindow);
    b_get_filterwindow=handle(b_get_filterwindow);
    
    %Add the button to prepare for autoscoring
    b_prepare_autoscore=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Prepare Autoscore', 'Position', [850, WINDOWHEIGHT-120,150,20], 'Callback', @prepare_autoscore);
    b_prepare_autoscore=handle(b_prepare_autoscore);
    
    %Add the control buttons for the graph appearance
    %The buttons that control the window
    b_window_backward=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', '<< Back', 'Position', [110, WINDOWHEIGHT-210, 80,20], 'Callback', @window_backward);
    b_window_forward=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Forw >>', 'Position', [200, WINDOWHEIGHT-210, 80,20], 'Callback', @window_forward);
    b_window_expand=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', '<Expand>', 'Position', [290, WINDOWHEIGHT-210, 80,20], 'Callback', @window_expand);
    b_window_shrink=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', '>Shrink<', 'Position', [380, WINDOWHEIGHT-210, 80,20], 'Callback', @window_shrink);
    b_window_fill=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'FILL', 'Position', [470, WINDOWHEIGHT-210, 80,20], 'Callback', @window_fill);
    %Add abutton to have a big display
    c_bigdisplay=uicontrol('Parent', f_scoregui, 'Style', 'checkbox', 'String', 'BIG Display', 'Value', DRAWBIG, 'Position', [600, WINDOWHEIGHT-210, 120,20], 'Callback', @check_drawbig);
    %Add the buttons that control the epoch selection
    b_epoch_backward=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', '<< Epoch', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-240, 80,20], 'Callback', @epoch_backward);
    b_epoch_forward=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'String', 'Epoch >>', 'Position', [WINDOWWIDTH-100, WINDOWHEIGHT-240, 80,20], 'Callback', @epoch_forward);
    %Add a text edit window that allows direct entry of the epoch number
    e_epoch_jump=uicontrol('Parent', f_scoregui, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', num2str(EPOCHNUMBER), 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-210, 60, 15],'Callback',@epoch_jump);
    e_epoch_jump=handle(e_epoch_jump);
    t_epoch_jump_label=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String', 'Jump to Epoch #', 'Position', [WINDOWWIDTH-120, WINDOWHEIGHT-213,120,20]);
    
    %An editable field for the for the beginning of the recording in hh:mm:ss
    e_record_start=uicontrol('Parent', f_scoregui, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', RECORDSTARTSTRING, 'Position', [1250, WINDOWHEIGHT-110, 60, 15],'Callback',@record_start);
    e_record_start=handle(e_record_start);
    t_record_start_label=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String', 'Record Start hh:mm:ss', 'Position', [1050, WINDOWHEIGHT-113,180,20]);
    %An editable field for setting ZT 0 in hh:mm:ss
    %An editable field for the for the beginning of the recording in hh:mm:ss
    e_ztzero_start=uicontrol('Parent', f_scoregui, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', ZTZEROSTRING, 'Position', [1250, WINDOWHEIGHT-140, 60, 15],'Callback',@ztzero_start);
    e_ztzero_start=handle(e_ztzero_start);
    t_ztzero_start_label=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String', 'ZT zero hh:mm:ss', 'Position', [1050, WINDOWHEIGHT-143,180,20]);
    
    %Add a big indicator which epoch we are working on
    t_epochnumber_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'FontSize', 18, 'BackgroundColor', [1,1,1], 'ForegroundColor', [1,0,0], 'HorizontalAlignment', 'center', 'String', '...', 'Position', [WINDOWWIDTH-150, WINDOWHEIGHT-170,80,40]);
    t_epochnumber_display=handle(t_epochnumber_display);
    %Add a label for this epoch number display
    t_epochnumber_label=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'center', 'String', 'EPOCH #', 'Position', [WINDOWWIDTH-150, WINDOWHEIGHT-130,80,20], 'BackgroundColor', [1,1,1]);
    %Add a small indicator for the toal number of epochs
    t_totalepoch_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String', '...', 'Position', [WINDOWWIDTH-50, WINDOWHEIGHT-190,80,40]);
    t_totalepoch_display=handle(t_totalepoch_display);
    %Add a display of the epoch time
    t_epochtime_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'FontSize', 12, 'BackgroundColor', [1,1,1], 'ForegroundColor', [1,0,0], 'HorizontalAlignment', 'center', 'String', '...', 'Position', [WINDOWWIDTH-250, WINDOWHEIGHT-170,80,20]);
    t_epochtime_display=handle(t_epochtime_display);
    %Add a chackbock that controls whether we auto-advance with scoring
    c_auto_advance=uicontrol('Parent', f_scoregui, 'Style', 'checkbox', 'String', 'Auto Advance', 'Value', AUTOADVANCE, 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-270, 180,20], 'Callback', @check_auto_advance);
    %The score display
    t_score_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'FontSize', 24, 'BackgroundColor', [1,1,1], 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'center', 'String', '...', 'Position', [WINDOWWIDTH-150, WINDOWHEIGHT-360,80,70]);
    t_score_display=handle(t_score_display);
    %display the previous score
    t_score_before_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'FontSize', 18, 'BackgroundColor', [1,1,1], 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'center', 'String', '...', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-340,40,50]);
    t_score_before_display=handle(t_score_before_display);
    %display the following score
    t_score_after_display=uicontrol('Parent', f_scoregui, 'Style', 'text', 'FontSize', 18, 'BackgroundColor', [1,1,1], 'ForegroundColor', [0,0,0], 'HorizontalAlignment', 'center', 'String', '...', 'Position', [WINDOWWIDTH-60, WINDOWHEIGHT-340,40,50]);
    t_score_after_display=handle(t_score_after_display);
    %Add scoring buttons
    b_score_wake=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [1,0,0] , 'String', 'w', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-450, 80,40], 'Callback', @score_wake);
    b_score_wake_artefact=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0.5,0,0] , 'String', 'w*', 'Position', [WINDOWWIDTH-100, WINDOWHEIGHT-450, 80,40], 'Callback', @score_wake_artefact);
    b_score_nrem=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0,0,1], 'String', 'n', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-500, 80,40], 'Callback', @score_nrem);
    b_score_nrem_artefact=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0,0,0.5], 'String', 'n*', 'Position', [WINDOWWIDTH-100, WINDOWHEIGHT-500, 80,40], 'Callback', @score_nrem_artefact);
    b_score_rem=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0,1,0], 'String', 'r', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-550, 80,40], 'Callback', @score_rem);
    b_score_rem_artefact=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0,0.5,0], 'String', 'r*', 'Position', [WINDOWWIDTH-100, WINDOWHEIGHT-550, 80,40], 'Callback', @score_rem_artefact);
    b_score_unknown=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 24, 'ForegroundColor', [0,0,0], 'String', 'u', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-600, 80,40], 'Callback', @score_unknown);
    %Add a chackbock that controls whether we protect the socres from
    %autoscoring
    c_do_autoprotect=uicontrol('Parent', f_scoregui, 'Style', 'checkbox', 'String', 'Auto Protect', 'Value', AUTOPROTECT, 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-630, 180,20], 'Callback', @do_autoprotect);
    
    
    %AUTOSCORING interactions
    b_do_autoscore=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 12, 'ForegroundColor', [0,0,0] , 'String', 'AUTOSCORE', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-700, 180,40], 'Callback', @do_autoscore);
    
    
    %The button for saving the score
    b_score_save=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 12, 'ForegroundColor', [0,0,0] , 'String', 'Save Score', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-750, 180,30], 'Callback', @score_save);
    %Button for saving SCOREPARAMETERSTRUCT
    b_param_save=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 8, 'ForegroundColor', [0,0,0] , 'String', 'Save Param', 'Position', [WINDOWWIDTH-200, WINDOWHEIGHT-800, 80,20], 'Callback', @param_save);
    %Button for loading SCOREPARAMETERSTRUCT
    b_param_load=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 8, 'ForegroundColor', [0,0,0] , 'String', 'Load Param', 'Position', [WINDOWWIDTH-110, WINDOWHEIGHT-800, 80,20], 'Callback', @param_load);
    
    %The axes for the EEG & EMG
    %EEG
    eegaxes=axes('Parent', f_scoregui, 'box', 'off', 'Units', 'pixels', 'Position', [60,WINDOWHEIGHT-300, 740, 80]);
    eegaxes=handle(eegaxes);
    eegaxes.XLim=[DISPLAYWINDOWBEGIN, DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION];
    %Legends for the following fields that allow setting the y axis scale
    t_scale_set_legend=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','Scale', 'Position', [820, WINDOWHEIGHT-250, 40, 20]);
    t_3s_legend=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','3Sigma', 'Position', [880, WINDOWHEIGHT-250, 40, 20]);
    %An editable field where the desired axis scaling can be entered an
    %empty field means autoscale
    e_eeg_scale_set=uicontrol('Parent', f_scoregui, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', '', 'Position', [820, WINDOWHEIGHT-300, 40, 20],'Callback',@eeg_scale_set);
    e_eeg_scale_set=handle(e_eeg_scale_set);
    %An indicator for the 3Sigma of the EEG to help set the axes scale
    t_eeg3s_indicator=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','...', 'Position', [880, WINDOWHEIGHT-300, 40, 20]);
    t_eeg3s_indicator=handle(t_eeg3s_indicator);
    %EMG
    emgaxes=axes('Parent', f_scoregui, 'box', 'off', 'Units', 'pixels', 'Position', [60,WINDOWHEIGHT-400, 740, 80]);
    emgaxes=handle(emgaxes);
    emgaxes.XLim=[DISPLAYWINDOWBEGIN, DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION];
    %An editable field where the desired axis scaling can be entered an
    %empty field means autoscale
    e_emg_scale_set=uicontrol('Parent', f_scoregui, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', '', 'Position', [820, WINDOWHEIGHT-400, 40, 20],'Callback',@emg_scale_set);
    e_emg_scale_set=handle(e_emg_scale_set);
    %An indicator for the 3Sigma of the EMG to help set the axes scale
    t_emg3s_indicator=uicontrol('Parent', f_scoregui, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','...', 'Position', [880, WINDOWHEIGHT-400, 40, 20]);
    t_emg3s_indicator=handle(t_emg3s_indicator);
    
    %EEG FFT axes
    fftaxes=axes('Parent', f_scoregui, 'box', 'off', 'Units', 'pixels', 'Position', [970,WINDOWHEIGHT-350, 240, 120]);
    fftaxes=handle(fftaxes);
    
    
    %The larger display at the bottom
    %EEG axes
    bigeegaxes=axes();
    bigeegaxes.Parent=f_scoregui;
    bigeegaxes.Units='pixels';
    bigeegaxes.Position=[50,80,WINDOWWIDTH-100,50];
    bigeegaxes.Visible='off';
    %EMG axes
    bigemgaxes=axes();
    bigemgaxes.Parent=f_scoregui;
    bigemgaxes.Units='pixels';
    bigemgaxes.Position=[50,20,WINDOWWIDTH-100,50];
    bigemgaxes.Visible='off';
    %empty handles for the plot (to turn their visibility off and on)
    bigeegplothandle=gobjects(1,1);
    bigemgplothandle=gobjects(1,1);
    eegbigmarkerplothandle=gobjects(1,1);
    emgbigmarkerplothandle=gobjects(1,1);
    
    %The autoscore parameter display
    autoscoreaxes=axes();
    autoscoreaxes.Parent=f_scoregui;
    autoscoreaxes.Units='pixels';
    autoscoreaxes.Position=[100,180,320,320];
    autoscoreaxes.ButtonDownFcn=@click_parameter_epoch;
    
    %Menus for the parameter selection
    %Add a pulldown menu for the parameter plot selection
    p_xparameter_select=uicontrol('Parent', f_scoregui,'Style', 'popupmenu', 'String', {'EEGTotalP', 'EEGDeltaP', 'EEGThetaP', 'EEGGammaP', 'EEGDeltaThetaRatio', 'EEGDeltaGammaRatio', 'EEGMaxPeak', 'EEGBandPower'}, 'Position', [480, 480, 150, 20], 'Callback', @xparameter_select);
    p_xparameter_select=handle(p_xparameter_select);
    
    p_yparameter_select=uicontrol('Parent', f_scoregui,'Style', 'popupmenu', 'String', {'EMGIntegral', 'EMGPower', 'EMGVariance', 'EMGBandPower', 'EMGP_over_Theta', 'EMGComplex'}, 'Position', [480, 300, 150, 20], 'Callback', @yparameter_select);
    p_yparameter_select=handle(p_yparameter_select);
    %Add buttons to plot the parameter really big in a new window
    b_plot_xparam_big=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 8, 'ForegroundColor', [0,0,0] , 'String', 'BIG', 'Position', [650, 480, 40, 20], 'Callback', @plot_xparam_big);
    b_plot_yparam_big=uicontrol('Parent', f_scoregui, 'Style', 'pushbutton', 'FontSize', 8, 'ForegroundColor', [0,0,0] , 'String', 'BIG', 'Position', [650, 300, 40, 20], 'Callback', @plot_yparam_big);
    %Empty handles for these figures and plots so that they are accessible
    %to other functions
    xparam_big_h=gobjects(1,1);
    xparam_bigplotaxes=gobjects(1,1);
    xparam_bigplot=gobjects(1,1);
    xparam_big_lineh=gobjects(1,2);
    yparam_big_h=gobjects(1,1);
    yparam_bigplotaxes=gobjects(1,1);
    yparam_bigplot=gobjects(1,1);
    yparam_big_lineh=gobjects(1,2);
    
    
    
    %Ineed the handle variable now since the dot may need to be placed and
    %removed
    parameterdothandle=gobjects(1,1);
    xparameterdothandle=gobjects(1,1);
    yparameterdothandle=gobjects(1,1);
    
    %Each parameter has two individual windows attached to it - one window
    %with its development over the recording and a histogram
    xparamtempaxes=axes();
    xparamtempaxes.Parent=f_scoregui;
    xparamtempaxes.Units='pixels';
    xparamtempaxes.Position=[730,370,550,120];
    
    xparamhistaxes=axes();
    xparamhistaxes.Parent=f_scoregui;
    xparamhistaxes.Units='pixels';
    xparamhistaxes.Position=[480,370,150,80];
    
    yparamtempaxes=axes();
    yparamtempaxes.Parent=f_scoregui;
    yparamtempaxes.Units='pixels';
    yparamtempaxes.Position=[730,190,550,120];
    
    yparamhistaxes=axes();
    yparamhistaxes.Parent=f_scoregui;
    yparamhistaxes.Units='pixels';
    yparamhistaxes.Position=[480,190,150,80];
    
    %Each of these parameter plots can have two lineplots attached
    xtparamlineh=gobjects(1,2);
    xhparamlineh=gobjects(1,2);
    ytparamlineh=gobjects(1,2);
    yhparamlineh=gobjects(1,2);
    
    %End UI code--------------------------------------
    
    %Child Functions
    
    %This function is called when the select_base_workspace button is
    %pressed
    function select_base_workspace(hObject, callbackdata)
        %Turn off the folder and file selection UI elements
        b_select_folder.Visible='off';
        t_folder_display.Visible='off';
        p_file_name_select.Visible='off';
        t_file_name_display.Visible='off';
        b_mfile_load.Visible='off';
        disp ('SORRY - This function is not yet properly implemented');
    end
    
    %This is the folder selection function
    %A standard dialog for folder selection is put up
    function select_folder(hObject,callbackdata) 
        %turn the 'use base workspace' button off
        b_select_base_workspace.Visible='off';
        % Display the dialog to select the directory
        FOLDERNAME=uigetdir(BASEFOLDERNAME, 'Please Select Data Folder');
        %Update the text field with the  folder information
        t_folder_display.String=FOLDERNAME;
        %Get a list of the .mat files
        mlist_query=strcat(FOLDERNAME,'/*.mat');
        tlist_query=strcat(FOLDERNAME,'/*.txt');
        mfolder_listing=dir(mlist_query);
        tfolder_listing=dir(tlist_query);
        %Update the popup menu information
        mpopuptext={'No files found'};
        if(size(mfolder_listing,1)>0)
            for i=1:size(mfolder_listing,1)
                mpopuptext{i} = mfolder_listing(i).name;
            end
        else
            i=0;
        end
        if(size(tfolder_listing,1)>0)
            for k=1:size(tfolder_listing,1)
                mpopuptext{i+k}=tfolder_listing(k).name;
            end
        end
        %Set the popupt menu string if we have any m or txt files
        p_file_name_select.String=mpopuptext;
        drawnow;
    end
    %This function selects the file name from the folder list
    function file_name_select(hObject, callbackdata)
        items = get(hObject,'String');
        index_selected = get(hObject,'Value');
        item_selected = items{index_selected};
        file=item_selected;
        %Check the filetype
        FILETYPE=file(end-2:end);
        switch FILETYPE
            case 'txt'
                %Text file
                %Store it in the TXTFILENAME global variable
                TXTFILENAME=file;
                TXTFILE=strcat(FOLDERNAME,'/',file);
                %Display the name in the text field
                t_file_name_display.String=file;
                b_file_load.Visible='on';
            case 'mat'
                %Matlab file
                %Store it in the MFILENAME global variable
                MFILENAME=file;
                MATFILE=strcat(FOLDERNAME,'/',file);
                %Display the name in the text field
                t_file_name_display.String=file;
                b_file_load.Visible='on';
            otherwise
                TXTFILENAME='';
                MFILENAME='';
                %Display warning in text field
                t_file_name_display.String='File type not supported';
                b_file_load.Visible='off';
        end 
    end

    %This function controls the EEG or EMG first column in *.txt files (called from UI control
    %checkbox)
    function check_eegfirst(hObject, callbackdata)
        checkstate=hObject.Value;
        TXTEEGFIRST=checkstate;
    end
    %This function loads the file
    function file_load(hObject, callbackdata)
        %Since there are a lot of try\catch statements that throw needless
        %waringings turn them off!
        warning('off');
       %Filetype check for the loading of the EEG, EMG
       switch FILETYPE
            case 'txt'
                %Text file
                if(TXTEEGFIRST)
                    [eeg, emg] = textread(TXTFILE, '%f %f', 'headerlines', 6 );
                else
                    [emg, eeg] = textread( File_Name, '%f %f', 'headerlines', 6 );
                end
                EEG=eeg;
                EMG=emg;
                SAMPLINGRATE_EEG=256;
                SAMPLINGRATE_EMG=256;
            case 'mat'
                %Loade the EEG
                eeg=load(MATFILE, 'EEG');
                EEG=eeg.EEG;
                %flip EEG if not row vector
                if(size(EEG,2)>1)
                EEG=EEG';
                end
                EEGRAW=EEG;
                %Load the EMG
                emg=load(MATFILE, 'EMG');
                EMG=emg.EMG;
                %flip EMG if not row vector
                if(size(EMG,2)>1)
                    EMG=EMG';
                end
                EMGRAW=EMG;
                %Read the sampling rate from the matfile
                try
                        samplingrate=load(MATFILE, 'Sampling_Rate');
                        SAMPLINGRATE_EEG=samplingrate.Sampling_Rate;
                        SAMPLINGRATE_EMG=samplingrate.Sampling_Rate;
                catch
                        SAMPLINGRATE_EEG=1000;
                        SAMPLINGRATE_EMG=1000;
                end 
                if(SAMPLINGRATE_EEG==1000)
                    %Data from Intan Systems with high samplingrates is automatically downsampled to 250 Hz
                    oldstring=b_file_load.String;
                    oldcolor=b_file_load.BackgroundColor;
                    b_file_load.String='RESAMPLING!';
                    b_file_load.BackgroundColor=[1,0,0];
                    drawnow;
                    EEG=resample(EEG, 1,4);
                    EMG=resample(EMG, 1,4);
                    SAMPLINGRATE_EEG=250;
                    SAMPLINGRATE_EMG=250;
                    EEGRAW=EEG;
                    EMGRAW=EMG;
                    b_file_load.String=oldstring;
                    b_file_load.BackgroundColor=oldcolor;
                    drawnow;
                end      
       end          
       %Calculate the statistics (three times the standard deviation) to
       %help set the scale
       EEG3S=std(EEG)*3;
       %update the indicator
       eegindicator=num2str(EEG3S);
       t_eeg3s_indicator.String=eegindicator(1:4);
       e_eeg_scale_set.String=eegindicator(1:4);
       %Set the scale
       EEGSCALE=EEG3S;
       %Calculate the statistics so that the scale adjustment works
       EMG3S=std(EMG)*3;
       %update the indicator
       emgindicator=num2str(EMG3S);
       t_emg3s_indicator.String=emgindicator(1:4);
       e_emg_scale_set.String=emgindicator(1:4);
       %Set the scale
       EMGSCALE=EMG3S; 
       
       try 
           recordstartsec=load(MATFILE, 'RECORDSTARTSEC');
           RECORDSTARTSEC=recordstartsec.RECORDSTARTSEC;
           ztzerosec=load(MATFILE, 'ZTZEROSEC');
           ZTZEROSEC=ztzerosec.ZTZEROSEC;
            
           RECORDSTARTSTRING=sec2timestring(RECORDSTARTSEC);
           ZTZEROSTRING=sec2timestring(ZTZEROSEC);
           t_record_start_label.String=['RecStart ',RECORDSTARTSTRING];
           t_ztzero_start_label.String=['ZT0 at ', ZTZEROSTRING];
           e_record_start.String=RECORDSTARTSTRING;
           e_ztzero_start.String=ZTZEROSTRING;
           startcalibrate()
       catch
           RECORDSTARTSEC=0;
           ZTZEROSEC=0;
       end
       
       SCORELENGTH=SAMPLINGRATE_EEG*SCORESEC;
       %Measure the number of epochs
       NUMBEROFEPOCHS=floor(numel(EEG)/SCORELENGTH);
       %disp(NUMBEROFEPOCHS);
       EPOCHNUMBER=1;
       t_epochnumber_display.String=num2str(EPOCHNUMBER);
       t_totalepoch_display.String=strcat('/', num2str(NUMBEROFEPOCHS));
       %Extract the first epoch
       EEG_EPOCH=zeros(SCORELENGTH,1);
       EEG_EPOCH(1:SCORELENGTH,1)=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
       EMG_EPOCH=zeros(SCORELENGTH,1);
       EMG_EPOCH(1:SCORELENGTH,1)=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
       
       %Extract the first big epoch
       EEG_BIGEPOCH=zeros(SCORELENGTH*3,1);
       EEG_BIGEPOCH(1:SCORELENGTH*3,1)=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH*3,1);
       EMG_BIGEPOCH=zeros(SCORELENGTH*3,1);
       EMG_BIGEPOCH(1:SCORELENGTH*3,1)=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH*3,1);
       
       %calulate the FFT for the first time
       FFTLENGTH = 2^nextpow2(SCORELENGTH);                                 %Next power of 2 from length of IMAGE_FRAMES
       EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;                       %discrete data fourier transform
       EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                    %The frequency axis
       
       scoredfile=0;
       try
           sv=load(MATFILE,'SCOREVECTOR');
           SCOREVECTOR=sv.SCOREVECTOR;
           sc=load(MATFILE,'SCORESTRUCT');
           SCORESTRUCT=sc.SCORESTRUCT;
           asc=load(MATFILE, 'AUTOSCORESTRUCT');
           AUTOSCORESTRUCT=asc.AUTOSCORESTRUCT;
           psc=load(MATFILE, 'SCOREPARAMETERSTRUCT');
           SCOREPARAMETERSTRUCT=psc.SCOREPARAMETERSTRUCT;
           scoredfile=1;
       catch
           SCOREVECTOR=ones(1,NUMBEROFEPOCHS)*4;
           SCORESTRUCT=cell(1,NUMBEROFEPOCHS);
           SCORESTRUCT(:)={'u'};
           XPARAMETER=zeros(1,NUMBEROFEPOCHS);
           YPARAMETER=zeros(1,NUMBEROFEPOCHS);
           %Prepare an empty AUTOSCORE struct
           parfor i=1:NUMBEROFEPOCHS
               AUTOSCORESTRUCT(i).Epoch=i;
               AUTOSCORESTRUCT(i).EpochTime=i*SCORESEC;
               AUTOSCORESTRUCT(i).EpochZT=i*SCORESEC;
               AUTOSCORESTRUCT(i).State=4;
               AUTOSCORESTRUCT(i).StateColor=[0,0,0];
               AUTOSCORESTRUCT(i).StateType=0;
               AUTOSCORESTRUCT(i).AutoScoreAllow=1;
           end
           scoredfile=0;
       end
       scoreunith=SCORESEC/(60*60);
       SCORETIMEVEC=scoreunith:scoreunith:scoreunith*NUMBEROFEPOCHS;        %This vector contains the core time in units of hours (calculated from the begginning)
       ZTVECTOR=SCORETIMEVEC;
       EPOCH_TIME=1/SAMPLINGRATE_EEG:1/SAMPLINGRATE_EEG:SCORELENGTH/SAMPLINGRATE_EEG;
       %Set the Autoscore prepare button to red to indicate that this needs
       %to be done
       b_prepare_autoscore.BackgroundColor=[1,0.6,0.6];
       drawnow;
       %An initial call to the plotting routines
       plot_score();
       plot_all();
       if(scoredfile)
           plot_parameters();
           %Set the Autoscore prepare button to green to indicate that this
           %is not neccessary
           b_prepare_autoscore.BackgroundColor=[0.6,1,0.6];
           drawnow; 
       else
          %Set the Autoscore prepare button to red to indicate that this needs
          %to be done
          b_prepare_autoscore.BackgroundColor=[1,0.6,0.6];
          drawnow; 
       end
       %turn warkings back on now that the try-catch statements are done
       %with
       warning('on');
    end
    
    function load_base_varibale_names()
        %In this variant the user can also select from variables in the base
        %workspace load these
        BASEVARIABLES=evalin('base', 'who');
        if(isempty(BASEVARIABLES))   %There were no variables to be found
            BASEVARIABLES={'NO variables'};
        end
    end

    %Filter functions are here - parameters will be displayed in their own
    %figure window
    function get_filterwindow(hObject, callbackdata)
        %Set the Autoscore prepare button to red to indicate that this needs
        %to be redone after filtering
        b_prepare_autoscore.BackgroundColor=[1,0.6,0.6];
        drawnow;
        %filter constants
        eegnotchcenterf=50;
        emgnotchcenterf=50;
        eegnotchfstring='50';
        emgnotchfstring='50';
        
        eeghighpasscornerf=0.5;
        emghighpasscornerf=0.5;
        eeghighpassfstring='0.5';
        emghighpassfstring='0.5';
        
        filterwindowheight=400;
        filterwindowwidth=700;
        %Create a new figure overlaying the original GUI
        filterfigh=figure();
        filterfigh.Name='Filter Parameters';
        filterfigh.NumberTitle='off';
        filterfigh.Position=[500,SCSIZE(4)-(filterwindowheight+60),filterwindowwidth,filterwindowheight];
        filterfigh.Resize='off';
        filterfigh.Units='pixels';
        filterfigh.Color=[1,1,1];
        filterfigh.MenuBar='none';
        filterfigh.ToolBar='none';
        
        %Add axes for the eeg sample plot
        eegsplotaxes=axes();
        eegsplotaxes.Parent=filterfigh;
        eegsplotaxes.Units='pixels';
        eegsplotaxes.Position=[30,250,350,100];
        eegsplotaxes.Title.String='EEG';
        %Add axes for the emg sample plot
        emgsplotaxes=axes();
        emgsplotaxes.Parent=filterfigh;
        emgsplotaxes.Units='pixels';
        emgsplotaxes.Position=[30,100,350,100];
        emgsplotaxes.Title.String='EMG';
        %Add axes for the EEG FFT plot
        eegfplotaxes=axes();
        eegfplotaxes.Parent=filterfigh;
        eegfplotaxes.Units='pixels';
        eegfplotaxes.Position=[450,250,200,100];
        eegfplotaxes.Title.String='EEG Spectrum';
        %Add axes for the EMG FFT plot
        emgfplotaxes=axes();
        emgfplotaxes.Parent=filterfigh;
        emgfplotaxes.Units='pixels';
        emgfplotaxes.Position=[450,100,200,100];
        emgfplotaxes.Title.String='EMG Spectrum';
        
        %Filter definitions
        eegnotchf=designfilt('bandstopiir','FilterOrder',6, ...
               'HalfPowerFrequency1', (eegnotchcenterf-1),'HalfPowerFrequency2',(eegnotchcenterf+1), ...
               'DesignMethod','butter','SampleRate',SAMPLINGRATE_EEG);
        
        emgnotchf=designfilt('bandstopiir','FilterOrder',6, ...
               'HalfPowerFrequency1',(emgnotchcenterf-1),'HalfPowerFrequency2',(emgnotchcenterf+1), ...
               'DesignMethod','butter','SampleRate',SAMPLINGRATE_EMG);
           
        eeghighpassf=designfilt('highpassiir','FilterOrder',8, ...
                'PassbandFrequency',eeghighpasscornerf,'PassbandRipple',0.2, ...
                'SampleRate',SAMPLINGRATE_EEG);
        
        emghighpassf=designfilt('highpassiir','FilterOrder',8, ...
                'PassbandFrequency',emghighpasscornerf,'PassbandRipple',0.2, ...
                'SampleRate',SAMPLINGRATE_EMG);
        
        %Button for EEG and EMG notch filtering  
        b_eeg_notchfilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'Notch Filter EEG', 'Position', [20, 50,120,20], 'Callback', @eeg_notchfilter);
        t_eegnotchf_label=uicontrol('Parent', filterfigh, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','Hz', 'Position', [180, 50, 20, 20]);
        e_eegnotchf_input=uicontrol('Parent', filterfigh, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', eegnotchfstring, 'Position', [150, 50, 30, 20],'Callback',@eeg_notchf_input);
        e_eegnotchf_input=handle(e_eegnotchf_input);
        
        b_emg_notchfilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'Notch Filter EMG', 'Position', [20, 20,120,20], 'Callback', @emg_notchfilter);
        t_emgnotchf_label=uicontrol('Parent', filterfigh, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','Hz', 'Position', [180, 20, 20, 20]);
        e_emgnotchf_input=uicontrol('Parent', filterfigh, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', eegnotchfstring, 'Position', [150, 20, 30, 20],'Callback',@emg_notchf_input);
        e_emgnotchf_input=handle(e_emgnotchf_input);
        
        %Button for EEG and EMG high pass filtering
        b_eeg_highpassfilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'Highpassf EEG', 'Position', [220, 50,120,20], 'Callback', @eeg_highpassfilter);
        t_eeghighpassf_label=uicontrol('Parent', filterfigh, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','Hz', 'Position', [380, 50, 20, 20]);
        e_eeghighpassf_input=uicontrol('Parent', filterfigh, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', eeghighpassfstring, 'Position', [350, 50, 30, 20],'Callback',@eeg_highpassf_input);
        e_eeghighpassf_input=handle(e_eeghighpassf_input);
        
        b_emg_highpassfilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'Highpassf EMG', 'Position', [220, 20,120,20], 'Callback', @emg_highpassfilter);
        t_emghighpassf_label=uicontrol('Parent', filterfigh, 'Style', 'text', 'HorizontalAlignment', 'left', 'String','Hz', 'Position', [380, 20, 20, 20]);
        e_emghighpassf_input=uicontrol('Parent', filterfigh, 'Style', 'edit', 'HorizontalAlignment', 'left', 'String', emghighpassfstring, 'Position', [350, 20, 30, 20],'Callback',@emg_highpassf_input);
        e_emghighpassf_input=handle(e_emghighpassf_input);
        
        
        %Button to remove the filters
        b_eeg_nofilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'No Filter EEG', 'Position', [550, 50,120,20], 'Callback', @eeg_nofilter);
        b_emg_nofilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'No Filter EMG', 'Position', [550, 20,120,20], 'Callback', @emg_nofilter);
        
        %Button to close the window
        b_emg_nofilter=uicontrol('Parent', filterfigh, 'Style', 'pushbutton', 'FontSize', 10, 'ForegroundColor', [0,0,0] , 'String', 'DONE', 'Position', [420, 35,100,20], 'Callback', @close_filterwindow);
        
        %issue a first plot sample command
        plotsamples();
        
        %This function is activated by the close button
        function close_filterwindow(hObject, callbackdata)
            %issue a replot command to the main window
            epoch_forward(1,1);
            plot_all();
            close(filterfigh);
        end
        
        %redo the filters with new frequencies if the user changes inputs
        %EEG NOTCH
        function eeg_notchf_input(hObject, callbackdata)
            input=hObject.String;
            eegnotchcenterf=str2double(input);
            eegnotchfstring=input;
            %redo the filter
            %Filter definitions
            eegnotchf=designfilt('bandstopiir','FilterOrder',6, ...
               'HalfPowerFrequency1', (eegnotchcenterf-1),'HalfPowerFrequency2',(eegnotchcenterf+1), ...
               'DesignMethod','butter','SampleRate',SAMPLINGRATE_EEG);
        end
        %EEG HIGHPASS
        function eeg_highpassf_input(hObject, callbackdata)
            input=hObject.String;
            eeghighpasscornerf=str2double(input);
            eeghighpassfstring=input;
            %redo the filter
            %Filter definitions
            eeghighpassf=designfilt('highpassiir','FilterOrder',8, ...
                'PassbandFrequency',eeghighpasscornerf,'PassbandRipple',0.2, ...
                'SampleRate',SAMPLINGRATE_EEG);
        end
        %EMG NOTCH
        function emg_notchf_input(hObject, callbackdata)
            input=hObject.String;
            emgnotchcenterf=str2double(input);
            emgnotchfstring=input;
            %redo the filter
            %Filter definitions
            emgnotchf=designfilt('bandstopiir','FilterOrder',6, ...
               'HalfPowerFrequency1', (emgnotchcenterf-1),'HalfPowerFrequency2',(emgnotchcenterf+1), ...
               'DesignMethod','butter','SampleRate',SAMPLINGRATE_EEG);
        end
        %EMG HIGHPASS
        function emg_highpassf_input(hObject, callbackdata)
            input=hObject.String;
            emghighpasscornerf=str2double(input);
            emghighpassfstring=input;
            %redo the filter
            %Filter definitions
            emghighpassf=designfilt('highpassiir','FilterOrder',8, ...
                'PassbandFrequency',emghighpasscornerf,'PassbandRipple',0.2, ...
                'SampleRate',SAMPLINGRATE_EMG);
        end
        
        
        %The filtering function are child function of the window function
        %EEG filter functions
        function eeg_notchfilter(hObject, callbackdata)
            b_eeg_notchfilter.ForegroundColor=[1,0,0];
            drawnow;
            EEG=filtfilt(eegnotchf, EEG);
            b_eeg_notchfilter.ForegroundColor=[0,0,0,];
            drawnow;
            plotsamples();
        end
        function eeg_highpassfilter(hObject, callbackdata)
            b_eeg_highpassfilter.ForegroundColor=[1,0,0];
            drawnow;
            EEG=filtfilt(eeghighpassf, EEG);
            b_eeg_highpassfilter.ForegroundColor=[0,0,0];
            drawnow;
            plotsamples();
        end
        %Removes all filters by copying back the raw signal
        function eeg_nofilter(hObject, callbackdata)
            EEG=EEGRAW;
            plotsamples();
        end
        %EMG filter functions
        function emg_notchfilter(hObject, callbackdata)
            b_emg_notchfilter.ForegroundColor=[1,0,0];
            drawnow;
            EMG=filtfilt(emgnotchf, EMG);
            b_emg_notchfilter.ForegroundColor=[0,0,0,];
            drawnow;
            plotsamples();
        end
        function emg_highpassfilter(hObject, callbackdata)
            b_emg_highpassfilter.ForegroundColor=[1,0,0];
            drawnow;
            EMG=filtfilt(emghighpassf, EMG);
            b_emg_highpassfilter.ForegroundColor=[0,0,0];
            drawnow;
            plotsamples();
        end
        %Removes all filters by copying back the raw signal
        function emg_nofilter(hObject, callbackdata)
            EMG=EMGRAW;
            plotsamples();
        end
        %Plot function within the filter window 
        function plotsamples()
            %reload the data
            eegsample=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
            eegrawsample=EEGRAW((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
            emgsample=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
            emgrawsample=EMGRAW((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH,1);
            
            %calculate the ffts
            %calculate the FFts for the new epoch
            fftlen = SCORELENGTH;    
            fftxaxes=SAMPLINGRATE_EEG/2*linspace(0,1,fftlen/2+1);            
            eegfft=fft(eegsample, fftlen)/SCORELENGTH; 
            eegrawfft=fft(eegrawsample, fftlen)/SCORELENGTH;
            emgfft=fft(emgsample, fftlen)/SCORELENGTH; 
            emgrawfft=fft(emgrawsample, fftlen)/SCORELENGTH;
            
            %Plot the EEG and EMG samples
            axes(eegsplotaxes);
            plot(eegrawsample, '.k');
            hold on;
            plot(eegsample, '-r');
            hold off;
            eegsplotaxes.FontSize=6;
            eegsplotaxes.XLim=[0, inf];
            eegsplotaxes.Title.String='EEG';
            eegsplotaxes.Title.FontSize=8;
            axes(emgsplotaxes);
            plot(emgrawsample, '.k');
            hold on;
            plot(emgsample,'-r');
            hold off;
            emgsplotaxes.FontSize=6;
            emgsplotaxes.XLim=[0, inf];
            emgsplotaxes.Title.String='EMG';
            emgsplotaxes.Title.FontSize=8;
            %Plot the FFTs of the samples
            axes(eegfplotaxes)
            plot(fftxaxes(1:SCORELENGTH/2+1),2*abs(eegrawfft(1:SCORELENGTH/2+1)), '-k');
            hold on;
            plot(fftxaxes(1:SCORELENGTH/2+1),2*abs(eegfft(1:SCORELENGTH/2+1)), '-r');
            hold off;
            eegfplotaxes.XLim=[0,SAMPLINGRATE_EEG/2];
            emgfplotaxes.YLim=[0, max(2*abs(eegfft(2:SCORELENGTH/2)))];
            eegfplotaxes.XTick=0:10:fftlen/2+1;
            eegfplotaxes.FontSize=6;
            eegfplotaxes.Title.String='EEG Spectrum';
            eegfplotaxes.Title.FontSize=8;
            axes(emgfplotaxes)
            plot(fftxaxes(1:SCORELENGTH/2+1),2*abs(emgrawfft(1:SCORELENGTH/2+1)), '-k');
            hold on;
            plot(fftxaxes(1:SCORELENGTH/2+1),2*abs(emgfft(1:SCORELENGTH/2+1)), '-r');
            hold off;
            emgfplotaxes.XLim=[0,SAMPLINGRATE_EEG/2];
            emgfplotaxes.YLim=[0, max(2*abs(emgfft(2:SCORELENGTH/2)))];
            emgfplotaxes.XTick=0:10:fftlen/2+1;
            emgfplotaxes.FontSize=6;
            emgfplotaxes.Title.String='EMG Spectrum';
            emgfplotaxes.Title.FontSize=8;
        end
        %End of the plot functions for filtering
    end
    %End of the filter functions!

    function record_start(hObject, callbackdata)
        input=hObject.String;
        RECORDSTARTSTRING=input;
        hour=str2double(input(1:2));
        min=str2double(input(4:5));
        sec=str2double(input(7:8));
        RECORDSTARTSEC=hour*3600+min*60+sec;
        t_record_start_label.String=['RecStart ',RECORDSTARTSTRING]; 
        startcalibrate()
    end

    function ztzero_start(hObject, callbackdata)
        input=hObject.String;
        ZTZEROSTRING=input;
        hour=str2double(input(1:2));
        min=str2double(input(4:5));
        sec=str2double(input(7:8));
        ZTZEROSEC=hour*3600+min*60+sec;
        t_ztzero_start_label.String=['ZT0 at ', ZTZEROSTRING];
        startcalibrate();
    end

    function startcalibrate()
        ztscorestart=(RECORDSTARTSEC-ZTZEROSEC)/(60*60);
        ztscoreinterval=SCORESEC/(60*60);
        ztscoreend=ztscoreinterval*NUMBEROFEPOCHS+ztscorestart;
        ZTVECTOR=ztscorestart:ztscoreinterval:ztscoreend;
        for i=1:NUMBEROFEPOCHS
            AUTOSCORESTRUCT(i).EpochTZ=ZTVECTOR(i);
        end
        plot_score();
    end


 %Window control functions
    function window_forward(hObject, callbackdata)
        if(DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION<SCORELENGTH)
            DISPLAYWINDOWBEGIN=DISPLAYWINDOWBEGIN+SCROLLFACTOR*DISPLAYWINDOWDURATION;
            %Adjust axes accordingly
            eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
            emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        end
    end
    function window_backward(hObject, callbackdata)
        if(DISPLAYWINDOWBEGIN>0)
            DISPLAYWINDOWBEGIN=DISPLAYWINDOWBEGIN-SCROLLFACTOR*DISPLAYWINDOWDURATION;
            %Adjust axes accordingly
            eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
            emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        end
    end
    function window_shrink(hObject, callbackdata)
        %The time domain window zoom
        if(DISPLAYWINDOWDURATION<SCORELENGTH)
            DISPLAYWINDOWDURATION=2*DISPLAYWINDOWDURATION;
            %Adjust axes accordingly
            eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
            emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        else
            DISPLAYWINDOWDURATION=SCORELENGTH;
            %Adjust axes accordingly
            eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
            emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        end
    %The FFT Window zoom
    if(FFTZOOM<2)
        %Zoomed out to the max
    else
        FFTZOOM=FFTZOOM-1;
        fftaxes.XLim=[0,EEG_FDAQ/(20*FFTZOOM)];
    end
    end
    function window_expand(hObject, callbackdata)
        if(DISPLAYWINDOWDURATION>(SCORELENGTH/16))
            DISPLAYWINDOWDURATION=DISPLAYWINDOWDURATION/2;
            %Adjust axes accordingly
            eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
            emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        end
        %The FFT Window zoom
        if(FFTZOOM>4)
        %Zoomed in to the max
    else
        FFTZOOM=FFTZOOM+1;
        fftaxes.XLim=[0,EEG_FDAQ/(20*FFTZOOM)];
    end
    end
    function window_fill(hObject, callbackdata)
        DISPLAYWINDOWBEGIN=0;
        DISPLAYWINDOWDURATION=SCORELENGTH;
        eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
    end

    %The epoch control functions
    function epoch_backward(hObject, callbackdata)
        if(EPOCHNUMBER>1)
            EPOCHNUMBER=EPOCHNUMBER-1;
            t_epochnumber_display.String=num2str(EPOCHNUMBER);
            t_epochtime_display.String=sec2timestring(EPOCHNUMBER*SCORESEC);
            %Extract the epoch data
            EEG_EPOCH=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            EMG_EPOCH=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            if(EPOCHNUMBER>1 && EPOCHNUMBER<(NUMBEROFEPOCHS-1))
                EEG_BIGEPOCH=EEG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
                EMG_BIGEPOCH=EMG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
            end
            %calculate the FFts for the new epoch
            FFTLENGTH = 2^nextpow2(SCORELENGTH);                               %Next power of 2 from length of SCORELENTH
            EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;                     %discrete data fourier transform
            EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                  %The frequency axis
            plot_all();
            plot_score();
            plot_parameterdot();
        end
    end
    function epoch_forward(hObject, callbackdata)
        if(EPOCHNUMBER<NUMBEROFEPOCHS)
            EPOCHNUMBER=EPOCHNUMBER+1;
            t_epochnumber_display.String=num2str(EPOCHNUMBER);
            t_epochtime_display.String=sec2timestring(EPOCHNUMBER*SCORESEC);
            %Extract the epoch data
            EEG_EPOCH=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            EMG_EPOCH=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            if(EPOCHNUMBER>1 && EPOCHNUMBER<(NUMBEROFEPOCHS-1))
                EEG_BIGEPOCH=EEG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
                EMG_BIGEPOCH=EMG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
            end
            %calculate the FFts for the new epoch
            FFTLENGTH = 2^nextpow2(SCORELENGTH);                               %Next power of 2 from length of IMAGE_FRAMES
            EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;                     %discrete data fourier transform
            EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                          %The frequency axis
            plot_all();
            plot_score();
            plot_parameterdot();
        end
    end
    %This function turns a numerical value of time in seconds into a string
    %of hh:mm:ss
    function timestring=sec2timestring(timeinsec)
        hh=floor(timeinsec/(60*60));
        mm=floor((timeinsec-(hh*60*60))/60);
        ss=(timeinsec-hh*60*60-mm*60);
        %Convert numbers to strings adding a '0' for single digits
        if(hh>9)
            hhs=num2str(hh);
        else
            hhs=['0',num2str(hh)];
        end
        if(mm>9)
            mms=num2str(mm);
        else
            mms=['0',num2str(mm)];
        end
        if(ss>9)
            sss=num2str(ss);
        else
            sss=['0',num2str(ss)];
        end
        timestring=[hhs, ':', mms, ':', sss];
    end

    %This function controls the auto_advance state (called from UI control
    %checkbox)
    function check_auto_advance(hObject, callbackdata)
        checkstate=hObject.Value;
        AUTOADVANCE=checkstate;
    end

    %This function controls the auto_advance state (called from UI control
    %checkbox)
    function do_autoprotect(hObject, callbackdata)
        checkstate=hObject.Value;
        AUTOPROTECT=checkstate;
    end

    %This function controls the drawbig state (called from UI control
    %checkbox)
    function check_drawbig(hObject, callbackdata)
        checkstate=hObject.Value;
        DRAWBIG=checkstate;
        if(DRAWBIG)
            bigeegplothandle.Visible='on';
            bigemgplothandle.Visible='on';
            eegbigmarkerplothandle.Visible='on';
            emgbigmarkerplothandle.Visible='on';
            plot_all();
        end
        if(~DRAWBIG)
            bigeegplothandle.Visible='off';
            bigemgplothandle.Visible='off';
            eegbigmarkerplothandle.Visible='off';
            emgbigmarkerplothandle.Visible='off';
        end
    end
    %This function controls the direct epoch number input through the edit
    %window of epoch_jump
    function epoch_jump(hObject, callbackdata)
        input=str2double(get(hObject,'String'));
        if isnan(input)
            errordlg('You must enter a numeric value','Invalid Input','modal');
            uicontrol(hObject);
        return
        else
            if(input>NUMBEROFEPOCHS)
                input=NUMBEROFEPOCHS;
            end
            if(input<1)
                input=1;
            end
            EPOCHNUMBER=input;
            t_epochnumber_display.String=num2str(EPOCHNUMBER);
            t_epochtime_display.String=sec2timestring(EPOCHNUMBER*SCORESEC);
            %Extract the epoch data
            EEG_EPOCH=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            EMG_EPOCH=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
            if(EPOCHNUMBER>1 && EPOCHNUMBER<(NUMBEROFEPOCHS-1))
                EEG_BIGEPOCH=EEG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
                EMG_BIGEPOCH=EMG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
            end
            %calculate the FFts for the new epoch
            FFTLENGTH = 2^nextpow2(SCORELENGTH);                               %Next power of 2 from length of IMAGE_FRAMES
            EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;               %discrete data fourier transform
            EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                          %The frequency axis
            plot_score();
            plot_all();
            plot_parameterdot();
        end
    end

    function click_epoch(src,evtdata)
        location=evtdata.IntersectionPoint;
        hours=location(1);
        epoch=floor(hours*60*6);
        EPOCHNUMBER=epoch;
        t_epochnumber_display.String=num2str(EPOCHNUMBER);
        t_epochtime_display.String=sec2timestring(EPOCHNUMBER*SCORESEC);
        %Extract the epoch data
        EEG_EPOCH=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
        EMG_EPOCH=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
        if(EPOCHNUMBER>1 && EPOCHNUMBER<(NUMBEROFEPOCHS-1))
                EEG_BIGEPOCH=EEG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
                EMG_BIGEPOCH=EMG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
        end
        %calculate the FFts for the new epoch
        FFTLENGTH = 2^nextpow2(SCORELENGTH);                               %Next power of 2 from length of IMAGE_FRAMES
        EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;                      %discrete data fourier transform
        EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                          %The frequency axis
        plot_score();
        plot_all();
        plot_parameterdot();
    end

    function click_parameter_epoch(src,evtdata)
        %disp('click');
        location=evtdata.IntersectionPoint;
        x=location(1);
        y=location(2);
        xepoch=find(XPARAMETER>=x*0.99 & XPARAMETER<=x*1.01);       %Since the click is never *exactly* on the dot we ask for +/- 1%
        yepoch=find(YPARAMETER>=y*0.99 & YPARAMETER<=y*1.01);       %Since the click is never *exactly* on the dot we ask for +/- 1%
        %The two arrays are the linear indices of the data that fulfills
        %the criteria - intersect asks for shared points and we pick the
        %first one...
        xyepoch=intersect(xepoch,yepoch);
        EPOCHNUMBER=xyepoch(1);
        t_epochnumber_display.String=num2str(EPOCHNUMBER);
        t_epochtime_display.String=sec2timestring(EPOCHNUMBER*SCORESEC);
        %Extract the epoch data
        EEG_EPOCH=EEG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
        EMG_EPOCH=EMG((EPOCHNUMBER-1)*SCORELENGTH+1:EPOCHNUMBER*SCORELENGTH);
        if(EPOCHNUMBER>1 && EPOCHNUMBER<(NUMBEROFEPOCHS-1))
                EEG_BIGEPOCH=EEG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
                EMG_BIGEPOCH=EMG((EPOCHNUMBER-2)*SCORELENGTH+1:(EPOCHNUMBER+1)*SCORELENGTH);
        end
        %calculate the FFts for the new epoch
        FFTLENGTH = 2^nextpow2(SCORELENGTH);                               %
        EEG_FFT=fft(EEG_EPOCH, FFTLENGTH)/SCORELENGTH;                     %discrete data fourier transform
        EEG_FAXIS=EEG_FDAQ/2*linspace(0,1,FFTLENGTH/2+1);                  %The frequency axis
        plot_score();
        plot_all();
        plot_parameterdot();
    end
    
    %This function controls the EEGSCALE - if 0 there will be autoscaling
    %otherwise the value will be used to scale the y axis
    function eeg_scale_set(hObject, callbackdata)
        input=str2double(get(hObject,'String'));
        if isnan(input)
            EEGSCALE=0;
        return
        else
            if(input>=0)
                EEGSCALE=input;
            end
            if(input<0)
                EEGSCALE=-input;
            end
        end
        plot_all();
    end
    %This function controls the EMGSCALE - if 0 there will be autoscaling
    %otherwise the value will be used to scale the y axis
    function emg_scale_set(hObject, callbackdata)
        input=str2double(get(hObject,'String'));
        if isnan(input)
            EMGSCALE=0;
        return
        else
            if(input>=0)
                EMGSCALE=input;
            end
            if(input<0)
                EMGSCALE=-input;
            end
        end
        plot_all();
    end

    %This function controls the plotting - since the graphs can be updated
    %through many ways it is easier to do this centrally
    %All variables used are global
    function plot_score()
        DRAWDONE=0;
        %Display the epoch data
        axes(somnoaxes);
        plotpointx=SCORETIMEVEC(EPOCHNUMBER);
        plotpointy=SCOREVECTOR(EPOCHNUMBER);
        somnoplothandle=plot(SCORETIMEVEC,SCOREVECTOR, '-k', 'ButtonDownFcn', @click_epoch);
        somnoaxes.YLim=[0,4];
        somnoaxes.YTick=[0,1,2,3,4];
        somnoaxes.YTickLabel={'a','w','n','r','u'};
        somnoaxes.XLim=[0, (max(SCORETIMEVEC))];
        maxhour=floor(max(SCORETIMEVEC));
        somnoaxes.XTick=2:2:maxhour;
        somnoaxes.FontSize=8;
        somnoaxes.XLabel.String='Time (h)';
        somnoaxes.XLabel.FontSize=8;
        hold on;
        markerplothandle=plot(plotpointx, plotpointy, 'dr', 'MarkerSize',4);
        somnoaxes.ButtonDownFcn=@click_epoch;
        somnoaxes.Box='off';
        hold off;
        %end
        somnotopaxes.XLim=[ZTVECTOR(1), ZTVECTOR(end)];
        minzthour=fix(ZTVECTOR(1));
        maxzthour=fix(ZTVECTOR(end));
        somnotopaxes.XTick=minzthour:1:maxzthour;
        somnotopaxes.YTick=[];
        somnotopaxes.Box='off';
        somnotopaxes.FontSize=8;
        somnotopaxes.XLabel.String='ZT Time(h)';
        somnotopaxes.XLabel.FontSize=8;
        DRAWDONE=1;
    end
    
    function plot_all()
        %Read the color from the AUTOSCORESTRUCT
        epc=AUTOSCORESTRUCT(EPOCHNUMBER).StateColor;
        %EEG
        axes(eegaxes);
        plot(EPOCH_TIME, EEG_EPOCH, 'Color',epc);
        eegaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        ylabel(eegaxes, 'EEG (mV)');
        if(EEGSCALE>0)
            eegaxes.YLim=[-EEGSCALE, EEGSCALE];
        end
        %EMG
        axes(emgaxes);
        plot(EPOCH_TIME, EMG_EPOCH, 'Color', epc);
        emgaxes.XLim=[DISPLAYWINDOWBEGIN/SAMPLINGRATE_EEG, (DISPLAYWINDOWBEGIN+DISPLAYWINDOWDURATION)/SAMPLINGRATE_EEG];
        ylabel(emgaxes, 'EMG (mV)');
        xlabel(emgaxes, 'Time (s)');
        if(EMGSCALE>0)
            emgaxes.YLim=[-EMGSCALE, EMGSCALE];
        end
        
        %The FFTs
        axes(fftaxes);
        fvalues=EEG_FAXIS';
        plot(fvalues(1:SCORELENGTH/2+1), 2*abs(EEG_FFT(1:SCORELENGTH/2+1)),'Color', epc);
        fftaxes.XLim=[0,EEG_FDAQ/20];
        fftaxes.XTick=0:5:FFTLENGTH/2+1;
        fftaxes.XLabel.String='f (Hz)';
        fftaxes.XLabel.FontSize=8;
        fftaxes.FontSize=8;
        
    %Write the score
    thescore=SCORESTRUCT{EPOCHNUMBER};
    t_score_display.String=thescore;
    t_score_display.ForegroundColor=epc;
    
    if(EPOCHNUMBER>1)
        thescorebefore=SCORESTRUCT{EPOCHNUMBER-1};
        t_score_before_display.String=thescorebefore;
        bepc=AUTOSCORESTRUCT(EPOCHNUMBER-1).StateColor;
        t_score_before_display.ForegroundColor=bepc;
    end
    if(EPOCHNUMBER<NUMBEROFEPOCHS)
        thescoreafter=SCORESTRUCT{EPOCHNUMBER+1};
        t_score_after_display.String=thescoreafter;
        aepc=AUTOSCORESTRUCT(EPOCHNUMBER+1).StateColor;
        t_score_after_display.ForegroundColor=aepc;
    end
    
    if(DRAWBIG)
        %Plot the big data
        axes(bigeegaxes);
        bigeegplothandle=plot(EEG_BIGEPOCH,'Color', [0.5,0.5,0.5]);
        hold on;
        eegbigmarkerplothandle=plot([SCORELENGTH, SCORELENGTH*2], [0,0], '.r', 'MarkerSize',15);
        hold off;
        %Set the scale
        bigeegaxes.YLim=[-EEGSCALE,EEGSCALE];
        bigeegaxes.XLim=[0, inf];
        axes(bigemgaxes);
        bigemgplothandle=plot(EMG_BIGEPOCH,'Color', [0.5,0.5,0.5]);
        hold on;
        %draw the markers
        emgbigmarkerplothandle=plot([SCORELENGTH, SCORELENGTH*2], [0,0], '.r', 'MarkerSize',15);
        hold off;
        %Set the scale
        bigemgaxes.YLim=[-EMGSCALE,EMGSCALE];
        bigemgaxes.XLim=[0, inf];
        %For easier plotting make axes invisible here - unclutters the
        %display - graph is still visible
        bigeegaxes.Visible='off';
        bigemgaxes.Visible='off';
    else
        %No drawing update
    end
    DRAWDONE=1;
    %End of plot_all function
    end

    %This function selects the xparameter name
    function xparameter_select(hObject, callbackdata)
        items=hObject.String;
        index_selected=hObject.Value;
        item_selected = items{index_selected};
        XPARAMETERNAME=item_selected;
        plot_parameters();
    end
    
    %This function selects the yparameter name
    function yparameter_select(hObject, callbackdata)
        items=hObject.String;
        index_selected=hObject.Value;
        item_selected = items{index_selected};
        YPARAMETERNAME=item_selected;
        plot_parameters();
    end

    function plot_parameters()
        XPARAMETER=[AUTOSCORESTRUCT.(XPARAMETERNAME)];
        YPARAMETER=[AUTOSCORESTRUCT.(YPARAMETERNAME)];
        %Extract the set limits from the parameter struct
        xlimits=[SCOREPARAMETERSTRUCT.(XPARAMETERNAME)];
        ylimits=[SCOREPARAMETERSTRUCT.(YPARAMETERNAME)];
        %Extract the score
        sc=[AUTOSCORESTRUCT.State];
        %Extract the wake nrem and rem parts of the parameters
        xwake=XPARAMETER(sc==1);
        ywake=YPARAMETER(sc==1);
        xnrem=XPARAMETER(sc==2);
        ynrem=YPARAMETER(sc==2);
        xrem=XPARAMETER(sc==3);
        yrem=YPARAMETER(sc==3);
        
        %XY plot of the two parameters
        axes(autoscoreaxes);
        %Plot all of them black
        plot(XPARAMETER, YPARAMETER, '.','Color', [0,0,0], 'MarkerSize',4, 'ButtonDownFcn', @click_parameter_epoch);
        hold on;
        %Plot wake nrem and rem on top
        plot(xwake, ywake, '.', 'Color', [1,0.5,0.5], 'MarkerSize',4, 'ButtonDownFcn', @click_parameter_epoch);
        plot(xnrem, ynrem, '.', 'Color', [0.5,0.5,1], 'MarkerSize',4, 'ButtonDownFcn', @click_parameter_epoch);
        plot(xrem, yrem, '.', 'Color', [0.5,1,0.5], 'MarkerSize',4, 'ButtonDownFcn', @click_parameter_epoch);
        %Plot the parameterdot
        parameterdothandle=plot(XPARAMETER(EPOCHNUMBER), YPARAMETER(EPOCHNUMBER), '*r', 'MarkerSize',6, 'ButtonDownFcn', @click_parameter_epoch);
        hold 'off';
        autoscoreaxes.FontSize=8;
        autoscoreaxes.XLabel.String=XPARAMETERNAME;
        autoscoreaxes.YLabel.String=YPARAMETERNAME;
        
        %Plot the PARAMETERS over the recordingtime and their histograms
        axes(xparamtempaxes);
        plot(SCORETIMEVEC,XPARAMETER, 'Color',[0.3,0.3,0.3], 'ButtonDownFcn', @xtparam_click);
        hold on;
        xparameterdothandle=plot(SCORETIMEVEC(EPOCHNUMBER), XPARAMETER(EPOCHNUMBER), '.r', 'MarkerSize', 12);
        if(~isnan(xlimits(1)))
           xtparamlineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [xlimits(1),xlimits(1)], 'Color',[0,0.6,0]); 
        end
        if(~isnan(xlimits(2)))
           xtparamlineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [xlimits(2),xlimits(2)], 'Color',[0.6,0,0]); 
        end
        hold off;
        xparamtempaxes.XLim=[0, (max(SCORETIMEVEC))];
        maxhour=floor(max(SCORETIMEVEC));
        xparamtempaxes.ButtonDownFcn=@xtparam_click;
        xparamtempaxes.XTick=2:2:maxhour;
        xparamtempaxes.FontSize=6;
        xparamtempaxes.XLabel.String='Time (h)';
        xparamtempaxes.XLabel.FontSize=6;
        
        axes(xparamhistaxes);
        hx=histogram(XPARAMETER, 'BinMethod', 'fd', 'Normalization', 'probability', 'FaceColor', [0.3,0.3,0.3], 'EdgeColor', 'none');
        hold on;
        if(~isnan(xlimits(1)))
           xhparamlineh(1)=plot([xlimits(1),xlimits(1)], [0,1], 'Color',[0,0.6,0]); 
        end
        if(~isnan(xlimits(2)))
           xhparamlineh(2)=plot([xlimits(2),xlimits(2)], [0,1], 'Color',[0.6,0,0]); 
        end
        hold off;
        xparamhistaxes.FontSize=6;
        xparamhistaxes.YLim=[0, max(hx.Values)];
        
        axes(yparamtempaxes);
        plot(SCORETIMEVEC,YPARAMETER, 'Color', [0.3,0.3,0.3], 'ButtonDownFcn', @ytparam_click);
        hold on;
        yparameterdothandle=plot(SCORETIMEVEC(EPOCHNUMBER), YPARAMETER(EPOCHNUMBER), '.r', 'MarkerSize', 12);
        if(~isnan(ylimits(1)))
           ytparamlineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [ylimits(1),ylimits(1)], 'Color',[0,0.6,0]); 
        end
        if(~isnan(ylimits(2)))
           ytparamlineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [ylimits(2),ylimits(2)], 'Color',[0.6,0,0]); 
        end
        hold off;
        yparamtempaxes.XLim=[0, (max(SCORETIMEVEC))];
        maxhour=floor(max(SCORETIMEVEC));
        yparamtempaxes.ButtonDownFcn=@ytparam_click;
        yparamtempaxes.XTick=2:2:maxhour;
        yparamtempaxes.FontSize=6;
        yparamtempaxes.XLabel.String='Time (h)';
        yparamtempaxes.XLabel.FontSize=6;
        
        axes(yparamhistaxes);
        hy=histogram(YPARAMETER,'BinMethod', 'fd', 'Normalization', 'probability', 'FaceColor', [0.3,0.3,0.3], 'EdgeColor', 'none');
        hold on;
        if(~isnan(ylimits(1)))
           yhparamlineh(1)=plot([ylimits(1),ylimits(1)], [0,1], 'Color',[0,0.6,0]); 
        end
        if(~isnan(ylimits(2)))
           yhparamlineh(2)=plot([ylimits(2),ylimits(2)], [0,1], 'Color',[0.6,0,0]); 
        end
        hold off;
        yparamhistaxes.FontSize=6;
        yparamhistaxes.YLim=[0, max(hy.Values)];
    end
    
    %This function opens a new window and plot a big version of the
    %XPARAMETER
    function plot_xparam_big(hObject, callbackdata)
        XPARAMETER=[AUTOSCORESTRUCT.(XPARAMETERNAME)];
        xlimits=[SCOREPARAMETERSTRUCT.(XPARAMETERNAME)];
        xparam_big_h=figure();
        xparam_big_h.Visible='on';
        xparam_big_h.Units='pixels';
        xparam_big_h.ToolBar='none';
        xparam_big_h.MenuBar='none';
        xparam_big_h.Name=XPARAMETERNAME;
        xparam_big_h.NumberTitle='off';
        xparam_big_h.Position=[10,SCSIZE(4)-(WINDOWHEIGHT+60),WINDOWWIDTH,WINDOWHEIGHT];
        xparam_big_h.Resize='off'; 
        %Add the axes for the plot
        xparam_bigplotaxes=axes();
        xparam_bigplotaxes.Parent=xparam_big_h;
        xparam_bigplotaxes.Units='pixels';
        xparam_bigplotaxes.Position=[100,100, (WINDOWWIDTH-150), (WINDOWHEIGHT-150)];
        xparam_bigplotaxes.FontSize=16;
        xparam_bigplotaxes.ButtonDownFcn=@xparam_big_click;
        
        axes(xparam_bigplotaxes);
        %Plot the parameter and the limits (if set)
        xparam_bigplot=plot(SCORETIMEVEC,XPARAMETER, 'Color',[0.3,0.3,0.3], 'ButtonDownFcn', @xparam_big_click);
        hold on;
        if(~isnan(xlimits(1)))
           xparam_big_lineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [xlimits(1),xlimits(1)], 'Color',[0,0.6,0]); 
        end
        if(~isnan(xlimits(2)))
           xparam_big_lineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [xlimits(2),xlimits(2)], 'Color',[0.6,0,0]); 
        end
        xparam_bigplotaxes.Box='off';
        xparam_bigplotaxes.XLim=[0, (max(SCORETIMEVEC))];
        maxhour=floor(max(SCORETIMEVEC));
        xparam_bigplotaxes.ButtonDownFcn=@xparam_big_click;
        xparam_bigplotaxes.XTick=2:2:maxhour;
        xparam_bigplotaxes.FontSize=16;
        xparam_bigplotaxes.XLabel.String='Time (h)';
        xparam_bigplotaxes.XLabel.FontSize=18;
        xparam_bigplotaxes.YLabel.String=XPARAMETERNAME;
        xparam_bigplotaxes.YLabel.FontSize=18;
        %Add a close button
        b_close_xparam_bigplot=uicontrol('Parent', xparam_big_h, 'Style', 'pushbutton', 'FontSize', 12, 'String', 'CLOSE', 'Position', [150,40,150,30], 'Callback', @close_xparam_bigplot);
    end

    function close_xparam_bigplot(hObject, callbackdata)
        %Close the bigplot window
        close(xparam_big_h);
        %Update the lines on the small plots
        plot_parameters();
    end

    %This function opens a new window and plots a big version of the
    %YPARAMETER
    function plot_yparam_big(hObject, callbackdata)
        YPARAMETER=[AUTOSCORESTRUCT.(YPARAMETERNAME)];
        ylimits=[SCOREPARAMETERSTRUCT.(YPARAMETERNAME)];
        yparam_big_h=figure();
        yparam_big_h.Visible='on';
        yparam_big_h.Units='pixels';
        yparam_big_h.ToolBar='none';
        yparam_big_h.MenuBar='none';
        yparam_big_h.Name=YPARAMETERNAME;
        yparam_big_h.NumberTitle='off';
        yparam_big_h.Position=[10,SCSIZE(4)-(WINDOWHEIGHT+60),WINDOWWIDTH,WINDOWHEIGHT];
        yparam_big_h.Resize='off'; %  
        %Add the axes for the plot
        yparam_bigplotaxes=axes();
        yparam_bigplotaxes.Parent=yparam_big_h;
        yparam_bigplotaxes.Units='pixels';
        yparam_bigplotaxes.Position=[100,100, (WINDOWWIDTH-150), (WINDOWHEIGHT-150)];
        yparam_bigplotaxes.FontSize=16;
        yparam_bigplotaxes.ButtonDownFcn=@yparam_big_click;
        
        axes(yparam_bigplotaxes);
        %Plot the parameter and the limits (if set)
        yparam_bigplot=plot(SCORETIMEVEC,YPARAMETER, 'Color',[0.3,0.3,0.3], 'ButtonDownFcn', @yparam_big_click);
        hold on;
        if(~isnan(ylimits(1)))
           yparam_big_lineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [ylimits(1),ylimits(1)], 'Color',[0,0.6,0]); 
        end
        if(~isnan(ylimits(2)))
           yparam_big_lineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [ylimits(2),ylimits(2)], 'Color',[0.6,0,0]); 
        end
        yparam_bigplotaxes.Box='off';
        yparam_bigplotaxes.XLim=[0, (max(SCORETIMEVEC))];
        maxhour=floor(max(SCORETIMEVEC));
        yparam_bigplotaxes.ButtonDownFcn=@yparam_big_click;
        yparam_bigplotaxes.XTick=2:2:maxhour;
        yparam_bigplotaxes.FontSize=16;
        yparam_bigplotaxes.XLabel.String='Time (h)';
        yparam_bigplotaxes.XLabel.FontSize=18;
        yparam_bigplotaxes.YLabel.String=YPARAMETERNAME;
        yparam_bigplotaxes.YLabel.FontSize=18;
        %Add a close button
        b_close_yparam_bigplot=uicontrol('Parent', yparam_big_h, 'Style', 'pushbutton', 'FontSize', 12, 'String', 'CLOSE', 'Position', [150,40,150,30], 'Callback', @close_yparam_bigplot);
    end
    
    function close_yparam_bigplot(hObject, callbackdata)
        %close the bigplot window
        close(yparam_big_h);
        %Update the lines on the small plots
        plot_parameters();
    end


    function xtparam_click(src, evtdata)
        %disp('click');
        location=evtdata.IntersectionPoint;
        button=evtdata.Button;
        x=location(1);
        y=location(2);
        %Set the parameter
        switch button
            case 1 %left mouse button
                SCOREPARAMETERSTRUCT.(XPARAMETERNAME)(1)=y;
                %draw horizontal line at the lower border
                axes(xparamtempaxes);
                delete(xtparamlineh(1));
                hold on;
                xtparamlineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0,0.6,0]);
                hold off;
                %draw the histogram line at the lower border
                axes(xparamhistaxes);
                delete(xhparamlineh(1));
                hold on;
                xhparamlineh(1)=plot([y,y], [0,1], 'Color',[0,0.6,0]); 
                hold off;
            case 3 %right mouse button on a three button mouse
                %draw horizontal line at the upper border
                SCOREPARAMETERSTRUCT.(XPARAMETERNAME)(2)=y;
                axes(xparamtempaxes);
                delete(xtparamlineh(2));
                hold on;
                xtparamlineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0.6,0,0]);
                hold off;
                %draw the histogram line at the upper border
                axes(xparamhistaxes);
                delete(xhparamlineh(2));
                hold on;
                xhparamlineh(2)=plot([y,y], [0,1], 'Color',[0.6,0,0]); 
                hold off;
        end  
    end

    function ytparam_click(src, evtdata)
        %disp('click');
        location=evtdata.IntersectionPoint;
        button=evtdata.Button;
        x=location(1);
        y=location(2);
        %Set the parameter
        switch button
            case 1 %left mouse button
                SCOREPARAMETERSTRUCT.(YPARAMETERNAME)(1)=y;
                %draw horizontal line at the lower border
                axes(yparamtempaxes);
                delete(ytparamlineh(1));
                hold on;
                ytparamlineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0,0.6,0]);
                hold off;
                %draw the histogram line at the lower border
                axes(yparamhistaxes);
                delete(yhparamlineh(1));
                hold on;
                yhparamlineh(1)=plot([y,y], [0,1], 'Color',[0,0.6,0]); 
                hold off;
            case 3 %right mouse button on a three button mouse
                %draw horizontal line at the upper border
                SCOREPARAMETERSTRUCT.(YPARAMETERNAME)(2)=y;
                axes(yparamtempaxes);
                delete(ytparamlineh(2));
                hold on;
                ytparamlineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0.6,0,0]);
                hold off;
                %draw the histogram line at the upper border
                axes(yparamhistaxes);
                delete(yhparamlineh(2));
                hold on;
                yhparamlineh(2)=plot([y,y], [0,1], 'Color',[0.6,0,0]); 
                hold off;
        end  
    end

    function xparam_big_click(src, evtdata)
        %disp('click');
        location=evtdata.IntersectionPoint;
        button=evtdata.Button;
        x=location(1);
        y=location(2);
        %Set the parameter
        switch button
            case 1 %left mouse button
                SCOREPARAMETERSTRUCT.(XPARAMETERNAME)(1)=y;
                %draw horizontal line at the lower border
                axes(xparam_bigplotaxes);
                delete(xparam_big_lineh(1));
                hold on;
                xparam_big_lineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0,0.6,0]);
                hold off;
                
            case 3 %right mouse button on a three button mouse
                %draw horizontal line at the upper border
                SCOREPARAMETERSTRUCT.(XPARAMETERNAME)(2)=y;
                axes(xparam_bigplotaxes);
                delete(xparam_big_lineh(2));
                hold on;
                xparam_big_lineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0.6,0,0]);
                hold off;
        end  
    end

    function yparam_big_click(src, evtdata)
        %disp('click');
        location=evtdata.IntersectionPoint;
        button=evtdata.Button;
        x=location(1);
        y=location(2);
        %Set the parameter
        switch button
            case 1 %left mouse button
                SCOREPARAMETERSTRUCT.(YPARAMETERNAME)(1)=y;
                %draw horizontal line at the lower border
                axes(yparam_bigplotaxes);
                delete(yparam_big_lineh(1));
                hold on;
                yparam_big_lineh(1)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0,0.6,0]);
                hold off;
                
            case 3 %right mouse button on a three button mouse
                %draw horizontal line at the upper border
                SCOREPARAMETERSTRUCT.(YPARAMETERNAME)(2)=y;
                axes(yparam_bigplotaxes);
                delete(yparam_big_lineh(2));
                hold on;
                yparam_big_lineh(2)=plot([SCORETIMEVEC(1),SCORETIMEVEC(end)], [y,y], 'Color',[0.6,0,0]);
                hold off;
        end  
    end


    function plot_parameterdot()
        %On the XY display
        axes(autoscoreaxes);
        hold on;
        delete(parameterdothandle);
        parameterdothandle=plot(XPARAMETER(EPOCHNUMBER), YPARAMETER(EPOCHNUMBER), '*r', 'MarkerSize',6, 'ButtonDownFcn', @click_parameter_epoch);
        hold off;
        %On the XPARAMETER plot
        axes(xparamtempaxes);
        hold on;
        delete(xparameterdothandle);
        xparameterdothandle=plot(SCORETIMEVEC(EPOCHNUMBER), XPARAMETER(EPOCHNUMBER), '.r', 'MarkerSize', 12);
        hold off;
        %On the YPARAMETER plot
        axes(yparamtempaxes);
        hold on;
        delete(yparameterdothandle)
        yparameterdothandle=plot(SCORETIMEVEC(EPOCHNUMBER), YPARAMETER(EPOCHNUMBER), '.r', 'MarkerSize', 12);
        hold off;
    end
    
    %This function reads keyboard input for the main GUI figure
    function keyPress(src, e)
        %disp(e.Key);
        switch e.Key
             case 'rightarrow'
                 epoch_forward();
             case 'leftarrow'
                 epoch_backward();
             case 'uparrow'
                 window_expand();
             case 'downarrow'
                 window_shrink();
            case 'w'
                score_wake();
            case 'n'
                score_nrem();
            case 'r'
                score_rem();
            case 'u'
                score_unknown();
            case 'space'
                score_wake();
            case 'd'
                score_nrem();
            case 'f'
                score_rem();
            case 'numpad1'
                score_wake();
            case 'numpad2'
                score_nrem();
            case 'numpad3'
                score_rem();
            case 'numpad4'
                score_unknown();
         end
    end
    %End of keypress readout function
    
    %This function reads out the scroll wheel clicks and uses it to go
    %through the epochs (only the direction of the clicks is important not
    %the number!
   function mouseScroll(src,e)
        %disp(e.VerticalScrollCount);
        direction=e.VerticalScrollCount;
        if(DRAWDONE)
            if(direction>0)
                epoch_forward();
            end
            if(direction<0)
                epoch_backward();
            end
        end
   end
    
    %The functions that do the actual scoring
    function score_wake(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='w';
        SCOREVECTOR(EPOCHNUMBER)=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[1,0,0];
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end
    function score_wake_artefact(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='w*';
        SCOREVECTOR(EPOCHNUMBER)=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0.3,0,0];
        AUTOSCORESTRUCT(EPOCHNUMBER).EEGArtefact=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).WarnFlag=1;
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end

    function score_nrem(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='n';
        SCOREVECTOR(EPOCHNUMBER)=2;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=2;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0,0,1];
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end

    function score_nrem_artefact(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='n*';
        SCOREVECTOR(EPOCHNUMBER)=2;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=2;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0,0,0.5];
        AUTOSCORESTRUCT(EPOCHNUMBER).EEGArtefact=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).WarnFlag=1;
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end

    function score_rem(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='r';
        SCOREVECTOR(EPOCHNUMBER)=3;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=3;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0,1,0];
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end

    function score_rem_artefact(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='r*';
        SCOREVECTOR(EPOCHNUMBER)=3;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=3;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0,1,0];
        AUTOSCORESTRUCT(EPOCHNUMBER).EEGArtefact=1;
        AUTOSCORESTRUCT(EPOCHNUMBER).WarnFlag=1;
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();    
        end
    end

    function score_unknown(hObject, callbackdata)
        SCORESTRUCT{EPOCHNUMBER}='u';
        SCOREVECTOR(EPOCHNUMBER)=4;
        AUTOSCORESTRUCT(EPOCHNUMBER).State=4;
        AUTOSCORESTRUCT(EPOCHNUMBER).StateColor=[0,0,0];
        AUTOSCORESTRUCT(EPOCHNUMBER).WarnFlag=1;
        if(AUTOPROTECT)
            AUTOSCORESTRUCT(EPOCHNUMBER).AutoScoreAllow=0;
        end
        if(AUTOADVANCE)
            if(EPOCHNUMBER<NUMBEROFEPOCHS)
                epoch_forward();
            end
        else
            plot_score();
            plot_all();
        end
    end
    %End of scoring functions
    
    %This function svaes the score structure (lettered score w, n, r, u)
    %and scorevector (numbers 1,2,3,4) to the matlab file
    function score_save(hObject, callbackdata)
        %This function saves a new file with a '_sc' appended into the
        %folder containing EEG EMG SamplingRate and 
        oldcolor=b_score_save.BackgroundColor;
        oldstring=b_score_save.String;
        b_score_save.String='WAIT';
        b_score_save.BackgroundColor=[1,0,0];
        drawnow;
        switch FILETYPE
            case 'txt'
                newfilename=[FOLDERNAME, '/', TXTFILENAME(1:end-4), '_sc.mat'];
            case 'mat'
                newfilename=[FOLDERNAME, '/', MFILENAME(1:end-4), '_sc.mat'];
        end
        Sampling_Rate=SAMPLINGRATE_EEG;
        save(newfilename, 'EEG', 'EMG', 'Sampling_Rate', 'SCOREVECTOR', 'SCORESTRUCT', 'AUTOSCORESTRUCT', 'SCOREPARAMETERSTRUCT', 'RECORDSTARTSEC', 'ZTZEROSEC', 'SAMPLINGRATE_EEG', 'SAMPLINGRATE_EMG');
        b_score_save.BackgroundColor=oldcolor;
        b_score_save.String=oldstring;
        drawnow;
    end

    %This function saves the SCOREPARAMETERSTRUCT to a separate file
    function param_save(hObject, callbackdata)
        filter=[FOLDERNAME, '/*.mat'];
        [paramfilename, paramfilepath]=uiputfile(filter, 'Enter a file name for the parameters');
        save(paramfilename, 'SCOREPARAMETERSTRUCT');
        PFILENAME=paramfilename;
        PFILE=[paramfilepath, '/', paramfilename];
    end
    %This function loads SCOREPARAMETERSTRUCT from a file
    function param_load(hObject, callbackdata)
        filter=[FOLDERNAME, '/*.mat'];
        [paramfilename, paramfilepath]=uigetfile(filter, 'Select a file to load parameters from');
        scp=load(paramfilename, 'SCOREPARAMETERSTRUCT');
        SCOREPARAMETERSTRUCT=scp.SCOREPARAMETERSTRUCT;
        PFILENAME=paramfilename;
        PFILE=[paramfilepath, '/', paramfilename];
        plot_parameters();
    end

    function prepare_autoscore(hObject, callbackdata)
%         %All values are per epoch
%     name1='Epoch';                  %The epoch number - a bit redundant...
%     name2='EpochTime';              %The time (in seconds after the start of the recording) of the epoch beginning
%     name3='EpochZT';                %The zeitgeber time of the epoch in seconds after ZT0 (negative for times before ZT)
%     name4='State';                  %The assigned state (numerical 0=not classifiable, 1=wake, 2=nrem, 3=rem, 4=unclassified)
%     name5='StateColor';             %Three element vector to hold the color [r,g,b] with which the state is drawn    
%     name6='StateType';              %0=automatically scored, 1=manually scored
%     name7='AutoScoreAllow';         %0=autoscoring can not overwrite score, 1=autoscoring can overwrite score
%     name8='EEGArtefact';            %0 no artefact, 1 artefact
%     name9='EMGArtefact';            %0 no artefact, 1 artefact
%     name10='WarnFlag';              %Warning flag if autiscoring has discovered a problematic case
%     name11='EEGTotalP';             %Total EEG power 
%     name12='EEGDeltaP';             %EEG power in the 0.5 to 4 Hz band
%     name13='EEGThetaP';             %EEG power in the 6 to 10 Hz band
%     name14='EEGGammaP';             %EEG power in the gamma 30-80 Hz band
%     name15='EEGDeltaThetaRatio';    %Ratio of delta to theta power in the EEG
%     name16='EEGDeltaGammaRatio';    %Ratio of delta to gamma power in the EEG
%     name17='EEGMaxPeak';            %Peak Amplitude of the EEG in this epoch
%     name18='EEGBandBorder';         %Two element vector with the lower and upper bounds in HZ of a specially defined EEG band
%     name19='EEGBandPower';          %Power in this specially defined EEG band
%     name20='EMGPower';              %Total EMG power in this epoch (0.5 Hz to SAMPLINGRATE_EMG/2)
%     name21='EMGIntegral';           %Sum of the absolute EMG values for the epoch
%     name22='EMGVariance';           %Variance of the EMG in this Epoch
%     name23='EMGBAndBorder';         %Two element vector with the lower and upper bounds in Hz of a specially defined EMG band
%     name24='EMGBandPower';          %Power in this speciallz defined EMG band
%     name25='EMGP_over_Theta';       %EMG total power divided by EEG theta power
%     name26='EMGComplex';            %Measure of EMG total power times EEG delta power divided by (EEG theta power)^2
%     name27='EEGSpecP';              %Power values for the EEG spectrum
%     name28='EEGSpecF';              %Corresponding frequency values for the EEG spectrum
        %Constant variables
        eegfdaq=SAMPLINGRATE_EEG;
        emgfdaq=SAMPLINGRATE_EMG;
        fftlen=SCORELENGTH;
        eegmaxf=floor(eegfdaq/2);
        emgmaxf=floor(emgfdaq/2);
        eegbandborder=[10,15];
        emgbandborder=[50,80];
        
        oldstring=b_prepare_autoscore.String;
        b_prepare_autoscore.String='WAIT...';
        drawnow;
        
        parfor i=1:NUMBEROFEPOCHS
            eegbit=EEG((i-1)*SCORELENGTH+1:i*SCORELENGTH);
            emgbit=EMG((i-1)*SCORELENGTH+1:i*SCORELENGTH);

            eegtotalp=bandpower(eegbit,eegfdaq,[0.5, eegmaxf]);
            eegdeltap=bandpower(eegbit,eegfdaq,[0.5,4]);
            eegthetap=bandpower(eegbit,eegfdaq,[6,10]);
            eeggammap=bandpower(eegbit,eegfdaq,[30,80]);
            eegmaxpeak=max(eegbit);
            eegbandpower=bandpower(eegbit, eegfdaq,eegbandborder);

            emgtotalp=bandpower(emgbit, emgfdaq, [0.5, emgmaxf]);
            emgintegral=sum(abs(emgbit));
            emgvariance=var(emgbit);
            emgbandpower=bandpower(emgbit, emgfdaq, emgbandborder);
            
            %Calculate the fft for the EEG bit    
            eegspecf=eegfdaq/2*linspace(0,1,fftlen/2+1);            
            eegspec=fft(eegbit, fftlen)/fftlen; 
            eegspecp=2*abs(eegspec);

            %Fill the struct
            AUTOSCORESTRUCT(i).Epoch=i;
            AUTOSCORESTRUCT(i).EpochTime=SCORETIMEVEC(i);
            AUTOSCORESTRUCT(i).EpochZT=ZTVECTOR(i);
            AUTOSCORESTRUCT(i).State=SCOREVECTOR(i);
            AUTOSCORESTRUCT(i).StateColor=[0,0,0];
            AUTOSCORESTRUCT(i).StateType=0;
            AUTOSCORESTRUCT(i).AutoScoreAllow=1;
            AUTOSCORESTRUCT(i).WarnFlag=0;
            AUTOSCORESTRUCT(i).EEGArtefact=0;
            AUTOSCORESTRUCT(i).EMGArtefact=0;
            AUTOSCORESTRUCT(i).EEGTotalP=eegtotalp;
            AUTOSCORESTRUCT(i).EEGDeltaP=eegdeltap;
            AUTOSCORESTRUCT(i).EEGThetaP=eegthetap;
            AUTOSCORESTRUCT(i).EEGGammaP=eeggammap;
            AUTOSCORESTRUCT(i).EEGDeltaThetaRatio=eegdeltap/eegthetap;
            AUTOSCORESTRUCT(i).EEGDeltaGammaRatio=eegdeltap/eeggammap;
            AUTOSCORESTRUCT(i).EEGMaxPeak=eegmaxpeak;
            AUTOSCORESTRUCT(i).EEGBandBorder=eegbandborder;
            AUTOSCORESTRUCT(i).EEGBandPower=eegbandpower;
            AUTOSCORESTRUCT(i).EMGPower=emgtotalp;
            AUTOSCORESTRUCT(i).EMGIntegral=emgintegral;
            AUTOSCORESTRUCT(i).EMGVariance=emgvariance;
            AUTOSCORESTRUCT(i).EMGBandBorder=emgbandborder;
            AUTOSCORESTRUCT(i).EMGBandPower=emgbandpower;
            AUTOSCORESTRUCT(i).EMGP_over_Theta=emgtotalp/eegthetap;
            AUTOSCORESTRUCT(i).EMGComplex=(emgtotalp*eegdeltap)/(eegthetap^2);
            AUTOSCORESTRUCT(i).EEGSpecP=eegspecp;
            AUTOSCORESTRUCT(i).EEGSpecF=eegspecf;
        end
    b_prepare_autoscore.String=oldstring;
    b_prepare_autoscore.BackgroundColor=[0.6,1,0.6];
    drawnow;
    plot_parameters();
    end

    function do_autoscore(hObject, callbackdata)
        %THis has currently hardcoded heuristics
        %Will change soon.....
        
        parfor ii=1:NUMBEROFEPOCHS
            if(AUTOSCORESTRUCT(ii).AutoScoreAllow)
                eegtp=AUTOSCORESTRUCT(ii).EEGTotalP;
                eegtplim=SCOREPARAMETERSTRUCT.EEGTotalP;

                emgint=AUTOSCORESTRUCT(ii).EMGIntegral;
                emgintlim=SCOREPARAMETERSTRUCT.EMGIntegral;

                %Set to NREM if EEGTotalP is above lower threshold
                if(eegtp>eegtplim(1))
                    AUTOSCORESTRUCT(ii).State=2;
                    AUTOSCORESTRUCT(ii).StateType=0;
                    AUTOSCORESTRUCT(ii).StateColor=[0,0,1];
                    SCORESTRUCT{ii}='n';
                    SCOREVECTOR(ii)=2;
                end
                %Set to wake if EMGIntegral is above lower limit and EEGTotalP
                %is is below lower limit
                if(eegtp<eegtplim(1) && emgint>emgintlim(1))
                    AUTOSCORESTRUCT(ii).State=1;
                    AUTOSCORESTRUCT(ii).StateType=0;
                    AUTOSCORESTRUCT(ii).StateColor=[1,0,0];
                    SCORESTRUCT{ii}='w';
                    SCOREVECTOR(ii)=1;
                end
                %Set to REM if EMGIntegral is below lower limit and EEGTotalP
                %is is below lower limit
                if(eegtp<eegtplim(1) && emgint<emgintlim(1))
                    AUTOSCORESTRUCT(ii).State=3;
                    AUTOSCORESTRUCT(ii).StateType=0;
                    AUTOSCORESTRUCT(ii).StateColor=[0,1,0];
                    SCORESTRUCT{ii}='r';
                    SCOREVECTOR(ii)=3;
                end
                %Set to EEG artefact if EEGTotalP is above upper limit
                if(eegtp>eegtplim(2))
                    AUTOSCORESTRUCT(ii).EEGArtefact=1;
                    AUTOSCORESTRUCT(ii).StateColor=AUTOSCORESTRUCT(ii).StateColor*0.5;
                    AUTOSCORESTRUCT(ii).WarnFlag=1;
                end
                %Set to Unscored if EMGIntegral is above upper limit and
                %EEGTotalP is above and set EMG Artefact
                if(eegtp>eegtplim(1) && emgint>emgintlim(2))
                    AUTOSCORESTRUCT(ii).State=4;
                    AUTOSCORESTRUCT(ii).EMGArtefact=1;
                    AUTOSCORESTRUCT(ii).StateColor=[0,0,0];
                    AUTOSCORESTRUCT(ii).WarnFlag=1;
                    SCORESTRUCT{ii}='u';
                    SCOREVECTOR(ii)=4;
                end

            end
        end
        plot_all();
        plot_score();
        plot_parameters();
    %End of do_autoscore
    end

%End of main function GVLAB_sleepscore()
end

  