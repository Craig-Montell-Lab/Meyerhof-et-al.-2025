%% this code runs the blob detection and matching 
vid = VideoReader(vidName); %read in video 

%generate mode background model
BackgroundModel

%get dimensions for ROI in cage 
cDims=(Params.Zones{foldNumber}); 

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
    'MinimumBlobArea', 20, ...
    'MaximumBlobArea', 60, ...
    'MaximumCount',1000000);%blob detector

vid.CurrentTime = 0;%set video to first frame 
data = cell(vid.NumFrames,1);%create container for blob data 
counter = 1;%initialize counter for blobs
bModelCounter=1; %initialize counter for background model

med_model=med_model_store{bModelCounter};%get first background model
cMed_model=cropFrame(med_model,cDims); %crop background model
cMed_model_bi=imbilatfilt(cMed_model); %filter background model

numFrames=vid.NumFrames; %get total frames in vid

h=fspecial('log',40,2);%create structuring element for image convolution
for nn=1:numFrames
    disp("Getting blobs for frame "+num2str(counter));

    frame = im2gray(readFrame(vid));%read in frame 
    cFrame=cropFrame(frame,cDims);%crop frame
    bModel=imhistmatch(cMed_model,cFrame);%match frame intensity to background model
    dframe=imabsdiff(bModel,cFrame);%get absolute diff. between frame and background model
    J = rescale(conv2(dframe,h,'same'));%convolve frame and rescale pixel values 
    Thresh = prctile(J,.6,"all");%identify foreground pixel threshold
    logFrame=J<Thresh;%segment image
    
    %get blobs and store in cell array 
    [Areas,CTs,BB,MALs,MiALs,Orients,Ecens] = hblob(logFrame); 
    data{counter,1} = [double(Areas),double(CTs),double(BB),double(MALs),double(MiALs),double(Orients),double(Ecens)];

    counter = counter + 1; %increment counter
    
    %check whether background model should be updated 
    if counter>FrameSteps(bModelCounter,2)
        bModelCounter=bModelCounter+1;
        bModelCounter=min(bModelCounter,size(FrameSteps,1));
        med_model=med_model_store{bModelCounter};
        cMed_model=cropFrame(med_model,cDims);
        cMed_model_bi=imbilatfilt(cMed_model);
    end
end

%% matching 
% Match blobs across video frames 
counter = 1;%create counter for pulling blob data 
speedThresh = Params.speedThresh; %get speed threshold for matching
invisibleLength=Params.invisibleLength;%how many frames before we stop trying to match to object

[tracks] = creatFirstTrack2_kalman(data); %create empty structure for track data 
[sTracks]=createStoreTracks();%create empty structure for stored tracks
[sTracks] = storeTracks2(tracks,sTracks,counter,[]); %store first set of empty tracks 

nextId = size(tracks,1)+1;%get next mosquito ID
GO = 1;
while GO == 1 && counter< size(data,1)
    disp("Matching mosquitoes for frame "+num2str(counter))
    counter = counter + 1; %increment counter
    DT = data{counter,1}; %get blob data 
    
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

%clean up sTracks data (keep tracks that are visible for over a second)
minVisibleFrames = Params.minVisibleFrames; %minimum number of visible frames 
[cleanTracks] = cleanSTracks2(sTracks,minVisibleFrames);

%annotate cleanTracks object with takeoffs 
[cleanTracks] = findTakeOffs2(cleanTracks,numFrames);%find takeoff frame

%annotate cleanTracks with searching behavior 
HostSeekSpeed=0.2;%speed threshold for searching 
[cleanTracks]=getHostSeeking2(cleanTracks,HostSeekSpeed);

%annotate cleanTracks with vector of travel 
[cleanTracks]=getTravelVector(cleanTracks);

%write video with tracking results (optional) 
display_data_HS








