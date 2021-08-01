classdef XOPERATOR < handle
    properties (SetAccess = protected, GetAccess = public)
        TAG
        MIN_PARENTS        
    end
    
    methods (Abstract)
       Cross(obj, Parentpool, Parameter)
    end
end

