function [cirf,CholBoot,cholu,CovU,u] = CholeskyBoot(y,p,H,c,MaxBoot,cl,ind,opt)
           
n=size(y,2);  % n= number of variables 

%_____________________________________
% OLS estimates
%_____________________________________
[Y X] = VarStr(y,c,p);       % yy and XX all the sample
T=size(Y,1);  % number of observations 
Bols=inv(X'*X)*X'*Y;
% VecB=reshape(Bols,n*(n*p+1),1);
% B=companion(VecB,p,n,c);
B=[Bols(2:end,:)';eye(n*(p-1)) zeros(n*(p-1),n)]; % is the F of zt=...(companion form)
C=Bols(1,:)';  % vector of constants 
u=Y-X*Bols;  % residuals of the model 
CovU=cov(u); % covariance matrix 
u=u'; %residual 
% impulse response functions
for h=1:H
    irf=B^(h-1); % irf is impulse response function 
    cirf(:,:,h)=irf(1:n,1:n)*chol(CovU)';
end
cholu=u'*inv(chol(CovU)')'; % chol u are the shocks of cholensky 
% up to here we do the stime puntuali 
%_____________________________________
% Bootstrapping
%_____________________________________
for i=1:MaxBoot    %maxboot number of bootstrap repetition 
    
    % generate new series
    for t=1:T+1
        if t==1
            YB(:,1)=X(1,2:end)';  % YB is the z of the zt = Fzt-1 + e
        else
            a = randi(size(u,2),1);
         
            uu=u(:,a);
            YB(:,t)=[C;zeros(n*p-n,1)]+B*YB(:,t-1)+[uu;zeros(n*p-n,1)];
        end
    end

    % estimate the new VAR
    yb=[y(1:p,:);YB(1:n,2:end)'];  %YB is a vector with lenght np 
    [Yn Xn] = VarStr(yb,c,p);     % yy and XX all the sample

    T=size(Yn,1);
    Bolsn=inv(Xn'*Xn)*Xn'*Yn;
    CovUBoot(:,:,i)=cov(Yn-Xn*Bolsn);
    
    Bn=[Bolsn(2:end,:)';eye(n*(p-1)) zeros(n*(p-1),n)];
    % impulse response functions
    for h=1:H
        irfBoot=Bn^(h-1);
        % cholesky
        CholBoot(:,:,h,i)=irfBoot(1:n,1:n)*chol(CovUBoot(:,:,i))';
    end
end
cirf(ind,:,:)=cumsum(cirf(ind,:,:),3);
CholBoot(ind,:,:,:)=cumsum(CholBoot(ind,:,:,:),3);


    k=0;
    figure(2)
    for ii=1:n
        for jj=1:n
            k=k+1;
            subplot(n,n,k),plot(1:H,squeeze(cirf(ii,jj,:)),'k',...
            1:H,squeeze(prctile(CholBoot(ii,jj,:,:),[16 84],4)),':k'),axis tight
        end
    end

