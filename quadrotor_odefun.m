function dx = quadrotor_odefun(x, u, a,b,c,d, m, I_x, I_y, I_z, K_T, K_Q)
    
    g = 9.80665;   % gravity acceleration constant (m/s^2)
    dx = zeros(12,1);
    
    % inputs
    x(13:16)=u;
    % squred inputs
%     x(13) = u(1)*u(1);
%     x(14) = u(2)*u(2);
%     x(15) = u(3)*u(3);
%     x(16) = u(4)*u(4);
    %-------------------------------------------------
    dx(1) = x(7);
    dx(2) = x(8);
    dx(3) = x(9);
    dx(4) = x(10) + sin(x(4))*tan(x(5))*x(11) + cos(x(4))*tan(x(5))*x(12);
    dx(5) = cos(x(4))*x(11) - sin(x(4))*x(12);
    dx(6) = sin(x(4))/cos(x(5))*x(11) + cos(x(4))/cos(x(5))*x(12);
    
    dx(7) = K_T/m*(x(13)+x(14)+x(15)+x(16))*(cos(x(4))*sin(x(5))*cos(x(6)) + sin(x(4))*sin(x(6)));
    dx(8) = K_T/m*(x(13)+x(14)+x(15)+x(16))*(cos(x(4))*sin(x(5))*sin(x(6)) - sin(x(4))*cos(x(6)));
    dx(9) = K_T/m*(x(13)+x(14)+x(15)+x(16))*(cos(x(4))*cos(x(5))) - g;    
%     dx(10) = (I_y-I_z)/I_x*x(11)*x(12) + K_T/I_x*(-a*x(13)+d*x(14)+a*x(15)-d*x(16));
%     dx(11) = (I_x-I_z)/I_y*x(10)*x(12) + K_T/I_y*(-b*x(13)+c*x(14)-b*x(15)+c*x(16));
%     dx(12) = (I_x-I_y)/I_z*x(10)*x(11) + K_Q/I_z*(-x(13)-x(14)+x(15)+x(16));
    dx(10) =  K_T/I_x*(-a*x(13)+d*x(14)+a*x(15)-d*x(16));
    dx(11) =  K_T/I_y*(-b*x(13)+c*x(14)-b*x(15)+c*x(16));
    dx(12) =  K_Q/I_z*(-x(13)-x(14)+x(15)+x(16));
    
    % our motor model (W1 - W4)
%     dx(13) = -alpha * x(13) + K_m * u(1)*u(1);
%     dx(14) = -alpha * x(14) + K_m * u(2)*u(2);
%     dx(15) = -alpha * x(15) + K_m * u(3)*u(3);
%     dx(16) = -alpha * x(16) + K_m * u(4)*u(4);
           
end


 