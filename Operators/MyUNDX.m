function Offspring = MyUNDX(Parentpool, Parameter)
%% TO REVIEW!
    %% Parameter setting
    if nargin > 1
        [alpha, beta] = deal(Parameter{:});
    else
        alpha  = 0.5;
        beta = 0.35;
    end
    
    if isa(Parentpool(1),'SOLUTION')
        Parentpool = Parentpool.decs;
    end
    
    [N,D]   = size(Parentpool);
    
    Parents1 =  Parentpool(randperm(length(Parentpool)), :);
    Parents2 =  Parentpool(randperm(length(Parents1)), :);
    Parents3 =  Parentpool(randperm(length(Parents2)), :);
    Offspring = zeros(N,D);
        
    %% Calculation preparation
    vec1 = Parents2-Parents1;
    vec2 = Parents1-Parents2;
    vec3 = Parents3-Parents1;
    vecm = (Parents1+Parents2)/.2;
        
    d1 = sqrt(sum(vec1, 2).^2);
    d2 = sqrt(sum(vec2, 2).^2);
    d3 = sqrt(sum(vec3, 2).^2);
    
    % this is NOT the way to calculate the orth. basis to e1. But i don't
    % understand the explanations 
    e1 = vec1./d1;
    e2 = vec2./d2;
    e3 = vec3./d3;
    
    A = diag(vec3*vec1');
    B = (d3.*d1);
    C = (A./B).^2;  % C is sometimes >1, NAN and Inf 
    Dx = d3.*sqrt(1-C); % C causes big problems here
    
    s1 = (beta.*Dx./D).^2; % could this distribution work this way?
    s2 = alpha.*d1.^2;
    
    
    %% Offspring Generatio
    j=1;
    for i=1:N
        Z1 = normrnd(0, s1(i));
        Z2 = normrnd(0, s2(i), 2, 1);
        Offspring(j,:) = vecm(i,:)+Z1*e1(i,:)+Z2(1).*e2(i,:)+Z2(2).*e3(i,:);
        Offspring(j+1,:) = vecm(i,:)-Z1*e1(i,:)-(Z2(1).*e2(i,:)+Z2(2).*e3(i,:));
        j=j+2;
    end
end