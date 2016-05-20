function plot_hylid_gt(gt,filter,varargin)

p = inputParser();
p.addParamValue('inds',true,@(x)isscalar(x));
p.addParamValue('names','short',@(x)ischar(x)&&any(strcmpi({'none','short','long'},x)));
p.addParamValue('sizes',true,@(x)isscalar(x));
p.addParamValue('Parent',[],@(x)isscalar(x));
p.parse(varargin{:});
args = p.Results;

if ~exist('filter','var')
    filter = [];
end

if isempty(args.Parent)
    ax = gca();
else
    ax = args.Parent;
end

if isstruct(gt) && isfield(gt,'groundTruth') && ~isfield(gt,'Targets_Type')
    % check if we passed in a hylid struct as the first arg, use its groundTruth field
    gt = gt.groundTruth;
end

hold(ax,'on');

ind = 1;
for i=1:numel(gt.Targets_colIndices)
    
    if matches_filter(filter,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i))        
   
        if strcmpi('short',args.names)
            switch gt.Targets_Type{i}
                case 'brown'
                    type = 'br';
                case 'pea green'
                    type = 'pg';
                case 'vineyard green'
                    type = 'vg';
                case 'faux vineyard green'
                    type = 'fvg';
                case 'dark green'
                    type = 'dg';
                otherwise
                    type = gt.Targets_Type{i};
            end                    
                    
        elseif strcmpi('long',args.names)
            type = gt.Targets_Type{i};
        else
            type = '';
        end
        
        if args.inds
            tid = strrep(gt.Targets_ID{i},'Target_','');
        else
            tid = '';
        end
        
        if args.sizes
            tsz = sprintf('%0.1f m',gt.Targets_Size(i));
        else 
            tsz = '';
        end
        
        txt = {type,tid,tsz};
        
        plot(ax,gt.Targets_colIndices(i),gt.Targets_rowIndices(i),'ws','MarkerSize',10);
        text(gt.Targets_colIndices(i)+3,gt.Targets_rowIndices(i),...
            txt, ...
            'Color',[1 1 1],'Parent',ax);
        
        %sprintf('Cf %d Ca %d',gt.Targets_HumanConf(i),gt.Targets_HumanCat(i))},...
        ind = ind+1;
    else
        plot(ax,gt.Targets_colIndices(i),gt.Targets_rowIndices(i),'kx','MarkerSize',5);
        
    end
end

end