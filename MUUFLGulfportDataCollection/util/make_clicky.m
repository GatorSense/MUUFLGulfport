function make_clicky(infig,outfig,hsi_img,wavelengths)
%
%function make_clicky(infig,outfig,hsi_img,wavelengths)
%
% adds a callback to a given figure to display spectra for a pixel when
% clicked
%
% infig - figure handle of figure to add click ability
% outfig - figure handle of figure to display spectra
% hsi_img - hyperspectral image row x column x bands
% wavelengths - wavelength labels for image bands (or [] for unknown)
%
% example:
%  figure(10); 
%  imagesc(mean(hsi_img,3));
%  make_clicky(figure(10),figure(11),hsi_img);
%
% -Taylor C. Glenn, 6/7/2012, tcg@cise.ufl.edu

if ~exist('wavelengths','var')
    wavelengths = 1:size(hsi_img,3);
end

    function click_on_hsi(obj,eventdata)
        
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
        
        figure(outfig);
        spectra = squeeze(hsi_img(row,col,:));
        plot(wavelengths,spectra);
        ylim([min(min(spectra(:)),0) max(min(spectra(:)),1)]);
        
        old_h = guidata(obj);
        if ~isempty(old_h)
            try
                delete(old_h);
            end
        end
        figure(obj);
        hold on;
        h = plot(col,row,'rs','MarkerSize',10);
        guidata(obj,h);

        
    end


set(infig,'WindowButtonUpFcn',{@click_on_hsi});

end