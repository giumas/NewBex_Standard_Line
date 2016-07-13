clear all; close all;

maxWCSampIdx = 1500;  % we are going to have a fixed water column buffer size - this is the maximum number of range samples

%% open an EM data file
[FILENAME, PATHNAME, ] = uigetfile({'*.all'}, 'load EM3002 data');
fname = [PATHNAME FILENAME];
fid = fopen(fname,'r');     % open the file



%% start reading the EM3 data file
tic
pingidx = 0;
pingidxNF = 0;
rangeSB = [];
BufSize = 50;
BSBuf1 = zeros(20000,5000);
stopp = 0;
BSidx = 0;
while ~stopp

    sz = fread(fid,1,'uint32');     % the size of the next datagram. note: the size does not include this field
    startid = fread(fid,1,'uint8'); % the start id of a datagram should be 2
    if startid == 2
       
        datatype = fread(fid,1,'char'); % this is the type of datagram that we are reading
        %disp(char(datatype))
        
        if datatype == 83      % note: char(83) = S, this is seabed image data, calls read3002_S.m;
            [DateVal,TimeVal,PingCount,MeanAbsorp,PulseLength,NormIncRange,TVGstartRange,...
                TVGstopRange,NormincBSN,OblqincBSO,TxBeamWidth,TVGcrossoverAng,NumBeamsHere,...
                beamIndexNum,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets,BeamDetAmp] = readEM_S(fid);
            
            % convert datagram time to matlab datenumber
            YY = floor(DateVal/10000);
            MM = floor( (DateVal-YY*10000)/100);
            DD = floor( (DateVal-YY*10000-MM*100));
            dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
            
            
            
        elseif datatype == 89 % note: char(89) = Y, newer seabed image data
            [DateVal,TimeVal,PingCount,sampRate,Samps2NormInc,TxBeamWidthAlong...
             TVGcrossoverAng,NormincBSN,OblqincBSO,NumBeamsHere,...
              detInfo,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets] = readEM_Y(fid);
            
          BSidx = BSidx + 1;
          BSsimrad = [];
          for i = 1:NumBeamsHere
              BSsimrad = [BSsimrad SimradSnippets(i,1:NumSampsPerBeam(i))/10];
          end
          
          BSBuf1(BSidx, round( (6000 - length(BSsimrad))/2 + (1:length(BSsimrad)))) = BSsimrad;
          
          if mod(BSidx,100) == 0
            imagesc(BSBuf1(1:BSidx,:))
            colormap(gray)
          
            drawnow
          end
            
            
            
            
        elseif datatype == 82      % note: char(82) = R, this is runtime parameters data
            [ModelNum,DateVal,TimeVal,PingCount,SystemSerNum,Mode,MinDepth,MaxDepth,AbsCoef,TxPulseLength...
                TxBeamWidth, TxPower,RxBeamWidth,RxBandWidth,RxFixedGain, TVGXover,MaxPortCoverage, MaxStbdCoverage,...
                MaxPortSwath,BeamSpacing,MaxStbdSwath] = readEM_R(fid);
            
            %pause
            
        else
            % we don't know what the data is, so scroll past this data
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


