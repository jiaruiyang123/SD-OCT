file_dir={'/projectnb/npbssmic/ns/191201_PSOCT/corrected_1000/'};
tile_num=[8 9 12 13 14 17 18 19];
slice=zeros(140,1000,1000);
for folderID=1:length(file_dir)
    folder=file_dir{folderID};
    cd(folder);
    for k=1:length(tile_num)
        tileID=tile_num(k)
        files=dir(strcat('2-', num2str(tileID),'*.dat'));
        num_files=length(files);
        for i=1:num_files
            fileID = fopen(files(i).name); 
            raw_data = fread(fileID,'float');        
            fclose(fileID);
            file_split=strsplit(files(i).name,'.');
            file_split2=strsplit(string(file_split(1)),'-');
            %X=str2double(file_split2{4});
            X=1000;
            %Z=str2double(file_split2{3});
            Z=140;
            %Y=str2double(file_split2{5});
            Y=1000;
            
            slice= slice+ reshape(raw_data,Z,X,Y);
        end
    end
end
slice=slice(20:80, :,:);
shade=smooth3(slice, 'gaussian',[51 51 3]);
view3D(shade)

fileID = fopen(strcat(folder,'shade.dat'),'w'); 
fwrite(fileID, slice, 'float');
fclose(fileID);