%% save data tables 
disp('Saving data tables')
dirContents = dir ;
strIdx = (strfind({dirContents.name},'.'));
strIdx = cellfun(@isempty,strIdx);
dirContents = dirContents(strIdx);

firstDir=pwd();
DataTable=table();
for i = 1:length(dirContents)
    cd(dirContents(i,:).name)
    try
        load(dirContents(i,:).name+".mat")
    catch
        lName=(dir('*.mat'));
        load(lName.name)
    end
    times=readtable("times.txt");
    StagePositions=readtable("StagePositions.txt");
    miniTable=table();
    miniTable.Genotype={dirContents(i,:).name};
    miniTable.vidTimes={times};
    miniTable.StagePos={StagePositions};
    miniTable.cleanTracks={masterData.cleanTracks};
    DataTable=[DataTable;miniTable];
    cd(firstDir)
end
save('DataTable.mat','DataTable')
disp('Saving data tables complete')

%% get takeoff data
[TakeOffData]=findTakeoffs3(DataTable);
%% get takeoff probabilities
filename = 'takeoffdata_2.xlsx';
writetable(TakeOffData,filename)

bootStrapTakeOffs
calculateTakeOffs_2


% %%
% nBins=150
% binnedData=table();
% for i = 1:height(TakeOffPattern)
%     DOI=TakeOffPattern(i,:).NumTakeOffs{:};
%     [binSum,binSEM] = binData2(DOI,nBins);
%     miniTable=table();
%     miniTable.binSum={binSum};
%     binnedData=[binnedData;miniTable];
% end
% TakeOffPattern=[TakeOffPattern,binnedData];
% % plot data here
% %close all
% figure
% Time=-TimeB4:(TimeB4+TimeAfter)/nBins:(TimeAfter)-((TimeAfter)/nBins)
% TakeOffPattern = sortrows(TakeOffPattern,'Light','ascend');
% [LDidx,~]=find(vertcat(TakeOffPattern.Light{:})=='LD')
% LD=[]
% for i = 1:length(LDidx)
%     DOI=TakeOffPattern(LDidx(i),:).binSum{:};
%     LD=[LD,DOI];
% end
% LDCount=TakeOffPattern(LDidx,:).NumMosquitos
% LDnorm=LD./LDCount'
% SEMplot(Time',LDnorm)
%
% [DLIdx,~]=find(vertcat(TakeOffPattern.Light{:})=='DL')
% DL=[]
% for i = 1:length(DLIdx)
%     DOI=TakeOffPattern(DLIdx(i),:).binSum{:};
%     DL=[DL,DOI];
% end
% DLCount=TakeOffPattern(DLIdx,:).NumMosquitos
%
% DLnorm=DL./DLCount'
% SEMplot(Time',DLnorm,'blue')
% xlabel('Time (s)')
% ylabel('Proportion take off')
% % plot cumulative takeoffs
% figure
% SEMplot(Time',cumsum(LD)./LDCount')
% hold on
% SEMplot(Time',cumsum(DL)./DLCount','blue')
% xlabel('Time (s)')
% ylabel('Cumulative takeoffs')
%

% %% host seeking over time
% sbs={};
% counter =1;
% for x=1:height(DataTable)
%     DOI=DataTable(x,:).cleanTracks{:};
%     numFrames=height(DataTable(x,:).vidTimes{:});
%     secondBySecond=zeros(numFrames,length(DOI));
%     for j = 1:length(DOI)
%         trackedFrames=DOI(j).trackedFrames;
%         trackedFrames=trackedFrames(1:end-1,:);
%         HostSeekLogical=DOI(j).HostSeekLogical;
%         secondBySecond(trackedFrames,j)=secondBySecond(trackedFrames,j)+HostSeekLogical;
%     end
%   secondBySecond=sum(secondBySecond,2);
%   sbs{counter,1}=secondBySecond;
%   sbs{counter,2}=DataTable(counter,:).vidTimes{:}.Time_s;
%   counter=counter+1;
% end
%
%
% binLength=0.5;%bin length in seconds
% bMean=[]
% binMean=[];
% for i = 1:length(sbs)
%     [binMean,binTimes] = binDataHostSeek(sbs{i,1},sbs{i,2},binLength);
%     sbs{i,1}=[binMean];
%     sbs{i,2}=[binTimes];
% end
% %
% LDData=horzcat(sbs{1:18,1});
% DLData=horzcat(sbs{19:36,1});
%
% Time1= 2:binLength:150-binLength
% Time2= 0:binLength:150-binLength
%
% hold on
% SEMplot(Time2',LDData,'red','red')
% SEMplot(Time1',DLData,'blue','blue')
%
% ylabel('Avg. host seeking')
% xlabel('Time (s)')
% ylim([0,30])
% FastStageMoveTime=0.83;
% slowStageMoveTime=12.03;
%
% patch([30 30+FastStageMoveTime 30+FastStageMoveTime 30],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
% patch([90 90+FastStageMoveTime 90+FastStageMoveTime 90],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
%
%
% patch([60 60+slowStageMoveTime 60+slowStageMoveTime 60],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
% patch([120 120+slowStageMoveTime 120+slowStageMoveTime 120],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
%
% %% number of tracked mosquitos over time
% sbs={};
% counter =1;
% for x=1:height(DataTable)
%     DOI=DataTable(x,:).cleanTracks{:};
%     numFrames=height(DataTable(x,:).vidTimes{:});
%     secondBySecond=zeros(numFrames,length(DOI));
%     for j = 1:length(DOI)
%         trackedFrames=DOI(j).trackedFrames;
%         trackedFrames=trackedFrames(1:end-1,:);
%         secondBySecond(trackedFrames,j)=secondBySecond(trackedFrames,j)+ones(length(trackedFrames),1);
%     end
%   secondBySecond=sum(secondBySecond,2);
%   sbs{counter,1}=secondBySecond;
%   sbs{counter,2}=DataTable(counter,:).vidTimes{:}.Time_s;
%   counter=counter+1;
% end
%
% figure
% binLength=0.5;%bin length in seconds
% bMean=[]
% binMean=[];
% for i = 1:length(sbs)
%     [binMean,binTimes] = binDataHostSeek(sbs{i,1},sbs{i,2},binLength);
%     sbs{i,1}=[binMean];
%     sbs{i,2}=[binTimes];
% end
% %
% DLData=horzcat(sbs{1:9,1});
% LDData=horzcat(sbs{1:18,1});
%
% Time1= 2:binLength:150-binLength
% Time2= 0:binLength:150-binLength
%
% hold on
% SEMplot(Time2',LDData,'red','red')
% SEMplot(Time1',DLData,'blue','blue')
%
% ylabel('Avg. landed mosquitoes')
% xlabel('Time (s)')
% ylim([0,30])
% FastStageMoveTime=0.83;
% slowStageMoveTime=12.03;
%
% patch([30 30+FastStageMoveTime 30+FastStageMoveTime 30],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
% %patch([60 60+FastStageMoveTime 60+FastStageMoveTime 60],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
% patch([90 90+FastStageMoveTime 90+FastStageMoveTime 90],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
% patch([120 120+FastStageMoveTime 120+FastStageMoveTime 120],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
%
%
% patch([60 60+slowStageMoveTime 60+slowStageMoveTime 60],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
% patch([120 120+slowStageMoveTime 120+slowStageMoveTime 120],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
%
% % figure
% % SEMplot(Time1(1:end-1)',diff(DLData)*-1,'blue','blue')
% % SEMplot(Time2(1:end-1)',diff(LDData)*-1,'red','red')
%
% %% take-offs over time
% sbs={};
% counter =1;
% for x=1:height(DataTable)
%     DOI=DataTable(x,:).cleanTracks{:};
%     numFrames=height(DataTable(x,:).vidTimes{:});
%     secondBySecond=zeros(numFrames,length(DOI));
%     for j = 1:length(DOI)
%         takeOffFrame=DOI(j).takeOffFrame;
%         if ~isnan(takeOffFrame)
%         secondBySecond(takeOffFrame,j)=secondBySecond(takeOffFrame,j)+1;
%         end
%     end
%   secondBySecond=sum(secondBySecond,2);
%   sbs{counter,1}=secondBySecond;
%   sbs{counter,2}=DataTable(counter,:).vidTimes{:}.Time_s;
%   counter=counter+1;
% end
%
% figure
% binLength=1;%bin length in seconds
% bMean=[]
% binMean=[];
% for i = 1:length(sbs)
%     [binMean,~,binSum] = binDataHostSeek(sbs{i,1},sbs{i,2},binLength);
%     sbs{i,1}=[binSum];
%     sbs{i,2}=[binTimes];
% end
% %
% DLData=horzcat(sbs{1:18,1});
% LDData=horzcat(sbs{19:36,1});
%
% Time1= 2:binLength:150-binLength
% Time2= 0:binLength:150-binLength
% figure
% hold on
% SEMplot(Time2',LDData./sum(LDData),'red','red')
% SEMplot(Time2',DLData./sum(DLData),'blue','blue')
%
% ylabel('Avg. landed mosquitoes')
% xlabel('Time (s)')
% ylim([0,.2])
% FastStageMoveTime=0.83;
% slowStageMoveTime=12.03;
%
%
% patch([30 30+FastStageMoveTime 30+FastStageMoveTime 30],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
% patch([90 90+FastStageMoveTime 90+FastStageMoveTime 90],[100 100 0 0], 'red','FaceAlpha',0.3,'LineStyle','none');
%
%
% patch([60 60+slowStageMoveTime 60+slowStageMoveTime 60],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
% patch([120 120+slowStageMoveTime 120+slowStageMoveTime 120],[100 100 0 0], 'm','FaceAlpha',0.3,'LineStyle','none');
%
