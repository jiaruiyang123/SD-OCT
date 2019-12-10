
%% ----------------------------------------- %%
% Note Oct 28 2019:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
% 
% volume stitching is currently in another code
%
% Note Nov 5 2019:
% 
% All parameters were moved to the beginning of the script
% volume stitching is currently in another code
%
% Author: Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%

%% set file path & system type & stitching parameters

% specify system name
sys = 'Thorlabs';

if strcmp(sys, 'Thorlabs')
    % start and end pixel depth for AIP/MIP generation
    start_pxl = 51;
    end_pxl = 350;
    % displacement parameters
    xx=199;
    xy=-4;
    yy=197;
    yx=10;
    disp=[xx xy yy yx];
    % mosaic parameters
    numX=26;
    numY=26;
    Xoverlap=0.5;
    Yoverlap=0.5;
    mosaic=[numX numY Xoverlap Yoverlap];    
    % pxlsize=[size(slice,2) size(slice,3)];
    pattern = 'unidirectional';
elseif strcmp(sys, 'PSOCT')
    % start and end pixel depth for AIP/MIP generation
    start_pxl = 22;
    end_pxl = 120;
    % displacement parameters
   xx=920;
   xy=-40;
   yy=969;
   yx=36;
    disp=[xx xy yy yx];
    % mosaic parameters
    numX=5;
    numY=5;
    Xoverlap=0.1;
    Yoverlap=0.1;
    mosaic=[numX numY Xoverlap Yoverlap];
    %pxlsize=[size(slice,2) size(slice,3)];
    pattern = 'bidirectional';
    % load grid distortion correction and FOV curvature correction matrix
    folder_distort='/projectnb/npbssmic/ns/191112_PSOCT';                     
    fileID = fopen(strcat(folder_distort,'/grid matrix.bin'), 'r'); 
    grid_matrix = fread(fileID,'double');
    fclose(fileID);
    grid_matrix=reshape(grid_matrix, 4,1100,1100);
    load(strcat(folder_distort,'/curvature.mat'));
end

% specify dataset directory
datapath  = strcat('/projectnb/npbssmic/ns/191209_Thorlabs/');
corrected_path=strcat('/projectnb/npbssmic/ns/191201_PSOCT/corrected/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);

% total number of slices
nslice=1;

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);

% create folder for AIPs and MIPs
create_dir(nslice, datapath);

for islice=id
    
    % get the directory of all image tiles
    cd(datapath);
    filename0=dir(strcat(num2str(islice),'-*.dat'));
    
    for iFile=1:length(filename0)

        % get data information
        name=strsplit(filename0(iFile).name,'-');
        name_dat=strsplit(name{5},'.');
        
        slice_index=name{1};
        coord=name{2};
        
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name{3}); Xrpt = 1; Xsize=str2num(name{4}); Yrpt = 1; Ysize = str2num(name_dat{1});
        
        dim=[Zsize Xrpt Xsize Yrpt Ysize];                                                                        %changed by stephan
        if strcmp(sys,'Thorlabs')
            dim=[400 1 400 1 400];
        end
        
        ifilePath=[datapath,filename0(iFile).name];
        
        slice = ReadDat_single(ifilePath, dim);
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
         % pre-processing for PSOCT
         if(strcmp(sys,'PSOCT'))
             Slice=ones(170,1100,1100).*54;
             slice = slice(:, 115:Xsize-36, :); %specify FOV cut
             Slice(21:end,:,:)=slice;
             slice = FOV_curvature_correction(Slice, curvature_B, size(Slice,1), Xsize-150, Ysize); % specify z and x 
             slice = Grid_correction(slice, grid_matrix, 1080, 30, 1080, 20, size(slice,1)); % specify x0,x1,y0,y1 and z
         end

         % surface profiling and save to folder
         sur=surprofile(slice);
         surname=strcat(datapath,'surf/vol',slice_index,'/',coord,'.mat');
         save(surname,'sur');
                  
         % saving AIPs and MIPs to folder
         if(strcmp(sys,'PSOCT'))

           FILE_corrected=strcat(corrected_path, filename0(iFile).name);

           FID=fopen(FILE_corrected,'w');
           fwrite(FID,slice,'single');
           fclose(FID);
         end
         
         aip=squeeze(mean(slice(start_pxl:end_pxl,:,:),1));
         mip=squeeze(max(slice(start_pxl:end_pxl,:,:),[],1));

         avgname=strcat(datapath,'aip/vol',slice_index,'/',coord,'.mat');
         mipname=strcat(datapath,'mip/vol',slice_index,'/',coord,'.mat');
         save(mipname,'mip');
         save(avgname,'aip');  

        aip = uint16(65535*(mat2gray(aip)));        % change this line if using mip

        tiffname=strcat(datapath,'aip/vol',slice_index,'/',coord,'_aip.tif');

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

        fprintf(strcat('Tile No. ',coord,' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    
    end
    pxlsize=[size(slice,2) size(slice,3)];

    Mosaic(datapath,disp,mosaic,pxlsize,islice,pattern,sys);
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end