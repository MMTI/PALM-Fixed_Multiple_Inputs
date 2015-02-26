function VG = palm_ptree2vg(Ptree)
% Define the variance groups based on a block tree.
% 
% Usage:
% VG = palm_ptree2vg(Ptree)
% 
% Ptree : Tree with the dependence structure between
%         observations, as generated by 'palm_tree'.
% VG    : Vector with the indexed variance groups.
% 
% _____________________________________
% Anderson M. Winkler
% FMRIB / University of Oxford
% Nov/2013
% http://brainder.org

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% PALM -- Permutation Analysis of Linear Models
% Copyright (C) 2015 Anderson M. Winkler
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Generate the variance groups, then reindex to integers
% for easier readability.
n = 1;
[VG,n] = pickvg(Ptree,isnan(Ptree{1,1}),n);
[~,~,VG] = unique(VG);

% Fix the sorting of rows using the 1st permutation
[~,idx] = palm_permtree(Ptree,1,false);
VG = VG(idx,:);

% ==============================================
function [VG,n] = pickvg(Ptree,withinblock,n)
% This is the one that actually does the job, recursively
% along the tree branches.

% Vars for later
nU = size(Ptree,1);
VG = [];

if size(Ptree,2) > 1,
    % If this is not a terminal branch
    
    if withinblock,    
        % If these branches cannot be swapped (within-block only),
        % define vargroups for each of them, separately, going
        % down more levels.
        for u = 1:nU,
            [VGu,n] = pickvg(Ptree{u,3},isnan(Ptree{u,1}),n);
            VG      = vertcat(VG,VGu); %#ok it's just a small vector
        end
        
    else
        % If these branches can be swapped (whole-block), then it
        % suffices to define the vargroups for the first one only,
        % then replicate for the others.
        [VGu,n] = pickvg(Ptree{1,3},isnan(Ptree{1,1}),n);
        VG      = repmat(VGu,[nU 1]);
    end
    
else
    % If this is a terminal branch
    
    if withinblock,    
        % If the observations cannot be shuffled, each has to belong
        % to its own variance group, so one random number for each
        sz = size(Ptree,1) - 1;
        VG = (n:n+sz)';
        n  = n + sz + 1;
    else
        % If the observations can be shuffled, then all belong to a
        % single vargroup.
        VG = n*ones(size(Ptree,1),1);
        n  = n + 1;
    end
end
