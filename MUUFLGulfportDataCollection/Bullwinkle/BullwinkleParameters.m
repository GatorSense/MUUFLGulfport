function [Parameters] = BullwinkleParameters()
%function [Parameters] = BullwinkleParameters()
%  
% Create a parameters stucture for scoring with Bullwinkle
%
% Bullwinkle is a per-pixel scoring method, made to complement
%  the blob-based scoring method ROCKY
%
%  to complain about the bad pun, email bjm@wossamotta.edu
%
% 8/14/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

Parameters.algorithmName = 'Bullwinkle';

Parameters.Halo = 2; %Halo Radius in Meters (from edge of target)
                     % for example at Halo==2: 
                     % .5m,and 1m targets get a 5x5 window
                     % 3m (and larger) targets get a 7x7 window

% Target filter for scoring:
%
% [] - no restriction, all targets scored
%
% otherwise, cell array of {type,size,human_conf,human_cat} tuples
%  type - [] specifies all types, otherwise give a string (or cell array of strings)
%            for target type, select from:
%            black, blue, red, green, dark green, brown, faux vineyard green, 
%             pea green, vineyard green
%
%  size - [] all sizes, otherwise select from [.5 1 3 6]
%                        for the .5m^2, 1m^2, 3m^2, and 6mx10m targets
%  human_conf - [] all location confidence categories, otherwise select from [1 2 3 4]
%              1 visible, 2 probably visible, 3 possibly visible, 4 not visible
%  human_cat - [] all occlusion categories, otherwise select from [0 1 2]
%                0 unoccluded, 1 part or fully in shadow but no tree occlusion, 2 part or full occlusion by tree                
%

Parameters.targetFilter = []; 

Parameters.ignore_clutter = true;  
% when ignore_clutter set to true, all values within halo of known non-targets are ignored
% ignored area is subtracted from total image area
% if false, non targets are treated as false alarms
                                     

