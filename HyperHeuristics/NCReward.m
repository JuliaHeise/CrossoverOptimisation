function New_Reward = NCReward(Old_Population, New_Population)
    %% Parameter Settings
    old_objs  = Old_Population.objs;
    new_objs = New_Population.objs;
    [N1,~] = size(new_objs);
    [N2,~] = size(old_objs);
    
    %% Are new Solutions better than old?
    two_gen = [new_objs ;old_objs];
    [FrontNo,~] = NDSort(two_gen, N1+N2);
    sorted_solutions = two_gen(FrontNo==1,:);
    
    %% C-Metric: Count non-dominated solutions (convergence)
    nd_new = intersect(new_objs, sorted_solutions, 'rows');
    nd_old = intersect(old_objs, sorted_solutions, 'rows');
   
    %% crowding distace score (diversity)
    % Maybe chose annother measurement as the median of CD might not be meaningful enough 
    cd_score_new = median(CrowdingDistance(new_objs));
    cd_score_old = median(CrowdingDistance(old_objs));
   
    %% Get the bonus and the malus
    bonus = 1/4 * cd_score_new/(cd_score_new+cd_score_old) + 3/4 * size(nd_new, 1)/N1;
    malus = 1/4 * cd_score_old/(cd_score_new+cd_score_old) + 3/4 * size(nd_old,1)/N2;
        
    %% Calculate new Reward
    New_Reward = bonus - malus;
end
