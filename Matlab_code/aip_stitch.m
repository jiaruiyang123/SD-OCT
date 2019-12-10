clear all;

% Experiment.NbSlices = size(Experiment.MapIndex_Tot,3);
% 
% Experiment.FOV = 4200;
% Experiment.NbPix = 600;
% Experiment.Tot_tiles = Experiment.X_tile * Experiment.Y_tile * Experiment.Z_tile;
% Experiment.First_Tile = 1;
% Experiment.MapIndex_Tot = Experiment.MapIndex_Tot + Experiment.First_Tile -1;
% if Experiment.NbSlices ==0 
%     Experiment.NbSlices=1;
% end
% 
% 
% Experiment.PixSize = Experiment.FOV / Experiment.NbPix;
% Experiment.X_step_pix = Experiment.X_step / Experiment.PixSize;
% Experiment.Y_step_pix = Experiment.Y_step / Experiment.PixSize;
% Experiment.X_Tot = Experiment.X_Tot / Experiment.PixSize;
% Experiment.Y_Tot = Experiment.Y_Tot / Experiment.PixSize;

Xsize=400;
Ysize=400;
Zsize=400;
Xoverlap=0.3;
Yoverlap=0.3;
Xtile=14;
Ytile=13;

%% get FIJI stitching info
filename = 'C:\Users\jryang\Desktop\Vibratome_data\0927\stitch\aip\TileConfiguration.registered.txt';
coord = read_Fiji_coord(filename);

%% define index map
coord=coord';
Xcen=zeros(size(coord,1),1);
Ycen=zeros(size(coord,1),1);
for ii=1:size(coord,1)
    Xcen(coord(ii,1))=round(coord(ii,2));
    Ycen(coord(ii,1))=round(coord(ii,3));
end
Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);
Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
Masque = zeros(size(Mosaic));
Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

% tile range -199~+200
stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(x,y);
ramp=rampx.*rampy;

%% blending & mosaicing
    
for i=1:Xtile
    for j=1:Ytile
        cordX = 72.5+(i-1)*0.7;
        cordY = 27.6+(j-1)*0.7;
        index = Ytile*(i-1) + j;
        %% Set file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\0927\',num2str(cordX),'-',num2str(cordY),'\');
        cd(datapath);
        filename0=dir('*.mat');
        load(filename0.name);
        
        % generate AIP
        aip=squeeze(20*mean(log10(slice(51:350,:,:)),1));
        %aip=aip-min(min(aip));
        
        row = Xcen(index)-Xsize/2+1:Xcen(index)+Xsize/2;
        column = Ycen(index)-Ysize/2+1:Ycen(index)+Ysize/2;
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+(aip').*Masque2(row,column);
        
        message=strcat('tile No. ',num2str(i),'-',num2str(j),' is processed');
        disp(message);
    end
end
MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal)==1)=0;
figure;imagesc(MosaicFinal');colormap gray;
