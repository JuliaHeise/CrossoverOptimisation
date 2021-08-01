function New_Reward = R2Reward(Old_Population, New_Population, Current_Reward)
    %% Parameter Settings
    if isa(Old_Population(1),'SOLUTION')
        old_objs = Old_Population.objs;
        new_objs = New_Population.objs;
    else
        old_objs = Old_Population;
        new_objs = New_Population;
    end
    
    [N,D] = size(old_objs);
    M = ceil(N*10);
    
    %% R2 of both Populations
    Lambda = RandFixedSum(M,D,1,0,1);   
    R2_new = CalcR2(new_objs, Lambda, size(new_objs, 1), size(new_objs, 2));
    R2_old = CalcR2(old_objs, Lambda, size(old_objs, 1), size(old_objs, 2));
        
    New_Reward = Current_Reward + (R2_old-R2_new)/R2_new;
end

function R2 = CalcR2(objs, Lambda, N, M)

    utopian = min(objs);
    A = repelem(utopian, N, 1);
    
    D = abs(A-objs);

    R = zeros(1,M);
    for i=1:M
        U = Lambda(i,:) .* D;
        R(i) = min(max(U, [], 2));
    end
    
    R2 = 1/M * sum(R);
end

