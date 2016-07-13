clear all; close all;

maxWCSampIdx = 1500;  % we are going to have a fixed water column buffer size - this is the maximum number of range samples

%% open an EM data file
[FILENAME, PATHNAME, ] = uigetfile({'*.wcd'}, 'load EM3002 data');
fname = [PATHNAME FILENAME];
fid = fopen(fname,'r');     % open the file



%% start reading the EM3 data file
tic
pingidx = 0;
pingidxNF = 0;
rangeSB = [];
BufSize = 50;
tsBuf1 = zeros(BufSize,256,1000);
tsBuf2 = zeros(BufSize,256,1000);
stopp = 0;
bufCt1 = 0;
bufCt2 = 0;
AttRoll = [];
AttPitch = [];
AttHeave = [];
AttHeading = [];
AttTime = [];
ridx = 0;
while ~stopp
    
    sz = fread(fid,1,'uint32');     % the size of the next datagram. note: the size does not include this field
    startid = fread(fid,1,'uint8'); % the start id of a datagram should be 2
    if startid == 2
        
        datatype = fread(fid,1,'char'); % this is the type of datagram that we are reading
        %     disp(char(datatype))
        
        if datatype == 83      % note: char(83) = S, this is seabed image data, calls read3002_S.m;
            [DateVal,TimeVal,PingCount,MeanAbsorp,PulseLength,NormIncRange,TVGstartRange,...
                TVGstopRange,NormincBSN,OblqincBSO,TxBeamWidth,TVGcrossoverAng,NumBeamsHere,...
                beamIndexNum,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets,BeamDetAmp] = readEM_S(fid);
        elseif datatype == 82      % note: char(82) = R, this is runtime parameters data
            [ModelNum,DateVal,TimeVal,PingCount,SystemSerNum,Mode,MinDepth,MaxDepth,AbsCoef,TxPulseLength...
                TxBeamWidth, TxPower,RxBeamWidth,RxBandWidth,RxFixedGain, TVGXover,MaxPortCoverage, MaxStbdCoverage,...
                MaxPortSwath,BeamSpacing,MaxStbdSwath,PUStatus,BSPStatus,SonHeadStatus] = readEM_R(fid);
            ridx = ridx + 1;
            PUStatusAll(ridx,1:8) = bitget(PUStatus,1:8);
            BSPStatusAll(ridx,1:8) = bitget(BSPStatus,1:8);
            SonHeadStatusAll(ridx,1:8) = bitget(SonHeadStatus,1:8);
            
            YY = floor(DateVal/10000);
            MM = floor( (DateVal-YY*10000)/100);
            DD = floor( (DateVal-YY*10000-MM*100));
            dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
            StatusDN(ridx) = dn;
            
        elseif datatype == 65     % note: char(65) = A, this is an attitude datagram
            [DateVal,TimeVal,AttCount,TimeOffset,SensorStat,Roll,Pitch,Heave,Heading,SensorDesc] = readEM_A(fid);
            
            % convert datagram time to matlab datenumber
            YY = floor(DateVal/10000);
            MM = floor( (DateVal-YY*10000)/100);
            DD = floor( (DateVal-YY*10000-MM*100));
            dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
            
            AttRoll = [AttRoll Roll];
            AttPitch = [AttPitch Pitch];
            AttHeave = [AttHeave Heave];
            AttHeading = [AttHeading Heading];
            AttTime = [AttTime dn+TimeOffset/1000/3600/24];
        else
            % we don't know what the data is, so scroll past this data
            disp(char(datatype))
            
            fread(fid,sz-2,'uint8');
        end
    else
        % the start id was not equal to 2, so either this is not a file
        % containing simrad datagrams or we have made an error reading
        % it...
        disp('start id not equal to 2!')
        pause(.1)
        if feof(fid)
            stopp = 1;
        end
    end
end
fclose(fid)


