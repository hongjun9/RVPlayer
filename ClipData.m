function [test_data] = ClipData(test_data, reference_motor, start_offset, end_offset, max_freq)
% Clip the data and keep only the part with motor signal higher than
% reference_motor. Initial time is the time first reaching reference_motor.
% start_offset: clip offset of starting time. Unit: s
% end_offset: clip offset of ending time. Unit: s

refer_idx = find(test_data(:, 14) >= reference_motor, 1);
reference_time = test_data(refer_idx, 1); % test_data(1, 1)
test_data(:, 1) = test_data(:, 1)-reference_time; % reset start time
%trim data (remove unnecessary parts)
isp = refer_idx + start_offset* max_freq;
iep = find(test_data(:, 14) >= reference_motor,1,'last') - end_offset* max_freq;
test_data = test_data(isp:iep, :);

end

