%% Visual threat tracker for male mosquitoes launch 
%Geoff Meyerhof 
%08/05/2024
%1.)
PATH2CODE='/Users/geoffmeyerhof/Desktop/visual_threat_code_final/male_mosquito_tracker';%add tracker code here path to code here 
addpath(PATH2CODE);
%2.) Navigate to folders with videos of interest 
%3.) Run Code 
%% get directory of interest (add directory to video files here)
selpath = uigetdir;
cd(selpath)
dirContents = dir ;
strIdx = (strfind({dirContents.name},'.'));
strIdx = cellfun(@isempty,strIdx);
dirContents = dirContents(strIdx);


%% create parameters object 
Params.FirstDir = pwd; %first directory to return to 
fullPath = {}
for i = 1:length(dirContents)
    fullPath{i,1} = strcat(dirContents(i).folder,'/',dirContents(i).name)
end
Params.Folders=fullPath
% get videos in each folder
allFiles = {}
for kk = 1:size(Params.Folders,1)
    cd(Params.Folders{kk})
    fileList = dir('*.avi')'
    fileList = {fileList.name}'
    allFiles{kk,1} = fileList
    cd(Params.FirstDir)
end
Params.vidNames = allFiles;

%get IR zones for each cage 
[Params] = getzones(Params)
%add analysis parameters 
Params.speedThresh = 10;
Params.invisibleLength=6;
Params.minVisibleFrames = 30; %minimum number of visible frames 
save("Params","Params")

%% Run tracking program in loop (this will loop over videos in directory of interest)
for foldNumber = 1:length(Params.Folders)
    cd(Params.Folders{foldNumber})
        vidName = Params.vidNames{foldNumber}{1}
        
        %run looming tracking program
        get_tracks_male
   
        %store output data
        masterData.rawData=data;
        masterData.allTracks = sTracks
        masterData.cleanTracks = cleanTracks
        
        %save data 
        saveName = vidName(1:end-4)
        save(saveName,"masterData")

    cd(Params.FirstDir)
end
%% Analyze data 
Analyze_data 








