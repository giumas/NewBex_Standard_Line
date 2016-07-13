function [DateVal,TimeVal,AttCount,TimeOffset,SensorStat,Roll,Pitch,Heave,Heading,SensorDesc] = readEM_A(fid)

% attitude datagram

ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
AttCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');

numEntries = fread(fid,1,'uint16');
for i = 1:numEntries
    TimeOffset(i) = fread(fid,1,'uint16');
    SensorStat(i) = fread(fid,1,'uint16');
    Roll(i) = fread(fid,1,'int16')/100;
    Pitch(i) = fread(fid,1,'int16')/100;
    Heave(i) = fread(fid,1,'int16')/100;
    Heading(i) = fread(fid,1,'int16')/100;
end
SensorDesc = fread(fid,1,'uint8');

    

ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    disp('error')
    pause
end
% checksum
checksum = fread(fid,1,'uint16'); %#ok<NASGU>
