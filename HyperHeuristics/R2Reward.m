function New_Rewards = R2Reward(Old_Population, New_Population, Current_Rewards)
    %% Parameter Settings
    old_objs = Old_Population.objs;
    new_objs = New_Population.objs;
    [N,D] = size(Old_Population);
    
    %% R2 of both Populations
    Lambda = ones(M,D);    
    R2_new = CalcR2(new_objs, Lambda,N,D);
    R2_old = CalcR2(old_objs, Lambda,N,D);
        
    New_Rewards = (R2_old-R2_new)/R2_new; 
end

function R2 = CalcR2(objs, Lambda,N,D)
    utopian = min(objs, 2);
    utility = zeros(M,D);

    for i=1:N
        for j=1:D
            utility(j,:) =Lambda(i,:).*(utopian-objs(i,:));
        end
        tmp = max(utility);
    end
    
    R2 = 1/M * sum(tmp);
end

