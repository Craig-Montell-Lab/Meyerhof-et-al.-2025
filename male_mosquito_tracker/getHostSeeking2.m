
function [cleanTracks]=getHostSeeking2(cleanTracks,HostSeekSpeed)
%get distance per frame 
data={cleanTracks.data}';
XYs = cellfun(@(matrix) matrix(:, 2:3), data, 'UniformOutput', false);
distance = cellfun(@(matrix) sqrt((diff(matrix(:,1)).^2)+(diff(matrix(:,2)).^2)) ...
    ,XYs, 'UniformOutput', false);
[cleanTracks.distance]=distance{:};

%%annotat with hostSeeking
%HostSeekSpeed=0.4;
% HostSeekLogical = cellfun(@(matrix) movmean(matrix,30,'omitnan','EndPoints','shrink')>HostSeekSpeed& ...
%  movmean(matrix,30,'omitnan','EndPoints','shrink')<1.5  ,distance, 'UniformOutput', false);

%distance = @(distance) cellfun(@(x) x .* (x <= 2), distance, 'UniformOutput', false);
for i= 1:length(distance)
    dist=distance{i,1};
    dist(dist>2)=0;
    distance{i,1}=dist;
end

HostSeekLogical = cellfun(@(matrix) movmedian(matrix,30,'omitnan','EndPoints','fill')>HostSeekSpeed& ...
 movmedian(matrix,30,'omitnan','EndPoints','fill')<1.5  ,distance, 'UniformOutput', false);

%fill in host seeking bouts that are separated by less than 1 second 
sameBoutcuttOff=30;
for i = 1:length(HostSeekLogical)
    HS=HostSeekLogical{i};
    HSIdx=find(HS==1);
    falseEndIdx=find(diff(HSIdx)<sameBoutcuttOff&diff(HSIdx)>1);
    for ii=1:length(falseEndIdx)
        FalseEnd=(HSIdx(falseEndIdx(ii)));
        FillEnd=min(find(HS(FalseEnd+1:end)>0)+FalseEnd);
        if FillEnd-FalseEnd<=sameBoutcuttOff
            HS(FalseEnd:FillEnd)=1;
        else
            warning('ERROR IN HS FILL: CHECK IDX')
        end
    end
end

[cleanTracks.HostSeekLogical]=HostSeekLogical{:};
end




