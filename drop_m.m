function [zones events, length1, endVal] =drop_m(nummer)

%fname = 'sound_analyzed.json';
fname = 's2019-12-12_10-46-49.json';

val2 = jsondecode(fileread(fname));
zones = str2num(val2.zones(nummer).time);
events = convertCharsToStrings(val2.events(nummer).event);
length1 = length(val2.zones);

endVal = str2num(val2.zones(end).time);
