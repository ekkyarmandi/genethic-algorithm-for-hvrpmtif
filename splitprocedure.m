function result = splitprocedure(q,data)

result = struct(...
    'totaldistance',[],...
    'completiontime',[],...
    'transportamount',[],...
    'trip',[]...
    );

% Data Set
demand = data.demand;
dmd = demand;
k = data.k;
ta = zeros(1,numel(k));
nv = numel(ta);
tr = cell(1,nv);
td = zeros(1,nv);
ct = zeros(1,nv);
loaded = data.loaded;
unload = data.unload;

% Split Procedure
i = 1;
t = 1;
rowtr = 1;  % row trip
vsq = 1:nv; % vehicle Sequence
temptr = [];% temporary trip

while (sum(dmd) > 0)
    if ta(rowtr,vsq(t)) <= k(vsq(t))
        ta(rowtr,vsq(t)) = ta(rowtr,vsq(t)) + dmd(q(i));
        dmd(q(i)) = 0;
        temptr = [temptr,q(i)];
        if ta(rowtr,vsq(t)) >= k(vsq(t))
            dmd(q(i)) = ta(rowtr,vsq(t))-k(vsq(t));
            if rowtr == 1
                tr(rowtr,vsq(t)) = {[1,temptr,max(q)+1]};
            else
                tr(rowtr,vsq(t)) = {[max(q)+1,temptr,max(q)+1]};
            end
            temptr = [];
            ta(rowtr,vsq(t)) = k(vsq(t));
            td(rowtr,vsq(t)) = hitungjarak(tr{rowtr,vsq(t)},data.dom);
            ct(rowtr,vsq(t)) = hitungjarak(tr{rowtr,vsq(t)},data.tom);
            ct(rowtr,vsq(t)) = ct(rowtr,vsq(t)) + ta(rowtr,vsq(t))*(loaded+unload);
            t = t + 1;
            if t > nv
                % re-arange vsq
                if rowtr == 1
                    [~,vsq] = sort(ct);
                else
                    [~,vsq] = sort(sum(ct));
                end
                
                % update tour
                rowtr = rowtr + 1;
                ta = [ta; zeros(1,nv)];
                tr = [tr; cell(1,nv)];
                td = [td; zeros(1,nv)];
                ct = [ct; zeros(1,nv)];
                t = 1;
            end
        else
            i = i + 1;
            if (i == max(q)) && (sum(dmd) == 0)
                if rowtr == 1
                    tr(rowtr,vsq(t)) = {[1,temptr,max(q)+1]};
                else
                    tr(rowtr,vsq(t)) = {[max(q)+1,temptr,max(q)+1]};
                end
                temptr = [];
                td(rowtr,vsq(t)) = hitungjarak(tr{rowtr,vsq(t)},data.dom);
                ct(rowtr,vsq(t)) = hitungjarak(tr{rowtr,vsq(t)},data.tom);
                ct(rowtr,vsq(t)) = ct(rowtr,vsq(t)) + ta(rowtr,vsq(t))*(loaded+unload);
            end
        end
    end
end

ta = [ta; zeros(1,nv)];
tr = [tr; repmat({[max(q)+1,1]},1,nv)];
td = [td; ones(1,nv)*hitungjarak([max(q)+1,1],data.dom)];
ct = [ct; ones(1,nv)*hitungjarak([max(q)+1,1],data.tom)];

% Output
result.totaldistance = td;
result.completiontime = ct;
result.transportamount = ta;
result.trip = tr;

end

% Calcualte Fitness Function
function f = hitungjarak(q,dom)
    f = 0;
    for i=1:numel(q)-1
        f = f + dom(q(i),q(i+1));
    end
end