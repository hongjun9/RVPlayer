clear;
close all;
filename = 'Test3/00000153.csv';
train_data = csvread(filename, 2, 0);  
% states [x y z roll pitch yaw vx vy vz p q r]
% output = states
% input [m1 m2 m3 m4]
NX = 12;    
NY = 12;
NU = 4;
raw_timestamps = train_data(:,1) * 1e-6;    %(s)    time vector
raw_states = train_data(:,2:13);            % array of state vector: 12 states
% converting: motor_input = (pwm - 1100)/900 
% motor signal [0..1] --> motor speed (PWM servo) [0...2000]
raw_motors = (((train_data(:,14:17)*1000)+1000)-1100)/900;   %(((0.5595*1000)+1000)-1100)/900=0.51

raw_N = size(train_data,1);                 % size of samples

%%%Preprocessing ================================
%%trasform frame NED --> ENU
% x <-> y, vx <-> vy
% temp = raw_states(:,1); 
% raw_states(:,1) = raw_states(:,2);
% raw_states(:,2) = temp;
% temp = raw_states(:,7); 
% raw_states(:,7) = raw_states(:,8);
% raw_states(:,8) = temp;
% 
% % z <-> -z, vz <-> -vz
% raw_states(:,3) = -raw_states(:,3);
% raw_states(:,9) = -raw_states(:,9);
% 
% % roll <-> pitch, p <-> q
% temp = raw_states(:,4); 
% raw_states(:,4) = raw_states(:,5);
% raw_states(:,5) = temp;
% temp = raw_states(:,10); 
% raw_states(:,10) = raw_states(:,11);
% raw_states(:,11) = temp;

%========= to NWU ==============
% raw_states(:,2) = -raw_states(:,2);
% raw_states(:,3) = -raw_states(:,3);
% raw_states(:,5) = -raw_states(:,5);
% raw_states(:,6) = -raw_states(:,6);
% raw_states(:,8) = -raw_states(:,8);
% raw_states(:,9) = -raw_states(:,9);
% raw_states(:,11) = -raw_states(:,11);
% raw_states(:,12) = -raw_states(:,12);

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



%%resample (for uniform sampling time)
desiredFs = 400; %(default 400Hz)
Ts = 1/desiredFs;
[res_states, res_timestamps] = resample(raw_states,raw_timestamps,desiredFs);
[res_motors, res_timestamps] = resample(raw_motors,raw_timestamps,desiredFs);
N = size(res_timestamps,1);

%plot (original and sampeled)
% title_name = ["x(North)", "y(West)", "z(up)", "roll", "pitch", "yaw", "vx", "vy", "vz", "p", "q", "r"]; 
title_name = ["x(east)", "y(north)", "z(up)", "roll", "pitch", "yaw", "vx", "vy", "vz", "p", "q", "r"]; 

figure;
for n=1:NY
    subplot(NY/3, 3, n);
    plot(raw_timestamps,raw_states(:,n),'b.-');
    hold on;
    plot(res_timestamps, res_states(:,n),'r-');
    legend('Original','Resampled');
    title(title_name(n));
end

%%convert to column vectors
timestamps = res_timestamps';
states = res_states';
motors = res_motors';
%%%============================================

%% ==============================================================
%% parameters (default)
g = 9.80665;   % gravity acceleration constant (m/s^2)

arm_scale = deg2rad(5000);
yaw_scale = deg2rad(400);

thetas = [deg2rad(45), deg2rad(-135), deg2rad(-45), deg2rad(135)];

% 
% a = 0.22;
% b = 0.13;
% c = 0.13;
% d = 0.22;
m = 1.5;
I_x = 0.008; %16365151e-9; %16365151e-9;      % Inertia (kg*m^2)
I_y = 0.015; %8354114e-9;    %8354114e-9;
I_z = 0.017; %24008439e-9;  %24008439e-9;


% alpha = 9.6;
throttle_hover = 0.51; %0.5595;%0.51; %0.7;    % (%)  (1559-1100)/900=0.51
% rpmmax = 10800;                % assumed max rpm (in min)          13024    9768      14784
% omega_max = (rpmmax/60)*2*pi;   % max motor speed (rad/s)        1099.9    1022.9
% K_m = (omega_max^2)*alpha;   % guess based on max rpm ((rad/s)^2)
% K_m = (rpmmax^2)*alpha;   % guess based on max rpm (rpm)
% K_T = m*g / 4/ (omega_max*throttle_hover)^2;   % guess based on rpm and max lift (N/(rad/s)^2)
% K_T = m*g / 4 /(rpmmax*throttle_hover)^2;   % guess based on rpm and max lift (N/(rpm)^2)
% K_T = m*g / (4*(throttle_hover*900+1100));
K_T = m*g / (4*throttle_hover);   % = 7.2108
% K_Q = K_T*0.034;                % guess based on K_T 0.034;
K_Q = yaw_scale * I_z;

