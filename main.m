clc; clear;

% Load Dataset
load('data/koordinat.mat');

% Dataset
data = load('data/data.mat');
tmax = 420;
n = numel(data.demand)-1;

% Parameter VRP
data.k = [10,10,6,6,6,6,6,6,6,6];
data.loaded = 10;
data.unload = 2;

% Parameter GA
nCr = 100;
itMax = 1000;
t = 0;

% Empty Variable (Data Structure);
bestfitness = [];
meanfitness = [];
empty_var = struct(...
    'solution',[],...
    'detail',[],...
    'fitness',[],...
    'fisibility',0 ...
    );

best_chr = empty_var;
best_chr.fitness = inf;

% Initial Solution
chr = repmat(empty_var,1,nCr);
for i=1:nCr
    while chr(i).fisibility == 0
        chr(i).solution = randperm(n);
        chr(i).solution(chr(i).solution==1) = [];
        chr(i).detail = splitprocedure(chr(i).solution,data);
        chr(i) = localoptimize(chr(i),data);
        chr(i) = cff(chr(i),tmax);
        if chr(i).fitness < best_chr.fitness
            best_chr = chr(i);
        end
    end
end

while t < itMax
    t = t + 1;
    
    % RWS-Selection
    fitness = [];
    fitness = [fitness,chr.fitness];
    fitness = fitness/sum(fitness);
    fitness = cumsum(fitness);
    idx = zeros(1,2);
    while idx(1) == idx(2)
        p = rand(1,2);
        for i=1:2
            if p(i) < fitness(1)
                idx(i) = 1;
            else
                idx(i) = find(p(i) < fitness,1,'first');
            end
        end
    end
    parent = repmat(empty_var,1,2);
    parent(1) = chr(idx(1));
    parent(2) = chr(idx(2));
    
    % Crossover-Pointer
    p = zeros(1,2);
    while p(1) == p(2)
        p = randi([1,n-1],1,2);
        if p(1) > p(2)
            p([1,2]) = p([2,1]);
        end
    end
    
    % Multi-point Crossover
    child = repmat(empty_var,1,2);
    child(1).solution = multicox(parent(1).solution,parent(2).solution,p);
    child(2).solution = multicox(parent(2).solution,parent(1).solution,p);
    
    % Mutation
    offspring = repmat(empty_var,1,2);
    for i=1:2
        offspring(i) = child(i);
        while offspring(i).fisibility == 0
            offspring(i).solution = mutation(offspring(i).solution);
            offspring(i).detail = splitprocedure(offspring(i).solution,data);
            offspring(i) = localoptimize(offspring(i),data);
            offspring(i) = cff(offspring(i),tmax);
        end
    end
    
    % Elitism
    fitness = [];
    fitness = [fitness,chr.fitness];
    [~,idx] = sort(fitness,'descend');
    idx  = idx(1:2);
    chr(idx) = offspring;
    for i=1:nCr
        if chr(i).fitness < best_chr.fitness
            best_chr = chr(i);
            
            % Plot
            % doing_plot(best_chr,x,y);
        end
    end
    
    % Record Fitness
    bestfitness = [bestfitness,best_chr.fitness];
    meanfitness = [meanfitness,mean(fitness)];
    
    % Output
    clc;
    fprintf('fitness: %0.0f\n',best_chr.fitness);
    fprintf('iterasi ke: %d dari %d\n',t,itMax);    
    
end

% Plot Fitness
figure(1);
figure('WindowState', 'maximized');
hold on
plot(meanfitness,'-r','LineWidth',0.5);
plot(bestfitness,'-b','LineWidth',1);
legend('Mean Fitness','Best Fitness');
hold off
ax = gca;
grid on
xlabel('Iterasi','FontWeight','bold');
ylabel('Fitness','FontWeight','bold');
ytickformat('%,d');
xtickformat('%,d');
xlim([0,itMax]);
set(ax,'FontName','Times New Roman');
set(ax.YRuler,'Exponent',0);

% Crossover Function
function parent1 = multicox(parent1,parent2,p)
partof = parent1(p(1):p(2));
idx = ismember(parent2,partof);
partof = parent2(idx);
parent1(p(1):p(2)) = partof;
end

% Mutation Function
function q = mutation(q)

n = randi(3);
p = ones(1,2);

while p(1) == p(2)
    for i=1:2
        p(i) = randi(numel(q));
    end
end

switch n
    case 1 % Do Swap Mutation
        q([p(1) p(2)]) = q([p(2) p(1)]);
        
    case 2 % Do Inversion Mutation
        if p(1) > p(2)
            p([1 2]) = p([2 1]);
        end
        q(p(1):p(2)) = q(p(2):-1:p(1));
        
    case 3 % Do Scramble Mutation
        if p(1) > p(2)
            p([1 2]) = p([2 1]);
        end
        tempSol = q(p(1):p(2));
        scrambled = randperm(numel(q(p(1):p(2))));
        q(p(1):p(2)) = tempSol(scrambled);
end
end

% Calculate Fitness & Fisibility Function
function q = cff(q,tmax)

if size(q.detail.totaldistance,1) > 1
    q.fitness = sum(sum(q.detail.completiontime)) + ...
        sum(sum(q.detail.totaldistance));
else
    q.fitness = sum(q.detail.completiontime) + ...
        sum(q.detail.totaldistance);
end
if size(q.detail.completiontime,1) > 1
    value = max(sum(q.detail.completiontime,1));
    if value > tmax
        q.fisibility = 0;
    else
        q.fisibility = 1;
    end
else
    value = max(q.detail.completiontime,1);
    if value > tmax
        q.fisibility = 0;
    else
        q.fisibility = 1;
    end
end
end
