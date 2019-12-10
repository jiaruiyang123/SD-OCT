z = 0.01:0.01:1;

w=1;
figure(1);
plot(z,(sin(z)./z).^2, z,(sin(z)./z).^2.*exp(-w^2*z.^2/(2*log(2))) );

w=0.5;
figure(2);
plot(z,(sin(z)./z).^2, z,(sin(z)./z).^2.*exp(-w^2*z.^2/(2*log(2))) );