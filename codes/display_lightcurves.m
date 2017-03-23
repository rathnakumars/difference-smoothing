% We take a first look at the lightcurves. We may optionally mask outlier epochs 
% as well as observing seasons having very fast extrinsic variability from further 
% analysis.    

clear all
close all
clc

filename = 'tdc1_rung3_double_pair435.txt';     % Name of the file containing the lightcurves.

rejection_cutoff = 4    % For automatic detection of outliers. Adjust the threshold value (in units of sigma) as needed!

% To mask outlier epochs from further analysis before you start masking entire observing seasons below. 
% Input one epoch at a time and add new entry to the right!
mask = [] 
% To mask entire observing seasons out of the analysis, if they have very fast extrinsic variations. 
% Input one observing season at a time and add new entry to the right!
seasonal_mask = []
% To mask outlier epochs from further analysis after you have started masking entire observing seasons above. 
% Input one epoch at a time and add new entry to the right!
secondary_mask = []

seasons_threshold = 3   % To automatically identify large seasonal gaps. Adjust the threshold value (in units of sigma) as needed!

all_plots = 0   % Set this to '1' if you want to see all the plots! Otherwise, only the essential plots will be shown.

investigator = 'rathna';    % Your name in short.
machine = 'laptop';     % Specify one of 'laptop', 'desktop', 'aad3', etc!

figure_outerposition = [0.025 0.35 0.85 0.5];
figure_position = [0.067 0.195 0.9 0.7];

current_path = pwd;
addpath(strcat(current_path, '/modules'))

filename_chunks = strsplit(filename,'_');
filepath = ['../time_delay_challenge/tdc1/' filename_chunks{2} '/',filename];   % The path to the file.

% We read the file using space as delimiter ignoring the first six lines, which contain file header.
data = dlmread(filepath,'',6,0);
t_all = data(:,1);
a_flux_all = data(:,2);
a_flux_error_all = data(:,3);
b_flux_all = data(:,4);
b_flux_error_all = data(:,5);

current_path = pwd;
addpath(strcat(current_path, '/modules'))

% We leave out epochs having negative fluxes.
positive_a_epochs = find(a_flux_all > 0);
positive_b_epochs = find(b_flux_all > 0);
positive_epochs = intersect(positive_a_epochs,positive_b_epochs);
t = t_all(positive_epochs);
a_flux = a_flux_all(positive_epochs);
a_flux_error = a_flux_error_all(positive_epochs);
b_flux = b_flux_all(positive_epochs);
b_flux_error = b_flux_error_all(positive_epochs);

negative_flux_epochs = length(t_all)-length(t)

% We convert fluxes to magnitudes.
a = -2.5*log10(a_flux);
a_error = 2.5*log10(1+a_flux_error./a_flux);
b = -2.5*log10(b_flux);
b_error = 2.5*log10(1+b_flux_error./b_flux);

% We arrange the data in ascending order of time, just in case it is not already arranged that way.
[t,sort_index] = sort(t);
a = a(sort_index);
a_error = a_error(sort_index);
b = b(sort_index);
b_error = b_error(sort_index);

% Masking of outlier epochs BEFORE masking of entire observing seasons. 
for i=1:length(mask)
    remaining_epochs = [1:mask(i)-1,mask(i)+1:length(t)]; 
    
    t = t(remaining_epochs);
    a = a(remaining_epochs);
    a_error = a_error(remaining_epochs);
    b = b(remaining_epochs);
    b_error = b_error(remaining_epochs);
end

% Identifying observing seasons.
gaps = t(2:length(t))-t(1:length(t)-1);
large_gap_cutoff = mean(gaps)+seasons_threshold*std(gaps); 
season_last_epochs = find(gaps > large_gap_cutoff);
gaps_sub = gaps(gaps <= large_gap_cutoff);
seasons = length(season_last_epochs)+1;

