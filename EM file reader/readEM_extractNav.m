clear all; close all;

maxWCSampIdx = 1500;  % we are going to have a fixed water column buffer size - this is the maximum number of range samples

%% open an EM data file
[FILENAME, PATHNAME, ] = uigetfile({'*.all'}, 'load EM3002 data');
fname = [PATHNAME FILENAME];
fid = fopen(fname,'r');     % open the file



%% start reading the EM3 data file
stopp = 0;
AttRoll = [];
AttPitch = [];
AttHeave = [];
AttHeading = [];
AttTime = [];
PosLat = [];
PosLon = [];
PosTime = [];
HghtHeight = [];
HghtTime = [];
while ~stopp
    
    sz = fread(fid,1,'uint32');     % the size of the next datagram. note: the size does not include this field
    startid = fread(fid,1,'uint8'); % the start id of a datagram should be 2
    if startid == 2
        
        datatype = fread(fid,1,'char'); % this is the type of datagram that we are reading
        %disp(char(datatype))

        
        if datatype == 80        % note: char(80) = P, this is a position datagram
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
            
        elseif datatype == 104   % note: char(104) = h, this is a depth (pressure) or height datagram
            [DateVal,TimeVal,heightCount,height,heightType] = readEM_h(fid);
            
            % convert datagram time to matlab datenumber
            YY = floor(DateVal/10000);
            MM = floor( (DateVal-YY*10000)/100);
            DD = floor( (DateVal-YY*10000-MM*100));
            dn = datenum(YY,MM,DD)+TimeVal/1000/3600/24;
            
            HghtHeight = [HghtHeight height];
            HghtTime = [HghtTime dn];
            
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


