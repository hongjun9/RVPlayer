function [is_log] = islog_disturb(disturb_accel,L_norm, k, max_freq, last_log_time, time_now)
% disturb_accel: 6 * 1
% L_norm:1 * 2
% k: order
% is_log: 1 * 2, bool

lin_acc = norm(disturb_accel(1:3));
rot_acc = norm(disturb_accel(4:6));
norm_acc = [lin_acc, rot_acc];
is_log = zeros(1,2);
for i = [1,2]
    if norm_acc(i) >= L_norm(i)
        is_log(i) = 1;
    else
        ratio = norm_acc(i) / L_norm(i);
        desired_freq = (ratio ^ k) * max_freq;
        current_freq = 1 / (time_now - last_log_time(i));
        is_log(i) = desired_freq > current_freq || current_freq < 1;
    end
end

