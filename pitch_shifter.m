% ------------- SETUP ------------- %
% Circular buffer length
l = 1024;

% Shifting factor
% 0.85 for low pitch
% 1 for normal voice
% 1.65 for high pitch
shift_factor = 0.8;

% Read .wav file
% Test audio file is a recitation of The Gettysburg Address
filename = 'gettysburg.wav';
% [samples,fs] = audioread(filename);

% Test sine wave to better visualize effect of shifting & filtering
fs = 45000;
x = linspace(0,1,fs);
samples = sin(2*pi*440*x);

% ------------- BUFFERS AND POINTERS ------------- %
% Create 2 buffers for left data, and two buffers for right data
% Initialize buffers to zero
l_buf_1 = zeros(1, l);
l_buf_2 = zeros(1, l);
r_buf_1 = zeros(1, l);
r_buf_2 = zeros(1, l);

% Output array of shifted samples
% In hardware implementation, samples will be streamed to Avalon bus

% Output
out_left = zeros(length(samples),1);
out_right = zeros(length(samples),1);

% Read and write pointers for l_buf_1, l_buf_2, r_buf_1, and r_buf_2
% Initialize w_1 to 1. MATLAB arrays start at 1.
% Initialize w_2 to 180 deg shifted cell.

% l_buf write
l_w_1 = 1;
l_w_2 = floor(l/2);

% l_buf read
l_r_1 = 1;
l_r_2 = 1;

% r_buf write
r_w_1 = 1;
r_w_2 = floor(l/2);

% r_buf read
r_r_1 = 1;
r_r_2 = 1;

% Indexing for read pointers
l_i_1= 0;
l_i_2= 0;
r_i_1= 0;
r_i_2= 0;

% ------------- ALGORITHM ------------- %
% Read one sample at a time from the array of samples
% Simulate reading one sample from a register in hardware
for i=1:length(samples)

    % LEFT BUFFER 
    % Add the sample to l_buf_1 at address l_w_1
    % Advance l_w_1
    l_buf_1(l_w_1) = samples(i);
    l_w_1 = mod(i, l) + 1;

    % Add the sample to l_buf_2
    % Advance l_w_2
    l_buf_2(l_w_2) = samples(i);
    l_w_2 = mod(i+floor(l/2), l) + 1;

    % Read from l_buf_1 at address l_r_1
    l_i_1= l_i_1 + shift_factor;
    l_r_1 = mod(floor(l_i_1), l) + 1;

    % Read from l_buf_2 at address l_r_2
    l_i_2= l_i_2 + shift_factor;
    l_r_2 = mod(floor(l_i_2), l) + 1;


    % RIGHT BUFFER 
    % Add the sample to l_buf_1 at address l_w_1
    % Advance l_w_1
    r_buf_1(r_w_1) = samples(i);
    r_w_1 = mod(i, l) + 1;

    % Add the sample to l_buf_2
    % Advance l_w_2
    r_buf_2(r_w_2) = samples(i);
    r_w_2 = mod(i + floor(l/2), l) + 1;

    % Read from l_buf_1 at address l_r_1
    r_i_1= r_i_1 + shift_factor;
    r_r_1 = mod(floor(r_i_1), l) + 1;

    % Read from l_buf_2 at address l_r_2
    r_i_2= r_i_2 + shift_factor;
    r_r_2 = mod(floor(r_i_2), l) + 1;

    out_left(i) = 0.5*(l_buf_1(l_r_1) + l_buf_2(l_r_2));
    out_right(i) = 0.5*(r_buf_1(r_r_1) + r_buf_2(r_r_2));

end

% ------------- WAVEFORM VIZUALIZATION & SOUND------------- %
% Listen to the original audio
% sound(samples, fs);

% ------------- VISUALIZE PITCH-SHIFT ------------- %
% Filter only in the human voice range using 4th order Butterworth filter
fc = 3500; 
[b,a] = butter(4, fc/(fs/2));
out_filtered = filter(b, a, out_left);

% Plot the original audio waveform
figure
plot(samples, 'LineWidth', 1, 'Color', '#0b2852');
hold on;

% Plot the time-shifted, filtered audio waveform
plot(out_filtered, 'LineWidth', 1, 'Color', '#629df5')

% Style plot
[t,s] = title("Pitch-shifting", 'Shift-factor = 0.8 (low-pitch)');
grid;
t.FontSize = 16;
s.FontAngle = 'italic';
lgd = legend('Original audio','Pitch-shifted audio');
lgd.FontSize = 14;

% Visualize a given domain of the sine wave
xlim([1000, 1500]);
ylim([-1.15, 1.15]);


% Listen to the pitch-shifted audio
% sound(out_filtered, fs);

% ------------- VISUALIZE FILTERING ------------- %
% Plot the pitch-shifted, unfiltered audio waveform
figure
plot(out_left, 'LineWidth', 1, 'Color', '#0b2852');
hold on;

% Plot the time-shifted, filtered audio waveform
plot(out_filtered, 'LineWidth', 1, 'Color', '#629df5')

% Style plot
[t,s] = title("Filtering", 'Butterworth Filter 3.5 kHz');
grid;
t.FontSize = 16;
s.FontAngle = 'italic';
lgd = legend('Unfilted output','Filtered output');
lgd.FontSize = 14;

% Visualize a given domain of the sine wave
xlim([1000, 1100]);
ylim([-1.15, 1.15]);

% Listen to the pitch-shifted audio
% sound(out_filtered, fs);


