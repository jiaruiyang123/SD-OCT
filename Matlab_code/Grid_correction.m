function[corrected_C_line]=Grid_correction(C_line, grid_matrix, x1, x0, y1, y0, z)
%author: Shuaibin Chang
%date: 09/30/2019
%this is the grid distortion corretion scripts, the output is the corrected
%and trimmed C scan
%C_line is the pre-corrected C scan, grid_matrix is the 3x1100x1100 element matrix used to correct the C scan at each depth

%becaused the edge of the C scan becomes 0 after correction, we will trim
%the stack after correction. x0,x1,y0,y1 defines the range of the
%stack that's free from the 0s

corrected_C_line=zeros(z, x1-x0, y1-y0);
for Z=1:z
    for k = x0:x1
        for j = y0:y1
           corrected_C_line(Z,k-x0+1,j-y0+1)=...
               grid_matrix(1,k,j)*grid_matrix(2,k,j)*C_line(Z,grid_matrix(3,k,j),grid_matrix(4,k,j))+...
               (1-grid_matrix(1,k,j))*grid_matrix(2,k,j)*C_line(Z,grid_matrix(3,k,j)+1,grid_matrix(4,k,j))+...
               grid_matrix(1,k,j)*(1-grid_matrix(2,k,j))*C_line(Z,grid_matrix(3,k,j),grid_matrix(4,k,j)+1)+...
               (1-grid_matrix(1,k,j))*(1-grid_matrix(2,k,j))*C_line(Z,grid_matrix(3,k,j)+1,grid_matrix(4,k,j)+1);
        end
    end
end
