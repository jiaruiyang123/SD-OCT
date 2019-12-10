function vol_out = depth_corr(vol_in,zpxl)
% depth correction based on de Boer OSA 2013
% zpxl is pixel size in z (mm)
% vol_in is the input volume and vol_out is the output volume
% Author: Jiarui Yang
% 11/08/19

vol_out=zeros(size(vol_in));

for x=1:size(vol_in,2)
    for y=1:size(vol_in,3)
        aline=squeeze(vol_in(:,x,y));
        for z=1:length(aline)
            aline(z)=aline(z)/(2*zpxl*sum(aline(min(z+1,end):end)));
        end
        vol_out(:,x,y)=aline;

    end
end

end