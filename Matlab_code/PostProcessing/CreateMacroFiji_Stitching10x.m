function CreateMacroFiji_Stitching10x(pathname, folder, Experiment)

mkdir([pathname folder])


fid_Macro = fopen([pathname folder 'Macro.ijm'], 'w');

m = max(Experiment.Z_tile,Experiment.Z_tile*Experiment.NbSlices);
for zz = 1:m
    
    Y = (round(squeeze(Experiment.X_Tot(:,:,zz))));
    X = (round(squeeze(Experiment.Y_Tot(:,:,zz))));
    MapIndex = ((Experiment.MapIndex_Tot(:,:,zz)));
    
% Create the file for the individual stitching of each depth
    fid = fopen([pathname folder 'Mosaic_depth' sprintf('%03i',zz) '.txt'], 'w');
    l1='# Define the number of dimensions we are working on\n';
    fprintf(fid,l1);
    l2='dim = 2\n \n';
    fprintf(fid,l2);
    l3='# Define the image coordinates\n';
    fprintf(fid,l3);       
%     for ii=1:size(X,2)
%     for jj=1:size(Y,1)
%           if MapIndex(jj,ii)>0 && isnan(X(jj,ii))==0
%                 lig=[pathname 'MIP_tiff2/AIP_10x_' sprintf('%04i',MapIndex(jj,ii)) '.tiff; ; (' sprintf('%04i',X(jj,ii)) ',' sprintf('%04i',Y(jj,ii)) ')\n'];
%                 fprintf(fid,lig);
%             end
%         end
%     end

B = ReadSpiral(size(MapIndex,1),size(MapIndex,2));
[~,id] = sort(B(:),'ascend');
for ii = 1:length(id)
          if MapIndex(id(ii))>0  && isnan(X(id(ii)))==0
                lig=[pathname 'MIP_tiff2/AIP_10x_' sprintf('%04i',MapIndex(id(ii))) '.tiff; ; (' sprintf('%04i',X(id(ii))) ',' sprintf('%04i',Y(id(ii))) ')\n'];
                fprintf(fid,lig);
          end
end

    fclose(fid);
    
 % Create the command line for the actual stitching
    l1=['run("Stitch Collection of Images", "layout=' pathname folder 'Mosaic_depth' sprintf('%03i',zz) '.txt compute_overlap channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method=[Linear Blending] fusion=1.50 regression=0.30 max/avg=2.50 absolute=3.50");\n'];
    l2 = 'close();\n';
    fprintf(fid_Macro,l1);
    fprintf(fid_Macro,l2);

end
fclose(fid_Macro);
   
