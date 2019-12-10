% load 3D data, Return nk_Nx_ny, applicable for non-stop Ascan
% Rpt_extract=[Rpt_start, Rpt_interval, Rpt_n]
function [data]= ReadDat_single(filePath, dim, iseg, ARpt_extract,RptBscan) % [nk nx nframe/ny]
nk = dim(1); nxRpt = dim(2); nx=dim(3); nyRpt = dim(4); ny = dim(5);
if nargin <3
    iseg=1;
    ARpt_extract=[1 1 nxRpt];
    RptBscan=0;
end
if nargin <4
    ARpt_extract=[1 1 nxRpt];
    RptBscan=0;
end
RptA_start_P=ARpt_extract(1);
RptA_interval_P=ARpt_extract(2);
RptA_n_P=ARpt_extract(3);

data = zeros(nk,RptA_n_P*nx*nyRpt,ny, 'single');
% read data   
fid=fopen(filePath,'r','l');
Start_iseg=(iseg-1)*nk*nxRpt*nx*nyRpt*ny*2;
for i = 1:ny
    fseek(fid,Start_iseg+(i-1)*nk*nxRpt*nx*nyRpt*4,'bof'); % due to the data type is single (32 bytes), it therefore has to x4
    frame_data = fread(fid, nk*nxRpt*nx*nyRpt, 'single');
    
    if RptBscan==1
        datatemp(:,:,:)=reshape(frame_data, [nk nxRpt*nx,nyRpt]);
        datatemp2=permute(datatemp,[1 3 2]);
        datatemp3=reshape(datatemp2,[nk,nyRpt*nxRpt*nx]);
        data(:,:,i)=datatemp3;
    else
        if RptA_n_P == nxRpt
            data(:,:,i)=reshape(frame_data, [nk nxRpt*nx*nyRpt]);
        else
            data_ori = zeros(nk,nxRpt,nx*nyRpt, 'single');
            data_ori(:,:,:) = reshape(frame_data, [nk nxRpt, nx*nyRpt]);
            data(:,:,i)=reshape(data_ori(:,RptA_start_P:RptA_interval_P:RptA_start_P+(RptA_n_P-1)*RptA_interval_P,:),[nk,RptA_n_P*nx*nyRpt]);
        end
    end
end
fclose(fid);
   

   