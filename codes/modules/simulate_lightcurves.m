function [a_simu,b_simu,a_noise,b_noise,norm_residuals_a,norm_residuals_b,no_residuals] = simulate_lightcurves(t,a,a_error,b,b_error,...
    first_epochs,last_epochs,sampling,delta,time_delay,smoothing,increment,make_plots,figure_outerposition,figure_position,all_plots)

t_shift = t-time_delay;
b_shift = b;

t_micro = zeros(length(t),1);
micro = zeros(length(t),1);
error_micro = zeros(length(t),1);

for j=1:length(t)
    t_micro(j) = t(j);
    micro(j) = a(j)-...
        sum(b_shift.*(max(gaussmf(t_shift,[delta t(j)]),eps*ones(length(t_shift),1)).*b_error.^-2))/...
        sum(max(gaussmf(t_shift,[delta t(j)]),eps*ones(length(t_shift),1)).*b_error.^-2);
    error_micro(j) = sqrt(a_error(j)^2+1/sum(max(gaussmf(t_shift,[delta t(j)]),eps*ones(length(t_shift),1)).*b_error.^-2));
end

model = zeros(length(t),1);

for j=1:length(t)
    model(j) = sum(micro.*(gaussmf(t_micro,[smoothing t_micro(j)]).*error_micro.^-2))...
        /sum(gaussmf(t_micro,[smoothing t_micro(j)]).*error_micro.^-2);
end

no_residuals = 10;
characterize_noise

intrinsic_a = zeros(length(t),1);
intrinsic_b = zeros(length(t),1);

for j=1:length(t)
    intrinsic_a(j) = sum((a-model).*(gaussmf(t,[sampling(j) t(j)]).*a_noise.^-2))/sum(gaussmf(t,[sampling(j) t(j)]).*a_noise.^-2);
    intrinsic_b(j) = sum(b_shift.*(gaussmf(t_shift,[sampling(j) t_shift(j)]).*b_noise.^-2))...
        /sum(gaussmf(t_shift,[sampling(j) t_shift(j)]).*b_noise.^-2);
end

t_merged = cat(1,t,t_shift);
merged = cat(1,a-model,b_shift);
sampling_merged = cat(1,sampling,sampling);
noise_merged = cat(1,a_noise,b_noise);

intrinsic = zeros(length(t_merged),1);

for j=1:length(t_merged)
    intrinsic(j) = sum(merged.*(gaussmf(t_merged,[sampling_merged(j) t_merged(j)]).*noise_merged.^-2))...
        /sum(gaussmf(t_merged,[sampling_merged(j) t_merged(j)]).*noise_merged.^-2);
end

fast_micro_a = intrinsic_a-intrinsic(1:length(t));
fast_micro_b = intrinsic_b-intrinsic(length(t)+1:length(t_merged));

t_merged_simu = cat(1,t+increment/2,t_shift-increment/2);

if min([isvector(t_merged) isvector(merged) isvector(sampling_merged) isvector(noise_merged) isvector(t_merged_simu)])==0
    error('You need to be careful when you merge two vectors into one in MATLAB!')
end;
    
intrinsic_simu = zeros(length(t_merged),1);

for j=1:length(t_merged_simu)
    [min_sep,index] = min(abs(t_merged_simu(j)-t_merged));
    intrinsic_simu(j) = sum(merged.*(gaussmf(t_merged,[sampling_merged(index) t_merged_simu(j)]).*noise_merged.^-2))...
        /sum(gaussmf(t_merged,[sampling_merged(index) t_merged_simu(j)]).*noise_merged.^-2);
end

a_simu = intrinsic_simu(1:length(t))+model+fast_micro_a;
b_simu_shift = intrinsic_simu(length(t)+1:length(t_merged))+fast_micro_b;
b_simu = b_simu_shift;

norm_residuals_a = fast_micro_a./a_noise;
norm_residuals_b = fast_micro_b./b_noise;

