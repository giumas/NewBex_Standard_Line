function [DateVald,TimeVald,PingCount,Head,SSPD,SampFrequ,z,y,x,...
    DetcWindowL,IBA,DetcInfo,cleanInfo,ReflecBS,NumBeams] = readEM_X(fid);



% this is a Seabed depth datagram
% Refer to the datagram formats in the EM Series Operator manual / Datagram
% Formats 850-160692/Rev.H 
ModelNum = fread(fid,1,'uint16');
DateVald = fread(fid,1,'uint32');
TimeVald = fread(fid,1,'uint32');
PingCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');
Head = fread(fid,1,'uint16');%0.01 degrees
SSPD = fread(fid,1,'uint16');%dm/s
Txdepth = fread(fid,1,'float');
NumBeams = fread(fid,1,'uint16');
NumValDet = fread(fid,1,'uint16');
SampFrequ = fread(fid,1,'float');
scaninfo = fread(fid,1,'uint8');
fread(fid,1,'ubit24'); %spare

for i=1:NumBeams
    z(i) = fread(fid,1,'float');
    y(i) = fread(fid,1,'float');
    x(i) = fread(fid,1,'float');
    DetcWindowL(i) = fread(fid,1,'uint16');
    Qfact(i) = fread(fid,1,'uint8');
    IBA(i) = fread(fid,1,'int8');
    DetcInfo(i) = fread(fid,1,'uint8');
    cleanInfo(i) = fread(fid,1,'int8');
    ReflecBS(i) = fread(fid,1,'int16');
end

fread(fid,1,'uint8')
    



% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end

% checksum
checksum = fread(fid,1,'uint16');
