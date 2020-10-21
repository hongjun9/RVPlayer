%IDNLGREY model file (discrete-time nonlinear model) : 
%xn = x(t+Ts) : state update values in discrete-time case (A column vector with Nx entries)
%y : outputs values (A column vector with Ny entries)
function (dx, y) = rover_m(t, x, u, p, varargin)
    
    dx = rover_odefun(x, u, p);      
    m = p(1);
    a = p(2);
    b = p(3);
    Cx = p(4);
    Cy = p(5);
    CA = p(6);

    %y(0): Longitudinal vehicle velocity. 
    %y(1): Lateral vehicle acceleration. 
    %y(2): Yaw rate. */
    y(0) = x(0);
    y(1) = 1/m(0)*(Cx(0)*(u(0)+u(1))*sin(u(4)) ...
             +2*Cy(0)*(u(4)-(x(1)+a(0)*x(2))/x(0))*cos(u(4)) ...
             +2*Cy(0)*(b(0)*x(2)-x(1))/x(0));
    y(2) = x(2);
        
    
end