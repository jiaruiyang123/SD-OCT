dataset='190531_Thorlabs';
datapath  = strcat('/projectnb/npbssmic/ns/',dataset,'/');
addpath('/projectnb/npbssmic/s/Jiarui/code/Matlab_batch');
cd(datapath);

%filename0=dir('RAW-*.dat');

njobs=27;
%% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
nfiles = 756;       % total number of tiles
nsection = round(nfiles/njobs);

istart = (id - 1) * nsection + 1;
iend = id * nsection;


for iFile=istart:iend

    %% get data information
    %[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
    nk = 2048; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
    dim=[nk nxRpt nx nyRpt ny];
    
    cd(datapath);
    filename0=dir(strcat('RAW-26-',num2str(iFile),'-*.dat'));
    
    if ~isempty(filename0)
        ifilePath=[datapath,filename0(1).name];
        disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
        [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
        disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
        data=Dat2RR(data_ori,-0.22);
        dat=abs(data(:,:,:));

        % crop the depth of the image
        slice=dat(1:400,:,:);
        %slice=convn(slice,v,'same');
        slice=10*log10(slice);

        C=strsplit(filename0(1).name,'-');
        coord=strcat(C{3});
        slice_index=C{2};
    %    %imagesc(squeeze(slice(:,200,:)));colormap gray;
         matname=strcat(slice_index,'-',coord,'.mat');
         save(matname,'slice');
         delete(ifilePath);

        % save the average A-line
    %     avg=squeeze(mean(mean(slice,2),3));
    %     save('avg.mat','avg');

         aip=squeeze(mean(slice(71:170,:,:),1));
         mip=squeeze(max(slice(71:170,:,:),[],1));

    %   imagesc(aip);colormap gray;
    %   imagesc(mip);colormap gray;
    %     avgname=strcat('/projectnb/npbssmic/ns/Jiarui/0126volume/volume/',coord,'.mat');
    %     mipname=strcat('/projectnb/npbssmic/ns/Jiarui/0207retake/mip/',coord,'.mat');
        avgname=strcat('/projectnb/npbssmic/ns/Jiarui/0510volume/aip/vol',slice_index,'/',coord,'.mat');
        mipname=strcat('/projectnb/npbssmic/ns/Jiarui/0510volume/mip/vol',slice_index,'/',coord,'.mat');
         save(mipname,'mip');
         save(avgname,'aip');
    %     
    %     % also save as TIFF
    %     
       cd(strcat('/projectnb/npbssmic/ns/Jiarui/0510volume/aip/vol',slice_index,'/'));
        %cd(strcat('/projectnb/npbssmic/ns/Jiarui/0207retake/aip/'));
        aip = uint16(65535*(mat2gray(aip)));        % change this line if using mip

        tiffname=strcat(coord,'_aip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = 400;%size(data,2);
        tagstruct.ImageWidth      = 400;%size(data,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();

        cd(strcat('/projectnb/npbssmic/ns/Jiarui/0510volume/mip/vol',slice_index,'/'));
    %    cd(strcat('/projectnb/npbssmic/ns/Jiarui/0207retake/mip/'));

        mip = uint16(65535*(mat2gray(mip)));        % change this line if using mip

        tiffname=strcat(coord,'_mip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = 400;%size(data,2);
        tagstruct.ImageWidth      = 400;%size(data,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mip);
        t.close();
    end
end
