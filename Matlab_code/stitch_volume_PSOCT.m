
% mosaic parameters

Xsize=1051;
Ysize=1061;
Xoverlap=0.1;
Yoverlap=0.1;
Xtile=5;
Ytile=5;

% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

%% get FIJI stitching info & adjust coordinates system

filename = strcat('/projectnb/npbssmic/ns/191201_PSOCT/191202_PSOCT/aip/vol27/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

% vol_index=[];
% for i=1:7
%     slice_index=(i-1)*3+1;
%     filename = strcat('/projectnb/npbssmic/ns/190619_Thorlabs/aip/vol',num2str(slice_index),'/');
%     f=strcat(filename,'TileConfiguration.registered.txt');
%     Fiji_coord{i} = read_Fiji_coord(f,'aip');
%     vol_index=[vol_index Fiji_coord{i}(1,:)];
% end
% 
% % use median corrdinates for all slices
% vol_index=unique(vol_index);
% coord=zeros(3,length(vol_index));
% coord(1,:)=vol_index;
% for i=1:length(vol_index)
%     temp=[];
%     for j=1:7
%         if ismember(vol_index(i),Fiji_coord{j}(1,:))
%             [~, loc]=ismember(vol_index(i),Fiji_coord{j}(1,:));
%             temp=[temp Fiji_coord{j}(2:3,loc)];
%         end
%     end
%     coord(2:3,i)=median(temp,2);
% end
% coord=squeeze(median(coord,1));

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+round(Xsize/2);
Ycen=Ycen+round(Ysize/2);

% tile range -199~+200
stepx = floor(Xoverlap*Xsize);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing
    
Mosaic = zeros(max(Xcen)+round(Xsize/2) ,max(Ycen)+round(Ysize/2),46);
Masque = zeros(size(Mosaic));
Masque2 = zeros(size(Mosaic));

filename = strcat('/projectnb/npbssmic/ns/191201_PSOCT/corrected/');
cd(filename);    

id=str2num(id);
for nslice=id

nk = 139; nxRpt = 1; nx=1051; nyRpt = 1; ny = 1061;
dim=[nk nxRpt nx nyRpt ny];
     
for i=1:length(index)
     
    in = index(i);
    
    filename0=dir(strcat(num2str(nslice),'-',num2str(in),'-*.dat'));

    ifilePath=[filename,filename0(1).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    
    slice = ReadDat_single(ifilePath, dim);
    %slice = depth_corr(slice,0.0026);
    slice = slice(42:87,:,:);
    
    row = Xcen(in)-round(Xsize/2)+1:Xcen(in)+round(Xsize/2)-1;
    column = Ycen(in)-round(Ysize/2)+1:Ycen(in)+round(Ysize/2)-1;  
    
    
    for j=1:size(slice,1)
        Masque2(row,column,j)=ramp;
        Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
        Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(slice(j,:,:)).*Masque2(row,column,j);        
    end 
end

Mosaic=Mosaic./Masque;
%Mosaic=Mosaic-min(Mosaic(:));
%Mosaic=Mosaic./max(Mosaic(:));
Mosaic(isnan(Mosaic(:)))=0;

save(strcat('/projectnb/npbssmic/ns/191201_PSOCT/corrected/nii/Mosaic',num2str(nslice),'.mat'),'Mosaic','-v7.3');
end