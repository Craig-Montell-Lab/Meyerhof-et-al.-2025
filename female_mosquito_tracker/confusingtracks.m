%% Update Unassigned Tracks
function [tracks,del_ids] = confusingtracks(tracks,unassignedTracks,invisibleLength)

for i = 1:length(unassignedTracks)
    
    ind = unassignedTracks(i);
    tracks(ind).consecutiveInvisibleCount = ...
    tracks(ind).consecutiveInvisibleCount + 1;
    tracks(ind).data  = nan(1,11);

end

%delete invisible tracks 
del_idx = vertcat(tracks.consecutiveInvisibleCount)>invisibleLength;

%delete short lived tracks
inVisi = vertcat(tracks.consecutiveInvisibleCount);
visi = vertcat(tracks.totalVisibleCount);
del_idx_1 = visi==1&inVisi==1;



del_idx = logical(del_idx_1 + del_idx);
if sum(del_idx)>0
    del_ids = tracks(del_idx).id;
else
    del_ids = [];
end
tracks(del_idx) = [];
end
