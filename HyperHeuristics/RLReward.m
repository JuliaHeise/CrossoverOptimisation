function New_Reward = RLReward(Old_Population, New_Population, Current_Reward)
    %% Parameter Settings
    old_objs  = Old_Population.objs;
    new_objs = New_Population.objs;
    [N,~] = size(new_objs);
    
    %% Are new Solutions better than old?
    two_gen = [new_objs ;old_objs];
    [FrontNo,~] = NDSort(two_gen, N*2);
    sorted_solutions = two_gen(FrontNo==1,:);
    
    %% C-Metric: Count non-dominated solutions (convergence)
    nd_new = intersect(new_objs, sorted_solutions, 'rows');
    nd_old = intersect(old_objs, sorted_solutions, 'rows');
   
    %% crowding distace score (diversity)
    % Maybe chose annother measurement as the median of CD might not be meaningful enough 
    cd_score_new = median(CrowdingDistance(new_objs));
    cd_score_old = median(CrowdingDistance(old_objs));
   
    %% Get the bonus and the malus
    bonus = ...1/4 * cd_score_new + 3/4 * 
        size(nd_new, 1)/N;
    malus = ...1/4 * cd_score_old + 3/4 * 
        size(nd_old,1)/N;
        
    %% Calculate new Reward
    New_Reward = Current_Reward + bonus - malus;
end
