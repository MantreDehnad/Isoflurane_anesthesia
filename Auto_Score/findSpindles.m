function [Spindles,out,stats] = findSpindles(EEG,EEG_By_Epoch,Stages,sr,Params)

if exist('Params','var')
    Up = Params(1);
    Down = Params(2);
    DurP = Params(3);
    disp(sprintf('Parameters are Up: %g, Down: %g, and DurP: %g.',Params));
    figFlag = 0;
else
    Up = 3.4;
    Down = .4;
    DurP = .25;
    figFlag = 1;
end

Wn = [10 13]; %set bandpass filter range in Hz
Wn = 2*Wn/sr;
B = fir1(200,Wn); % create 200th order FIR bandpass filter

%bandpass filter data from 10 to 13 Hz
FEEG = filtfilt(B,1,EEG);

FEEG_By_Epoch = reshape(FEEG, sr  * 2, []);

EpochTimeCenter = 1:2:size(FEEG_By_Epoch,2)*2 - 1;
EpochEEGPower = EpochTimeCenter*0;
h = spectrum.welch('Hamming',256,50);
for i=1:size(FEEG_By_Epoch,2),
    Hmss = msspectrum(h,FEEG_By_Epoch(:,i),'Fs',sr);
    EpochEEGPower(i) = sum(Hmss.Data);
end

[peakEEG,peakLocs] = findpeaks(EpochEEGPower);
peakTimes = EpochTimeCenter(peakLocs);

%rectify and lowpass data at 4 Hz
Wn = 2*4/sr;
RecEEG = abs(FEEG);
B = fir1(100,Wn);
FEEG2 = filtfilt(B,1,RecEEG).*sqrt(2);

time = (1:numel(FEEG))./sr;
% f1 = figure;
% ax1 = axes;
% filtSig = plot(time,FEEG,'k');
% title({'Filtered EEG signal for spindle Identification','Bandpassed at 10-13Hz'})
% xlabel('Time (s)')
% hold on
% Envelope = plot(time,FEEG2,'b','LineWidth',2);
% xlim([50 60])

upperThresh = Up*mean(FEEG2);
% upperThreshLine = plot(time,time*0+upperThresh,'r--','LineWidth',1);

lowerThresh = mean(FEEG2)-Down*std(FEEG2);
% lowerThreshLine = plot(time,time*0+lowerThresh,'m-.','LineWidth',1);

posSpindles = find(FEEG2>=upperThresh);

a = diff(posSpindles)';
b = find([a inf]>1);
c = diff([0 b]);
d = cumsum(c);

Spindles = zeros(numel(d),7);
lastSpot = 1;
h = spectrum.welch('Hamming',100,50);
EpochSize = size(EEG_By_Epoch,1);


for i=1:numel(d),
    if lastSpot<posSpindles(d(i)),
        spinStart = find(FEEG2(lastSpot:posSpindles(d(i)))<=lowerThresh,1,'last');
        spinStart = spinStart+lastSpot-1;
        
        spinEnd = find(FEEG2(posSpindles(d(i)):end)<=lowerThresh,1,'first');
        spinEnd = posSpindles(d(i))+spinEnd-1;
        lastSpot = spinEnd+1;
        
        %get spindle frequency
        spinData = FEEG(spinStart:spinEnd);
        Hmss = [];
        try
            Hmss = msspectrum(h,spinData,'Fs',sr);
        catch
            if numel(spinData)>=64
                h2 = spectrum.welch('Hamming',numel(spinData),50);
                Hmss = msspectrum(h2,spinData,'Fs',sr);
            end
        end
        
        if ~isempty(Hmss)
            spinSpectrum(:,i) = Hmss.Data;
            if i == 1
                Freq_Axis = Hmss.Frequencies;
            end
            [~,idx] = max(spinSpectrum(:,i));
            spinFreq = Freq_Axis(idx);
            
            spinAmp = max(FEEG(spinStart:spinEnd));
            
            spinEpoch = fix(spinStart/EpochSize) + (1*(mod(spinStart,EpochSize)~=0));
            spinState = Stages(spinEpoch);
            spinLen = spinEnd-spinStart;
            
            Spindles(i,:) = [spinStart,spinEnd,spinLen,spinFreq,spinAmp,spinEpoch,spinState];
            
