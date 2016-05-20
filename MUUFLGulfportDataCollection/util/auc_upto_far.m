function auc = auc_upto_far(far,score)
% auc = auc_upto_far(far,score)
%
%  compute area under the ROC curve up to a given FAR from the Bullwinkle scoring output
%    or if score is a N by 2 array, treat it as x,y values for an ROC
%
% 5/28/2013 - Taylor Glenn - tcg@cise.ufl.edu 

% given the scoring output
% auc is sum of (max_far-FAR[i]) for each target

if iscell(score)
    auc = zeros(1,numel(score));
    for i=1:numel(score)
        auc(i) = auc_upto_far(far,score{i});
    end
    return;
end

if isstruct(score)
    bw = score.Bullwinkle;
    
    pds = vertcat(bw{:,2});
    fars = vertcat(bw{:,3});
    
elseif isnumeric(score)
    % 2-columns, x,y pairs
    pds = score(:,2);
    fars = score(:,1);
else
    error('hmm');    
end

auc = 0;

for i=2:numel(fars)
    
    if fars(i) > far
        break;
    end
    
    auc = auc + (pds(i)-pds(i-1))*(far - fars(i));
end

auc = auc/far; %convert AUC to a percentage


end