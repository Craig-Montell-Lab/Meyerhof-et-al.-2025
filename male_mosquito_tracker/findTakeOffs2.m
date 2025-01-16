function [cleanTracks] = findTakeOffs2(cleanTracks,numFrames)
dataArray={cleanTracks.data};
frameArray={cleanTracks.trackedFrames};

takeOffs=nan(length(dataArray),1);
% Initialize last  NonNaN Index to an empty array
for i = 1:length(dataArray)
    cellOfInterest=dataArray{1,i};
    framesOfInterest=frameArray{1,i};
    [row,~]=find(~isnan(cellOfInterest));
    
    takeOffIdx=max(row);
    
    takeOffFrame=framesOfInterest(takeOffIdx)+1;
    if takeOffFrame<numFrames
        takeOffs(i,1)=takeOffFrame;
    else
        takeOffs(i,1)=nan;
    end
takeOffData=num2cell(takeOffs);
[cleanTracks.takeOffFrame]=takeOffData{:};
end
end

    
    
    