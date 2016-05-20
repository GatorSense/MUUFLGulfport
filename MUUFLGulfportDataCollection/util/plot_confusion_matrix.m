function plot_confusion_matrix(C,last_is_unlabeled,class_labels)
%function plot_confusion_matrix(C,last_is_unlabeled,class_labels)
%
%  plot a confusion matrix with overlayed numbers
%
% 10/31/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

if last_is_unlabeled
    class_labels = [class_labels 'Unlabeled'];
    
    normC = zeros(size(C));
    lC = C(1:(end-1),1:(end-1));
    normC(1:(end-1),1:(end-1)) = lC./repmat(sum(lC,2),[1 size(lC,2)]);
else
    normC = C./repmat(sum(C,2),[1 size(C,2)]);
end


imagesc(normC);
colorbar;

n_class = size(C,1);

for i=1:n_class
    for j=1:n_class
        text(j,i,num2str(C(i,j)));
    end
end
xlabel('True Class');
ylabel('Output Class');

set(gca,'XTickLabel',class_labels);
set(gca,'YTickLabel',class_labels);

end