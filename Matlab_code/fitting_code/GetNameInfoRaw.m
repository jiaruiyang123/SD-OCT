%% GET data information
function [dim, fNameBase, fIndex]=GetNameInfoRaw(filename0)
Name_info=strsplit(filename0,'-');
% Nk=str2num(Name_info{2});     % # of camera pixel
% Nx_rpt=str2num(Name_info{3}); % # of Ascan repeat
% Nx=str2num(Name_info{4}); % # of Ascan
% Ny_rpt=str2num(Name_info{5}); % # of Bscan repeat
% Ny=str2num(Name_info{6}); % # of Bscan

% dim=[Nk,Nx_rpt,Nx,Ny_rpt,Ny];
im=1;
for ip=2:6
    dim(im)=str2num(Name_info{ip});
    im=im+1;
end
fNameBase=[strjoin(Name_info(1:end-1),'-'),'-'];
fIndexInfo=strsplit(Name_info{end},'.');
fIndex=str2num(fIndexInfo{1});