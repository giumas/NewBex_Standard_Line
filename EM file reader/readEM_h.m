function [DateVal,TimeVal,heightCount,height,heightType] = readEM_h(fid)

% attitude datagram

ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
heightCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');

height = fread(fid,1,'int32')/100;
heightType = fread(fid,1,'uint8');

ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    disp('error')
    pause
end
% checksum
checksum = fread(fid,1,'uint16'); %#ok<NASGU>
