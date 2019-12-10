%% Experiment 1
% Objective 40x and I32 Block3 EC4
% FOV : 200um x 200
% 512pix x 512pix
%
addpath('/autofs/space/oswin_001/users/cmagnain/Programs/OCT_Processing_Visualization');
% addpath('/autofs/space/vault_002/users/cmagnain/OCT_Processing_Visualization')
%% Experiment with 40x objective

pathnameLogFile = [pwd '/'];
pathnameResults = [pwd '/'];
pathnameData = [pwd '/Data/'];
filename = 'Mosaic_LogFile';
skipSlice = 0;
Experiment = ReadLogFile_skip(pathnameLogFile,filename,skipSlice);
% filename_log = 'Mosaic_Horizontal.txt';



% Experiment.Z_step = (skipSlice+1)*Experiment.CutSize;
Experiment.NbSlices = size(Experiment.MapIndex_Tot,3);

Experiment.FOV = 4200;
Experiment.NbPix = 600;
Experiment.Tot_tiles = Experiment.X_tile * Experiment.Y_tile * Experiment.Z_tile;
Experiment.First_Tile = 1;
Experiment.MapIndex_Tot = Experiment.MapIndex_Tot + Experiment.First_Tile -1;
if Experiment.NbSlices ==0 
    Experiment.NbSlices=1;
end


Experiment.PixSize = Experiment.FOV / Experiment.NbPix;
Experiment.X_step_pix = Experiment.X_step / Experiment.PixSize;
Experiment.Y_step_pix = Experiment.Y_step / Experiment.PixSize;
Experiment.X_Tot = Experiment.X_Tot / Experiment.PixSize;
Experiment.Y_Tot = Experiment.Y_Tot / Experiment.PixSize;


for ii = min(Experiment.MapIndex_Tot(:)): max(Experiment.MapIndex_Tot(:))
    ii
    load([pathnameResults 'MIP_mat/AIP_10x_' sprintf('%04i',ii) '.mat']);
    I(ii,1) = mean(AIP(:));
    I(ii,2)= median(AIP(:));
    I(ii,3)= std(AIP(:));
end
plot(I(:,3))
num = find(I(:,3)<0.35);
for ii = 1:length(num)
a=find(Experiment.MapIndex_Tot == num(ii));
Experiment.MapIndex_Tot(a) = 0; 
end


folder = 'Fiji_Stitching_10x/';
CreateMacroFiji_Stitching10x(pathnameResults, folder, Experiment);



%% Read Fiji output

Experiment_Fiji = ReadFijiStitchingResults10x(pathnameResults, folder, Experiment);
save([pathnameResults 'Experiment.mat'],'Experiment_Fiji');


%% Mosaicing + Blending
modality='MIP';
NbProjection = 1; %% Number of pixel kept in the z direction

for cut = 1:Experiment_Fiji.NbSlices %% going through the slices
    
%     for n=1 
%         for nbpart=[1] %% for optical frequency compounding
            
            MapIndex = Experiment_Fiji.MapIndex_Tot(:,:,cut);
            X = round(squeeze(Experiment_Fiji.X_Mean));
            Y = round(squeeze(Experiment_Fiji.Y_Mean));
            sizecol = Experiment_Fiji.NbPix;
            sizerow = Experiment_Fiji.NbPix;
            
            % Center of the images
            XC=X+round(Experiment_Fiji.NbPix/2);
            YC=Y+round(Experiment_Fiji.NbPix/2);
            
            M=zeros(max(max(Y))+sizerow,max(max(X))+sizecol,NbProjection);
            Ma=zeros(max(max(Y))+sizerow,max(max(X))+sizecol);

            for kk=1:2
                for ll=1:2
                    
                    tabrow= [1:16] + 16 * (kk-1);%(1:size(MapIndex,1));
                    tabcol= [1:12] + 12 * (ll-1);%(1:size(MapIndex,2));
