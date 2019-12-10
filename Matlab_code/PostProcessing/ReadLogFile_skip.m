function Experiment = ReadLogFile_skip(pathname,filename,skipSlice)

run([pathname filename]);
% Mosaic Parameters

Experiment.X_step = mosaic_step(1);
Experiment.Y_step = mosaic_step(2);
Experiment.Z_step = mosaic_step(3);
if mosaic_num_cuts~=0
    Experiment.NbSlices = mosaic_num_cuts;
else
    Experiment.NbSlices = 1;
end



Experiment.X_tile = mosaic_ntiles(1);
Experiment.Y_tile = mosaic_ntiles(2);
Experiment.Z_tile = mosaic_ntiles(3);
n = Experiment.X_tile * Experiment.Y_tile *Experiment.Z_tile;

if mosaic_num_cuts~=0
    Experiment.CutSize = mosaic_cut_size_z;
end

m = max(1,Experiment.NbSlices);
nn=0;
for jj = skipSlice+1:skipSlice+1:m
    nn = nn+1;
    for ii = 1:size(mosaic_array,1)    
    Experiment.MapIndex_Tot(mosaic_array(ii,2,jj),mosaic_array(ii,1,jj),mosaic_array(ii,3,jj) + nn -1 ) = ii + (nn-1) * n;
    Experiment.X_Tot(mosaic_array(ii,2,jj),mosaic_array(ii,1,jj), nn ) = mosaic_array(ii,4,jj);
    Experiment.Y_Tot(mosaic_array(ii,2,jj),mosaic_array(ii,1,jj),nn ) = mosaic_array(ii,5,jj);
    Experiment.Z_Tot(mosaic_array(ii,2,jj),mosaic_array(ii,1,jj),nn ) = mosaic_array(ii,6,jj);
    end
end

for ii = 1:size(Experiment.MapIndex_Tot,3)
    Experiment.MapIndex_Tot(:,:,ii)= flipud(squeeze(Experiment.MapIndex_Tot(:,:,ii)));
end
    
Experiment.X_Tot = Experiment.X_Tot - min(Experiment.X_Tot(:)) +1;
Experiment.Y_Tot = Experiment.Y_Tot - min(Experiment.Y_Tot(:)) +1;
Experiment.Z_Tot = Experiment.Z_Tot - min(Experiment.Z_Tot(:)) +1;


end
