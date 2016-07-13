function [ModelNum,DateVal,TimeVal,PingCount,SystemSerNum,Mode,MinDepth,MaxDepth,AbsCoef,TxPulseLength...
        TxBeamWidth, TxPower,RxBeamWidth,RxBandWidth,RxFixedGain, TVGXover,MaxPortCoverage, MaxStbdCoverage,...
            MaxPortSwath,BeamSpacing,MaxStbdSwath,PUStatus,BSPStatus,SonHeadStatus] = readEM_R(fid)
%  this is a Run Time Parameters datagram
% Refer to the datagram formats in the EM Series Operator manual / Datagram
% Formats 850-160692/Rev.H 
% Modified Rev. I 20.6.06 
ModelNum = fread(fid,1,'uint16'); 
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
PingCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16'); 
OpStatStatus = fread(fid,1,'uint8');
PUStatus=fread(fid,1,'uint8');
BSPStatus=fread(fid,1,'uint8');  
SonHeadStatus=fread(fid,1,'uint8');
Mode=fread(fid,1,'uint8');

FilterIden=fread(fid,1,'uint8');
MinDepth = fread(fid,1,'uint16');
MaxDepth = fread(fid,1,'uint16');
AbsCoef = fread(fid,1,'uint16'); %in 0.01 dB/km
TxPulseLength=fread(fid,1,'uint16');% in micro sec
TxBeamWidth=fread(fid,1,'uint16');% in 0.1 degrees
TxPower = fread(fid,1,'int8'); %Transmit power re maximum in dB
RxBeamWidth = fread(fid,1,'uint8');%in 0.1 degrees
RxBandWidth = fread(fid,1,'uint8');%Receive bandwidth in 50 Hz resolution
RxFixedGain = fread(fid,1,'uint8');% Receiver fixed gain in dB
TVGXover = fread(fid,1,'uint8'); %TVG law crossover angle in degrees
SourceSoundSpdAthead = fread(fid,1,'uint8');
MaxPortSwath = fread(fid,1,'uint16'); % Max. Port Swath in m
BeamSpacing = fread(fid,1,'uint8');
MaxPortCoverage = fread(fid,1,'uint8');%in degrees
YawPitchStabMode = fread(fid,1,'uint8');
MaxStbdCoverage=fread(fid,1,'uint8');%in degrees
MaxStbdSwath = fread(fid,1,'uint16');%in m
DurSpd = fread(fid,1,'uint16');%in dm/s
HiLoFrqAbsCoef = fread(fid,1,'uint8');

% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end

% checksum
checksum = fread(fid,1,'uint16');