%                     tabrow= (1:size(MapIndex,1));
%                     tabcol= (1:size(MapIndex,2));
                    
                    
%                     if kk==3, tabrow=19:28; end
                      if ll==2, tabcol=13:25; end
                    %
                    %center of the images for the blending
                    Ly=zeros(size(MapIndex,2),1);
                    for ii=tabrow
                        Ly(ii)=round((max(YC(ii,tabcol))+min(YC(ii,tabcol)))/2);
                    end
                    Ly2=Ly(find(isnan(Ly)==0 & Ly > 0));
                    if length(Ly2)==0, continue; end
                    dy=round(abs(mean( Ly2(2:end) - Ly2(1:end-1))));
                    
                    Lx=zeros(size(MapIndex,1),1);
                    for ii=tabcol
                        Lx(ii)=round((max(XC(tabrow,ii))+min(XC(tabrow,ii)))/2);
                    end
                    Lx2=Lx(find(isnan(Lx)==0 & Lx > 0));
                    if length(Lx2)==0, continue; end
                    dx=round(abs(mean( Lx2(2:end) - Lx2(1:end-1))));
                    
                    b=dx-round(sizecol/2);
                    c=dy-round(sizerow/2);
                    
                    
                    %ramping mask
                    if (c<=0 || b<=0),  % more than 50% overlapping
                        x=ones(1,2*dx);
                        y=ones(1,2*dy);
                        x=[0:dx-1 dx-1:-1:0]./(dx);
                        y=[0:dy-1 dy-1:-1:0]./(dy);
                        
                    else  % less than 50% overlapping
                        dx=round(sizecol/2);dy=round(sizecol/2);
                        x=ones(1,2*dx);
                        y=ones(1,2*dy);
                        x(1,1:b)=[0:b-1]/b;
                        x(1,2*dx-b+1:2*dx)=[b-1:-1:0]/b;
                        y(1,1:c)=[0:c-1]/c;
                        y(1,2*dy-c+1:2*dy)=[c-1:-1:0]/c;
                    end
                    [rampy,rampx]=meshgrid(x,y);
                    ramp1=rampx.*rampy;
                    RampOrig=ramp1;
                    
                    Ly = Ly;
                    Lx = Lx+1;
                    Mosaic=zeros(max(max(Y))+sizerow,max(max(X))+sizecol,NbProjection);
                    Masque=zeros(max(max(Y))+sizerow,max(max(X))+sizecol);
                    
                    for ii=tabcol
                        for jj=tabrow
                            if MapIndex(jj,ii)>0 && isnan(X(jj,ii))==0
                                Masque2=zeros(max(max(Y))+sizerow,max(max(X))+sizecol,NbProjection);
                                
                                ramp=repmat(RampOrig,[1 1 NbProjection]);
                                
                                Masque2(Ly(jj)-dy:Ly(jj)+dy-1,Lx(ii)-dx:Lx(ii)+dx-1,:)=ramp;
                                row=Y(jj,ii):Y(jj,ii)+sizerow-1;
                                columns=X(jj,ii):X(jj,ii)+sizecol-1;
                                Masque(row,columns)=Masque(row,columns)+1.*Masque2(row,columns,1);
                                
                                switch modality
                                    
                                    case 'MIP'
                                        MIP = readnifti([pathnameData 'test_processed_' sprintf('%03i', MapIndex(jj,ii)) '_mip.nii']);
                                        Mosaic(row,columns,:)=Mosaic(row,columns,:)+(MIP).*Masque2(row,columns,:);

                                    case '3DMIP'
                                        MIP = readnifti([pathnameData 'test_processed_' sprintf('%03i', MapIndex(jj,ii)) '_' sprintf('%i',NbProjection) '.nii']);
                                        MIP = permute(MIP,[3 1 2]);
                                        Mosaic(row,columns,:)=Mosaic(row,columns,:)+(MIP).*Masque2(row,columns,:);
                                        
                                    case 'AIP'
                                        AIP = readnifti([pathnameData 'test_processed_' sprintf('%03i', MapIndex(jj,ii)) '_aip.nii']);
                                        Mosaic(row,columns,:)=Mosaic(row,columns,:)+(AIP).*Masque2(row,columns,:);
                                    
                                    case '3DAIP'
                                        AIP = readnifti([pathnameData 'test_processed_' sprintf('%03i', MapIndex(jj,ii)) '_' sprintf('%i',NbProjection) '.nii']);
                                        Mosaic(row,columns,:)=Mosaic(row,columns,:)+(AIP).*Masque2(row,columns,:);

                                end
                            end
                        end
                    end
                    M=M+Mosaic;
                    Ma=Ma+Masque;
                end
            end
            
            for mm = 1 : NbProjection
            MosaicFinal(:,:,mm)=((rot90(M(:,:,mm)./(Ma),0)));
            end
            MosaicFinal(isnan(MosaicFinal)==1)=0;
            
%             Volume(:,:,n + (cut-1) * NbProjection: (cut) * NbProjection)=MosaicFinal;
%             imwrite(mat2gray(MosaicFinal),['I41_BA17_bl2_Slice' sprintf('%02i', cut) '_' modality '.tiff'],'compression','none');
                 imwrite(mat2gray(MosaicFinal),['I33_BA2533_LSM03_' modality '.tiff'],'compression','none');
%             figure; imagesc(MosaicFinal); colormap gray; axis off;axis equal
        end
    end
end
clear ramp ramp1 rampx rampy x y Lx Lx2 Ly Ly2 b c ans dx dy ii jj kk ll tabcol tabrow columns row  XC YC RampOrig Mosaic Masque Masque2 M Ma;
clear MosaicFinal;
% close all




% pixdim = [0.007 0.007 0.0029];
% MakeNii(['Volume_' modality '.nii'], Volume, pixdim);
% clear Volume;
%%

Volume_smooth = smooth3(Volume,'box',[1 1 3]);
view3D(Volume_smooth(:,:,2:3:end))



