%load data.mat;

%avg_z_8=squeeze(mean(mean(slice,3),2));

figure;hold on;
plot(log10(avg_z_1(51:end)),'LineWidth',1);
plot(log10(avg_z_2(51:end)),'LineWidth',1);
plot(log10(avg_z_3(51:end)),'LineWidth',1);
plot(log10(avg_z_4(51:end)),'LineWidth',1);
plot(log10(avg_z_5(51:end)),'LineWidth',1);
plot(log10(avg_z_6(51:end)),'LineWidth',1);
plot(log10(avg_z_7(51:end)),'LineWidth',1);
plot(log10(avg_z_8(51:end)),'LineWidth',1);
legend('0.5hr','1hr','1.5hr','2hr','2.5hr','3hr','3.5hr','4hr');
xlabel('Depth (um)');ylabel('Intensity');title('averaged A-line under TDE');
set(gca,'XTickLabel',{'165','330','495','660','825','990','1155','1320'});

figure;imagesc(squeeze(mean(slice,2)));title('averaged B-scan at 4hr under TDE');...
set(gca,'YTickLabel',{'165','330','495','660','825','990','1155','1320'});...
set(gca,'XTickLabel',{'125','250','375','500','625','750','875','1000'});...
ylabel('Depth (um)');xlabel('X-axis (um)');