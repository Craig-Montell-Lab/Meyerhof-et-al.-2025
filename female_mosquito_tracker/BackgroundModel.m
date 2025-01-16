%% this code generates the background model
numModels=5;
FrameStep=round(vid.NumFrames/numModels);
FrameSteps=nan(numModels,2);
minIdx=1;
for i = 1:numModels
    maxIdx=min(minIdx+FrameStep,vid.NumFrames);
    FrameSteps(i,:)=[minIdx,maxIdx];
    minIdx=maxIdx;
end

fIdx={};
for i = 1:numModels
    fIdx{i}=sort(randi([FrameSteps(i,1),FrameSteps(i,2)],100,1)');
end

med_model_store={};
for j=1:numModels

    frame_id = fIdx{j};
    vid.CurrentTime = 0;

    for i = 1:length(frame_id)
        get_im = rgb2gray(read(vid,frame_id(i)));
        im_rep(:,:,i) = (get_im);
    end

    disp("Calculating background model number "+num2str(j))
    med_model=median(im_rep,3);
    med_model_store{j}=med_model;
end

disp('Background Model Complete')


