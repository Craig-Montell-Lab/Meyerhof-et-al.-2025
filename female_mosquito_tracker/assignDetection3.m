%% Assign Detections to Tracks (mosquitoes) %this version can handle empty detections (051424)
function [assignments,unassignedTracks,unassignedDetections] = ...
    assignDetection3(tracks,DT,speedThresh)

% assign detections 
nTracks = length(tracks);
nDetections = size(DT,1);

% Compute the cost of assigning each detection to each track.
cost = nan(nDetections,nTracks); %rows are detections; columns are tracks
trackCTs=vertcat(tracks.predictedCentroid);
if ~isempty(trackCTs)
for i = 1:nDetections
    QueryPoints =DT(i,2:3);  
    [~,dist] = knnsearch(QueryPoints,trackCTs(:,2:3));
    cost(i,:) = dist;
end
end

% filter for speed
TooExpensive = find(cost>speedThresh|isnan(cost));
cost(TooExpensive)=1e5;
[assignment,~]=munkres(cost); %Hungarian Algorithm: Yi Cao (2024). Munkres Assignment Algorithm (https://www.mathworks.com/matlabcentral/fileexchange/20328-munkres-assignment-algorithm), MATLAB Central File Exchange. Retrieved August 5, 2024.

assignment(TooExpensive)=0;

[assignmentsX,assignmentsY] = find(assignment==1);
assignments = [assignmentsX,assignmentsY];

%find unassigned tracks 
unassignedTracks = find(~any(assignment,1));

%find unassigned detections 
unassignedDetections = find(~any(assignment,2));
end

