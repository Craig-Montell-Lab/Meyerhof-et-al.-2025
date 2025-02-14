function [cleanTracks] = cleanSTracks2(sTracks,minVisibleFrames)

%filter tracks less than minVisibleFrames
A={sTracks.data}';

%%remove nanas
for i = 1:length(A)
    A{i} = A{i}(~isnan(A{i}(:,1)),:) ;
end

cellLengths =  (cellfun('size',A,1))';
killIdx = find(cellLengths < minVisibleFrames);
cleanTracks = sTracks;
cleanTracks(killIdx) = [];

%filter tracks with all nans
killIdx = find(cell2mat(cellfun(@(x) all(isnan(x(:,1))),{cleanTracks.data},'UniformOutput',false)))';
cleanTracks(killIdx) = [];

%filter tracks with < 5 observations
sumVis = cell2mat(cellfun(@(x) sum(~isnan(x(:,1))),{cleanTracks.data},'UniformOutput',false))';
killIdx = sumVis < 5;
cleanTracks(killIdx) = [];

% %re-label IDs
newIds = (1:length(vertcat(cleanTracks.id)))';
for i = 1:max(newIds)
    
    cleanTracks(i).id = newIds(i);
    
end
end

