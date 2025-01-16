function [cleanTracks]=getTravelVector(cleanTracks)
HostSeekSpeed=0.4;
%calculates travel vector of clean tracks
%get distance per frame 
data={cleanTracks.data}';
XYs = cellfun(@(matrix) matrix(:, 2:3), data, 'UniformOutput', false);
XYs = cellfun(@(matrix) movmean(matrix,30,'omitnan','EndPoints','fill'),XYs, 'UniformOutput', false);

HostSeekLogical={cleanTracks.HostSeekLogical}';
%distance={cleanTracks.distance}';
distance = cellfun(@(matrix) sqrt((diff(matrix(:,1)).^2)+(diff(matrix(:,2)).^2)) ...
    ,XYs, 'UniformOutput', false);

% HostSeekLogical = cellfun(@(matrix) movmedian(matrix,30,'omitnan','EndPoints','fill')>HostSeekSpeed& ...
%  movmedian(matrix,30,'omitnan','EndPoints','fill')<1.5  ,distance, 'UniformOutput', false);
%% vector annotation begins here
TravelVector=cell(size(HostSeekLogical));
for i = 1:length(TravelVector)
    HSofI=HostSeekLogical{i};
    XYData=XYs{i};
    distData=distance{i};
    HSofI=distData>.1&HSofI==1;
    MoveVector=nan(size(HSofI));
    indices = findRepeatedOnes(HSofI);
    for ii=1:size(indices,1)
        startIdx=max(indices(ii,1)-1,1);
        endIdx=indices(ii,2);
        dX=diff(XYData(startIdx:endIdx,1));
        dY=-diff(XYData(startIdx:endIdx,2));%flip sign so that 90 degrees points up
        degrees=atan2d(dY,dX);
        
        %speed=rescale(distData(indices(ii,1):indices(ii,2)));%weight degrees by speed (to do)
%         WindowSize=1;
%         weightedDegrees=conv(degrees.*speed,ones(1,WindowSize)/WindowSize,'same');
%         movingAvgDegrees=movmean(degrees,WindowSize);
        movingAvgDegrees=degrees;
        MoveVector(endIdx-length(movingAvgDegrees)+1:endIdx)=movingAvgDegrees;
    end
    TravelVector(i,1)={MoveVector};
end
[cleanTracks.TravelVector]=TravelVector{:};













