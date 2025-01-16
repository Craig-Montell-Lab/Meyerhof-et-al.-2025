%Write annotated video with searching and takeoff behavior 
vidName = Params.vidNames{foldNumber}{1};
vid = VideoReader(vidName);
cDims=(Params.Zones{foldNumber}); %crop dimensions
if exist('DataTable','var')
    cleanTracks=DataTable(foldNumber,:).cleanTracks{:};
   [cleanTracks]=getHostSeeking2(cleanTracks,.18)
end
sVidName=vidName+"_data_v2"+".mp4";
v = VideoWriter(sVidName,'MPEG-4');
open(v)
disp('Writing annotated video file');
%videoPlayer=vision.VideoPlayer
%% display data
%video=VideoReader(vidName);
NumFrames=vid.numFrames
maxT=NumFrames;
%create empty data container
dispData = cell(1,max(vertcat(cleanTracks.id)));
HsData = cell(1,max(vertcat(cleanTracks.id)));
takeOffFrames=cell2mat({cleanTracks.takeOffFrame}');

for i = 1:length(dispData)
    dispData{1,i} = nan(maxT,11);
    HsData{1,i} = nan(maxT,1);
end
maxTF=0;
for i = 1:length(dispData)
    trackedFrames = cleanTracks(i).trackedFrames;
    dispData{1,i}(trackedFrames,:) = cleanTracks(i).data;
    HsData{1,i}(trackedFrames,1) = [0;cleanTracks(i).HostSeekLogical];
    if max(trackedFrames) > maxTF
        maxTF=max(trackedFrames);
    end
end

%display loop
vid.CurrentTime = 0;
videoPlayer = vision.VideoPlayer;
counter=1
for i = 1:maxTF
    frame = im2gray(readFrame(vid));
    frame=repmat(frame,[1 1 3]);
    frame=imcrop(frame,cDims);    
    XYs = [];
    pXYs = [];
    for ii = 1:length(dispData)
        XYs = [XYs;dispData{1,ii}(i,2:3)];
        pXYs = [pXYs;HsData{1,ii}(i,1)];
    end
    %get XY data
    XYs(:,3) = (1:size(XYs,1))';
    keepIdx=all(~isnan(XYs(:,1)),2);
    XYs = XYs(keepIdx,:);
    
    %get HS annotation
    pXYs(:,2) = (1:size(pXYs,1))';
    pXYs = pXYs(keepIdx,:);   
    
    hXYs=XYs(pXYs(:,1)==1,1:2);%HS XYs

    TOI=find(i==takeOffFrames);

    if isempty(XYs)&& isempty(TOI)
        sFrame = frame;
    else
        %show tracked data 
        sFrame = insertShape(frame,'FilledCircle',[XYs(:,1:2), ones(size(XYs,1),1).*4],'color','blue'); %annotate all mosquitos 
%         sFrame = insertText(sFrame,XYs(:,1:2),cellstr(num2str(XYs(:,3))),'FontSize',20,'BoxOpacity',0);%annotatee with id 
      
        %show hs data 
        sFrame = insertShape(sFrame,'FilledCircle',[hXYs(:,1:2), ones(size(hXYs,1),1).*4],'color','red'); %annotate all mosquitos 
%         sFrame = insertText(sFrame,pXYs(:,1:2),cellstr(num2str(pXYs(:,3))),'FontSize',10,'BoxOpacity',0,'TextColor','red');%annotatee with id 
%        sFrame = insertText(sFrame,[0 0],num2str(counter),'FontSize',20,'BoxOpacity',0);%annotatee with id 
        
        %show takeoff frame
        if ismember(i,takeOffFrames)%show take off
            for jj=1:length(TOI)
                dt = cleanTracks(TOI(jj)).data;
                id=cleanTracks(TOI(jj)).id;
                [rowIdx]=~isnan(dt(:,1));
                rowIdx=find(rowIdx==1);
                XY=dt(max(rowIdx),2:3);
                sFrame = insertShape(sFrame,'FilledCircle',[XY(:,1:2), ones(size(XY,1),1).*10],'color','green');
                %sFrame = insertText(sFrame,XY(:,1:2),cellstr(num2str(id)),'FontSize',20,'TextColor','blue','BoxOpacity',0);
            end
        end
    
    
    
    end
    writeVideo(v,sFrame)
    %videoPlayer(sFrame)
    %pause(1/30)
    disp("Writing annotated video: "+num2str(NumFrames-counter)+" frames remain")

    counter = counter + 1;
end
close(v)
disp('Done writing annotated video file');




