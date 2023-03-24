% Circular buffer length
l = 512;

% Shifting factor
% 0.8 for low voice
% 1 for normal voice
% 1.65 for high pitch
a = 0.6;

% Read .wav file
filename = 'gettysburg.wav';
[samples,Fs] = audioread(filename);

% Initialize buffers to zero
circ_buff_0 = zeros(1, l);
circ_buff_1 = zeros(1, l);

% Output array for plotting
output = zeros(1,length(samples));

% Read and write pointers
w_0 = 0;
w_1 = 0;
r_0 = 0;
r_1 = 0;

% Indexing
i_0= 0;
i_1 = 0;

% Read one sample at a time
for i=1:length(samples)

    % Add the sample to circ_buff_0
    % Replace older samples if we run out of space
    w_0 = mod(i,l) + 1;
    circ_buff_0(w_0) = samples(i);

    % Add the sample to circ_buff_1 at some offset from buff0
    % Replace older samples if we run out of space
    w_1 = mod(i + round(l/2),l) + 1;
    circ_buff_1(w_1) = samples(i);
    
    % Read from circ_buff_0
    i_0 = i_0 + a;
    r_0 = mod(floor(i_0),l)+1;

    % Read from circ_buff_1
    i_1 = i_1 + a;
    r_1 = mod(floor(i_1),l)+1;

    output(i) = mean(circ_buff_0(r_0) + circ_buff_1(r_1));

end

% Listen to the original audio
%sound(samples, Fs);

% % Plot the original audio waveform
% tiledlayout(2,1);
% 
% nexttile;
% plot(output);
% title('Original audio');
% grid;
% 
% % Plot the pitch-shifted audio waveform
% nexttile;
% % plot(output);
% % title('Pitch-shifted audio');
% % grid;
% 
% % Filter only in the human voice range using 4th order Butterworth filter
% fc = 3500; 
% [b,a] = butter(4, fc/(Fs/2));
% output_filt = filtfilt(b, a, output);
% 
% plot(output_filt);
% grid;

% Listen to the pitch-shifted audio
sound(output, Fs);


