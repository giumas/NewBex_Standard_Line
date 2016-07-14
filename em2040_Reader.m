%{
Test File

This script creates backscatter waterfall plots for use in the Newbex standardline
project. It also takes relevant information regarding the line pass to aid
in comparison.

Both the image data and the navigation data are from the Kongsberg EM2040.
This script uses the EM File reader directory to extract the data.

THIS IS A TEST FILE. Not really that useful just yet.
Hopefully this will grow to be useable one day.
Michael Smith
Initial creation: 06/13/2016
GitVersion: 1
date:7/13/2014
%}

clc; 
clear; 
close all;

addpath(genpath('NewBex_Standard_Line\Em file reader'))
DIR=pwd;
load('navRef')      %data for he reference plot

%% open the EM data file
[fname,pname] = uigetfile({'*.all'}, 'load EM3002 data','MultiSelect', 'on');
Foldn = uigetdir('','Select Save location');
if ischar(fname)
    fname=cellstr(fname);
end
%%
for i=1:numel(fname)
    fn=char(fname(i));
    fid = fopen([pname fn],'r');
    
    %% read the EM data file
    
    
    stopp = 0;                      %while loop stop parameter
    
    
    pingidx = 0;                    %preallocate memory for image data
    pingidxNF = 0;
    rangeSB = [];
    BufSize = 50;
    BSBuf1 = zeros(20000,6000);
    BSraw = zeros(20000,400);
    BSidx = 0;
    BSindx78=0;
    Rinc=[];
    pincount=0;
    AttRoll = [];                   %preallocate memory for nav and attitude data
    AttPitch = [];
    AttHeave = [];
    AttHeading = [];
    AttTime = [];
    PosLat = [];
    PosLon = [];
    PosTime = [];
    HghtHeight = [];
    HghtTime = [];
    
    %{
The following loop steps through the data file selected above. The data
file contains datagrams with specific headers. The loops looks if the
header matchs one of the desired datagram packets and will extract that
information. If it doesn't match it skips it. It does this through the
whole file until it reaches the end changing the stopp loop param
    %}
    while ~stopp
        
        sz = fread(fid,1,'uint32');     % the size of the next datagram. note: the size does not include this field
        startid = fread(fid,1,'uint8'); % the start id of a datagram should be 2
        if startid == 2
            
            datatype = fread(fid,1,'char') % this is the type of datagram that we are reading
            %disp(char(datatype))
            
            
            if datatype == 89 % note: char(89) = Y, newer seabed image data
                [DateValBS,TimeVal,PingCount,sampRate,Samps2NormInc,TxBeamWidthAlong...
                    TVGcrossoverAng,NormincBSN,OblqincBSO,NumBeamsHere,...
                    detInfo,sortDir,NumSampsPerBeam,BeamCenterSampNum,SimradSnippets] = readEM_Y(fid);
                Rinc=[Rinc Samps2NormInc];
                BSidx = BSidx + 1;
                BSsimrad = [];
                for i = 1:NumBeamsHere
                    BSsimrad = [BSsimrad SimradSnippets(i,1:NumSampsPerBeam(i))/10];
                end
                
                BSBuf1(BSidx, round( (6000 - length(BSsimrad))/2 + (1:length(BSsimrad)))) = BSsimrad;
                
                
            elseif datatype == 82      % note: char(82) = R, this is runtime parameters data
                [ModelNum,DateValRT,TimeVal,PingCount,SystemSerNum,Mode,MinDepth,MaxDepth,AbsCoef,TxPulseLength...
                    TxBeamWidth, TxPower,RxBeamWidth,RxBandWidth,RxFixedGain, TVGXover,MaxPortCoverage, MaxStbdCoverage,...
                    MaxPortSwath,BeamSpacing,MaxStbdSwath] = readEM_R(fid);
                
            elseif datatype == 80        % note: char(80) = P, this is a position datagram
                [DateVal,TimeVal,PosCount,latitude,longitude,fixQual,SOG,COG,heading,inputDatagram] = readEM_P(fid);
                
                % convert datagram time to matlab datenumber
                YY = floor(DateVal/10000);
                MM = floor( (DateVal-YY*10000)/100);
                DD = floor( (DateVal-YY*10000-MM*100));
                dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
                
                PosLat = [PosLat latitude];
                PosLon = [PosLon longitude];
                PosTime = [PosTime dn];
                
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
                
            elseif datatype == 78   % note: char(78) = N, this is a raw range and angle datagram
                [DateValRaw,TimeValRaw,PingCount,SSPD,SampFreq,TiltAng,...
                    CentFreq,XmitSecNum,BeamAngle,XmitSecNumByBeam,...
                    TwoWayTT,DetInfo,BS] = readEM_N(fid);
                
                % BS RAW (uncorrected?)
                BSindx78=BSindx78+1;
                BSraw(BSindx78,:)=BS; 
                
            elseif datatype == 88 % this is the xyz depth datagram
                [DateVald,TimeVald,PingCount,Head,SSPD,SampFrequ,z,y,x,...
                    DetcWindowL,IBA,DetcInfo,cleanInfo,ReflecBS,NumBeams] = readEM_X(fid);
                pincount=pincount+1;
                Z(pincount,:) = z;
                Y(pincount,:) = y;
                X(pincount,:) = x;
                BSd(pincount,:) =ReflecBS./10;
                
            elseif datatype == 104   % note: char(104) = h, this is a depth (pressure) or height datagram
                [DateVal,TimeVal,heightCount,height,heightType] = readEM_h(fid);
                
                % convert datagram time to matlab datenumber
                YY = floor(DateVal/10000);
                MM = floor( (DateVal-YY*10000)/100);
                DD = floor( (DateVal-YY*10000-MM*100));
                dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
                
                HghtHeight = [HghtHeight height];
                HghtTime = [HghtTime dn];
