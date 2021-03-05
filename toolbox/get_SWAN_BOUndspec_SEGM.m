function [SWANBOU]=get_SWAN_BOUndspec_SEGM(x1,y1,x2,y2,len,fname)

% get_SWANBOU_SEGM() concatinates boundary segment's data in the format read by
% SWAN.
% Inputs:
%   -x1,y1: first  points coordinates
%   -x2,y2: second points coordinates
%   -len:  the distance (m) from the first point of the side or segment to the point along the side or segment for which the incident wave spectrum is prescribed
%   -fname: .par file name including segment's wave data
%
% Output:
%   - concatinated boundary segment's data in the format read by SWAN.
%__________________________________________________________________________
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date  : Jan 2017
%__________________________________________________________________________

SWANBOU=['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d')...
                 ' ' num2str(y2,'%06d') ' VAR FILE ' num2str(len) ' ''' fname ''' '];
             
end