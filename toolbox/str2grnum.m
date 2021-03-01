function [grnum]=str2grnum(string,ci,cj)

% str2grnum() function reads specific continious section from a character
% array and transform it into a grouped integer.
% Only number characters are indentified, all other characterd are
% discarded.
% Grouped and inspired from Mathworks forums, similar functions could be
% available.
% by Ahmad Kourani, PhD student, American University of Beirut
% Jan 2017


str2mat= str2double(regexp(num2str(string),'\d','match'));
mat2grstr=[];
for ii=ci:cj
    mat2grstr=[mat2grstr, num2str(str2mat(ii))];
end
grnum=str2double(strcat(mat2grstr));
% grnum=str2double(mat2grstr);

end