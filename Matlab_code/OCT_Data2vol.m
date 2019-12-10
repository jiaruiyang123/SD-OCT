datapath  = strcat('/projectnb/npbssmic/ns/191125_Thorlabs/test/');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir('1-*.dat');

% add subfunctions for the script
% get the directory of all image tiles

for iFile=1:length(filename0)
    
    %% add MATLAB functions' path
    %addpath('D:\PROJ - OCT\CODE-BU\Functions') % Path on JTOPTICS
    % addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % Path on SCC server
    %load(filename0(iFile).name);
    %% get data information
     nk = 400; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
     dim=[nk nxRpt nx nyRpt ny];
     
     ifilePath=[datapath,filename0(iFile).name];
     disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
     [slice] = ReadDat_single(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx

    coord=;
     
     aip=squeeze(mean(slice(51:end,:,:),1));
     mip=squeeze(max(slice(51:end,:,:),[],1));

     aip = uint16(65535*(mat2gray(aip)));        % change this line if using mip

     tiffname=strcat(datapath,'aip/',coord,'_aip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(slice,2);
        tagstruct.ImageWidth      = size(slice,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();

        mip = uint16(65535*(mat2gray(mip)));        % change this line if using mip

        tiffname=strcat(datapath,'mip/vol',slice_index,'/',coord,'_mip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(slice,2);
        tagstruct.ImageWidth      = size(slice,3);
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