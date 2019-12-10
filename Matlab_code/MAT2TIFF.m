for j=2:27
    load(strcat('Mosaic',num2str(j),'.mat'));
    s=uint16(65535*(mat2gray(Mosaic))); 
    tiffname=strcat('/projectnb/npbssmic/ns/191201_PSOCT/corrected/nii/vol',num2str(j),'.tif');
    for i=1:size(s,3)
        t = Tiff(tiffname,'a');
        image=squeeze(s(:,:,i));
        tagstruct.ImageLength     = size(image,1);
        tagstruct.ImageWidth      = size(image,2);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(image);
        t.close();
    end
    disp(['Slice No.', num2str(j), 'is finished.']);
end
