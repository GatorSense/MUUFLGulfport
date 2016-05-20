function [C,has_unlabeled] = make_confusion(out_img,truth_img,n_class)
%function [C,has_unlabeled] = make_confusion(out_img,truth_img,n_class)
%
%  make a confusion matrix, treat nan and zero as extra unlabeled class
%
% 10/31/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

has_unlabeled = false;
if or(any(isnan(out_img(:))),any(isnan(truth_img(:)))) || ...
        or(any(out_img(:)==0),any(truth_img(:)==0))
    has_unlabeled = true;
    
    out_img(out_img == 0) = nan;
    truth_img(truth_img == 0) = nan;
   
    n_class = n_class+1;
end


C = zeros(n_class,n_class);

[n_row,n_col] = size(out_img);
n_pix = n_row*n_col;

out_lin = reshape(out_img,n_pix,1);
truth_lin = reshape(truth_img,n_pix,1);

for i=1:n_pix
   if isnan(out_lin(i))
       row = n_class;
   else
       row = out_lin(i);
   end
   if isnan(truth_lin(i))
       col = n_class;
   else
       col = truth_lin(i);
   end
      
   C(row,col) = C(row,col)+1;
   
end


end