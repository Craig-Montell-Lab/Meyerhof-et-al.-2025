
vid = VideoReader(vidName)


%% detecting
try
    release(hblob)
    clear(hblob)
end
hblob = vision.BlobAnalysis(...
    'CentroidOutputPort', true, ...
    'AreaOutputPort', true, ...
    'BoundingBoxOutputPort', true, ...
    'MinimumBlobAreaSource', 'Property',...
    'MajorAxisLengthOutputPort',true,...
    'MinorAxisLengthOutputPort',true,...
    'BoundingBoxOutputPort',true,...
    'EccentricityOutputPort',true,...
    'OrientationOutputPort',true,...
    'MinimumBlobArea', 10, ...
    'MaximumBlobArea', 80, ...
    'MaximumCount',1000000);%blob detector

vid.CurrentTime =0; %46.2 for window in frame
counter = 1
data = cell(vid.NumFrames,1);
% videoPlayer = vision.VideoPlayer;

cDims=(Params.Zones{foldNumber}) %crop dimensions

bModelCounter=1;
% med_model=med_model_store{bModelCounter};
% cMed_model=cropFrame(med_model,cDims);
% cMed_model_bi=imbilatfilt(cMed_model);
ForegroundThresh=0.2%0.2 for aedes males 0.35 for An. Steph.
numFrames=vid.NumFrames
while hasFrame(vid)
    frame = im2gray(readFrame(vid));
    cFrame=cropFrame(frame,cDims);

    % find stationary mosquitoes
    gaussFrame=imgaussfilt(double(cFrame),10);
    normFrame=rescale(double(cFrame)./gaussFrame);
    invFrame=1-normFrame;
    bpFrame=rescale(bpass(invFrame,1.5,10,.05)); %051424

    logFrame=(bpFrame>ForegroundThresh);
    [Areas,CTs,BB,MALs,MiALs,Orients,Ecens] = hblob(logFrame);
    kpIdx=Ecens<0.9;
    Areas=Areas(kpIdx,:);CTs=CTs(kpIdx,:);BB=BB(kpIdx,:);MALs=MALs(kpIdx,:);MiALs=MiALs(kpIdx,:);Orients=Orients(kpIdx,:);Ecens=Ecens(kpIdx,:);

    data{counter,1} = [double(Areas),double(CTs),double(BB),double(MALs),double(MiALs),double(Orients),double(Ecens)];
    DT = data{counter,1};
    counter = counter + 1
end

%% matching
% Detect moving objects, and track them across video frames.

counter = 1;
speedThresh = Params.speedThresh; 
invisibleLength=Params.invisibleLength;

[tracks] = creatFirstTrack2_kalman(data) %create empty structure for track data
[sTracks]=createStoreTracks()
[sTracks] = storeTracks2(tracks,sTracks,counter,[]) %create empty structure for stored data

nextId = size(tracks,1)+1
GO = 1
while GO == 1 && counter< size(data,1)

    counter = counter + 1

    DT = data{counter,1};

    %predict location based on Kalman Filter
    [tracks] = predictLocation_model_kalman(tracks);

    [assignments,unassignedTracks,unassignedDetections] = ...
        assignDetection3(tracks,DT,speedThresh);

    %update assigned tracks
    [tracks] = updateAssignment3(tracks,assignments,DT);

    %update unassigned tracks
    [tracks,del_ids] = confusingtracks(tracks,unassignedTracks,invisibleLength);

    %create new tracks
    [tracks,nextId] = newTracks2_kalman(tracks,unassignedDetections,DT,nextId);

    %store tracks
    [sTracks] = storeTracks2(tracks,sTracks,counter,del_ids); %create empty structure for stored data


end

%clean up sTracks data
minVisibleFrames = Params.minVisibleFrames %minimum number of visible frames
[cleanTracks] = cleanSTracks2(sTracks,minVisibleFrames);
[cleanTracks] = findTakeOffs2(cleanTracks,numFrames);
HostSeekSpeed=0.4;
[cleanTracks] = getHostSeeking2(cleanTracks,HostSeekSpeed);

% display tracking results
display_data_HS








