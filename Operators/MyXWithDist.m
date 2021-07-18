function Offspring = MyXWithDist(Population, Operators, Distribution)
    % Divide Population into pool for each Operator
    % corresponding to Distribution
   Offspring = Operators{1}(Population); 
end

