function make_clicky_scatter(scatter_fig,rgb_fig,spectra_fig,pts_2d,hsi_img,wvl)
%
% utility to make clicky scatter plots tied to rgb images
%
% clicking on the scatter plot highlights the closest data point in the
% scatter plot and in the rgb image and plots the pixel's spectra,
% clicking on the rgb image highlights the corresponding point in the image and scatter plot
%
% INPUTS:
%  scatter_fig - handle to scatter plot figure
%  rgb_fig - handle to rgb image figure
%  spectra_fig - handle to spectra figure
%  pts_2d - 2 x n_pixels, data points to scatter plot
%  hsi_img - n_row x n_col x n_band, hyperspectral image
%  wvl - wavelength labels of hsi bands (if not supplied or empty uses 1:n_band)
%
% 12/3/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

if ~exist('wvl','var') || isempty(wvl); wvl = 1:size(hsi_img,3); end    

sz = [size(hsi_img,1) size(hsi_img,2)];
T = delaunayn(pts_2d');

    function click_on_scatter(obj,eventdata)
        
        %find the x,y of where the mouse was clicked
        mpos = get(obj,'CurrentPoint');

        %find the offset of this point into the axes
        %offset = mpos - lower left of the axes
        axes_rel = get(gca,'Position');
        figure_pos = get(obj,'Position');
        axes_lower_left = [axes_rel(1)*figure_pos(3) axes_rel(2)*figure_pos(4)];
        offset = round(mpos - axes_lower_left);

        %find position of axes boundaries in screen pixels
        ax_left = axes_rel(1)*figure_pos(3);
        ax_right = (axes_rel(1)+axes_rel(3))*figure_pos(3);
        ax_bottom = axes_rel(2)*figure_pos(4);
        ax_top = (axes_rel(2)+axes_rel(4))*figure_pos(4);

        %see if we clicked within the axes
        if(~((mpos(1) > ax_left) && (mpos(1) < ax_right) && (mpos(2) > ax_bottom) && (mpos(2) < ax_top)) )
            return
        end
        
        %scale each points index and confidence values to pixel values within axes object
        xl = get(gca,'XLim');
        yl = get(gca,'YLim');
                        
        y = (offset(2)/(ax_top - ax_bottom) *(yl(2) - yl(1)) + yl(1));
        x = (offset(1)/(ax_right - ax_left) *(xl(2) - xl(1)) + xl(1));
                       
        ind = dsearchn(pts_2d',T,[x y]);
        
        [row,col] = ind2sub(sz,ind);
        
        fprintf('y: %f x: %f ind: %d row: %d col: %d\n',y,x,ind,row,col);
        
        plot_spectra(row,col);
        
        % set clicked on the rgb plot
        select_rgb(row,col);
        
        % set clicked point on the scatter plot
        select_scatter(row,col);
        
    end

    function click_on_rgb(obj,eventdata)
        
        %find the x,y of where the mouse was clicked
        mpos = get(obj,'CurrentPoint');

        %find the offset of this point into the axes
        %offset = mpos - lower left of the axes
        axes_rel = get(gca,'Position');
        figure_pos = get(obj,'Position');
        axes_lower_left = [axes_rel(1)*figure_pos(3) axes_rel(2)*figure_pos(4)];
        offset = round(mpos - axes_lower_left);

        %find position of axes boundaries in screen pixels
        ax_left = axes_rel(1)*figure_pos(3);
        ax_right = (axes_rel(1)+axes_rel(3))*figure_pos(3);
        ax_bottom = axes_rel(2)*figure_pos(4);
        ax_top = (axes_rel(2)+axes_rel(4))*figure_pos(4);

        %see if we clicked within the axes
        if(~((mpos(1) > ax_left) && (mpos(1) < ax_right) && (mpos(2) > ax_bottom) && (mpos(2) < ax_top)) )
            return
        end
        
        %scale each points index and confidence values to pixel values within axes object
        xl = get(gca,'XLim');
        yl = get(gca,'YLim');
                        
        row = round(offset(2)/(ax_top - ax_bottom) *(yl(1) - yl(2)) + yl(2));
        col = round(offset(1)/(ax_right - ax_left) *(xl(2) - xl(1)) + xl(1));
        
        fprintf('row: %d col: %d\n',row,col);
        
        % plot the appropriate spectra
        plot_spectra(row,col);
        
        % set clicked on the rgb plot
        select_rgb(row,col);
        
        % set clicked point on the scatter plot
        select_scatter(row,col);
    end

    function plot_spectra(row,col)
        figure(spectra_fig);
        spectra = squeeze(hsi_img(row,col,:));
        plot(wvl,spectra);
        ylim([min(min(spectra(:)),0) max(min(spectra(:)),1)]);                
    end

    function select_rgb(row,col)
        
        old_h = guidata(rgb_fig);
        if ~isempty(old_h)
            try
                delete(old_h);
            end
        end
        figure(rgb_fig);
        hold on;
        h = plot(col,row,'rs','MarkerSize',10);
        guidata(rgb_fig,h);        
    end

    function select_scatter(row,col)
        ind = sub2ind(sz,row,col);
        
        old_h = guidata(scatter_fig);
        if ~isempty(old_h)
            try
                delete(old_h);
            end
        end
        figure(scatter_fig);
        hold on;
        h = scatter(pts_2d(1,ind),pts_2d(2,ind),'r*');
        guidata(scatter_fig,h);
        
    end


set(scatter_fig,'WindowButtonUpFcn',{@click_on_scatter});
set(rgb_fig,'WindowButtonUpFcn',{@click_on_rgb});

end