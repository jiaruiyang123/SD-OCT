function Spiral = ReadSpiral(num_row,num_col);

Spiral = zeros(num_row,num_col);
id1=0;
ii=0;
while(length(find(Spiral(:)==0))>0)
        ii=ii+1;
    if ii==1
        A = squeeze(Spiral(1,:));
        tab = find(A==0);
        Spiral(1,tab) = id1+[1:length(tab)];
    else
        id1=max(Spiral(:));
        A = squeeze(Spiral(tab1(1),:));
        tab = find(A==0);
        Spiral(tab1(1),tab) = id1+[1:length(tab)];
    end    
    
    if (length(find(Spiral(:)==0))==0); break;end
    id1=max(Spiral(:));
    A = squeeze(Spiral(:,tab(end)));
    tab1 = find(A==0);
    Spiral(tab1,tab(end)) = id1+[1:length(tab1)];
    
    if (length(find(Spiral(:)==0))==0); break;end
    id1=max(Spiral(:));
    A = squeeze(Spiral(tab1(end),:));
    tab = find(A==0);
    Spiral(tab1(end),tab) = id1+[length(tab):-1:1];
    
    if (length(find(Spiral(:)==0))==0); break;end
    id1=max(Spiral(:));
    A = squeeze(Spiral(:,tab(1)));
    tab1 = find(A==0);
    Spiral(tab1,tab(1)) = id1+[length(tab1):-1:1];
end


