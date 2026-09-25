function [mixedsign_irfPointestimate, mixedesign_irfboot]= mixed_restrictions(maxiteration,maxiterationboot,maxbootcirf,lb,ub,restrictions,slowmov,cirf,cirfboot,labels,shocklabels)

i=0;
n=size(restrictions,1);
hor=size(cirf,3);


while i<maxiteration

% Instead of generating a full NxN random matrix and checking if it's zero (which is rare),
% I generate a smaller random orthogonal matrix for the "fast-moving" variables only.    
    
[tempH, ~] = qr(randn(n-slowmov));
% candidate rotation matrix Q (tempH)
tempH=[zeros(slowmov,size(restrictions,2));tempH(:,1:size(restrictions,2))]; 
i_rand=randi(maxbootcirf);
% Compute impact response using the candidate rotation
temp_irf(:,:,1)=cirf(:,:,1)*tempH;
% We check signs only for the fast-moving variables (slowmov+1:end).
% The slow variables are already 0 by construction, so we exclude them from the sign check.
check_sign=sum(abs(sign(temp_irf(slowmov+1:end,:,1))-restrictions(slowmov+1:end,:)),'all');
% If restrictions are satisfied (check_sign == 0), keep the draw
  if check_sign==0
    
        for j=2:size(cirf,3)
            temp_irf(:,:,j)=cirf(:,:,j)*tempH; 
        end
        debug="debug_i:";
        i=i+1;
        signed_irf(:,:,:,i)=temp_irf;
        H(:,:,i)=tempH;
    end
end

mixedsign_irfPointestimate=mean(signed_irf,4);
% Repeat the procedure for bootstrapped reduced-form estimates to generate confidence bands.
i_boot=0;

while i_boot<maxiterationboot

[tempH, ~] = qr(randn(n-slowmov));
tempH=[zeros(slowmov,size(restrictions,2));tempH(:,1:size(restrictions,2))];


i_rand=randi(maxbootcirf);

temp_irf(:,:,1)=cirfboot(:,:,1,i_rand)*tempH;
check_sign=sum(abs(sign(temp_irf(slowmov+1:end,:,1))-restrictions(slowmov+1:end,:)),'all');

    if check_sign==0
        for j=2:size(cirf,3)
            temp_irf(:,:,j)=cirfboot(:,:,j,i_rand)*tempH; 
        end
        i_boot=i_boot+1;
        mixedesign_irfboot(:,:,:,i_boot)=temp_irf;
        Hboot(:,:,i_boot)=tempH;
    end
end

mixedsign_irfPointestimate=squeeze(mixedsign_irfPointestimate);

