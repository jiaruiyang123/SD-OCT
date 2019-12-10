%% define dataset path
datapath = '/projectnb/npbssmic/ns/191103_PSOCT_small_blade/';
addpath('/projectnb/npbssmic/s/Matlab_code');
%% define grid pattern
% displacement parameters
xx=199;
xy=-4;
yy=197;
yx=10;

% mosaic parameters
numX=24;
numY=24;
Xoverlap=0.5;
Yoverlap=0.5;

% tile parameters
Xsize=400;
Ysize=400;

% slice index we are working on
islice=19;

numTile=numX*numY;
grid=zeros(2,numTile);

for i=1:numTile
    if mod(i,numX)==0
        grid(1,i)=(numY-ceil(i/numX))*xx;
        grid(2,i)=(numY-ceil(i/numX))*xy;
    else
        grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
        grid(2,i)=(numY-ceil(i/numX))*xy+(numX-(mod(i,numX)))*yy;
    end
end
%% generate distorted grid pattern

%% write coordinates to file
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
    if val(j)>=0.407   % threshold tunable for agarose blocks, visual examine after done
        fprintf(fileID,[num2str(j) '_aip.tif; ; (%d, %d)\n'],round(grid(:,j)));
        tile=tile+1;
    end   
end
fclose(fileID);

%% generate Macro file
macropath=[filepath,'Macro.ijm'];
filepath_rev=strcat(datapath,'aip/');

fid_Macro = fopen(macropath, 'w');
for j=islice
    l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',filepath_rev,'vol',num2str(j),' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',filepath_rev,'vol',num2str(j),'");\n'];
    fprintf(fid_Macro,l);
end
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
    for ii=1:size(coord,2)
        Xcen(coord(1,ii))=round(coord(2,ii));
        Ycen(coord(1,ii))=round(coord(3,ii));
    end
    Xcen=Xcen-min(Xcen);
    Ycen=Ycen-min(Ycen);

    Xcen=Xcen+Xsize/2;
    Ycen=Ycen+Ysize/2;

    % tile range -199~+200
    stepx = Xoverlap*Xsize;
    x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
    stepy = Yoverlap*Ysize;
    y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
    [rampy,rampx]=meshgrid(x,y);
    ramp=rampx.*rampy;      % blending mask

    % blending & mosaicing
  
    Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
    Masque = zeros(size(Mosaic));

    cd(filename);    

for i=1:length(index)

    in = index(i);

    % load file and linear blend

    filename0=dir(strcat(num2str(in),'.mat'));
    load(filename0.name);

    row = Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2;
    column = Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2;
    Masque2 = zeros(size(Mosaic));
    Masque2(row,column)=ramp;
    Masque(row,column)=Masque(row,column)+Masque2(row,column);
    Mosaic(row,column)=Mosaic(row,column)+aip'.*Masque2(row,column);

end

    % process the blended image

    MosaicFinal=Mosaic./Masque;
    MosaicFinal=MosaicFinal-min(min(MosaicFinal));
    MosaicFinal(isnan(MosaicFinal))=0;
    MosaicFinal=MosaicFinal';

    MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));       
    %% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');
    tiffname='aip.tif';
    imwrite(MosaicFinal,tiffname,'Compression','none');
