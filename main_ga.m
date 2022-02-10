clear; clc;

% GA for TSP

% Data Set
n = 10;
xyMax = 50;
xyMin = -50;
x = randi([xyMin,xyMax],1,n);
y = randi([xyMin,xyMax],1,n);
dom = distanceofmatrix(x,y);

% Parameter GA
nCr = 10;
itMax = 100;
t = 0;

% Initial Solution
empty_var = struct('solution',[],'fitness',[]);
best_chr = empty_var;
best_chr.fitness = inf;
chr = repmat(empty_var,1,nCr);
for i=1:nCr
    chr(i).solution = randperm(n);
    chr(i).solution = [chr(i).solution,chr(i).solution(1)];
    chr(i).fitness = hitungjarak(chr(i).solution,dom);
    if chr(i).fitness < best_chr.fitness
        best_chr = chr(i);
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
    for i=1:2
        parent(i) = chr(idx(i));
        parent(i).solution(end) = []; % Cut the Tail
    end
    
    % Crossover-Pointer
    p = zeros(1,2);
    while p(1) == p(2)
        p = randi([1,n],1,2);
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
        offspring(i).solution = mutation(offspring(i).solution);
        offspring(i).solution = [offspring(i).solution,offspring(i).solution(1)];
        offspring(i).fitness = hitungjarak(offspring(i).solution,dom);
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
        end
    end
    
    % Output
    clc;
    fprintf('Iteration: %d of %d\n',t,itMax);
    
    % Plot
    clf;
    hold on
    % All Solution Plot    
    for i=1:nCr
        line(x(chr(i).solution),y(chr(i).solution),'LineWidth',1,'Color','g');
    end
    % Best Solution Plot
    line(x(best_chr.solution),y(best_chr.solution),'LineWidth',1,'Color','k');
    % Point Plot
    plot(x,y,'or','MarkerFace','r','MarkerSize',9);
    hold off
    axis([xyMin,xyMax,xyMin,xyMax]);
end

% Distance of Matrix Function
function dom = distanceofmatrix(x,y)
    n = numel(x);
    dom = zeros(n);
    for j=1:n
        for i=1:n
            % Euclidean Equation
            dom(j,i)=sqrt((x(j)-x(i))^2+(y(j)-y(i))^2);
        end
    end

end

% Calcualte Fitness Function
function f = hitungjarak(q,dom)
    f = 0;
    for i=1:numel(q)-1
        f = f + dom(q(i),q(i+1));
    end

end

% Crossover Function
function parent1 = multicox(parent1,parent2,p)
    partof = parent1(p(1):p(2));
    idx = ismember(parent2,partof);
    partof = unique(parent2(idx),'stable');
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