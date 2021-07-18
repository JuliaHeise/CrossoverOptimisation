function Offspring = MyCMAX(Parentpool, Parameter)
    %% Parameter Setting
    Problem = PROBLEM.Current();
    if isa(Parentpool(1),'SOLUTION')
        Parentpool = Parentpool.decs;
    end
    
    if nargin > 1
        sigma = deal(Parameter{:});
    else
        sigma = 1;
    end
    
    % Number of parents
    N = size(Parentpool,1);
    
    % Center point 
    centerPoint = mean(Parentpool);

    
    %% Covariance Matrix Adaption  
    Cov = cov(Parentpool);
    Samples = mvnrnd(zeros(1,Problem.D), Cov, N);
    Offspring = centerPoint + sigma .* Samples;
end