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
            MaxPortSwath,BeamSpacing,MaxStbdSwath] = readEM_R(fid);

    elseif datatype == 107      % note: char(107) = k, this is water column data
            % read the water column data (calls read3002_k.m)
            [DateVal,TimeVal,PingCount,NumDatagrams,DatagramNum,NumXmitSect,...
                NumRecBeams,NumBeamsHereTemp, SoundSpeed, SampFreq, TxTimeHeave, TVGFuncApplied, TVGOffset,...
                centFreqTemp,tiltAngle, xmitSectNumTemp,beamAngleTemp,startRangeSampNumTemp,numSampsTemp,xmitSectNumRecTemp,...
                beamNumTemp,beamAmpTemp,DRtemp] = readEM_k(fid);

            
            % convert datagram time to matlab datenumber
            YY = floor(DateVal/10000);
            MM = floor( (DateVal-YY*10000)/100);
            DD = floor( (DateVal-YY*10000-MM*100));
            dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
            
  
            % there may be more than one water column datagram due to the
            % size limit on a single datagram, and we want to stitch all of
            % the data for a single ping together.  The offset calculated
            % below allows the data to be associated with its proper beam
            % number
            NumBeamsHere(DatagramNum) = NumBeamsHereTemp;
            if DatagramNum > 1
                offsetidx = sum(NumBeamsHere(1:(DatagramNum-1)));
            else
                offsetidx = 0;
            end
            indx = 1:length(beamAngleTemp);
            beamAngle(offsetidx + indx) = beamAngleTemp;
            startRangeSampNum(offsetidx + indx) = startRangeSampNumTemp;
            numSamps(offsetidx + indx) = numSampsTemp;
            xmitSectNum(offsetidx + indx) = xmitSectNumRecTemp;
            beamNum(offsetidx + indx) = beamNumTemp;
            beamAmp(offsetidx + indx,1:length(beamAmpTemp(1,:))) = beamAmpTemp;
            DR(offsetidx + indx) = DRtemp;
            

            % if we have read all of the data for a single ping (plot this
            % data)
  
            if DatagramNum == NumDatagrams 
                disp( [num2str(floor(TimeVal/1000/3600)) ':' num2str(floor(rem(TimeVal/1000/3600,1)*60),'%2d') ':' num2str(rem(rem(TimeVal/1000/3600,1)*60,1)*60,'%2.2f')])
                
                
                
                
                pingidx = pingidx + 1;
                pingidxNF = pingidxNF + 1;
                pingTime(pingidx) = TimeVal/1000;    % time in seconds since midnight
                
                beamAmp = [beamAmp zeros(NumRecBeams,maxWCSampIdx-length(beamAmp(1,:)))-999];
                
  
                %disp({'SoundSpeed=' SoundSpeed});
                %disp({'SampFreq=' SampFreq});
                range =  (1:(length(beamAmp(1,:))))*SoundSpeed/10/2/(SampFreq/100); % range in meters
                range = [range zeros(1,maxWCSampIdx-length(range))];                  % pad with zeros out to the maximum range
                z = cos(beamAngle'/100*pi/180)*range;                               % this is depth
                y = sin(beamAngle'/100*pi/180)*range;                               % this is across-trackd distance
                
                Awc = beamAmp/2;
                
                X = TVGFuncApplied;
                C = TVGOffset;
                clear TS
                TS = Awc + 10*log10((RxBeamWidth/10)*pi/1800*(TxBeamWidth/10)*pi/180) - X*log10(ones(length(Awc(:,1)),1)*range) + 40*log10(ones(length(Awc(:,1)),1)*range) - C;
 

                pause
                
                TSorig = TS;
                
                %% 'remove' stuff after the bottom detect
                DRorig = DR;
                idx1 = find(DR > 0);
                idx2 = find(DR == 0);
                DR(idx2) = round(interp1(idx1,DR(idx1),idx2,'linear','extrap'));
                for i = 1:length(TS(:,1))
                    TS(i,(DR(i)+100):end) = -999;
                end
                
                %% remove possible sidelobes
                SLL = 18;       %% this should be variable - user selected?
%                 sectors = unique(xmitSectNum);
%                 for i = 1:length(sectors)
%                     idx = find(xmitSectNum == sectors(i));
%                     for samps = 1:length(TS(1,:))
%                         maxVal = max(TS(idx,samps));
%                         idx2 = find(TS(idx,samps) <= maxVal - SLL);
%                         TS( idx(idx2),samps ) = -999;
%                     end
%                 end
                for samps = 1:length(TS(1,:))
                    maxVal = max(TS(:,samps));
                    idx2 = find(TS(:,samps) <= maxVal - SLL);
                    TS( idx2,samps ) = -999;
                end
                        
                
                %% get rid of the seabed 
                idx2 = find(DR == 0);
                DR(idx2) = round(interp1(idx1,DR(idx1),idx2,'linear','extrap'));
                DR = min(DR,length(TSorig(1,:)));
                [B,A] = butter(5,.1);
                TSfilt = filtfilt(B,A,TSorig')';
                BottomMask = ones(size(TS));
                for i = 1:length(TSfilt(:,1))
                    for bstp = DR(i):(-1):1
                        if TSfilt(i,bstp) < -65
                            break
                        end
                    end
                    BottomMask(i,(bstp-10):end) = -999;
                end
                %if the water column data was detected as seabed, this is
                %probably not a good thing to do.  the following line turns
                %this off
                BottomMask = ones(size(TS));

                
                %% set a threshold
                TH = -65;
                TSaccepted = TSorig;
                idx = find( TS + BottomMask < TH);
                TSaccepted(idx) = -999;
                
                %% get rid of small targets
                TargetSizeMask = ones(size(TSaccepted));
                idx = find(TSaccepted == -999);
                TargetSizeMask(idx) = 0;
                B = ones(3,10);     % three beams, 20 samples
                idx = find(filter2(B,TargetSizeMask) < 25);
                TargetSizeMask(idx) = 0;
                
                               
                %% plot the result
                plott = 1;
                if plott
                    clear a
                    a(1) = subplot(151);
                    imagesc(TSorig');caxis([-80 -20]);
                    title('raw TS')
                    a(2) = subplot(152);
                    imagesc(TS'); caxis([-80 -20]);
                    title('sidelobes removed')
                    a(3) = subplot(153);
                    imagesc(TS' + BottomMask'); caxis([-80 -20]);
                    hold on
                    plot(DRorig,'r')
                    plot(DR,'k--')
                    hold off
                    title('bottom removed')
                    a(4) = subplot(154);
                    imagesc(TSaccepted'); caxis([-80 -20]);
                    title('thresholded')
                    a(5) = subplot(155);
                    imagesc( TS' + BottomMask' + (1-TargetSizeMask')*(-999)); caxis([-80 -20]);
                    title('minimum cluster size')
                                        
                    
                    linkaxes(a)
                    c = colormap(jet);
                    c(1,:) = 1;
                    colormap(c);
                    drawnow
                    pause
                    
      
                end
                    
                    
                %% save the targets
                beamAngleTemp = beamAngle'*ones(1,length(beamAmp(1,:)));
                beamNumTemp = (1:length(beamAmp(:,1)))'*ones(1,length(beamAmp(1,:)));
                xmitSectNumTemp = xmitSectNum'*ones(1,length(beamAmp(1,:)));
                sampNumTemp = ones(length(beamAmp(:,1)),1)*(1:length(beamAmp(1,:)));
                
                
                Targets(pingidx).DateVal = DateVal;
                Targets(pingidx).TimeVal = TimeVal;
                Targets(pingidx).dn = dn;
                Targets(pingidx).SampFreq = SampFreq;
                

                
                TSfinal = (TS + BottomMask + (1-TargetSizeMask)*(-999));
                
                %% decimate the data
                beamDec = 2;
                sampDec = 5;
                TSfinal = TSfinal(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                TSorig = TSorig(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                beamAngleTemp = beamAngleTemp(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                beamNumTemp = beamNumTemp(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                xmitSecNumTemp = xmitSectNumTemp(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                sampNumTemp = sampNumTemp(1:beamDec:length(TS(:,1)),1:sampDec:length(TS(1,:)));
                
                %% threshold and extract the targets
                idx = find( TSfinal >= TH);
                Targets(pingidx).TS = TSorig(idx);
                Targets(pingidx).beamAngle = beamAngleTemp(idx);
                Targets(pingidx).beamNum = beamNumTemp(idx);
                Targets(pingidx).xmitSectNum = xmitSectNumTemp(idx);
                Targets(pingidx).sampNum = sampNumTemp(idx);
                

            end
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


