function Offspring = MyMutation(ToMutate, Parameter)
    %% Parameter setting
    if nargin > 1
        [~,~,proM,disM] = deal(Parameter{:});
    else
        [~,~,proM,disM] = deal(1,20,1,20);
    end
    
    if isa(ToMutate(1),'SOLUTION')
        calObj = true;
        ToMutate = ToMutate.decs;
    else
        calObj = false;
    end
    
    [N,D]   = size(ToMutate);
    Problem = PROBLEM.Current();
    
    %% Polynomial mutation
    Lower = repmat(Problem.lower,N,1);
    Upper = repmat(Problem.upper,N,1);
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
        Offspring = SOLUTION(Offspring);
    end
end