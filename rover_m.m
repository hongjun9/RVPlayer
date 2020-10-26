%IDNLGREY model file (discrete-time nonlinear model) : 
%xn = x(t+Ts) : state update values in discrete-time case (A column vector with Nx entries)
%y : outputs values (A column vector with Ny entries)
function [dx, y] = rover_m(t, x, i, m, a, b, Cx, Cy, CA, varargin)

    u(1) = i(2);
    u(2) = i(2);
    u(3) = 0;
    u(4) = 0;
    u(5) = i(1);
    
    dx = rover_odefun(x, u, m, a, b, Cx, Cy, CA);      
    
%     m = p(1);
%     a = p(2);
%     b = p(3);
%     Cx = p(4);
%     Cy = p(5);
%     CA = p(6);
    
%     y(1) = x(1);
%     y(2) = x(2);
%     y(3) = x(3);    

    %y(1): Postion X
    %y(2): Position Y
    %y(3): Yaw
    %y(4): Longitudinal vehicle velocity. 
    %y(5): Lateral velocity.
    %y(6): Yaw rate. 
    %y(7): Lateral vehicle acceleration. 
    y(1) = x(1);
    y(2) = x(2);
    y(3) = x(3);    
    y(4) = x(4)*cos(x(3));
    y(5) = x(4)*sin(x(3));
    y(6) = x(6);
% %     y(7) = 1/m*(Cx*(u(1)+u(2))*sin(u(5)) ...
% %                 +2*Cy*(u(5)-(x(5)+a*x(6))/x(4))*cos(u(5)) ...
% %                 +2*Cy*(b*x(6)-x(5))/x(4));

    
%     %y(0): Longitudinal vehicle velocity. 
%     %y(1): Lateral vehicle acceleration. 
%     %y(2): Yaw rate. */
%     y(0) = x(0);
%     y(1) = 1/m*(Cx(0)*(u(0)+u(1))*sin(u(4)) ...
%              +2*Cy(0)*(u(4)-(x(1)+a(0)*x(2))/x(0))*cos(u(4)) ...
%              +2*Cy(0)*(b(0)*x(2)-x(1))/x(0));
%     y(2) = x(2);
        
    
end