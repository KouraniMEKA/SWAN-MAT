function[iso_date_time]=iso_notation_time(yyyy,mm,dd,hh)
% 
% iso_notation_time() concatinates time data into iso notation of time of
% the form : yyyymmdd.hhmmss
%
% Inputs:
%   -yy1: fist 2 digits of year (i.e: 20)
%   -yy2: second 2 digits of year (i.e: 17)
%   -mm : month
%   -dd : day
%   -hh : hour
%
% Outputs: 
%   -iso_date_time: time in iso notation
%__________________________________________________________________________
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date  : Jan 2017
%__________________________________________________________________________

    iso_date_time=[num2str(yyyy,'%04d') num2str(mm,'%02d') num2str(dd,'%02d') '.' num2str(hh,'%02d'), '0000'];

end