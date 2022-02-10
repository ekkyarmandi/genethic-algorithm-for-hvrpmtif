clc; clear;

% function: q,idk,tps

load data/sample.mat
load data/kendaraan.mat
load data/kodetps.mat

trips = [];
ntrip = [];
td = [];
ct = [];
ta = [];

for j=1:size(q.detail.trip,2)
    
    perjalanan = [];
    ntr = 0;
    temptd = 0;
    tempct = 0;
    tempta = 0;
    
    for i=1:size(q.detail.trip,1)
        
        if ~isempty(q.detail.trip{i,j})            
            trip = tps(q.detail.trip{i,j});
            ntr = ntr + 1;
            perjalanan = [perjalanan,sprintf('%s-',trip{1:end-1})];
            if i == size(q.detail.trip,1)
                perjalanan = [perjalanan,sprintf('%s',trip{end})];
            end
            temptd = temptd + q.detail.totaldistance(i,j);
            tempct = tempct + q.detail.completiontime(i,j);
            tempta = tempta + q.detail.transportamount(i,j);
        end
    end
    
    trips = [trips;{perjalanan}];
    ntrip = [ntrip;{ntr}];
    td = [td;{temptd}];
    ct = [ct;{tempct}];
    ta = [ta;{tempta}];
end

% Result
data = [idk(2,:)',trips,ntrip,td,ct,ta];