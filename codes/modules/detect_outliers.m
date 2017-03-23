% A script to automatically produce 'mask' or 'secondary_mask' in order to mask 
% outlier epochs. We plot the lightcurves with circles around the identified 
% outlier epochs. Copy & paste the output displayed in terminal into 'mask' or 
%'secondary_mask' variable, as needed, in 'display_lightcurves.m' in order to 
% mask those epochs from further analysis!

no_residuals = 100;
characterize_noise

title_string = sprintf('%s = %0.3f %50s = %0.3f','max NSV A',a_NSV_max,'max NSV B',b_NSV_max);
title(title_string)

a_residuals_normalised = a_residuals./a_noise;
b_residuals_normalised = b_residuals./b_noise;

if length(seasonal_mask) == 0
    i = 1;
    for j=1:length(t)
        if max(abs([a_residuals_normalised(j) b_residuals_normalised(j)])) > rejection_cutoff 
            circle_epochs(i) = j;
            mask(length(mask)+1) = j-i+1;
            i = i+1;
        end;
    end
else
    i = 1;
    for j=1:length(t)
        if max(abs([a_residuals_normalised(j) b_residuals_normalised(j)])) > rejection_cutoff 
            circle_epochs(i) = j;
            secondary_mask(length(secondary_mask)+1) = j-i+1;
            i = i+1;
        end;
    end
end;

if i > 1
    if length(seasonal_mask) == 0
        fprintf('%s\n','To mask the circled epochs, copy & paste the below line')
        fprintf('%s\n\n','into ''mask'' variable in ''display_lightcurves.m''!')
        fprintf('%0.0f ',mask)
        fprintf('\n\n')
    else
        fprintf('%s\n','To mask the circled epochs, copy & paste the below line')
        fprintf('%s\n\n','into ''secondary_mask'' variable in ''display_lightcurves.m''!')
        fprintf('%0.0f ',secondary_mask)
        fprintf('\n\n')
    end;        
    
    % For MATLAB 2015/2016 ----------------------------------------------------
    fontsize = 10;
    scattersize = 100;
    %--------------------------------------------------------------------------
    
    figure('units','normalized','outerposition',figure_outerposition)
    scatter(t,a_plot,scattersize,'r.')
    hold on
    scatter(t,b_plot,scattersize,'b.')
    hold on
    scatter(t(circle_epochs),a_plot(circle_epochs),75,'r')
    hold on
    scatter(t(circle_epochs),b_plot(circle_epochs),75,'b')
    box on
    for i=1:length(t)
        line([t(i) t(i)],[a_plot(i)-a_error(i) a_plot(i)+a_error(i)],'color','r')
    end
    for i=1:length(t)
        line([t(i) t(i)],[b_plot(i)-b_error(i) b_plot(i)+b_error(i)],'color','b')
    end
    for i=1:seasons-1
        line([(t(last_epochs(i))+t(first_epochs(i+1)))/2 (t(last_epochs(i))+t(first_epochs(i+1)))/2],[-100 100],'color','k')
    end
    xlim([min(t)-30 max(t)+30])
    ylim([min(min(a_plot),min(b_plot))-0.1 max(max(a_plot),max(b_plot))+0.1])
    set(gca,'YDir','reverse','FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
    xlabel('Time [days]')
    ylabel('Magnitude')
    title('There are outliers!')
else
    display('There are no outliers!')
end;