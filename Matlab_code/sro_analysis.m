datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.38opt\');
cd(datapath);
load max.mat;
depth0=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.305\');
cd(datapath);
load max.mat;
depth1=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.23\');
cd(datapath);
load max.mat;
depth2=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.155\');
cd(datapath);
load max.mat;
depth3=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.08\');
cd(datapath);
load max.mat;
depth4=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\30.005\');
cd(datapath);
load max.mat;
depth5=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\29.93\');
cd(datapath);
load max.mat;
depth6=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\29.855\');
cd(datapath);
load max.mat;
depth7=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Axial\29.78\');
cd(datapath);
load max.mat;
depth8=mip;

datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.38\');
cd(datapath);
load max.mat;
nf0=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.305\');
cd(datapath);
load max.mat;
nf1=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.23\');
cd(datapath);
load max.mat;
nf2=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.155\');
cd(datapath);
load max.mat;
nf3=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.08\');
cd(datapath);
load max.mat;
nf4=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\30.005\');
cd(datapath);
load max.mat;
nf5=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\29.93\');
cd(datapath);
load max.mat;
nf6=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\29.855\');
cd(datapath);
load max.mat;
nf7=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Noise_floor\29.78\');
cd(datapath);
load max.mat;
nf8=mip;


% noise
sn0=20*log10(nf0);   % since OD of relective ND filter is 1.0
sn1=20*log10(nf1);
sn2=20*log10(nf2);
sn3=20*log10(nf3);
sn4=20*log10(nf4);
sn5=20*log10(nf5);
sn6=20*log10(nf6);
sn7=20*log10(nf7);
sn8=20*log10(nf8);
% signal
sn0=20*log10(depth0);   % since OD of relective ND filter is 1.0
sn1=20*log10(depth1);
sn2=20*log10(depth2);
sn3=20*log10(depth3);
sn4=20*log10(depth4);
sn5=20*log10(depth5);
sn6=20*log10(depth6);
sn7=20*log10(depth7);
sn8=20*log10(depth8);
% signal noise ratio
sn0=20*log10(depth0./nf0)+20;   % since OD of relective ND filter is 1.0
sn1=20*log10(depth1./nf1)+20;
sn2=20*log10(depth2./nf2)+20;
sn3=20*log10(depth3./nf3)+20;
sn4=20*log10(depth4./nf4)+20;
sn5=20*log10(depth5./nf5)+20;
sn6=20*log10(depth6./nf6)+20;
sn7=20*log10(depth7./nf7)+20;
sn8=20*log10(depth8./nf8)+20;


%% plotting
err=[std(sn0) std(sn1) std(sn2) std(sn3) std(sn4) std(sn5) std(sn6) std(sn7) std(sn8)]./400;
y=[mean(sn0) mean(sn1) mean(sn2) mean(sn3) mean(sn4) mean(sn5) mean(sn6) mean(sn7) mean(sn8)];
x=1:9;
% gaussEqn = 'a*exp(-((x-b)/c)^2)+d';
% f=fit(x',y',gaussEqn);
figure;hold on;
errorbar(x,y,err,'o');ylabel('Intensity(dB)');xlabel('depth (um)');ylim([0 80]);xlim([0 9]);set(gca,'XTickLabel',{'','0','75','150','225','300','375','450','525','600'});


datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.855mw\');
cd(datapath);
load max.mat;
pw0=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.801mw\');
cd(datapath);
load max.mat;
pw1=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.750mw\');
cd(datapath);
load max.mat;
pw2=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.705mw\');
cd(datapath);
load max.mat;
pw3=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.652mw\');
cd(datapath);
load max.mat;
pw4=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.601mw\');
cd(datapath);
load max.mat;
pw5=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.554mw\');
cd(datapath);
load max.mat;
pw6=mip;
datapath  = strcat('C:\Users\jryang\Desktop\Vibratome_data\1002\Power\0.501mw\');
cd(datapath);
load max.mat;
pw7=mip;

y=[mean(pw0) mean(pw1) mean(pw2) mean(pw3) mean(pw4) mean(pw5) mean(pw6) mean(pw7)];
err=[std(pw0) std(pw1) std(pw2) std(pw3) std(pw4) std(pw5) std(pw6) std(pw7)]./400;
x=[0.855 0.801 0.750 0.705 0.652 0.601 0.554 0.501];
gaussEqn = 'a*exp(-((x-b)/c)^2)+d';
%f=fit(x',y','gauss2');
figure;hold on;
errorbar(x,y,err,'o');ylabel('Intensity(dB)');xlabel('depth (um)');%xlim([0 9]);
%plot(f,x,y);