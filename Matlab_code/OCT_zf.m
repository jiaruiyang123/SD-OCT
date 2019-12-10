%% Optical property fitting - fit tilt for plane of focus depth
% indicate dataset location
datapath  = strcat('/projectnb/npbssmic/ns/190825_Thorlabs/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/code/Matlab_batch');

% get the directory of one example agarose tile
cd(datapath);

filename0=dir(strcat('1-132-*.dat'));

%options for non-linear fitting
opts = optimset('Display','off','TolFun',1e-10);
        
% get binary data and transform into matrix

 nk = 400; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
 dim=[nk nxRpt nx nyRpt ny];
 slice=zeros(400,400,400);
for i=1:length(filename0)
 ifilePath=[datapath,filename0(i).name];
 disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
 [s] = ReadDat_single(ifilePath, dim); 
 slice=slice+s;
end

 % filed curvature correction
 slice=curvature_corr(slice./length(filename0));
 I=slice;
    
% data range for fitting
fit_depth = round(300/3);       

% Average attenuation for the full ROI
mean_I = mean(mean(I,2),3);
mean_I = mean_I - mean(mean_I(380:end));
[m, xav] = max(mean_I(21:150));
xav=xav+15;
ydata = double(mean_I(xav:fit_depth+xav-1)');
z = xav*3:3:(fit_depth+xav-1)*3;
fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
lb = [0 0 0 0];
ub = [10000 0.02 400 150];
est = lsqcurvefit(fun,[1000 0.001 250 100],z,ydata,lb,ub,opts);
A = fun(est,z);
  % plotting intial fitting
figure
plot(z,ydata,'b.')
hold on
plot(z,A,'r-')
xlabel('z (um)')
ylabel('I')
title('Four parameter fit of averaged data')
dim = [0.2 0.2 0.3 0.3];
str = {'Estimated values: ',['Relative back scattering: ',num2str(round(est(1)),4)],['Scattering coefficient: ',...
    num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
annotation('textbox',dim,'String',str,'FitBoxToText','on');

% fitting for the whole tile

res = 40;
est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),3);

for i = 1:round(size(I,2)/res)
    for j = 1:round(size(I,3)/res)
        area = I(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
        int = squeeze(mean(mean(area,2),3));
        int = int - mean(int(380:end));
        int = movmean(int,5);
        [v, x] = max(int(21:150));
        x=x+20;
        ydata = double(int(x:fit_depth+x-1)');
        z = x*3:3:(fit_depth+x-1)*3;
        fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./est(4)).^2)));
        lb = [0 0 est(3)-100];
        ub=[10000 0.02 est(3)+100];
        est_pix(i,j,:) = lsqcurvefit(fun_pix,[1000 0.005 est(3)],z,ydata,lb,ub,opts);
    end           
end
        
% fit zf surface using 1st polynomial

zf = squeeze(est_pix(:,:,3));
figure;imagesc(zf);
x = 40:40:400;
y = x;
[X, Y] = meshgrid(x,y);
X = reshape(X,[100,1]);
Y = reshape(Y,[100,1]);
surfit = fit([X,Y],reshape(zf,[100,1]),'poly11');

%savename=['zf_',num2str(s_seg),'_',num2str(z_seg)];
%save([datapath, '/fitting/', savename, '.mat'],'zf');
figure;plot(surfit,[X,Y],reshape(zf,[100,1]));