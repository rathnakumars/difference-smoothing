function [a_simu,b_simu] = symmetrise_simulation(t,a_simu1,b_simu1,a_simu2,b_simu2,a_noise,b_noise,make_plots,figure_outerposition,all_plots)

a_simu = (a_simu1+b_simu2)/2;
b_simu = (b_simu1+a_simu2)/2;

if make_plots == 1
    if all_plots == 1

        % For MATLAB 2015/2016 ------------------------------------------------
        fontsize = 6;
        %----------------------------------------------------------------------
        
        set(0,'DefaultFigureWindowStyle','normal')
        
        figure('units','normalized','outerposition',figure_outerposition)
        subplot(4,1,1)
        scatter(t,a_simu1,'b.')
        hold on
        scatter(t,b_simu2,'g.')
        hold on
        scatter(t,a_simu,'r.')
        box on
        xlim([min(t)-30 max(t)+30])
        ylim([min(min(a_simu1),min(b_simu2))-0.05 max(max(a_simu1),max(b_simu2))+0.05])
        set(gca,'YDir','reverse','XMinorTick','on','FontName','Times','FontWeight','bold','FontSize',fontsize,...
            'Position',[0.064 0.768 0.9 0.19],'XTickLabel','')
        ylabel('Simu A')
        
        subplot(4,1,2)
        scatter(t,a_noise,'k.')
        box on
        xlim([min(t)-30 max(t)+30])
        ylim([min(a_noise)-0.01 max(a_noise)+0.01])
        set(gca,'XMinorTick','on','FontName','Times','FontWeight','bold','FontSize',fontsize,'Position',[0.064 0.562 0.9 0.19],'XTickLabel','')
        ylabel('Noise A')
        
        subplot(4,1,3)
        scatter(t,b_simu1,'b.')
        hold on
        scatter(t,a_simu2,'g.')
        hold on
        scatter(t,b_simu,'r.')
        box on
        xlim([min(t)-30 max(t)+30])
        ylim([min(min(a_simu2),min(b_simu1))-0.05 max(max(a_simu2),max(b_simu1))+0.05])
        set(gca,'YDir','reverse','XMinorTick','on','FontName','Times','FontWeight','bold','FontSize',fontsize,...
            'Position',[0.064 0.356 0.9 0.19],'XTickLabel','')
        ylabel('Simu B')
        
        subplot(4,1,4)
        scatter(t,b_noise,'k.')
        box on
        xlim([min(t)-30 max(t)+30])
        ylim([min(b_noise)-0.01 max(b_noise)+0.01])
        set(gca,'XMinorTick','on','FontName','Times','FontWeight','bold','FontSize',fontsize,'Position',[0.064 0.15 0.9 0.19])
        xlabel('Time [days]')
        ylabel('Noise B')
    end;
end;