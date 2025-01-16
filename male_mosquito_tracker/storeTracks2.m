%store Tracks in sTracks object
function sTracks = storeTracks2(tracks,sTracks,counter,del_ids)

ids = vertcat(tracks.id);

for i = 1:length(ids)
    IDpos = ids(i);
    sTracks(IDpos).id = IDpos;
    catFrames = [sTracks(IDpos).trackedFrames;counter];
    sTracks(IDpos).trackedFrames = catFrames;
    %concatenate data
    catData = [sTracks(IDpos).data;tracks(i).data(1,:)];
    sTracks(IDpos).data = catData;

    %concatenate predicted data
    catData = [sTracks(IDpos).data;tracks(i).data(1,:)];
    sTracks(IDpos).predictedData=[sTracks(IDpos).predictedData;tracks(i).predictedCentroid(1,:)];
end



end
