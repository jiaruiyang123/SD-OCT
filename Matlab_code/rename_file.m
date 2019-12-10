file_dir={'/projectnb/npbssmic/ns/191201_PSOCT/'};
for folderID=1:length(file_dir)
    folder=file_dir{folderID};
    cd(folder);
    B_mag_files=dir('*-A.dat');
    num_files=length(B_mag_files);
    for id = 1:num_files
        % Get the file name (minus the extension)
        %[~, f] = fileparts(B_mag_files(id).name);
          % Convert to number
          file_split=strsplit(B_mag_files(id).name,'.');
          file_split2=strsplit(string(file_split(1)),'-');
          slice=(str2double(file_split2{1})-1)*3+ceil(str2double(file_split2{2})/25);
          tile=mod(str2double(file_split2{2}),25);
              % If numeric, rename
              if tile==0
                  tile=25;
              end
              new_file=sprintf('/projectnb/npbssmic/ns/191201_PSOCT/191202_PSOCT/%d-%d-150-1250-1100-A.dat', slice, tile);
              movefile( B_mag_files(id).name, new_file);
          
    end
end