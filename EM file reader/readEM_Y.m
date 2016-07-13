function [DateVal,TimeVal,PingCount,sampRate,Samps2NormInc,TxBeamWidthAlong...
             TVGcrossoverAng,NormincBSN,OblqincBSO,NumBeamsHere,...
              detInfo,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets] = readEM_Y(fid)
    

% this is a Seabed image datagram
% Refer to the datagram formats in the EM Series Operator manual / Datagram
% Formats 850-160692/Rev.H 
ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
PingCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');
sampRate = fread(fid,1,'single');
Samps2NormInc = fread(fid,1,'uint16');
NormincBSN = fread(fid,1,'int16');
OblqincBSO = fread(fid,1,'int16');
TxBeamWidthAlong = fread(fid,1,'uint16');
TVGcrossoverAng = fread(fid,1,'uint16');
NumBeamsHere = fread(fid,1,'uint16');

% NumRecBeams
for i = 1:NumBeamsHere
    sortDir(i) = fread(fid,1,'int8');
    detInfo(i) = fread(fid,1,'uint8');
    NumSampsPerBeam(i) = fread(fid,1,'uint16');
    BeamCenterSampNum(i) = fread(fid,1,'uint16');
end


SimradSnippets = zeros(NumBeamsHere,max(NumSampsPerBeam));
for i = 1:NumBeamsHere
    SimradSnippets(i,1:NumSampsPerBeam(i)) = fread(fid,NumSampsPerBeam(i),'int16');%amplitude in 0.5 dB
end


% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end

% checksum
checksum = fread(fid,1,'uint16');
