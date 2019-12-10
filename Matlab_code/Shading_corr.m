file_dir={'/projectnb/npbssmic/ns/191201_PSOCT/corrected_1000/'};
%load(strcat(folder_distort,'\curvature_B_flip.mat'));
fileID = fopen(strcat('/projectnb/npbssmic/ns/PSOCT_grid/','shading.dat')); 
shade = fread(fileID,'double');  
shade=reshape(shade,1000,1000,61);
fclose(fileID);
for folderID=1:length(file_dir)
    folder=file_dir{folderID};
    cd(folder);
    for islice=1:2
        B_mag_files=dir(strcat(num2str(islice),'-*.dat'));
        num_files=length(B_mag_files);
        for i=1:num_files
            fileID = fopen(B_mag_files(i).name); 
            raw_data = fread(fileID,'float');        
            fclose(fileID);
            file_split=strsplit(B_mag_files(i).name,'.');
            file_split2=strsplit(string(file_split(1)),'-');
            file_split2{2}
            %X=str2double(file_split2{4});
            X=1000;
            %Z=str2double(file_split2{3});
            Z=140;
            %Y=str2double(file_split2{5});
            Y=1000;
            slice= reshape(raw_data,Z,X,Y);
            %FOV curvature correction
%             if mode(islice,3)~=1
%                 slice = slice(20:80, :, :); %specify FOV cut
% 
%                 for n=1:1000
%                     
%                     for j=1:1000
%                         for k=1:61
%                             slice(k,n,j)=slice(k,n,j)/shade(j,n,k);
%                         end
%                     end
%                 end
%             else
                %FOV curvature correction
                slice = slice(38:80, :, :); %specify FOV cut
  
                for n=1:1000
                    
                    for j=1:1000
                        for k=1:43
                            slice(k,n,j)=slice(k,n,j)/shade(j,n,k+18);
                        end
                    end
                end
%             end
            fileID = fopen(strcat('/projectnb/npbssmic/ns/191201_PSOCT/shaded_1000/',B_mag_files(i).name),'w'); 
            fwrite(fileID, slice,'float');     
            fclose(fileID);

        end
    end
end
