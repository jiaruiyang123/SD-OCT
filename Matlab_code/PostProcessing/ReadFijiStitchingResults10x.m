function Experiment_Fiji = ReadFijiStitchingResults10x(pathname, folder, Experiment)

Experiment_Fiji = Experiment;

m = max(Experiment.Z_tile,Experiment.Z_tile*Experiment.NbSlices);
for zz = 1:m

    MapIndex = squeeze(Experiment_Fiji.MapIndex_Tot(:,:,zz));
    
    fid = fopen([pathname folder  'Mosaic_depth' sprintf('%03i',zz) '.txt.registered'],'r');
    pathname_img=[pathname 'MIP_tiff2/AIP_10x_'];
    
    for ii=1:4
        kk = fgets(fid);
    end
    
    ii=0;
    while ~feof(fid)
        ii = ii +1;
        kk = fgets(fid);
        img(:,ii)=sscanf(kk,[pathname_img '%d.tiff; ; ( %f, %f)']);
    end
    fclose(fid);
    
    MapIndex2 = -1*ones(size(MapIndex));
    coord=(img');
    for ii=1:size(coord,1)
        [row,col]=find(MapIndex==coord(ii,1));
        MapIndex2(row,col)=coord(ii,1);
        Y1(row,col)=round(coord(ii,3));
        X1(row,col)=round(coord(ii,2));
    end
    
    clear img coord;
    
    MapIndex=MapIndex2;
    X = zeros(size(MapIndex));
    Y = zeros(size(MapIndex));
    X(1:size(X1,1),1:size(X1,2))=X1;
    Y(1:size(Y1,1),1:size(Y1,2))=Y1;
    X(MapIndex==-1)=NaN;
    Y(MapIndex==-1)=NaN;
%     X=X-min(min(X))+1;
%     Y=Y-min(min(Y))+1;
    X=X-X(round(size(X,1)/3),round(size(X,2)/3));
    Y=Y-Y(round(size(Y,1)/3),round(size(Y,2)/3));
%     X=X-X(5,16);
%     Y=Y-Y(5,16);
    
    Experiment_Fiji.X_Tot(:,:,zz) = X;
    Experiment_Fiji.Y_Tot(:,:,zz) = Y;
    
end

% tab =[1:8];
tab =[1:size(Experiment_Fiji.X_Tot,3)];
for ii = 1:size(Experiment_Fiji.X_Tot,1)
    for jj = 1:size(Experiment_Fiji.X_Tot,2)
        XX = squeeze(Experiment_Fiji.X_Tot(ii,jj,tab));
        Experiment_Fiji.X_Mean(ii,jj) = median(XX(isnan(XX)==0));
        Experiment_Fiji.X_Std(ii,jj) = std(XX(isnan(XX)==0));
        YY = squeeze(Experiment_Fiji.Y_Tot(ii,jj,tab));
        Experiment_Fiji.Y_Mean(ii,jj) = median(YY(isnan(YY)==0));
        Experiment_Fiji.Y_Std(ii,jj) = std(YY(isnan(YY)==0));        
    end
end

Experiment_Fiji.X_Mean = Experiment_Fiji.X_Mean - min(Experiment_Fiji.X_Mean(:))+1;
Experiment_Fiji.Y_Mean = Experiment_Fiji.Y_Mean - min(Experiment_Fiji.Y_Mean(:))+1;

% Experiment_Fiji.X_Mean = squeeze(mean(Experiment_Fiji.X_Tot(:,:,tab),3));
% Experiment_Fiji.Y_Mean = squeeze(mean(Experiment_Fiji.Y_Tot(:,:,tab),3));
% Experiment_Fiji.X_std = squeeze(std(Experiment_Fiji.X_Tot(:,:,tab),[],3));
% Experiment_Fiji.Y_std = squeeze(std(Experiment_Fiji.Y_Tot(:,:,tab),[],3));


% X_row = Experiment_Fiji.X_Tot(1:end-1,:,:) - Experiment_Fiji.X_Tot(2:end,:,:);
% X_col = Experiment_Fiji.X_Tot(:,1:end-1,:) - Experiment_Fiji.X_Tot(:,2:end,:);
% Y_row = Experiment_Fiji.Y_Tot(1:end-1,:,:) - Experiment_Fiji.Y_Tot(2:end,:,:);
% Y_col = Experiment_Fiji.Y_Tot(:,1:end-1,:) - Experiment_Fiji.Y_Tot(:,2:end,:);
% 
% 
% tab = [1:size(Experiment_Fiji.X_Tot,3)];
% for ii = 1:size(X_row,1)
%     for jj = 1:size(X_col,2)
%         XX = X_row(ii,jj,tab);
%         X_row_Tot(ii,jj,:) = median(XX(isnan(XX)==0));
%         XX = X_col(ii,jj,tab);
%         X_col_Tot(ii,jj) = median(XX(isnan(XX)==0));
%         
%         YY = Y_row(ii,jj,tab);
%         Y_row_Tot(ii,jj) = median(YY(isnan(YY)==0));
%         YY = Y_col(ii,jj,tab);
%         Y_col_Tot(ii,jj) = median(YY(isnan(YY)==0));
%         
%         
%     end
% end
% 
% X_Tot = zeros(size(Experiment_Fiji.X_Tot,1),size(Experiment_Fiji.X_Tot,2));
% Y_Tot = zeros(size(Experiment_Fiji.X_Tot,1),size(Experiment_Fiji.X_Tot,2));
% X_Tot(1,1) = 1;
% Y_Tot(1,1) = 1;
% for ii = 1:size(Experiment_Fiji.X_Tot,1)-1
%     X_Tot(ii+1,1) = X_Tot(ii,1) - X_row_Tot(ii,1);
%     Y_Tot(ii+1,1) = Y_Tot(ii,1) - Y_row_Tot(ii,1);
% end
% for ii = 1:size(Experiment_Fiji.X_Tot,1)-1
%     X_Tot(1,ii+1) = X_Tot(1,ii) - X_col_Tot(1,ii);
%     Y_Tot(1,ii+1) = Y_Tot(1,ii) - Y_col_Tot(1,ii);
% end
% 
% for jj = 2:size(Experiment_Fiji.X_Tot,1)
%     for ii = 2 :size(Experiment_Fiji.X_Tot,2)
%         X_Tot(jj,ii) = X_Tot(jj-1,ii) - X_row_Tot(jj-1,ii-1);
% %         Y_Tot(jj,ii) = Y_Tot(jj-1,ii-1) - Y_row_Tot(jj-1,ii-1);
%     end
% end
% for jj = 2:size(Experiment_Fiji.X_Tot,1)
%     for ii = 2 :size(Experiment_Fiji.X_Tot,2)
% %         X_Tot(jj,ii) = X_Tot(jj-1,ii-1) - X_row_Tot(jj-1,ii-1);
%         Y_Tot(jj,ii) = Y_Tot(jj-1,ii) - Y_row_Tot(jj-1,ii-1);
%     end
% end
% 
% X_Tot=X_Tot-min(min(X_Tot))+1;
% Y_Tot=Y_Tot-min(min(Y_Tot))+1;
% 
%     Experiment_Fiji.X_Mean = round(X_Tot);
%     Experiment_Fiji.Y_Mean = round(Y_Tot);
