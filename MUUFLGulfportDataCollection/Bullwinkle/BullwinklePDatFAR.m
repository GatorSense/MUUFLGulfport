function pd = BullwinklePDatFAR(score,far)

% go through the scores backwards, find the first PD event at less than or equal far

pd = 0;
for i=size(score.Bullwinkle,1):-1:1
    
    if strcmp(score.Bullwinkle{i,7},'tbfi') && score.Bullwinkle{i,3} <= far
        pd = score.Bullwinkle{i,2};
        break;
    end
    
end


end