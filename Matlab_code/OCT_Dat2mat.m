clear all;

%% ----------------------------------------- %%
% Note Jan 23:

% Current version of code does resampling, background extraction, 
% dispersion compensation, FFT and data stripping, MIP/AIP generation.

% Write to TIF images, stitching and blending was done in a seperate script.

% Will implement the surface finding function for data stripping soon.
% Current algorithm needs some further testing.

% Will also integrate write to TIF images, stitching and blending in the
% same script soon.

% - Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%
%% set file path
datapath  = strcat('/projectnb/npbssmic/ns/191122_Thorlabs_OCTA/intralipid_3/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');

% get the directory of all image tiles
cd(datapath);

%% get data information
%[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
nk = 2048; nxRpt = 2; nx=400; nyRpt = 1; ny = 400;
dim=[nk nxRpt nx nyRpt ny];

filename0=dir(strcat('RAW-*.dat'));

ifilePath=[datapath,filename0(1).name];
disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
[data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
data=Dat2RR(data_ori,-0.22);
%dat=abs(data(:,:,:));

AG1 = data(:,1:400,:);
AG2 = data(:,401:800,:);
% crop the depth of the image and take log
AG = abs(AG2-AG1);
AG = AG(1:400,:,:);
AG = 10.*log10(AG);

% C=strsplit(filename0(1).name,'-');
% coord=strsplit(C{7},'.');
% index=coord{1};
%s=dat(1:400,:,:);
matname=strcat('AG.mat');
save(matname,'AG');