% For masking whole observing seasons.
for i=1:length(seasonal_mask)
    if seasonal_mask(i)==1
        remaining_epochs = [season_last_epochs(1)+1:length(t)];  
        t = t(remaining_epochs);
        a = a(remaining_epochs);
        a_error = a_error(remaining_epochs);
        b = b(remaining_epochs);
        b_error = b_error(remaining_epochs);
        
    elseif seasonal_mask(i)==seasons
        remaining_epochs = [1:season_last_epochs(seasons-1)]; 
        t = t(remaining_epochs);
        a = a(remaining_epochs);
        a_error = a_error(remaining_epochs);
        b = b(remaining_epochs);
        b_error = b_error(remaining_epochs);
        
    else
        remaining_epochs = [1:season_last_epochs(seasonal_mask(i)-1),season_last_epochs(seasonal_mask(i))+1:length(t)]; 
        t = t(remaining_epochs);
        a = a(remaining_epochs);
        a_error = a_error(remaining_epochs);
        b = b(remaining_epochs);
        b_error = b_error(remaining_epochs);
    end;
    
    gaps = t(2:length(t))-t(1:length(t)-1);
    large_gap_cutoff = mean(gaps)+seasons_threshold*std(gaps);
    season_last_epochs = find(gaps > large_gap_cutoff);
    gaps_sub = gaps(gaps <= large_gap_cutoff);
    seasons = length(season_last_epochs)+1;
end

% Masking of outlier epochs AFTER masking of entire observing seasons. 
for i=1:length(secondary_mask)
    remaining_epochs = [1:secondary_mask(i)-1,secondary_mask(i)+1:length(t)];
    
    t = t(remaining_epochs);
    a = a(remaining_epochs);
    a_error = a_error(remaining_epochs);
    b = b(remaining_epochs);
    b_error = b_error(remaining_epochs);
end

characterize_sampling

% For MATLAB 2015/2016 ----------------------------------------------------
fontsize = 10;
scattersize = 100;
%--------------------------------------------------------------------------

% Plotting the lightcurves. The median values are subtracted to enable easier visual comparison between the lightcurves. 
% Use the plot with 'Epoch #' as x-axis if you want to know the epoch number of a particular outlier epoch! 
a_plot = a-median(a);
b_plot = b-median(b);

set(0,'DefaultFigureWindowStyle','normal')

if all_plots == 1
    figure('units','normalized','outerposition',figure_outerposition)
    scatter(t,sampling,scattersize,'k.')
    box on
    for i=1:seasons-1
        line([(t(last_epochs(i))+t(first_epochs(i+1)))/2 (t(last_epochs(i))+t(first_epochs(i+1)))/2],[-100 100],'color','k')
    end
    xlim([min(t)-0.05*(max(t)-min(t)) max(t)+0.05*(max(t)-min(t))])
    ylim([min(sampling)-0.1*(max(sampling)-min(sampling)) max(sampling)+0.1*(max(sampling)-min(sampling))])
    set(gca,'FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
    xlabel('Time [days]')
    ylabel('Sampling [days]')
end;

figure('units','normalized','outerposition',figure_outerposition)
scatter(1:length(t),a_plot,scattersize,'r.')
hold on
scatter(1:length(t),b_plot,scattersize,'b.')
box on
for i=1:length(t)
    line([i i],[a_plot(i)-a_error(i) a_plot(i)+a_error(i)],'color','r')
end
for i=1:length(t)
    line([i i],[b_plot(i)-b_error(i) b_plot(i)+b_error(i)],'color','b')
end
for i=1:seasons-1
    line([last_epochs(i)+0.5 last_epochs(i)+0.5],[-100 100],'color','k')
end
xlim([-4 length(t)+5])
ylim([min(min(a_plot),min(b_plot))-0.1 max(max(a_plot),max(b_plot))+0.1])
set(gca,'YDir','reverse','FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
xlabel('Epoch #')
ylabel('Magnitude')

figure('units','normalized','outerposition',figure_outerposition)
scatter(t,a_plot,scattersize,'r.')
hold on
scatter(t,b_plot,scattersize,'b.')
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
xlim([min(t)-0.05*(max(t)-min(t)) max(t)+0.05*(max(t)-min(t))])
ylim([min(min(a_plot),min(b_plot))-0.1 max(max(a_plot),max(b_plot))+0.1])
set(gca,'YDir','reverse','FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
xlabel('Time [days]')
ylabel('Magnitude')

detect_outliers

save('data.mat','t','a','b','a_error','b_error','first_epochs','last_epochs','figure_outerposition','figure_position','no_gaps',...
    'sampling','mean_sampling','delta','mask','seasonal_mask','secondary_mask','a_NSV_max','b_NSV_max','filename','investigator','machine')