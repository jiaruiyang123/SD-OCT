file_dir={'/projectnb/npbssmic/ns/191201_PSOCT/corrected_1000/'};
%load(strcat(folder_distort,'\curvature_B_flip.mat'));
% fileID = fopen(strcat('C:\Projects\SSOCT\Data\191204\','shading.dat')); 
% shade = fread(fileID,'double');  
% shade=reshape(shade,1000,1000,61);
% fclose(fileID);
for folderID=1:length(file_dir)
    folder=file_dir{folderID};
    cd(folder);
    B_mag_files=dir('5-2*.dat');
    num_files=length(B_mag_files);
    for i=1:num_files
        fileID = fopen(B_mag_files(i).name); 
        raw_data = fread(fileID,'float');        
        fclose(fileID);
        file_split=strsplit(B_mag_files(i).name,'.');
        file_split2=strsplit(string(file_split(1)),'-');
        %X=str2double(file_split2{4});
        X=1000;
        %Z=str2double(file_split2{3});
        Z=140;
        %Y=str2double(file_split2{5});
        Y=1000;
        slice= reshape(raw_data,Z,X,Y);
    end
    %FOV curvature correction
    %slice = slice(20:80, :, :); %specify FOV cut
    %slice = FOV_curvature_correction(slice, curvature_B, Z, X-150, Y); % specify z and x 
    %find tissue surface
    %sur=surprofile_PSOCT(slice);
    %figure;imagesc(sur);colorbar;caxis([0,max(sur(:))/2]);
    
    view3D(slice);
end