function [ret,header] = findEpisodes(Stages,Delta_Power,Theta_Power,Epoch_Dur,StartCrit)
%Written by Roshan Nanu, July 2014
%this returns a list of all sleep episodes as differentiated by 3
%consecutive non-artifact epochs in a given state
%ret is setup as [epiode_state, episode_start_epoch, episode_length,
%incursions, mean_delta_power, mean_theta_power]
if ~exist('StartCrit','var')
    StartCrit = 30;
end
if ~isrow(Stages),
    Stages = Stages';
end
if ~isrow(Delta_Power),
    Delta_Power = Delta_Power';
end
if isempty(Theta_Power)
    Theta_Power = Delta_Power*0;
end
if ~isrow(Theta_Power),
    Theta_Power = Theta_Power';
end

total = length(Stages);

%sets criteria to start an episode to be StartCrit continuous seconds of 
%being in one state
startCrit = fix(StartCrit/Epoch_Dur)-1;

%finds all runs of startCrit+1 consecutive epochs in the same state
x = diff(Stages)==0;
f = find([false,x]~=[x,false]);
g = find(f(2:2:end)-f(1:2:end-1)>=startCrit);
ep_start = f(2*g-1);

%removes those started by artifacts or that are the same state as the
%previous episode
remove = [];
for i=2:length(ep_start),
    if Stages(ep_start(i-1))==Stages(ep_start(i))
        remove = [remove i];
        
    elseif Stages(ep_start(i-1))==Stages(ep_start(i))-3
        remove = [remove i];
        
    elseif Stages(ep_start(i))==7 || Stages(ep_start(i))==0
        remove = [remove i];
    end
end
ep_start(remove) = [];

%removes those that are the same state as the previous episode
remove = [];
for i=2:length(ep_start),
    if Stages(ep_start(i-1))==Stages(ep_start(i))
        remove = [remove i];
    end
end
ep_start(remove) = [];

%determines the length of each episode as well as the number of incursions
%and the mean delta power of the episode ignoring all artifacts
ep_lengths = diff([ep_start total+1]);
ep_state = Stages(ep_start);
for i=1:length(ep_start),
    si = ep_start(i);
    ei = si+ep_lengths(i)-1;
    incursions(i) = numel(find(Stages(si:ei)~=Stages(si) & Stages(si:ei)~=Stages(si)+3));
    dpow = Delta_Power(si:ei);
    dpow(find(Stages(si:ei)>3))=[];
    tpow = Theta_Power(si:ei);
    tpow(find(Stages(si:ei)>3))=[];
    delta(i) = mean(dpow);
    theta(i) = mean(tpow);
    ret(i,:) = [ep_state(i) ep_start(i) ep_lengths(i) incursions(i) delta(i) theta(i)];
end

header = {'Episode State','Start Epoch','Episode Duration','Incursions','Mean Delta Power','Mean Theta Power'};


end

