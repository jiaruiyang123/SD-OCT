function create_dir(nslice,datapath)
%% create folders for each volume during oct processing
% Author: Jiarui Yang
    cd(datapath);
    if isempty(dir('aip'))
        mkdir aip
        cd(strcat(datapath,'aip/'));
        for i=1:nslice
            foldername=strcat('vol',num2str(i));

            mkdir(foldername);
        end
    end
    if isempty(dir('mip'))
        cd(datapath);
        mkdir mip
        cd(strcat(datapath,'mip/'));
        for i=1:nslice
            foldername=strcat('vol',num2str(i));
            mkdir(foldername);
        end
    end
    if isempty(dir('surf'))
        cd(datapath);
        mkdir surf
        cd(strcat(datapath,'surf/'));
        for i=1:nslice
            foldername=strcat('vol',num2str(i));            
            mkdir(foldername);
        end 
    end
end