% To measure the time delay between the lightcurves.

clear all
close all
clc

% We tell the code to search for time delay in the range 'mindelay' to 'maxdelay'.
mindelay = -120
maxdelay = 120

% The value of smoothing timescale free parameter specified as a multiple of decorrelation length.
smoothing_by_delta = 10

sampling_factor = 1     % To control the sampling of trial time delay values while plotting normalized chi squared values.

all_plots = 0   % Set this to '1' if you want to see all the plots! Otherwise, only the essential plots will be shown.

load data

smoothing = smoothing_by_delta*delta;

current_path = pwd;
addpath(strcat(current_path, '/modules'))

% Optimizer searching for the time delay.
time_delay = fminbnd(@(delay) optimise_delay(delay,t,a,a_error,b,b_error,delta,smoothing),mindelay,maxdelay);

increment = 0;

make_plots = 1;

clc

parallel_processing

[a_simu1,b_simu1,a_noise1,b_noise1,norm_residuals_a1,norm_residuals_b1,no_residuals] = simulate_lightcurves(t,a,a_error,b,b_error,...
    first_epochs,last_epochs,sampling,delta,time_delay,smoothing,increment,make_plots,figure_outerposition,figure_position,all_plots);

[a_simu2,b_simu2,a_noise2,b_noise2,norm_residuals_a2,norm_residuals_b2,no_residuals] = simulate_lightcurves(t,b,b_error,a,a_error,...
    first_epochs,last_epochs,sampling,delta,-time_delay,smoothing,-increment,make_plots,figure_outerposition,figure_position,all_plots);

display(delta)
display(smoothing)
display(time_delay)

[a_simu,b_simu] = symmetrise_simulation(t,a_simu1,b_simu1,a_simu2,b_simu2,a_noise1,b_noise1,make_plots,figure_outerposition,all_plots);

a_ratio = mean([max(abs(norm_residuals_a1)) max(abs(norm_residuals_b2))])
b_ratio = mean([max(abs(norm_residuals_b1)) max(abs(norm_residuals_a2))])

max_ratio = max([a_ratio b_ratio]);

save('time_delay.mat','time_delay','mindelay','maxdelay','smoothing','max_ratio','all_plots')

trial_delay_values = mindelay+delta/sampling_factor/2:delta/sampling_factor:maxdelay;
cost_function_values1 = zeros(length(trial_delay_values),1);
cost_function_values2 = zeros(length(trial_delay_values),1);
parfor i=1:length(trial_delay_values)
    trial_time_delay = trial_delay_values(i);
    cost_function_values1(i) = cost_function(trial_time_delay,t,a,a_error,b,b_error,delta,smoothing);
    cost_function_values2(i) = cost_function(-trial_time_delay,t,b,b_error,a,a_error,delta,smoothing);
end
cost_function_values = (cost_function_values1+cost_function_values2)/2;

% For MATLAB 2015/2016 ----------------------------------------------------
fontsize = 10;
scattersize = 100;
%--------------------------------------------------------------------------

title_string = sprintf('%s = %0.2f %s %50s = %0.1f%s %50s = %0.3f',...
    '\Deltat',time_delay,'days','s',smoothing/delta,'\delta','max |ratio|',max_ratio);

set(0,'DefaultFigureWindowStyle','normal')

% seasons = length(first_epochs);
% 
% figure('units','normalized','outerposition',figure_outerposition)
% scatter(t,a_noise1,scattersize,'r.')
% hold on
% scatter(t,b_noise1,scattersize,'b.')
% box on
% for i=1:seasons-1
%     line([(t(last_epochs(i))+t(first_epochs(i+1)))/2 (t(last_epochs(i))+t(first_epochs(i+1)))/2],[-100 100],'color','k')
% end
% xlim([min(t)-0.05*(max(t)-min(t)) max(t)+0.05*(max(t)-min(t))])
% ylim([0 1.1*max(max(a_noise1),max(b_noise1))])
% set(gca,'FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
% xlabel('Time [days]')
% ylabel('Noise [mag]')

figure('units','normalized','outerposition',figure_outerposition)
scatter(trial_delay_values,cost_function_values,scattersize,'k.')
box on
line([time_delay time_delay],[-10*max(cost_function_values) 10*max(cost_function_values)],'color','r','LineWidth',1)
xlim([mindelay maxdelay])
ylim([min(cost_function_values)-0.05*max(cost_function_values) 1.05*max(cost_function_values)])
set(gca,'FontName','Times','fontsize',fontsize,'fontweight','bold','XMinorTick','on','Position',figure_position)
xlabel('Trial time delay [days]')
ylabel('Normalized \chi^2')
title(title_string)