offsetrange=80;
coef=zeros(1,offsetrange);
for i=1:offsetrange
    Y=circshift(I,i-1,1);         % select the dimension wnat to shift
    coef(i)=corr2(I,Y);
end

figure;plot(0:offsetrange-1,coef);