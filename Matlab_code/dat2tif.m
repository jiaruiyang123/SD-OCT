%% Set file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for jj=1
datapath  = strcat('/projectnb/npbssmic/ns/191209_Thorlabs//fitting/');
cd(datapath);
filename0=dir('mus_1_*.mat');

for i=1:length(filename0)
    load(filename0(i).name);
    c=strsplit(filename0(i).name,'_');
    cc=strsplit(c{3},'.');
    index=cc{1};
    
    us=uint16(65535*rescale(us));
    
    tiffname=strcat(index,'_us.tif');

    t = Tiff(tiffname,'w');
    tagstruct.ImageLength     = size(us,1);
    tagstruct.ImageWidth      = size(us,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(us);
    t.close();
end
end