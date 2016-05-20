function y = matches_filter(filt,type,sz,vis,occ)
%function y = matches_filter(filt,type,sz,vis,occ)
%
% test if a Hylid ground truth entry matches a scoring filter
%
% 8/14/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

  if isempty(filt)
      y = true;
      return
  end

  y = false;
  
  for i=1:numel(filt)
            
      % check for type match
      match = ( any(strcmpi(filt{i}{1},type)) || isempty(filt{i}{1}) );

      if ~match, continue; end
     
      % check for size match
      if isempty(filt{i}{2})
          match = true;
      else
          match = any(filt{i}{2} == sz);
      end
     
      if ~match, continue; end
     
      % check for location confidence (visibility) match
      if isempty(filt{i}{3})
          match = true;
      else
          match = any(filt{i}{3} == vis);
      end
      
      if ~match, continue; end
     
      % check for occlusion match
      if isempty(filt{i}{4})
          match = true;
      else
          match = any(filt{i}{4} == occ);
      end
            
      if match
          y = true;
          break;
      end
      
  end

end