%a=d, b=c
a =  sin(thetas(1)) * arm_scale * I_x / K_T;    %0.7071 * 87.2665 * 0.008 / 7.2108 = 0.0685
b =  cos(thetas(1)) * arm_scale * I_y / K_T;    %0.7071 * 87.2665 * 0.015 / 7.2108 = 0.1284
c = -cos(thetas(4)) * arm_scale * I_y / K_T;    %0.7071 * 87.2665 * 0.015 / 7.2108 = 0.1284
d =  sin(thetas(4)) * arm_scale * I_x / K_T;    %0.7071 * 87.2665 * 0.008 / 7.2108 = 0.0685

%====================================
% test the model implementation
t = timestamps;
x = zeros(NX,N);    x(1:12,1) = states(:,1);
dx = zeros(NX,N);
y = zeros(NY,N);
u = motors;
for n=1:N-1
    dt = t(n+1) - t(n);
    [dx(:,n),y(:,n)] = quadrotor_m(t(n), x(:,n), u(:,n), a,b,c,d, m, I_x, I_y, I_z, K_T, K_Q);
    x(:,n+1) = x(:,n) + dx(:,n) * dt; 
    x(6,n+1) = mod(x(6,n+1), 2*pi);
%     x(10:12,n+1) = states(10:12,n+1);
%     x(4:6,n+1) = states(4:6,n+1);
    if n * dt < 10
        x(10:12,n+1) = states(10:12,n+1);
        x(4:6,n+1) = states(4:6,n+1);
    end
    
    
%     %k-step ahead estiamtion (sync at every-k loop)
%     k = 10;
%     if mod(n, k) == 0
%         x(:,n+1) = states(:,n+1);
%     end
end

figure;
for n=1:NY
    if NY > 1
        subplot(NY/3, 3, n);
    end
    plot(timestamps, states(n,:),'r.-');
    hold on;
    plot(t, y(n,:), 'b-');  
    legend('Resampled', 'Model');
    title(title_name(n));
end
% figure;plot(t, x(13,:))
% hold on; plot(t, x(14,:))
% hold on; plot(t, x(15,:))
% hold on; plot(t, x(16,:))
return

%====================================
%% System Identification

% data = iddata(states, motors, 'SamplingInstants', timestamps); %non-uniform sampling
data = iddata(states', motors', Ts);    % uniform sampling (Ts)
Filename       = 'quadrotor_m';                % File describing the model structure.
Order          = [NY NU NX];               % Model orders [ny nu nx].
Parameters    = [a; b; c; d; m; I_x; I_y; I_z; K_T; K_Q];   % Initial parameter vector.
InitialStates = x(:,1);
nlgr_m    = idnlgrey(Filename, Order, Parameters, InitialStates);   %Nonlinear grey-box model

%%SI options
%
opt = nlgreyestOptions;
opt.Display = 'on';
%opt.GradientOptions.DiffMaxChange              % default: Inf
% opt.GradientOptions.DiffMinChange = 1e-3;    % defailt: 0.01*sqrt(eps) = 1.4901e-10
%opt.GradientOptions.DiffScheme = 'auto';       % default: auto, 'Central approximation', 'Forward approximation', 'Backward approximation'
% opt.GradientOptions.GradientType = 'auto';      % default: auto, 'Basic', 'Refined'
opt.SearchMethod = 'gn';                        % default: auto(lsqnonlin), gn, gna, lm, grad, fmincon
% opt.SearchOption.Tolerance = 1e-10;     %FunctionTolerance (1e-5) - gn
% opt.SearchOption.Algorithm = 'interior-point';     % interior-point, sqp, active-set, trust-region-reflective, 
% opt.SearchOption.TolFun = 1e-10;      %FunctionTolerance (1e-5)
% opt.SearchOption.TolX = 1e-10;        %StepTolerance (1e-6)
opt.SearchOption.MaxIter = 100;
% opt.SearchOption.Advanced.GnPinvConst = 10000000;
%opt.Regularization.Nominal = 'model';          %default: 'zero'

