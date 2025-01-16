%Kalman Filter for predicting track location
function [tracks] = predictLocation_model_kalman(tracks)
for i = 1:length(tracks)
    tracks(i).age = tracks(i).age+1; %update age of track
    % Predict the current location of the track.
    if tracks(i).age<5 %if track is new, predicted location is current location
        tracks(i).predictedCentroid = tracks(i).data;
    else 
        KOI=tracks(i).kalman; %get kalman filter table
        KOI.Qestimate = {KOI.A{:} * KOI.Qestimate{:} + KOI.B{:} * KOI.u};
        KOI.P = {KOI.A{:} * KOI.P{:} * KOI.A{:}' + KOI.Ex{:}};
        if tracks(i).consecutiveInvisibleCount==0
            XYmat=[tracks(i).data(:,2);tracks(i).data(:,3)];
            % Kalman Gain
            KOI.K = {KOI.P{:}*KOI.C{:}'*inv(KOI.C{:}*KOI.P{:}*KOI.C{:}'+KOI.Ez{:})};
            KOI.Qestimate = {KOI.Qestimate{:} + KOI.K{:} * (XYmat - KOI.C{:} * KOI.Qestimate{:})};
            %KOI.P ={(eye(4)-KOI.K{:}*KOI.C{:})*KOI.P{:}};
        end
        KOI.P ={(eye(4)-KOI.K{:}*KOI.C{:})*KOI.P{:}};
        tracks(i).kalman=KOI;
        dataPacket=nan(1,11);
        dataPacket(:,2:3)=[KOI.Qestimate{:}(1),KOI.Qestimate{:}(2)];
        tracks(i).predictedCentroid=dataPacket; %store Kalman-predicted location
    end
    
end



