function StagePosClean=cleanStagePos(StagePos,Thresh)
badIdx=find(sqrt(diff(StagePos).^2)>Thresh);

for i = 1:length(badIdx)
    if badIdx(i)>1
        newNum=badIdx(i)-3:badIdx(i)+1;
        badIdx=[badIdx;newNum'];
    end
end
StagePosClean=StagePos;
StagePosClean(badIdx)=nan;
if ~isempty(badIdx)
% perform linear interpolation to fill in missing values 
x_known=1:length(StagePos);
y_known=StagePosClean;
% Find indices of missing values
missing_indices = badIdx;

% Perform linear interpolation using interp1 with 'linear' method
y_known(missing_indices) = interp1(x_known(~isnan(y_known)), y_known(~isnan(y_known)), x_known(missing_indices), 'linear');
StagePosClean=y_known;

badIdx=find(sqrt(diff(StagePosClean).^2)>Thresh);
if ~isempty(badIdx)
     StagePosClean=cleanStagePos(StagePosClean,Thresh);
end
end
    
    
    
    