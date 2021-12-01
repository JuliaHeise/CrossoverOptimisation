function Offspring = MyMutation(Offspring, Parameter)
    %% Parameter setting
    if nargin > 1
        [proM,disM] = deal(Parameter{:});
    else
        [proM,disM] = deal(1,20);
    end
    
    Tags = zeros(size(Offspring,1));
    
    if isa(Offspring(1),'SOLUTION')
        calObj = true;
        Tags = Offspring.tags;
        population = Offspring.decs;
        Problem = PROBLEM.Current();
        low = Problem.lower;
        up = Problem.upper;
        [N,D] = size(population);
    else
        calObj = false;
        population = Offspring;
        [N,D] = size(population);
        low = zeros(1,D);
        up = ones(1,D);
    end
       
    %% Polynomial mutation
    Lower = repmat(low,N,1);
    Upper = repmat(up,N,1);
    Site  = rand(N,D) < proM/D;
    mu    = rand(N,D);
    temp  = Site & mu<=0.5;
    Offspring       = min(max(ToMutate,Lower),Upper);
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                      (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
    temp = Site & mu>0.5; 
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                      (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
    if calObj
        Offspring = SOLUTION(Offspring, [], Tags);
    end
end