

% % initiate the surface image
% sur=zeros(size(slice));
% 
% % demo
% K=wiener2(squeeze(slice(:,300,:)),[5 5]);
% figure;imagesc(K);colorbar;title('sample slice after adaptive filtering');ylabel('depth (pxl)');xlabel('Y axis (pxl)');
% [p,lp]=findpeaks(K(:,100),'MinPeakDistance',6,'SortStr','descend');
% figure;findpeaks(K(:,100),'MinPeakDistance',6,'SortStr','descend');text(lp+.02,double(p),num2str((1:numel(p))'));...
%     title('sample line profile');ylabel('log intensity');xlabel('depth (pxl)');

edge=zeros(400,400);
for i=1%:400
    % adaptive filter for each slice
    K = squeeze(slice(:,:,i));
    %figure;imagesc(K);hold on;title('sample slice');ylabel('depth (pxl)');xlabel('Y axis (pxl)');
    
    % using peaks information to find the tissue surface
    for j=1:5
        line=movmean(K(:,j),5);
        [sp, slp]=findpeaks(line,'MinPeakDistance',6,'SortStr','descend');
        if slp(2)<100
            btm_glass=slp(2);
        else
            btm_glass=slp(3);
        end
        [p, lp]=findpeaks(line,'MinPeakDistance',6);
        top_tissue=lp(find(lp==btm_glass)+1);
        if top_tissue > 80
            %sur(top_tissue,j,i)=1;
            edge(j,i)=top_tissue;
        end        
        
        % A-line profile & surface point
      surfline=zeros(1,400);surfline(top_tissue)=line(top_tissue);surfline(surfline==0)=NaN;
      figure;plot(line,'b');hold on;scatter(1:400,surfline,'or');...
          legend('A-line intensity','surface');title('A-line profile - mouse brain');
    end
end



%% surface detection for agarose block
edge=zeros(400,400);
slice_cropped=slice(140:end,:,:);
for i=1%:400
    for j=381:385
        line=movmean(slice_cropped(:,i,j),5);
        [v, loc]=findpeaks(line,'MinPeakDistance',8);
        edge(i,j)=loc(1);
        surfline=zeros(1,400);surfline(loc(1))=line(loc(1));surfline(surfline==0)=NaN;
        figure;plot(line,'b');hold on;scatter(1:400,surfline,'or');legend('A-line intensity','surface');title('A-line profile - agarose block');
    end
end

%% visualize the surface
figure;imagesc(edge);colorbar;title('surface profile - mouse brain');...
         ylabel('Y axis (pxl)');xlabel('X axis (pxl)');