function q = localoptimize(q,data)

% input: q.detil, data
% 1. filter and re-optimize q.detil.trip
% 2. re-calculate q.detil.totaldistance
% 3. re-calculate q.detil.completiontime
% output: q.detil

% Dataset & Initial Variable
dom = data.dom;
tom = data.tom;
unload = data.unload;
loaded = data.loaded;
possible = struct('trip',[],'fitness',[]);
besttrip = possible;

% Limit Permutation Parameter
limit = 7;
rand_num = rand();

for i=1:size(q.detail.trip,1)
    for j=1:size(q.detail.trip,2)
        
        n = numel(q.detail.trip{i,j});
        
        % Filtering trip by n lenght & Re-optimize the trip
        if (n > 3) && (n < 10)
            
            trip = q.detail.trip{i,j};
            front_end = trip([1,end]); % Cut Front-End trip
            trip([1,end]) = [];
            besttrip.fitness = inf;
            trips = perms(trip);
            
            if numel(trip) > limit
                % Upporbound to get trips index
                upperbound = limit/numel(trip);
                while rand_num > upperbound
                    rand_num = rand();
                end
                rand_pos = floor(rand_num*factorial(numel(trip)))-1;
                possible.trip = zeros(factorial(limit),numel(trip));
                possible.fitness = zeros(1,factorial(limit));
                for u=1:factorial(limit)
                    possible.trip(u,:) = trips(rand_pos+u,:);
                end
            else
                possible.trip = trips;
            end
            
            % Re-evaluate all possible permutation from trip
            for m=1:size(possible.trip,1)
                possible.fitness(m) = hitungjarak([front_end(1),...
                    possible.trip(m,:),front_end(end)],dom) +...
                    hitungjarak([front_end(1),possible.trip(m,:),...
                    front_end(end)],tom);
                % Note: Load and Unloading Processing Time Skipped
                
                if possible.fitness(m) < besttrip.fitness
                    besttrip.trip = possible.trip(m,:);
                    besttrip.fitness = possible.fitness(m);
                end
            end
            
            % Update Trip Total Distance & Total Completion Time
            % (Include Load and Unload)
            
            q.detail.trip(i,j) = {[front_end(1),besttrip.trip,...
                front_end(end)]};
            q.detail.totaldistance(i,j) = hitungjarak(q.detail.trip{i,j},dom);
            q.detail.completiontime(i,j) = hitungjarak(q.detail.trip{i,j},tom);
            q.detail.completiontime(i,j) = q.detail.completiontime(i,j) +...
                q.detail.transportamount(i,j)*(unload+loaded);
            
        end
        
    end
end
end

% Calculate Distance Function
function f = hitungjarak(q,dom)
f = 0;
for i=1:numel(q)-1
    f = f + dom(q(i),q(i+1));
end
end