% Convert raw spectrum data to Reflectivity



function RR = Dat2RR(Dat, intpDk, bavgfrm)

% choose parameter for lamda-k interpolation
if nargin < 2
	intpDk = -0.37;
end
if nargin < 3
	bavgfrm = 0;
end

% substract the reference signal, Subtract mean
[nk,nx,nf] = size(Dat);
if bavgfrm == 1
    Dat = Dat - repmat(mean(Dat(:,:),2),[1 nx nf]);
else
    for ifr=1:nf
        Dat(:,:,ifr) = Dat(:,:,ifr) - repmat(mean(Dat(:,:,ifr),2),[1 nx]);
    end
end
%%%%
nz = round(nk/2);
RR = zeros(nz,nx,nf,'single');
data_k= zeros(nk,nx,nf,'single');
%% transform from lamda to k, lamda-k interpolation, and ifft
if intpDk ~= 0
    k = linspace(1-intpDk/2, 1+intpDk/2, nk);
    lam = 1./fliplr(k);
    for ifr=1:nf
        %% lamda to k space
        temp = interp1(lam, Dat(:,:,ifr), linspace(min(lam),max(lam),length(lam)), 'spline');
        data_k(:,:,ifr)=temp;
        %% ifft
        RRy = ifft(data_k(:,:,ifr));
        RR(:,:,ifr) = RRy(1:nz,:);  
        if (mod(ifr,ceil(nf/5)) == 0)  
            disp(['... Raw to RR ' num2str(ifr) '/' num2str(nf) '  ' datestr(now,'HH:MM')]);  
        end
    end	
end


