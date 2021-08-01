function New_Reward = SurvivalReward(Offsprings, New_Population, Current_Reward)
    old_tags = Offsprings.tags;
    if(size(New_Population, 2) == 0)
         New_Reward = Current_Reward -1;
         return;
    end
    new_tag = New_Population(1).tag;

    nd_survived = size(old_tags(strcmp(old_tags, new_tag)), 1);
    
    New_Reward = Current_Reward + nd_survived;
end

