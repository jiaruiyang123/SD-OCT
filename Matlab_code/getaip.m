clear all;
datapath  = strcat('/projectnb/npbssmic/ns/Jiarui/1119blockface/');
cd(datapath);
for i=1
    for j=1:28
    coord = strcat(num2str((i-1)*0.7+20.5),'-',num2str((j-1)*0.7+39.5));

filename0=dir('*.dat');
for iFile=1:length(filename0)
    %% add MATLAB functions' path
    %addpath('D:\PROJ - OCT\CODE-BU\Functions') % Path on JTOPTICS
    % addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % Path on SCC server
    %% get data information
    [dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
    nk = dim(1); nxRpt = dim(2); nx=dim(3); nyRpt = dim(4); ny = dim(5);
    nz0 = round(nk/2);
    Nx=nxRpt*nx*nyRpt;
    dt = 1/47e3;
    %% File numbers
    Num_file=1;  % number of file
    LengthZ=400;  % extraction depth
    Nspec=1;

    data_k_ispec=zeros(nk,Nx,ny);
    RR_original=zeros(nz0,Nx,ny);
%% Angiogram calculation 
%%%%%%% used for calculating multiple subspectrum, eg. Nspec=[1 2 3 4 8]. set to 1 if calculating only one Nsepc, eg. Nspec=4. 
    Num_pixel=floor(nk/Nspec); % number of pixels for each sub spectrum
    ifilePath=[datapath,filename0(iFile).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
    disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
    data=Dat2RR(data_ori,-0.22);
    dat=abs(data(:,:,:));

    % crop the depth of the image
    slice=dat(1:400,:,:);
    matname=strcat('data_',num2str(iFile),'.mat');
    save(matname,'slice');
    
    % save the average A-line
%     avg=squeeze(mean(mean(slice,2),3));
%     save('avg.mat','avg');
    
end

filename1=dir('*.mat');
sum=zeros(400,400,400);
for iFile=1:length(filename1)
    matname=strcat('data_',num2str(iFile),'.mat');
    load(matname);
    sum=sum+slice;
end
slice_avg=sum./length(filename1);
save('avg_data.mat','slice_avg');
aip=squeeze(mean(slice_avg(200:300,:,:),1));
mip=squeeze(max(slice_avg(200:300,:,:),[],1));
%imagesc(aip);colormap gray;
%imagesc(mip);colormap gray;
avgname=strcat('/projectnb/npbssmic/ns/Jiarui/1106/aip/',coord,'.mat');
mipname=strcat('/projectnb/npbssmic/ns/Jiarui/1106/mip/',coord,'.mat');
save(mipname,'mip');
save(avgname,'aip');
    end
end