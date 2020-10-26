function dx = rover_odefun(x, u, m, a, b, Cx, Cy, CA)
    
%     m = p(1);
%     a = p(2);
%     b = p(3);
%     Cx = p(4);
%     Cy = p(5);
%     CA = p(6);
    
%     %[x y yaw vx vy r]
    dx(1) = x(4)*cos(x(3));
    dx(2) = x(4)*sin(x(3));
    dx(3) = x(6);
    dx(4) = (x(5)*x(6) + 1/m*( Cx*(u(1)+u(2))*cos(u(5)) ...
                             -2*Cy*(u(5)-(x(5)+a*x(6))/x(4))*sin(u(5)) ...
                             +Cx*(u(3)+u(4)) ...
                             -CA*x(4)^2));
    dx(5) = -x(4)*x(6) + 1/m*( Cx*(u(1)+u(2))*sin(u(5)) ...
                              +2*Cy*(u(5)-(x(5)+a*x(6))/x(4))*cos(u(5)) ...
                              +2*Cy*(b*x(6)-x(5))/x(4));
    dx(6) = 1/(((a+b)/2)^2*m)*( a*(Cx*(u(1)+u(2))*sin(u(5)) ...
                                  +2*Cy*(u(5)-(x(5)+a*x(6))/x(4))*cos(u(5))) ...
                               -2*b*Cy*(b*x(6)-x(5))/x(4));

    
%     dx(1) = x(2)*x(3) + 1/m*( Cx*(u(1)+u(2))*cos(u(5)) ...
%                              -2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*sin(u(5)) ...
%                              +Cx*(u(3)+u(4)) ... 
%                              -CA*x(1)^2);
%     dx(2) = -x(1)*x(3) + 1/m*( Cx*(u(1)+u(2))*sin(u(5)) ...
%                               +2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*cos(u(5)) ...
%                               +2*Cy*(b*x(3)-x(2))/x(1));
%     dx(3) = 1/(((a+b)/2)^2*m) * ( a*(Cx*(u(1)+u(2))*sin(u(5)) ...
%                                     +2*Cy*(u(5)-(x(2)+a*x(3))/x(1))*cos(u(5))) ...
%                                  -2*b*Cy*(b*x(3)-x(2))/x(1));
                   
end


 