%                 
                
            else
                % we don't know what the data is, so scroll past this data
                fread(fid,sz-2,'uint8');
            end
        else
            % the start id was not equal to 2, so either this is not a file
            % containing simrad datagrams or we have made an error reading
            % it...
            disp('start id not equal to 2!')
            
            if feof(fid)
                stopp = 1;
            end
        end
    end
    fclose(fid)
        
    %% Create plots and save
    
    BSfig=figure();     %creatae the BSimage, modified caxis, not sure if right
    imagesc(BSBuf1);
    colormap(gray);
    colorbar;
    caxis([-30 0]);
    
    figure()
    eh=zeros(length(BSd(:,1)),1000);
    tester=[eh BSd eh];
    imagesc(tester)
    colormap gray;
    colorbar
    caxis([-30 0]);
    
    
    Navfig=figure();
    plot(RefLong,RefLat,'--',PosLon,PosLat,'LineWidth',2)
    
%     %% Save the data
%     BSinfo=sparse(BSBuf1);  %convert to sparse to cut down on data
%     geoRef=[fn(1:end-4) '_geoRef'];
%     BSImagry=[fn(1:end-4) '_BSImagry'];
%     navdata=[fn(1:end-4) '_Navdata'];
%     BSInfo=[fn(1:end-4) '_BSinfo'];
%     RunParam=[fn(1:end-4) '_RunParam'];
%     cd(Foldn);
%     
%     
%     a= exist(fn(1:end-4),'file');
%     if a==7
%         cd(fn(1:end-4));
%     else
%         mkdir(fn(1:end-4));
%         cd(fn(1:end-4));
%     end
%     saveas(BSfig,BSImagry,'tiff');
%     saveas(Navfig,geoRef,'tiff');
%     save(navdata,'AttCount','AttHeading','AttHeave','AttPitch','AttRoll','AttTime','PosCount','PosLat','PosLon','PosTime','HghtHeight','HghtTime','SensorStat','SensorDesc');
%     save(BSInfo,'BSinfo','DateValBS','TimeVal','PingCount','sampRate','Samps2NormInc','TxBeamWidthAlong','TVGcrossoverAng','NormincBSN','OblqincBSO','NumBeamsHere','detInfo','sortDir','NumSampsPerBeam','BeamCenterSampNum')
%     save(RunParam,'ModelNum','DateVal','TimeVal','PingCount','SystemSerNum','Mode','MinDepth','MaxDepth','AbsCoef','TxPulseLength','TxBeamWidth','TxPower','RxBeamWidth','RxBandWidth','RxFixedGain','TVGXover','MaxPortCoverage','MaxStbdCoverage','MaxPortSwath','BeamSpacing','MaxStbdSwath')
%     close all
%     cd(DIR);
 end