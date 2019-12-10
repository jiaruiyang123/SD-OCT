function section=find_surface(volume,depth)
    [dimz dimx dimy]=size(volume);
    section=zeros(depth,dimx,dimy);
    for i=1:dimx
        for j=1:dimy
            axial_profile=volume(21:end,i,j);
            if max(axial_profile)>0.7
                [pks, locs]=findpeaks(axial_profile,'MinPeakHeight',0.7);
                sur=locs(1)-3;               
            else
                sur=50;
            end
            section(:,i,j)=axial_profile(sur:sur+depth-1);
        end
    end
end