classdef TestSettings
    properties (SetAccess = protected, GetAccess = public)
        problemClasses
        problems
        setup
        algorithms
        singleAlgorithms
        hhAlgorithms
    end
    
    methods(Access = public)
         function obj = TestSettings()
             obj.problemClasses = ...
                 [struct('name', "RM", 'versions', 2), ...
                 struct('name', "DTLZ", 'versions', []), ...
                 struct('name', "WFG", 'versions', 5)];
             
             obj.problems = ...
             [join([repmat(obj.problemClasses(1).name,...
                 1,length(obj.problemClasses(1).versions));...
                 obj.problemClasses(1).versions],"",1), ...
              join([repmat(obj.problemClasses(2).name,...
                  1,length(obj.problemClasses(2).versions));...
                 obj.problemClasses(2).versions],"",1) ...
              join([repmat(obj.problemClasses(3).name,...
                  1,length(obj.problemClasses(3).versions));...
                 obj.problemClasses(3).versions],"",1)...
            ];
        
            %set(1) = struct('name', "STD", 'DMulti', 1, 'MMulti', 1, 'maxFE', 10000);
            set(1) = struct('name', "HARDER", 'DMulti', 4, 'MMulti', 1, ...
                'maxFE', 10000);
            %%set(3) = struct('name', "HARDEST", 'DMulti', 6, 'MMulti', 1, ...
              %  'maxFE', 10000);
            
            obj.setup = set;
            obj.singleAlgorithms = ["LCX3NSGAII", "DENSGAII", "LXNSGAII", ...
                "RSBXNSGAII", "UXNSGAII", "CMAXNSGAII", "NSGAII"];
            obj.hhAlgorithms = ["AlternatingHHXNSGAII", "CaterpillarHHXNSGAII", ...
                "SRXDNSGAII", "SRXSNSGAII"];
                %"URXSNSGAII", "URXDNSGAII", ...
               % "NCRXSNSGAII", "NCRXDNSGAII", "R2XSNSGAII", ...
              %  "R2XDNSGAII", 
              %  "SRXSNSGAII", "SRXDNSGAII"]; 
                        
            obj.algorithms =  [obj.singleAlgorithms, obj.hhAlgorithms];
         end
  
         function settings = Get(obj)
             settings = {};
             for set = obj.setup
                for prob = obj.problems
                     pro = str2func(prob);
                     p = pro('DMulti', set.DMulti, 'MMulti', set.MMulti, ...
                         'maxFE', set.maxFE);
                    for alg = obj.algorithms
                        settings{end+1} = ...
                            struct('setup', set.name, 'algorithm', alg , 'dataset',...
                            prob, 'M', p.M, 'D', p.D);
                    end
                end
            end
         end
    end
end

