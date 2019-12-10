function outdata = rolloff_corr(indata,w)
% perform sensitivity roll-off compensation on volume data
% indata: input data volume
% w: constant for the roll-off fitting equation, dependent on objective
% types
% Author: Jiarui Yang, jryang@bu.edu
% 02/05/19

%%--------------------%%

    outdata=zeros(size(indata));
%     % find the focus plane
%     [~, focus_depth]=max(squeeze(mean(mean(indata,2),3)));
%     focus_depth=focus_depth+30;
    depth=size(indata,1);
    z=1:1:depth;
    z0=z/1024;
    sr=(sin(z0)./z0).^2.*exp(-w^2*z0.^2/(2*log(2)));
    sr(isnan(sr(:)))=1;
    for i=1:size(indata,2)
        for j=1:size(indata,3)
            outdata(:,i,j)=indata(:,i,j)./sr';
        end
    end
    
end

