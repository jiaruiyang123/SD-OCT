function [curved_C_scan]=FOV_curvature_correction(C_line, curvature, z0, x, y)
%author: Shuaibin Chang
%date: 09/30/2019
%this is the FOV curvature correction scripts. The output is the corrected
%stack, after trimming out the bottom part which has a lot of 0s

%C-line is the uncorrected C scan, curvature is the 2D matrix used to
%corrected teh whole volume

%z0 is the number of pixels after correction that's free from the 0s, x, y
%is the dimension of the stack in x and y directions
curved_C_scan=zeros(z0,x,y);
for X=1:x
    for Y=1:y
        depth=curvature(X,Y);
        curved_C_scan(:,X,Y)=C_line((depth+1):(depth+z0),X,Y);
    end
end
