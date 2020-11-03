clear;
close all;
currentFolder = pwd;

model_file = strcat(currentFolder, '/model_sitl.mat');
load(model_file); % read model

%nonlinear greybox model
model = nlgr_m;
present(model);
a = model.Parameters(1).Value;
b = model.Parameters(2).Value;
c = model.Parameters(3).Value;
d = model.Parameters(4).Value;
m = model.Parameters(5).Value;
I_x = model.Parameters(6).Value; 
I_y = model.Parameters(7).Value; 
I_z = model.Parameters(8).Value; 
K_T = model.Parameters(9).Value;
K_Q = model.Parameters(10).Value;

%%%%%
% important paraemters for compression
max_freq = 400;
sync_k = 400 * 5; %max_freq*10;     % 5 (sec)
%%%%%



%% Read test data
filename = 'Test7/00000247.csv';
test_data = csvread(filename, 2, 0);  
test_data(:, 1) = test_data(:, 1)-test_data(1, 1); % reset start time
%trim data (remove unnecessary parts with starting point (s) and end point (s)
    sp = 1; % starting point (s)
    ep = 270; % end point (s)
    isp = find(test_data(:,1) * 1e-6 > sp, 1);
    iep = find(test_data(:,1) * 1e-6 > ep, 1);
    if isempty(iep)
        iep = size(test_data,1);
    end
    test_data = test_data(isp:iep, :);

NX = 12;    
NY = 12;
NU = 4;
raw_timestamps = test_data(:,1) * 1e-6;    %(s)    time vector
time_us = test_data(:,1);
raw_states = test_data(:,2:13);            % array of state vector: 12 states
raw_motors = (((test_data(:,14:17)*1000)+1000)-1100)/900;   %SITL: (((0.5595*1000)+1000)-1100)/900=0.51
N = size(test_data,1);                 % size of samples
%========== to ENU ==============
% x <-> y, vx <-> vy
temp = raw_states(:,1); 
raw_states(:,1) = raw_states(:,2);
raw_states(:,2) = temp;
temp = raw_states(:,7); 
raw_states(:,7) = raw_states(:,8);
raw_states(:,8) = temp;
% z <-> -z, vz <-> -vz
raw_states(:,3) = -raw_states(:,3);
raw_states(:,9) = -raw_states(:,9);
% pitch <-> -pitch yaw = (-yaw + pi/2)
raw_states(:,5) = -raw_states(:,5);
raw_states(:,6) = mod(-raw_states(:,6)+pi/2, 2*pi);
% q <-> -q r <-> -r
raw_states(:,11) = -raw_states(:,11);
raw_states(:,12) = -raw_states(:,12);
%================================

timestamps = raw_timestamps';
states = raw_states';
motors = raw_motors';

%========== add acceleration AND disturbance data ============
N = N-1;
accel_states = (states(7:12, 2:end)-states(7:12, 1:end-1))./(timestamps(2:end) - timestamps(1:end-1));
timestamps = timestamps(1:end-1);
time_us = time_us(1:end-1);
states = states(:, 1:end-1);
motors = motors(:, 1:end-1);
wind_window = [18222708, 22456014];

disturb_data = [];
%========================================

title_name = ["x(east)", "y(north)", "z(up)", "roll", "pitch", "yaw", "vx", "vy", "vz", "p", "q", "r"]; 
% t, x, y, u
t = timestamps;
x = zeros(NX,N);    x(1:12,1) = states(:,1);    
y = zeros(NY,N);    %model output
y_accel = zeros(6, N);
u = motors;
dx = zeros(NX,N);


global frame_height;
frame_height = 0.1;
for n=1:N-1
    dt = t(n+1) - t(n);
    [dx(:,n),y(1:NX,n)] = quadrotor_m(t(n), x(:,n), u(:,n), a,b,c,d, m, I_x, I_y, I_z, K_T, K_Q);
    y_accel(:, n) = dx(7:12, n); % record y_accel.
    disturb_accel = accel_states(:, n) - y_accel(:, n);
    if time_us(n) >= wind_window(1) && time_us(n) <= wind_window(2)
        disturb_data = [disturb_data; time_us(n) disturb_accel'];
    end
    x(:,n+1) = x(:,n) + dx(:,n) * dt; 
    x(6,n+1) = mod(x(6,n+1), 2*pi); % wrap yaw to [0,2pi)
    
    %========= on ground check ==========
    if on_ground(x(3, n+1), frame_height)
        x(3, n+1) = frame_height; % z ;
        x(4:5,n+1) = 0; % roll = pitch = 0;
        x(7:8, n+1) = 0; % vx = vy = 0;
        x(10:12, n+1) = 0; %pqr = 0;
        if x(9, n+1) < 0
            x(9, n+1) = 0; %vz = 0;
        end
    end
%     if n * dt < 10
%         x(10:12,n+1) = states(10:12,n+1);
%         x(4:6,n+1) = states(4:6,n+1);
%     end
    
    %k-step ahead estiamtion (sync at every-k loop)
    if mod(n, sync_k) == 0
        x(:,n+1) = states(:,n+1);
    end
end

%% write data

sync_log_k = max_freq;
sync_data = test_data(1:sync_log_k:end, 1:13); % NED frame
T_syn = array2table(sync_data);
T_syn.Properties.VariableNames(1:13) = {'Time_us','x','y', 'z', 'roll', 'pitch', 'yaw',...
    'V_x', 'V_y', 'V_z', 'Gyro_x', 'Gyro_y', 'Gyro_z'};

%==========from ENU to NED=============

%body: y = -y, z = -z
disturb_data(:, [6,7]) = -disturb_data(:, [6,7]);
%world x <-> y, z = -z
disturb_data(:, 4) = -disturb_data(:, 4); %z
temp = disturb_data(:, 2);
disturb_data(:, 2) = disturb_data(:, 3); %x
disturb_data(:, 3) = temp; %y
%=====================================
T_disturb = array2table(disturb_data);
T_disturb.Properties.VariableNames(1:7) = {'Time_us','accel_x','accel_y', 'accel_z',...
    'angl_accel_x', 'angl_accel_y', 'angl_accel_z'};

% writetable(T_syn,[filename(1: end-4) '_syn.csv']);
% writetable(T_disturb,[filename(1: end-4) '_disturb.csv']);

%% plot
figure;
for n=1:NY
    if NY > 1
        subplot(NY/3, 3, n);
    end    
    yyaxis left
    plot(timestamps, states(n,:),'k-');     %truth
    hold on;
    plot(t, y(n,:), 'b--');                  %model prediction
    hold on;
    yyaxis right
    area(t, abs(states(n,:)-y(n,:)), 'FaceAlpha', 0.8, 'EdgeColor', 'none');    % deviation
    legend('State', 'Model prediction',  'Error');
end

figure;

for n=1:6
    subplot(2,3, n);
    yyaxis left
    plot(timestamps, accel_states(n,:),'k-');     %truth
    hold on;
    plot(t, y_accel(n,:), 'b--');                  %model prediction
    hold on;
    yyaxis right
    area(t, abs(accel_states(n,:)-y_accel(n,:)), 'FaceAlpha', 0.8, 'EdgeColor', 'none');    % deviation
    legend('State', 'Model prediction',  'Error');
end