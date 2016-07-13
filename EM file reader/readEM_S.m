function [DateVal,TimeVal,PingCount,MeanAbsorp,PulseLength,NormIncRange,TVGstartRange,...
             TVGstopRange,NormincBSN,OblqincBSO,TxBeamWidth,TVGcrossoverAng,NumBeamsHere,...
              beamIndexNum,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets,BeamDetAmp] = read3002_S(fid)
    

% this is a Seabed image datagram
% Refer to the datagram formats in the EM Series Operator manual / Datagram
% Formats 850-160692/Rev.H 
ModelNum = fread(fid,1,'uint16');
DateVal = fread(fid,1,'uint32');
TimeVal = fread(fid,1,'uint32');
PingCount = fread(fid,1,'uint16');
SystemSerNum = fread(fid,1,'uint16');
MeanAbsorp = fread(fid,1,'uint16');%0.01 dB/km
PulseLength = fread(fid,1,'uint16');%in micro second
NormIncRange = fread(fid,1,'uint16');%Range to normal incidence used to correct sample amplitudes in no. of samples
TVGstartRange = fread(fid,1,'uint16');
TVGstopRange = fread(fid,1,'uint16');
NormincBSN = fread(fid,1,'int8');%BSn in 
OblqincBSO = fread(fid,1,'int8');%BSO
TxBeamWidth = fread(fid,1,'uint16');% Beam Width in 0.1 degrees
TVGcrossoverAng = fread(fid,1,'int8');%TVG law crossover angle in 0.1 deg
NumBeamsHere = fread(fid,1,'uint8');


% NumRecBeams
for i = 1:NumBeamsHere
    beamIndexNum(i) = fread(fid,1,'uint8');
    sortDir(i) = fread(fid,1,'int8');
    NumSampsPerBeam(i) = fread(fid,1,'uint16');
    BeamCenterSampNum(i) = fread(fid,1,'uint16');
end

SimradSnippets = zeros(NumBeamsHere,max(NumSampsPerBeam));
for i = 1:NumBeamsHere
    SimradSnippets(i,1:NumSampsPerBeam(i)) = fread(fid,NumSampsPerBeam(i),'int8');%amplitude in 0.5 dB
    
    BeamDetAmp(i) = SimradSnippets(i,BeamCenterSampNum(i));
end

    



% is this the end?
ETXcheck = fread(fid,1,'uint8');
if ETXcheck ~= 3
    % must have been a spare byte
    ETXcheck = fread(fid,1,'uint8');
end

% checksum
checksum = fread(fid,1,'uint16');
