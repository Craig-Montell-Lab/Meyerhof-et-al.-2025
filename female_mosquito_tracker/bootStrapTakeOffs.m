%% boot strap average takeoffs 
NumSamples=20000; %times to iterate over list of videos 
minMosq=10; %number of mosquitos to included for analysis (i.e., only take frames with at least 10 mosquitoes)

%Create output table
bootStrapTable=table();

%calculate average stage move time for each condition  
avgStageMoveTime = grpstats(TakeOffData, 'Light', {'mean'}, 'DataVars', 'StageMoveTime');

% calculate the average number of frames corresponding avg stage move time
TakeOffData.Diff = TakeOffData.EndFrame - TakeOffData.StartFrame;
avgDiffByLight = grpstats(TakeOffData, 'Light', {'mean'}, 'DataVars', 'Diff');

disp('Sampling to calculate spontaneous takeoffs')
for CondCount=1:height(avgDiffByLight)
Cond=avgStageMoveTime(CondCount,:).Light{:};
StageMoveTime=avgStageMoveTime(CondCount,:).mean_StageMoveTime ;
FramesPerMove= round(avgDiffByLight(CondCount,:).mean_Diff);
TimeWindow=StageMoveTime;
%Create time vs. mosquito count to generate potential indexes for sampling 
observedMosq={}; %cell array indicating which frames of video mosquito was observed on back wall (rows correpond to vid ID)    
MosqCount=[];% columns=vid Idx (in data table), time stamp, mosquitoes on backwall, vid length (s)
for i = 1:height(DataTable)
    vidTimes=DataTable(i,:).vidTimes{:};
    cleanTracks=DataTable(i,:).cleanTracks{:};
    onWall=zeros(height(vidTimes),length(cleanTracks));
    
    for mosqId=1:length(cleanTracks)
        TOF=cleanTracks(mosqId).takeOffFrame;
        if isnan(TOF)
            TOF=size(onWall,1);
        end
        FirstSeen=cleanTracks(mosqId).trackedFrames;
        FirstSeen=FirstSeen(1);
        onWall(FirstSeen:TOF,mosqId)=1;
    end
    %create temporary array 
    VidID=repmat(i,height(vidTimes),1);
    TimeStamp=vidTimes.Time_s;
    onWallSum=sum(onWall,2);
    numSeconds=repmat(max(TimeStamp),height(vidTimes),1);
    tIdx=1:length(TimeStamp);
    miniMosqCount=[VidID,TimeStamp,onWallSum,numSeconds,tIdx'];
    %censor indexes related to stage movement 
    vid=DataTable(i,:).Genotype{:};
    TOD=TakeOffData(strcmp(vid,TakeOffData.Video),:);
    TOD=TOD(strcmp(Cond,TOD.Light),:);
    uniqueStart=unique(TOD.StartFrame);
    uniqueEnd=unique(TOD.EndFrame);
    for cFrames=1:length(uniqueStart)
        CensorIdx1=find(miniMosqCount(:,5)==uniqueStart(cFrames)-60); %add two second buffer 
        CensorIdx2=find(miniMosqCount(:,5)==uniqueEnd(cFrames)+60); %add two second  buffer
        CensorFrames=[CensorIdx1:CensorIdx2];
        miniMosqCount(CensorFrames,:)=[];
    end
    %grow output table
    MosqCount=[MosqCount;miniMosqCount];
    
    %store on wall in cell array 
    observedMosq{i,1}=onWall;
end

%filter MosqCount by time and by minimum number of mosquitoes on back wall
%MosquitoFilt
idx=MosqCount(:,3)>minMosq;
MosqCount=MosqCount(idx,:);
%TimeFilt 
idx=MosqCount(:,2)<MosqCount(:,4)-TimeWindow;
MosqCount=MosqCount(idx,:);
%Filter stage move events 
% idx=MosqCount(:,2)>55&MosqCount(:,2)<75;
% idx2=MosqCount(:,2)>115&MosqCount(:,2)<135;
% idx=logical(idx+idx2);
% MosqCount=MosqCount(~idx,:);

%create indexes for random sampling of videos 
sampleIdx=randi([1, size(MosqCount,1)], 1, NumSamples);

vidId=nan(NumSamples,1);
TimeStamp=nan(NumSamples,1);
PropTO=nan(NumSamples,1);
for i = 1:length(sampleIdx)
    %get video ID
    vidID(i,1)=MosqCount(sampleIdx(i),1);
    %get recording of interest
    recordingOfInterest=observedMosq{vidID(i,1)};
    
    TimeStamp(i,1)=MosqCount(sampleIdx(i),2);
    startIdx=MosqCount(sampleIdx(i),5);
    
    %find end index 
    endIdx=startIdx+FramesPerMove;
    endIdx=min(endIdx,size(recordingOfInterest,1));
    
    %calculate Proportion that took off
    ThereAtStart=find(recordingOfInterest(startIdx,:)==1);
    ThereAtEnd=find(recordingOfInterest(endIdx,:)==1);
    PropTO(i,1)=1-sum(ismember(ThereAtStart,ThereAtEnd))/length(ThereAtStart);
end

figure
histogram(PropTO)
title("The mean takeoff rate for "+Cond+" is "+num2str(mean(PropTO)))
xline(mean(PropTO),'LineStyle','--','Color','red')

%makeTable
miniBSTable=table();
miniBSTable.Light={Cond};
miniBSTable.StageMoveTime=StageMoveTime;
miniBSTable.FramesPerMove=FramesPerMove;
miniBSTable.vidID={vidID};
miniBSTable.TimeStamp={TimeStamp};
miniBSTable.PropTO={PropTO};
miniBSTable.MedianPropTO={median(PropTO)};
miniBSTable.MeanPropTO={mean(PropTO)};
miniBSTable.SDPropTO={std(PropTO)};
%grow table 
bootStrapTable=[bootStrapTable;miniBSTable];
end
%%
save('bootStrapTable.mat', 'bootStrapTable')

%clearvars -except DataTable bootStrapTable TakeOffData



