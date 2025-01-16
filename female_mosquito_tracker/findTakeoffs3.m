%%
function [TakeOffData]=findTakeoffs3(DataTable)
TimeB4=.5;%3;%seconds
TimeBuffer=0; %seconds
TimeAfter=1;%3;%seconds
TakeOffData=table();
TakeOffPattern=table();
for x = 1:height(DataTable)
    StagePos=DataTable.StagePos{x,1}.StagePositions;
    StagePos=cleanStagePos(StagePos,10);%10

    DarkStagePos=max(StagePos);
    LightStagePos=min(StagePos);
    
    
    VidTimes=DataTable.vidTimes{x,1}.Time_s;
    VidFrames=(1:length(VidTimes))';
    
    indices = find(StagePos == LightStagePos & circshift(StagePos, -1)>LightStagePos);
    LDStartIdx=indices(indices>1);
%     %round indices to closest whole number in time step
%     TargetTime=round(VidTimes(LDStartIdx));
%     [LDStartIdx, ~] = arrayfun(@(x) find(abs(VidTimes - x) == min(abs(VidTimes - x)),1), TargetTime);
    
    
    indices = find(StagePos == DarkStagePos & circshift(StagePos, -1)<DarkStagePos);
    DLStartIdx=indices(indices<length(StagePos));
%     %round indices to closest whole number in time step
%     TargetTime=round(VidTimes(DLStartIdx));
%     [DLStartIdx, ~] = arrayfun(@(x) find(abs(VidTimes - x) == min(abs(VidTimes - x)),1), TargetTime);

    StageMoveTable=table();
    for xx=1:length(LDStartIdx)
        SMT=table();
        SMT.MoveIdx=LDStartIdx(xx);
        %find stage move time 
        QueryPos=StagePos(LDStartIdx(xx):end);
        QueryPos=min(find(QueryPos==DarkStagePos))+LDStartIdx(xx);
        StageMoveTime=VidTimes(QueryPos)-VidTimes(LDStartIdx(xx));
        SMT.endIdx=QueryPos;
        SMT.StageMoveTime=StageMoveTime;
        SMT.Light='LD';
        StageMoveTable=[StageMoveTable;SMT];
        %disp('A')
    end
    for xx=1:length(DLStartIdx)
        SMT=table();
        SMT.MoveIdx=DLStartIdx(xx);
        %find stage move time 
        QueryPos=StagePos(DLStartIdx(xx):end);
        QueryPos=min(find(QueryPos==LightStagePos))+DLStartIdx(xx);
        StageMoveTime=VidTimes(QueryPos)-VidTimes(DLStartIdx(xx));
        SMT.StageMoveTime=StageMoveTime;
        SMT.endIdx=QueryPos;
        SMT.Light='DL';
        StageMoveTable=[StageMoveTable;SMT];
        %('disp B')
    end
   

    
    for i = 1:height(StageMoveTable)
        idx=StageMoveTable(i,:).MoveIdx;
        endIdx=StageMoveTable(i,:).endIdx;
        Lighting={StageMoveTable(i,:).Light};
        StageMoveTotalTime=StageMoveTable(i,:).StageMoveTime+TimeAfter;
        StartTime=VidTimes(idx)-TimeB4;
        [~,StartFrame]=min(abs(StartTime-VidTimes));
        
        BufferTime=StartTime+TimeBuffer;
        [~,BufferFrame]=min(abs(BufferTime-VidTimes));
        
        
        EndTime=VidTimes(endIdx)+TimeAfter;
        [~,EndFrame]=min(abs(EndTime-VidTimes));
        
        MosquitoID=[];
        TOF=[];
        Video=[];
        SF=[];
        EF=[];
        Lit={};
        cleanTracks=DataTable(x,:).cleanTracks{:};
        for j=1:length(cleanTracks)
            FOI=cleanTracks(j).trackedFrames;
            obsFrames=~isnan(cleanTracks(j).data(:,1));
            FOI=FOI(obsFrames);
            MosqID=cleanTracks(j).id;
            if sum(ismember(FOI,StartFrame:BufferFrame)) > 0
                MosquitoID=[MosquitoID;MosqID];
                TOF=[TOF;cleanTracks(j).takeOffFrame];
                Video=[Video;DataTable{x,1}];
                SF=[SF;StartFrame];
                EF=[EF;EndFrame];
                Lit=[Lit;Lighting];
            end
        end
        TakeOff=table();
        TakeOff.Video=Video;
        TakeOff.StartFrame=SF;
        TakeOff.EndFrame=EF;
        TakeOff.StageMoveFrame=repmat(idx,height(TakeOff),1);
        TakeOff.StageMoveTime=repmat(StageMoveTotalTime,height(TakeOff),1);
        TakeOff.MosquitoID=MosquitoID;
        TakeOff.takeOffFrame=TOF;
        TakeOff.normTakeOff=TOF-StartFrame;
        TakeOff.Light=Lit;%repmat(Lighting,height(TakeOff),1);
        TakeOffData=[TakeOffData;TakeOff];
             
    end
    
    
end

