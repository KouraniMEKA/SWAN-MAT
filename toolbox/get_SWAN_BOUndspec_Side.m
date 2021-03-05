function [SWANBOU]=get_SWAN_BOUndspec_Side(side,fname)

% get_SWANBOU_SEGM() concatinates boundary segment's data in the format read by
% SWAN.
% Inputs:
%   -side : index of the side: N,S,W,E
%   -fname: .par file name including segment's wave data
%
% Output:
%   - concatinated boundary segment's data in the format read by SWAN.
%__________________________________________________________________________
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date  : April 2017
%__________________________________________________________________________

SWANBOU=['BOU SIDE ' side ' CONST FILE ''' fname ''''];
             
end