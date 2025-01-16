%Create table for Kalman filter 
%Approach modified from Student Dave
%(https://studentdavestutorials.weebly.com/object-tracking-2d-kalman-filter.html)
function [kalmanFilter]=createKalman(DOI)
kalmanFilter=struct();
kalmanFilter.u=0.005;% define acceleration magnitude (0.005-works with small lag)
kalmanFilter.dt=1; %sampling rate
kalmanFilter.Fly_noise_mag=.3;%process noise: the variability in how fast the fly is speeding up (stdv of acceleration: pixels/sec^2) 
kalmanFilter.Q={[DOI(1,2);DOI(1,3);0;0]};%initized state--it has four components: [positionX; positionY; velocityX; velocityY] 
kalmanFilter.Qestimate=kalmanFilter.Q;
kalmanFilter.tkn_x=5;%measurement noise in the horizontal direction (x axis). 
kalmanFilter.tkn_y = 5;%measurement noise in the horizontal direction (y axis). 
kalmanFilter.Ez={[kalmanFilter.tkn_x 0; 0 kalmanFilter.tkn_y]};
kalmanFilter.Ex={[kalmanFilter.dt^4/4 0 kalmanFilter.dt^3/2 0; ...
    0 kalmanFilter.dt^4/4 0 kalmanFilter.dt^3/2; ...
    kalmanFilter.dt^3/2 0 kalmanFilter.dt^2 0; ...
    0 kalmanFilter.dt^3/2 0 kalmanFilter.dt^2].*kalmanFilter.Fly_noise_mag^2};% Ex convert the process noise (stdv) into covariance matrix
kalmanFilter.P=kalmanFilter.Ex;% estimate of initial fly position variance (covariance matrix)
kalmanFilter.K={zeros(4,2)};
%% kinematics equations 
kalmanFilter.A = {[1 0 kalmanFilter.dt 0; 0 1 0 kalmanFilter.dt; 0 0 1 0; 0 0 0 1]}; %state update matrice
kalmanFilter.B = {[(kalmanFilter.dt^2/2); (kalmanFilter.dt^2/2); kalmanFilter.dt; kalmanFilter.dt]};
kalmanFilter.C = {[1 0 0 0; 0 1 0 0]} ;


end
