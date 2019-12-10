function J=curvature_corr(I)
%% z curvature correction for Thorlabs OCT
% usage: output image = curvature_corr(input image)
% currently only supports 400x400x400 image size, will generalize in the
% future
% - Jiarui Yang
%     load('C:\Users\jryang\Desktop\Data\code\curvature.mat','fov_curvature');
%     depth=size(I,1)-(max(max(fov_curvature))-min(min(fov_curvature)));
%     J=zeros(depth,size(I,2),size(I,3));
%     for i=1:size(I,2)
%         for j=1:size(I,3)
%             height=fov_curvature(i,j);
%             J(:,i,j)=I(1+height:height+depth,i,j);
%         end
%     end
    fov=zeros(size(I,2),size(I,3));
    for i=1:size(I,2)
        for j=1:size(I,3)
            aline=squeeze(I(1:200,i,j));
            dl=movmean(diff(aline),5);
            [in, loc]=max(dl);
            fov(i,j)=loc+1;
        end
    end
    fov=fov-min(fov(:));
    depth=size(I,1)-(max(max(fov))-min(min(fov)));
    J=zeros(depth,size(I,2),size(I,3));
    for i=1:size(I,2)
        for j=1:size(I,3)
            height=fov(i,j);
            J(:,i,j)=I(1+height:height+depth,i,j);
        end
    end
end