if make_plots == 1
    [sort_t_merged,sort_indices] = sort(t_merged);
    sort_intrinsic = intrinsic(sort_indices);
    
    gaps = sort_t_merged(2:length(sort_t_merged))-sort_t_merged(1:length(sort_t_merged)-1);
    large_gap_cutoff = mean(gaps)+2*std(gaps);
    season_last_epochs_merged = find(gaps > large_gap_cutoff);
    gaps_sub = gaps(gaps <= large_gap_cutoff);
    seasons_merged = length(season_last_epochs_merged)+1;
    
    first_epochs_merged = zeros(length(seasons_merged),1);
    last_epochs_merged = zeros(length(seasons_merged),1);
        
    for k=1:seasons_merged
        if k==1
            first_epochs_merged(k) = 1;
        else
            first_epochs_merged(k) = season_last_epochs_merged(k-1)+1;
        end;
        
        if k==seasons_merged
            last_epochs_merged(k) = length(sort_t_merged);
        else
            last_epochs_merged(k) = season_last_epochs_merged(k);
        end;
    end
    
    % For MATLAB 2015/2016 ------------------------------------------------
    fontsize = 10;
    scattersize = 100;
    %----------------------------------------------------------------------
    
    set(0,'DefaultFigureWindowStyle','normal')
    
    max_ratio = max([max(abs(norm_residuals_a)) max(abs(norm_residuals_b))]);
    
    title_string = sprintf('%s = %0.2f %s %50s = %0.1f%s %50s = %0.3f',...
        '\Deltat',time_delay,'days','s',smoothing/delta,'\delta','max |ratio|',max_ratio);
    
    figure('units','normalized','outerposition',figure_outerposition)
    scatter(t,a-model,scattersize,'r.')
    box on
    hold on
    scatter(t_shift,b_shift,scattersize,'b.')
    hold on
    for j=1:length(first_epochs)
        plot(t(first_epochs(j):last_epochs(j)),intrinsic_a(first_epochs(j):last_epochs(j)),'r','LineWidth',1)
        hold on
        plot(t_shift(first_epochs(j):last_epochs(j)),intrinsic_b(first_epochs(j):last_epochs(j)),'b','LineWidth',1)
        hold on
    end
    for j=1:length(first_epochs_merged)
        plot(sort_t_merged(first_epochs_merged(j):last_epochs_merged(j)),sort_intrinsic(first_epochs_merged(j):last_epochs_merged(j)),...
            'k','LineWidth',1)
        hold on
    end
    xlim([min(t_merged)-0.05*(max(t_merged)-min(t_merged)) max(t_merged)+0.05*(max(t_merged)-min(t_merged))])
    ylim([min(min(a-model),min(b_shift))-0.05 max(max(a-model),max(b_shift))+0.05])
    set(gca,'YDir','reverse','FontName','Times','FontWeight','bold','FontSize',fontsize,'XMinorTick','on','Position',figure_position)
    xlabel('Time [days]')
    ylabel('Magnitude')
    title(title_string)
        
    if all_plots == 1
        figure('units','normalized','outerposition',figure_outerposition)
        subplot(1,2,1)
        hist(norm_residuals_a,min(norm_residuals_a):0.1:max(norm_residuals_a))
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','m','EdgeColor','k')
        set(gca,'FontName','Times','FontWeight','bold','FontSize',fontsize,'Position',[0.061 0.195 0.44 0.75])
        [n,xout] = hist(norm_residuals_a,min(norm_residuals_a):0.1:max(norm_residuals_a));
        line([-2 -2],[0 100],'color','r')
        line([2 2],[0 100],'color','r')
        xlim([min(xout)-0.1 max(xout)+0.1])
        ylim([0 20])
        xlabel('Normalised residuals A')
        ylabel('No. of occurences')
        subplot(1,2,2)
        hist(norm_residuals_b,min(norm_residuals_b):0.1:max(norm_residuals_b))
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','m','EdgeColor','k')
        set(gca,'FontName','Times','FontWeight','bold','FontSize',fontsize,'Position',[0.527 0.195 0.44 0.75],'YTickLabel','')
        [n,xout] = hist(norm_residuals_b,min(norm_residuals_b):0.1:max(norm_residuals_b));
        line([-2 -2],[0 100],'color','r')
        line([2 2],[0 100],'color','r')
        xlim([min(xout)-0.1 max(xout)+0.1])
        ylim([0 20])
        xlabel('Normalised residuals B')
    end;
end;