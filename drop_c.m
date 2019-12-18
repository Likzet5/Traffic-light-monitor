function [frames, colours, length1, X, Y, W, H, endVal] =drop_c(nummer)

%fname = 'camera_analyzed.json';
fname = 'c2019-12-12_10-46-49.json';

val3 = jsondecode(fileread(fname));
length1 = length(val3.frames);
frames = str2num(val3.frames(nummer).frame);
colours = convertCharsToStrings(val3.colours(nummer).colour);
X = str2num(val3.X(nummer).X);
Y = str2num(val3.Y(nummer).Y);
W = str2num(val3.W(nummer).W);
H = str2num(val3.H(nummer).H);

endVal = str2num(val3.frames(end).frame);

