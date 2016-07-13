function [DateVal,TimeVal,PosCount,latitude,longitude,fixQual,SOG,COG,heading,inputDatagram] = readEM_P(fid)

% position datagram

ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
PosCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');


latitude = fread(fid,1,'int32')/20000000;
longitude = fread(fid,1,'int32')/10000000;
fixQual = fread(fid,1,'uint16');
SOG = fread(fid,1,'uint16');
COG = fread(fid,1,'uint16');
heading = fread(fid,1,'uint16');
psd = fread(fid,1,'uint8');
numbytes = fread(fid,1,'uint8');
inputDatagram = fread(fid,numbytes,'char');


% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end
% checksum
checksum = fread(fid,1,'uint16'); %#ok<NASGU>
