datapath  = strcat('/projectnb/npbssmic/ns/190426_Thorlabs/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/code/Matlab_batch');

% get the directory of all image tiles
cd(datapath);

filename0=dir(strcat('16-*.mat'));
zrs=zeros(1,length(filename0));
opts = optimset('Display','off','TolFun',1e-10);
        

for iFile=1:length(filename0)
     %% get data information
     


  load(filename0(iFile).name);
     
     slice=curvature_corr(slice);
     I=slice;
    
    % determine if it is agarose
%     aip=squeeze(mean(I(41:200,:,:),1));
%     val=std2(aip);
    
    info = strsplit(filename0(iFile).name,'-');
    s_seg = str2double(info{1});
    z_seg = str2double(info{2});
        
        % sensitivity roll-off correction
        %w=2.22; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
        %I=rolloff_corr(I,w);

        fit_depth = round(300/3);       % depth want to fit, tunable
        % Average attenuation for the full ROI
        mean_I = mean(mean(I,2),3);
        mean_I = mean_I - mean(mean_I(380:end));
        [m, xav] = max(mean_I(21:150));
        xav = xav + 15;
        ydata = double(mean_I(xav:fit_depth+xav-1)');
        z = xav*3:3:(fit_depth+xav-1)*3;
        fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
        lb = [0 0 0 0];
        ub = [10000 0.02 300 150];
        est = lsqcurvefit(fun,[1000 0.001 150 50],z,ydata,lb,ub,opts);
%       A = fun(est,z);
%        % plotting intial fitting
%         figure
%         plot(z,ydata,'b.')
%         hold on
%         plot(z,A,'r-')
%         xlabel('z (um)')
%         ylabel('I')
%         title('Four parameter fit of averaged data')
%         dim = [0.2 0.2 0.3 0.3];
%         str = {'Estimated values: ',['Relative back scattering: ',num2str(round(est(1)),4)],['Scattering coefficient: ',...
%             num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
%         annotation('textbox',dim,'String',str,'FitBoxToText','on');
    zrs(iFile)=est(4);
    disp(strcat('No. ',num2str(iFile),' is processed.'));

end
save('zrs.mat','zrs');