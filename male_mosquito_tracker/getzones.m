%function for selecting ROI (back wall) of each mosquito cage
function [Params] = getzones(Params)
Zones = {};
for foldNumber = 1:length(Params.Folders)
    cd(Params.Folders{foldNumber});
    vidName = Params.vidNames{foldNumber}{1};
    vid = VideoReader(vidName);
    zFrame = readFrame(vid);
    zFrame = insertText(zFrame,[50 1],'Select back wall of cage','FontSize',20);
    imshow(zFrame)
    hold on
    z1=drawrectangle();
    disp("press 'Enter' to continue")
    pause;
    z1=round(z1.Position);
    %select zone 1
    zFrame = insertShape(zFrame,'FilledRectangle',z1,'Opacity',0.5);
    imshow(zFrame)
    drawnow()
    Zones{foldNumber} = z1;
    cd(Params.FirstDir)
    close all
end
Params.Zones = Zones';

close all
end