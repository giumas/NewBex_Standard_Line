function [DateVal,TimeVal,PingCount,SSPD,SampFreq,TiltAng,CentFreq,XmitSecNum,BeamAngle,XmitSecNumByBeam,TwoWayTT,DetInfo,BS] = readEM_N(fid);


% this is a Seabed image datagram
% Refer to the datagram formats in the EM Series Operator manual / Datagram
% Formats 850-160692/Rev.H 
ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
PingCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');
SSPD = fread(fid,1,'uint16');%0.01 dB/km
Ntx = fread(fid,1,'uint16');
Nrx = fread(fid,1,'uint16');
NvalDet = fread(fid,1,'uint16');
SampFreq = fread(fid,1,'float');
fread(fid,1,'float');




for i = 1:Ntx
    TiltAng(i) = fread(fid,1,'int16');
    FocRange(i) = fread(fid,1,'uint16');
    SignalLength(i) = fread(fid,1,'float');
    SectorXmitDelay(i) = fread(fid,1,'float');
    CentFreq(i) = fread(fid,1,'float');
    MeanAbsorpt(i) = fread(fid,1,'uint16');
    SigWavID(i) = fread(fid,1,'uint8');
    XmitSecNum(i) = fread(fid,1,'uint8');
    BW(i) = fread(fid,1,'float');
end

for i = 1:Nrx
    BeamAngle(i) = fread(fid,1,'int16');
    XmitSecNumByBeam(i) = fread(fid,1,'uint8');
    DetInfo(i) = fread(fid,1,'uint8');
    DetWindowLength(i) = fread(fid,1,'uint16');
    QualFac(i) = fread(fid,1,'uint8');
    fread(fid,1,'uint8');
    TwoWayTT(i) = fread(fid,1,'float');
    BS(i) = fread(fid,1,'int16');
    RTCI(i) = fread(fid,1,'uint8');
    fread(fid,1,'uint8');
end


fread(fid,1,'uint8');
    



% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end

% checksum
checksum = fread(fid,1,'uint16');
