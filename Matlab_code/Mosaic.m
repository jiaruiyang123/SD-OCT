function Mosaic(datapath,disp,mosaic,pxlsize,islice,pattern,sys)
%%% ---------------------- %%%
% function version of mosaicing & blending
% input: displacement parameters: four elements array [xx xy yy yx]
%        mosaic parameters: four elemetns array [number of x tile, number of y tile,
%                                                 overlap in x, overlap in y]
%        pixel size parameters: two elements array [x pixel size, y pixel size]
%        slice index: index of slice you wish to perform stitching & blending
%
% Author: Jiarui Yang
% 10/28/19
%% define parameters
   %displacement parameters
    xx=disp(1);
    xy=disp(2);
    yy=disp(3);
    yx=disp(4);
    % mosaic parameters
    numX=mosaic(1);
    numY=mosaic(2);
    Xoverlap=mosaic(3);
    Yoverlap=mosaic(4);
    
    Xsize=pxlsize(1);                                                                              %changed by stephan
    Ysize=pxlsize(2);
    
    numTile=numX*numY;
    grid=zeros(2,numTile);

    if strcmp(pattern,'unidirectional')
        for i=1:numTile
            if mod(i,numX)==0
                grid(1,i)=(numY-ceil(i/numX))*xx;
                grid(2,i)=(numY-ceil(i/numX))*xy;
            else
                grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
                grid(2,i)=(numY-ceil(i/numX))*xy+(numX-(mod(i,numX)))*yy;
            end
        end
    elseif strcmp(pattern,'bidirectional')
        for i=1:numTile
            if mod(ceil(i/numX),2)==1
                if mod(i,numX)==0
                    grid(1,i)=(numY-ceil(i/numX))*xx-yx;
                    grid(2,i)=(numY-ceil(i/numX))*xy;
                else
                    grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
                    grid(2,i)=(numY-ceil(i/numX))*xy+((numX-mod(i,numX)))*yy;
                end
            else
                if mod(i,numX)==0
                    grid(1,i)=(numY-ceil(i/numX))*xx+(numX-1)*yx;
                    grid(2,i)=(numY-ceil(i/numX))*xy+(numX-1)*yy;
                else
                    grid(1,i)=(numY-ceil(i/numX))*xx+((mod(i,numX)-1))*yx;
                    grid(2,i)=(numY-ceil(i/numX))*xy+((mod(i,numX)-1))*yy;
                end
            end
        end
    end
    %% generate distorted grid pattern& write coordinates to file

    filepath=strcat(datapath,'aip/vol',num2str(islice),'/');
    cd(filepath);
    fileID = fopen([filepath 'TileConfiguration.txt'],'w');
    fprintf(fileID,'# Define the number of dimensions we are working on\n');
    fprintf(fileID,'dim = 2\n\n');
    fprintf(fileID,'# Define the image coordinates\n');
    tile=0;
    val=zeros(numTile,1);
    for j=1:numTile
        filename0=dir(strcat(num2str(j),'.mat'));       % load AIP to determine whether it is agarose
        load(filename0.name);
        val(j)=std2(aip);
    end
    for j=1:numTile
        if val(j)>=0.3     % threshold tunable for agarose blocks, visual examine after done
            fprintf(fileID,[num2str(j) '_aip.tif; ; (%d, %d)\n'],round(grid(:,j)));
            tile=tile+1;
        end   
    end
    fclose(fileID);

    %% generate Macro file
    macropath=[filepath,'Macro.ijm'];
    filepath_rev=strcat(datapath,'aip/');

    fid_Macro = fopen(macropath, 'w');

    l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',filepath_rev,'vol',num2str(islice),' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',filepath_rev,'vol',num2str(islice),'");\n'];
    fprintf(fid_Macro,l);

    fclose(fid_Macro);

    %% execute Macro file
    tic
    system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);
    toc

    %% get FIJI stitching info
    
    filename = strcat(datapath,'aip/vol',num2str(islice),'/');
    f=strcat(filepath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'aip');

    % define coordinates for each tile

    Xcen=zeros(size(coord,2),1);
    Ycen=zeros(size(coord,2),1);
    index=coord(1,:);
    if strcmp(sys,'PSOCT')
        for ii=1:size(coord,2)
            Xcen(coord(1,ii))=round(coord(3,ii));
            Ycen(coord(1,ii))=round(coord(2,ii));
        end
    elseif strcmp(sys,'Thorlabs')
        for ii=1:size(coord,2)
            Xcen(coord(1,ii))=round(coord(2,ii));
            Ycen(coord(1,ii))=round(coord(3,ii));
        end
    end
    Xcen=Xcen-min(Xcen);
    Ycen=Ycen-min(Ycen);

    Xcen=Xcen+round(Xsize/2);
    Ycen=Ycen+round(Ysize/2);

    % tile range -199~+200
    stepx = Xoverlap*Xsize;
    x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) stepx-1:-1:0]./stepx;
    stepy = Yoverlap*Ysize;
    y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) stepy-1:-1:0]./stepy;
    if strcmp(sys,'PSOCT')
        [rampy,rampx]=meshgrid(y, x);
    elseif strcmp(sys,'Thorlabs')
        [rampy,rampx]=meshgrid(x, y);
    end   
    ramp=rampy.*rampx;      % blending mask
    %size(ramp)                                                                                           %changed by stephan
    %size(aip)
    % blending & mosaicing
  
    Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
    Masque = zeros(size(Mosaic));

    cd(filename);    

    for i=1:length(index)

        in = index(i);

        % load file and linear blend

        filename0=dir(strcat(num2str(in),'.mat'));
        load(filename0.name);

        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                                                 %changed by stephan
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        %size(row)
        %size(column)
        
        Masque2 = zeros(size(Mosaic));
        %size(Masque2(row,column))
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+aip.*Masque2(row,column);
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+aip'.*Masque2(row,column);
        end
    end

    % process the blended image

    MosaicFinal=Mosaic./Masque;
    MosaicFinal=MosaicFinal-min(min(MosaicFinal));
    MosaicFinal(isnan(MosaicFinal))=0;
    if strcmp(sys,'Thorlabs')
        MosaicFinal=MosaicFinal';
    end
    
    %% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');
    MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));    
    tiffname='aip.tif';
    imwrite(MosaicFinal,tiffname,'Compression','none');
    end