%--------------------------------------------
% outputweight = eye(NX);
% outputweight(1,1) = 1;
% outputweight(2,2) = 1;
% outputweight(3,3) = 1;
% outputweight(4,4) = 1000;
% outputweight(5,5) = 1;
% outputweight(6,6) = 1;
% opt.OutputWeight = outputweight;

%-----------------------------------------------------------
%% Parameter setting
% 
nlgr_m.Parameters(1).Fixed = true;      %abcd
nlgr_m.Parameters(2).Fixed = true;      
nlgr_m.Parameters(3).Fixed = true;
nlgr_m.Parameters(4).Fixed = true;
nlgr_m.Parameters(5).Fixed = true;      %weight
nlgr_m.Parameters(6).Fixed = true;      %Ix
nlgr_m.Parameters(7).Fixed = true;      %Iy
nlgr_m.Parameters(8).Fixed = true;      %Iz
% nlgr_m.Parameters(9).Fixed = true;     %thrust const  **
% nlgr_m.Parameters(10).Fixed = true;    %torque_const  **
%nlgr_m.Parameters(11).Fixed = true;    %K_m  **
%nlgr_m.Parameters(12).Fixed = true;    %alpha  **
% %-----------------------------------------------------------
% nlgr_m.Parameters(1).Minimum = 0.10;      %abcd [0.1..0.26]
% nlgr_m.Parameters(2).Minimum = 0.10;      
% nlgr_m.Parameters(3).Minimum = 0.10;      
% nlgr_m.Parameters(4).Minimum = 0.10; %0.18;      
% nlgr_m.Parameters(5).Minimum = 0;       %weight     
% nlgr_m.Parameters(6).Minimum = 0;         %I_x
% nlgr_m.Parameters(7).Minimum = 0;         %I_y      
% nlgr_m.Parameters(8).Minimum = 0;         %I_z   
nlgr_m.Parameters(9).Minimum = 0;       %th const
nlgr_m.Parameters(10).Minimum = 0;      %torque_const
% nlgr_m.Parameters(11).Minimum = 0;      %K_m
% nlgr_m.Parameters(12).Minimum = 0;      %alpha

% nlgr_m.Parameters(1).Maximum = 0.30; %0.22;      %abcd [0.1..0.26]
% nlgr_m.Parameters(2).Maximum = 0.30; %0.16;
% nlgr_m.Parameters(3).Maximum = 0.30; %0.16;
% nlgr_m.Parameters(4).Maximum = 0.30; %0.20;
% nlgr_m.Parameters(5).Maximum = 1.6;%1.4;         %weight     
% nlgr_m.Parameters(6).Maximum = 0.1;        %I_x
% nlgr_m.Parameters(7).Maximum = 0.1;  
% nlgr_m.Parameters(8).Maximum = 0.2;  
% nlgr_m.Parameters(9).Maximum = 0.6;         %th_const
% nlgr_m.Parameters(10).Maximum = 0.001;      %torque_const
% nlgr_m.Parameters(11).Maximum = 0.001;      %K_m
% nlgr_m.Parameters(12).Maximum = 0.001;      %alpha

nlgr_m = setpar(nlgr_m, 'Name', {'a' 'b' 'c' 'd' 'weight' 'Ix' 'Iy' 'Iz' 'thrust_const' 'torque_const'});
nlgr_m = setpar(nlgr_m, 'Unit', {'m' 'm' 'm' 'm' 'kg' 'kg*m^2' 'kg*m^2' 'kg*m^2' '%', 'N*(rad/s)^2'});
% nlgr_m.SimulationOptions.AbsTol = 1e-10;
% nlgr_m.SimulationOptions.RelTol = 1e-10;

model = nlgreyest(data, nlgr_m, opt);    %Estimate nonlinear grey-box model parameters

return

%%===================================================
%% plot results
%%

present(model);
yy = sim(model,data);
% figure; yy = compare(model, data);

output = yy.OutputData';
% N = size(output,2);
% figure;
% for n=1:NY
%     if NOUT > 1
%         ax = subplot(NY/NCOL, NCOL, n);
%     end
%     plot(t, states(n,:), 'r--', t, output(n,sp:ep), 'b-');   
% %     ylim([-1.5 1.5]);
% %     title(title_name(n));
% end

figure;
for n=1:NY
    subplot(NY/3, 3, n);
    plot(timestamps,states(n,:),'b.-');
    hold on;
    plot(timestamps, output(n,:),'r--');
    legend('Original','Model');
    title(title_name(n));
end
