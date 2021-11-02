function New_Reward = SurvivalReward(Offsprings, New_Population)
    old_tags = Offsprings.tags;
    if(size(New_Population, 2) == 0)
         New_Reward = - 1;
         return;
    end
    new_tag = New_Population(1).tag;
    
    nd_born = size(old_tags(strcmp(old_tags, new_tag)),1);
    nd_survived = size(New_Population,2);
    nd_all = size(old_tags,1);

    New_Reward = nd_survived/nd_all + nd_survived/nd_born;
end

