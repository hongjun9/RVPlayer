clear;
close all;
load('sample_data.mat');
%%sample_data: 
%motors
%states ["x(east)", "y(north)", "z(up)", "roll", "pitch", "yaw", "vx", "vy", "vz", "p", "q", "r"]; 
%timestamps

fs = 400;
Ts = 1/fs;
pos = states(1:3,:);
ang = states(4:6,:);
vel = states(7:9,:);
angvel = states(10:12,:);
time = timestamps;

struct_data =  struct('x', pos, 'theta', ang, 'vel', vel, 'angvel', angvel, 't', time, 'dt', Ts);
visualize(struct_data);


