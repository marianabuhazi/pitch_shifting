% <------------ NUMBER GENERATION ------------>
% Script for 24-bit random number generator
% Generates 100 24-bit random binary numbers
% Writes randomly-generated numbers to file in_data

in_data = fopen('./in_data', 'w');
for i = 1:10
    random= randi([0,1],1, 24);
    print_format = [repmat('%g', 1, numel(random)-1), '%g\n'];
    fprintf(in_data, print_format, random);
end
fclose(in_data);

% <------------ SETUP ------------>
% Circular buffer length
l = 1024;

% Shifting factor
% 0.8 for low pitch
% 1 for normal voice
% 1.65 for high pitch
shift_factor = 0.8;

% Sample number
i = 0;

% ------------- BUFFERS AND POINTERS ------------- %
% Create 2 buffers for left data, and two buffers for right data
% Initialize buffers to zero
l_buf_0 = strings([1, l]);
l_buf_1 = strings([1, l]);
r_buf_0 = strings([1, l]);
r_buf_1 = strings([1, l]);

% Read and write pointers for l_buf_0, l_buf_1, r_buf_0, and r_buf_1
% Initialize w_0 to 1. MATLAB arrays start at 1.
% Initialize w_1 to 180 deg shifted cell.

% l_buf write
l_w_0 = 1;
l_w_1 = floor(l/2);

% l_buf read
l_r_0 = 1;
l_r_1 = 1;

% r_buf write
r_w_0 = 1;
r_w_1 = floor(l/2);

% r_buf read
r_r_0 = 1;
r_r_1 = 1;

% Indexing for read pointers
l_i_0= 0;
l_i_1= 0;
r_i_0= 0;
r_i_1= 0;

% Reads 2 binary numbers from in_data file
% First binary number: in_left
% Second binary number: in_right
% "Streams" them into the pitch_shifter function
in_data = fopen('./in_data', 'r');
out_data = fopen('./out_data','w');

in_left = fgetl(in_data); % Read the left data
in_right = fgetl(in_data); % Read the right data

while ~isequal(in_left, -1) && ~isequal(in_right, -1)
    % Computes sum and writes to data_out
    [out_left, out_right] = pitch_shifter(l, shift_factor, in_left, in_right, ...
        i, l_buf_0, l_buf_1, l_w_0, ...
        l_w_1, l_r_0, l_r_1, r_buf_0, r_buf_1,r_w_0, r_w_1, r_r_0, ...
        r_r_1, l_i_0, l_i_1, r_i_0, r_i_1);
    print_format = [repmat('%g', 1, numel(out_left)-1), '%g\n'];
    fprintf(out_data, print_format, out_left);
    print_format = [repmat('%g', 1, numel(out_right)-1), '%g\n'];
    fprintf(out_data, print_format, out_right);
    in_left = fgetl(in_data);     
    in_right = fgetl(in_data);
end

fclose(in_data);
fclose(out_data);

% Converts binary number to a matlab array
function[in_arr] = to_array(in)
    in_arr = char(num2cell(convertStringsToChars(in)));
    in_arr = reshape(str2num(in_arr),1,[]); %#ok<ST2NM> 
end

function[out] = add(in_0, in_1)
    % Function for 24-bit adder
    % Takes 2 24-bit numbers 
    % Computes bit-wise addition
    if (isvector(in_0) && length(in_0)==24) && (isvector(in_1) && length(in_1)==24)
        out = zeros(1,24);
        carry_out = 0;
        
        for i = 24:-1:1
            out(i) = in_0(i) + in_1(i) + carry_out;
            if out(i) == 2
                out(i) = 0;
                carry_out = 1;
            elseif out(i) == 3
                out(i) = 1;
                carry_out = 1;
            else
                carry_out = 0;
            end
        end
    else
        error("The given inputs are not 24-bit vectors");
    end
end

function[out] = shift(in)
    out = zeros(size(in));
    out(2:24) = in(1:23);
end

% ------------- ALGORITHM ------------- %
% Read two samples at a time
% Add to buffers
% Read from buffers
% Take average
% Output to file
function [out_left, out_right] = pitch_shifter(l, shift_factor, in_left, in_right, i, ...
    l_buf_0, l_buf_1, l_w_0, l_w_1, l_r_0, l_r_1, r_buf_0, r_buf_1, ...
    r_w_0, r_w_1, r_r_0, r_r_1, l_i_0, l_i_1, r_i_0, r_i_1)
        % LEFT BUFFER 
        % Add the sample to l_buf_0 at address l_w_0
        % Advance l_w_0
        l_buf_0(l_w_0) = in_left;
        l_w_0 = mod(i, l) + 1;
    
        % Add the sample to l_buf_1
        % Advance l_w_1
        l_buf_1(l_w_1) = in_left;
        l_w_1 = mod(i+floor(l/2), l) + 1;
    
        % Read from l_buf_0 at address l_r_0
        l_i_0= l_i_0 + shift_factor;
        l_r_0 = mod(floor(l_i_0), l) + 1;
    
        % Read from l_buf_2 at address l_r_1
        l_i_1= l_i_1 + shift_factor;
        l_r_1 = mod(floor(l_i_1), l) + 1;
    
    
        % RIGHT BUFFER 
        % Add the sample to l_buf_1 at address l_w_0
        % Advance l_w_0
        r_buf_0(r_w_0) = in_right;
        r_w_0 = mod(i, l) + 1;
    
        % Add the sample to l_buf_1
        % Advance l_w_1
        r_buf_1(r_w_1) = in_right;
        r_w_1 = mod(i + floor(l/2), l) + 1;
    
        % Read from l_buf_1 at address l_r_1
        r_i_0= r_i_0 + shift_factor;
        r_r_0 = mod(floor(r_i_0), l) + 1;
    
        % Read from l_buf_2 at address l_r_2
        r_i_1= r_i_1 + shift_factor;
        r_r_1 = mod(floor(r_i_1), l) + 1;
    
        % Adjust left values
        if (l_buf_0(l_r_0)=="") 
            l_r_0_out = "000000000000000000000000"; 
        else
            l_r_0_out = l_buf_0(l_r_0); 
        end

        if (l_buf_1(l_r_1)=="") 
            l_r_1_out = "000000000000000000000000"; 
        else
            l_r_1_out = l_buf_1(l_r_1); 
        end

        % Adjust right values
        if (r_buf_0(r_r_0)=="") 
            r_r_0_out = "000000000000000000000000"; 
        else
            r_r_0_out = r_buf_0(r_r_0); 
        end

        if (r_buf_1(r_r_1)=="") 
            r_r_1_out = "000000000000000000000000"; 
        else
            r_r_1_out = r_buf_1(r_r_1); 
        end
    
        out_left = add(to_array(l_r_0_out), to_array(l_r_1_out));
        out_left = shift(out_left);

        out_right = add(to_array(r_r_0_out), to_array(r_r_1_out));
        out_right = shift(out_right);
    end