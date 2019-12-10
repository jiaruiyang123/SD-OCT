function sur=surprofile(slice)

    % volumetric averaging smoothing
    n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,3);
    sizeX=size(vol,2);
                                            
    % find edge using the first order derivative
    sur=zeros(sizeX,sizeY);
    for k=1:sizeY
        bscan=squeeze(vol(:,:,k));
        for i=1:sizeX
            aline=bscan(:,i);
            dl=movmean(diff(aline),5);
            [in, loc]=max(dl(5:80));
            loc=loc+6;
            sur(i,k)=loc;
        end
    end
end
