function [DateVal,TimeVal,PingCount,NumDatagrams,DatagramNum,NumXmitSect,...
                NumRecBeams,NumBeamsHere, SoundSpeed, SampFreq, TxTimeHeave, TVGFuncApplied, TVGoffsetdb,...
                centFreq,tiltAngle, xmitSectNum,beamAngle,startRangeSampNum,numSamps,xmitSectNumRec,...
                beamNum,beamAmp,DR] = read3002_k(fid)
% this function reads water column data from EM3002 datagrams. 
% Refer to the datagram formats in the EM Series Operator manual / Datagram Formats 850-160692/Rev.H 

 % then this is water column data
            ModelNum = fread(fid,1,'uint16');
            DateVal = fread(fid,1,'uint32');
            TimeVal = fread(fid,1,'uint32');
            PingCount = fread(fid,1,'uint16');
            SystemSerNum = fread(fid,1,'uint16');
            NumDatagrams = fread(fid,1,'uint16');   % Note: there is a max of 64 kBytes in one datagram, so more than one datagram may be required...
            DatagramNum = fread(fid,1,'uint16');
            NumXmitSect = fread(fid,1,'uint16');
            NumRecBeams = fread(fid,1,'uint16');
            NumBeamsHere = fread(fid,1,'uint16');
            SoundSpeed = fread(fid,1,'uint16');
            SampFreq = fread(fid,1,'uint32'); %0.01 Hz
            TxTimeHeave = fread(fid,1,'int16');
            TVGFuncApplied=fread(fid,1,'int8');
            TVGoffsetdb=fread(fid,1,'int8');
            fread(fid,1,'uint32');  % spare

            % NumXmitSect
            for i = 1:NumXmitSect
                tiltAngle(i) = fread(fid,1,'int16');
                centFreq(i) = fread(fid,1,'uint16');
                xmitSectNum(i) = fread(fid,1,'uint8');
                fread(fid,1,'uint8');   % spare
            end



            % NumRecBeams
            for i = 1:NumBeamsHere
                beamAngle(i) = fread(fid,1,'int16');
                startRangeSampNum(i) = fread(fid,1,'uint16');
                numSamps(i) = fread(fid,1,'uint16');
                DR(i) = fread(fid,1,'uint16');
                xmitSectNumRec(i) = fread(fid,1,'uint8');
                beamNum(i) = fread(fid,1,'uint8');
                beamAmp(i,1:numSamps(i)) = fread(fid,numSamps(i),'int8'); %Amplitude in 0.5 dB resolution
%                 for ii = 1:numSamps(i)
%                     beamAmp(i,ii) = fread(fid,1,'int8');
%                 end
            end

            % is this the end?
            ETXcheck = fread(fid,1,'uint8');
            if ETXcheck ~= 3
                % must have been a spare byte
                ETXcheck = fread(fid,1,'uint8');
            end
            % checksum
checksum = fread(fid,1,'uint16'); %#ok<NASGU>