%             spinHighlight = plot(time(spinStart:spinEnd),FEEG(spinStart:spinEnd),'g','LineWidth',1);
        end
    end
end

Spindles(find(Spindles(:,1)==0),:)=[];

%combine spindles that are super close together
for i=2:size(Spindles,1),
    if i>size(Spindles,1)
        break;
    end
    lastSpin = Spindles(i-1,2);
    thisSpin = Spindles(i,1);
    
    if time(thisSpin)-time(lastSpin)<=DurP,
        Spindles(i-1,2) = Spindles(i,2);
        Spindles(i-1,3) = Spindles(i-1,2)-Spindles(i-1,1);
        Spindles(i-1,4) = mean(Spindles(i-1:i,4));
        Spindles(i-1,5) = max(Spindles(i-1:i,5));
        Spindles(i,:) = [];
        i = i-1;
%         plot(time(lastSpin:thisSpin),FEEG(lastSpin:thisSpin),'g','LineWidth',1);
    end
end

%check spindles for EEG peak
for i=1:size(Spindles,1),
    if i>size(Spindles,1)
        break;
    end
    startTime = time(Spindles(i,1));
    endTime = time(Spindles(i,2));
    
    loc1 = find(EpochTimeCenter<=startTime,1,'last');
    loc2 = find(EpochTimeCenter>=endTime,1,'first');
    if isempty(loc2)
        loc2 = numel(EpochTimeCenter);
    end
    if isempty(loc1)
        loc1 = loc2-1;
    end
    if ~any(peakLocs>=loc1 & peakLocs<=loc2)
%         disp(['Spindle Removed at ' num2str(EpochTimeCenter(loc1)) ' due to no EEG peak.']);
        Spindles(i,:) = [];
        i = i-1;
    end
    
end

Spindles(:,3) = Spindles(:,3)/sr;

marker=1;
% xlim([time(Spindles(1,1))-2 time(Spindles(1,2))+2]);
% ylim([-upperThresh-100 upperThresh+100])

% title({'Filtered EEG signal for spindle Identification',...
%     'Bandpassed at 10-13Hz',[num2str(size(Spindles,1)) ' Spindles Found']})

% axes(ax1)
% legend([filtSig Envelope upperThreshLine lowerThreshLine spinHighlight],...
%     'Bandpassed Signal','Signal Envelope','Upper Threshold','Lower Threshold',...
%     'Spindles','Location','SouthWest')

% fig_pos = get(f1,'Position');
% nextSpin = uicontrol('Style','pushbutton','String','>',...
%     'Position',[fig_pos(3)-30 0 30 30],'Callback',@next_spin);
% 
% prevSpin = uicontrol('Style','pushbutton','String','<',...
%     'Position',[fig_pos(3)-60 0 30 30],'Callback',@prev_spin);

if figFlag
    f2 = figure;
    [hax,~,hline] = plotyy(EpochTimeCenter,EpochEEGPower,time,FEEG,'bar','plot');
    set(hline,'Color',[0 0 1]);
    axes(hax(1))
    title({'Filtered EEG signal for spindle Identification',...
        'Bandpassed at 10-13Hz',[num2str(size(Spindles,1)) ' Spindles Found']});
    yyyy = ylabel('EEG Power from 10-13 Hz');
    set(yyyy,'Units','normalized','Position',[-.05,.2,0])
    xlabel('Time (Sec)');
    axes(hax(2))
    ylabel('Filtered EEG Signal');
    hold on
    
    %show EEG peak positions
