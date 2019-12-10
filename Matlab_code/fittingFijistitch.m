clear all;

%% define grid pattern

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');

% displacement parameters
xx=20;
xy=0;
yy=20;
yx=0;

% mosaic parameters
numX=26;
numY=26;
Xoverlap=0.5;
Yoverlap=0.5;

% tile parameters
Xsize=40;
Ysize=40;

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

% redefine the origin of the grid, choose a non-agarose tile
grid(1,:)=grid(1,:)-grid(1,68);
grid(2,:)=grid(2,:)-grid(2,68);
%% generate distorted grid pattern

%% write coordinates to file

filepath=strcat('/projectnb/npbssmic/ns/191209_Thorlabs/fitting/');
cd(filepath);
fileID = fopen([filepath 'TileConfiguration.txt'],'w');
fprintf(fileID,'# Define the number of dimensions we are working on\n');
fprintf(fileID,'dim = 2\n\n');
fprintf(fileID,'# Define the image coordinates\n');
for j=1:numTile
    fprintf(fileID,[num2str(j) '_us.tif; ; (%d, %d)\n'],round(grid(:,j))); 
end
fclose(fileID);

%% generate Macro file

pathname=filepath;
macropath=[pathname,'Macro.ijm'];

pathname_rev=pathname;

fid_Macro = fopen(macropath, 'w');
l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',pathname_rev,' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',pathname_rev,'");\n'];
fprintf(fid_Macro,l);
fclose(fid_Macro);

%% execute Macro file
tic
system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);
toc

%% get FIJI stitching info

filename = filepath;
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'us');

%% coordinates correction
% use median corrdinates for all slices
% coord=squeeze(median(coord,1));

%% define coordinates for each tile

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

%% blending & mosaicing

Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
Masque = zeros(size(Mosaic));

cd(filename);    

for i=1:length(index)
        
        in = index(i);
        
        % load file and linear blend

        filename0=dir(strcat('mus_1_',num2str(in),'.mat'));
        load(filename0.name);
        
        row = Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2;
        column = Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2;
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+us'.*Masque2(row,column);
        
end

% process the blended image

MosaicFinal=Mosaic./Masque;
MosaicFinal=MosaicFinal-min(min(MosaicFinal));
MosaicFinal(isnan(MosaicFinal))=0;
MosaicFinal=MosaicFinal';
save('Mosaic.mat','MosaicFinal');

% plot in original scale
% 
% figure;
% imshow(MosaicFinal,'XData', (1:size(MosaicFinal,2))*0.05, 'YData', (1:size(MosaicFinal,1))*0.05);
% axis on;
% xlabel('x (mm)')
% ylabel('y (mm)')
% title('Scattering coefficient (mm^-^1)')
% colorbar;caxis([0 10]);

% rescale and save as tiff
MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));         
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
cd(strcat('/projectnb/npbssmic/ns/191209_Thorlabs/fitting/'));
tiffname='mus.tif';
imwrite(MosaicFinal,tiffname,'Compression','none');
