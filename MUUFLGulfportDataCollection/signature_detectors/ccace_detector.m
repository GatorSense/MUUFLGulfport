function [ccace_out,segs,U,C] = ccace_detector(hsi_img,tgt_sig,mask,n_comp)
%
%function [ccace_out,segs,U,C] = ccace_detector(hsi_img,tgt_sig,mask,n_comp)
%
% Class Conditional ACE
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_comp - number of Gaussian components to use
%
% outputs:
%  ccace_out - detector image
%  segs - segment image
%  U - cluster memberships
%  C - cluster centers
%
% 2/21/2013 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_comp','var'); n_comp = 5; end

[ccace_out,segs,U,C] = img_det(@ccace_det,hsi_img,tgt_sig,mask,n_comp);

end

function [ccace_data,idx,U,C] = ccace_det(hsi_data,tgt_sigs,n_comp)

[n_band,n_pix] = size(hsi_data);
n_sigs = size(tgt_sigs,2);

% fit the model
%gmm = gmdistribution.fit(hsi_data',n_comp,'Replicates',1,'Regularize',1e-6);
[fcmC,U] = fcm(hsi_data',n_comp);
C = fcmC';

% make a crisp partitioning
[~,idx] = max(U,[],1);

% make a matched filter for each background class
%means = gmm.mu;
%sigmas = gmm.Sigma;


mu = cell(1,n_comp);
siginv = cell(1,n_comp);
S = cell(1,n_comp);
z = cell(1,n_comp);
G = cell(1,n_comp);

for i=1:n_comp
   %mu{i} = means(i,:)';
   %siginv{i} = pinv(squeeze(sigmas(:,:,i)));

   mu{i} = C(:,i);
   z{i} = hsi_data - repmat(mu{i},[1 n_pix]);

   sigma = zeros(n_band,n_band);
   for j=1:n_pix
       
       y = hsi_data(:,j) - mu{i};
        
       sigma = sigma + U(i,j) * y*y';
   end
   sigma = sigma/sum(U(i,:));
   
   siginv{i} = pinv(sigma);
   
   S{i} = tgt_sigs - repmat(mu{i},[1,n_sigs]);
   
   G{i} = siginv{i}*S{i}*pinv(S{i}'*siginv{i}*S{i})*S{i}'*siginv{i};
end

% run appropriate filter for class of each pixel
%idx = gmm.cluster(hsi_data');

ccace_data = zeros(1,n_pix);

for i=1:n_pix
    k = idx(i);    
    ccace_data(i) = (z{k}(:,i)'*G{k}*z{k}(:,i)) / (z{k}(:,i)'*siginv{k}*z{k}(:,i));
end

end