%     yRang = get(gca,'YLim');
%     for i=1:numel(peakTimes),
%         plot([peakTimes(i) peakTimes(i)],yRang,'r-','LineWidth',1)
%     end


    set(hline,'LineWidth',1)
    for i=1:size(Spindles,1),
        spin2 = plot(hax(2),time(Spindles(i,1):Spindles(i,2)),FEEG(Spindles(i,1):Spindles(i,2)),'g','LineWidth',1);
    end
    Env2 = plot(hax(2),time,FEEG2,'k','LineWidth',2);
    low2 = plot(hax(2),time,time*0+lowerThresh,'m--','LineWidth',1);
    high2 = plot(hax(2),time,time*0+upperThresh,'r--','LineWidth',1);
    legend([hline Env2 high2 low2 spin2],...
        'Bandpassed Signal','Signal Envelope','Upper Threshold','Lower Threshold',...
        'Spindles','Location','NorthEast')
    fig_pos = get(f2,'Position');
    nextPush = uicontrol('Style','pushbutton','String','>',...
        'Position',[fig_pos(3)-30 0 30 30],'Callback',@next_spin);
    
    prevPush = uicontrol('Style','pushbutton','String','<',...
        'Position',[fig_pos(3)-60 0 30 30],'Callback',@prev_spin);
    
    set(hax,'XLim',[0 20])
end

    function next_spin(~,~,~)
        if marker<size(Spindles,1),
            marker = marker+1;
%             if ishandle(ax1)
%                 axes(ax1)
%                 xlim([time(Spindles(marker,1))-2 time(Spindles(marker,2))+2]);
%                 ylim([-upperThresh-100 upperThresh+100])
%             end
            if ishandle(hax)
                set(hax,'Xlim',[time(Spindles(marker,1))-7 time(Spindles(marker,2))+7]);
            end
        end
    end

    function prev_spin(~,~,~)
        if marker>1,
            marker = marker-1;
%             if ishandle(ax1)
%                 axes(ax1)
%                 xlim([time(Spindles(marker,1))-2 time(Spindles(marker,2))+2]);
%                 ylim([-upperThresh-100 upperThresh+100])
%             end
            if ishandle(hax)
                set(hax,'Xlim',[time(Spindles(marker,1))-7 time(Spindles(marker,2))+7]);
            end
        end
    end


spinStates = Spindles(:,7);

SpinOut = Spindles;
SpinOut(:,1:2) = Spindles(:,1:2)/sr;


out = cell(size(Spindles,1)+12,size(Spindles,2));

out(3,1) = {['Average Spindle Length(Sec): ' num2str(mean(Spindles(:,3))) ' +- ' num2str(std(Spindles(:,3)))]};
out(4,1) = {['Average Spindle Frequency(Hz): ' num2str(mean(Spindles(:,4))) ' +- ' num2str(std(Spindles(:,4)))]};
out(5,1) = {['Average Spindle Amplitude(dB): ' num2str(mean(Spindles(:,5))) ' +- ' num2str(std(Spindles(:,5)))]};

out(7,1:3) = {'State','Time in State(Hrs)','# Spindles in State'};
out(8,1:3) = {'NREM',sum(Stages==2 | Stages==5)/360,sum(spinStates==2 | spinStates==5)};
out(9,1:3) = {'REM',sum(Stages==3 | Stages==6)/360,sum(spinStates==3 | spinStates==6)};
out(10,1:3) = {'Wake',sum(Stages==1 | Stages==4)/360,sum(spinStates==1 | spinStates==4)};

out(13:end,:) = num2cell(SpinOut);
out(12,:) = {'Spindle Start (Sec)','Spindle End (Sec)','Spindle Length(Sec)',...
    'Spindle Freq (Hz)','Spindle Amplitude (dB)',...
    'Spindle Epoch','Spindle Epoch State'};

if nargout==3
    stats = [mean(Spindles(:,3)) sum(spinStates==2 | spinStates==5) sum(spinStates==1 | spinStates==4)];
end


end

