% We compute the TDC performance metrics - success fraction, goodness of fit, 
% precision, and accuracy.

clear all
close all
clc

rung_no = 3     % TDC rung for which to compute the performance metrics.

precision_threshold = 100    % To select only those measured time delays with empirical precision in percentage <= the specified threshold. 
smoothing_threshold = 1000    % To select only those time delays measured with smoothing/delta < the specified threshold.

% To select only those lightcurves having true time delays between the specified range.
minimum_true_delay_threshold = 0
maximum_true_delay_threshold = 120

figure_outerposition = [0.4 0.3 0.35 0.55];

filepath = strcat('/home/rathna/difference_smoothing/crash_testing/truth_compare_rung',num2str(rung_no),'.txt');
data = dlmread(filepath,'',1,1);

true_delays = data(:,1);
measured_delays = data(:,2);
% measured_delays = data(:,8);    % Measured time delays, without correcting for systematic bias.
uncertainties = data(:,3);
delta_values = data(:,6);
smoothing_values = data(:,7);

smoothing_by_delta_values = smoothing_values./delta_values;

for i=1:length(true_delays)
    if true_delays(i) < 0
        true_delays(i) = -true_delays(i);
        measured_delays(i) = -measured_delays(i);
    end;
end

no_lightcurves_true_delay_range = length(true_delays(true_delays >= minimum_true_delay_threshold))-...
    length(true_delays(true_delays >= maximum_true_delay_threshold))

true_delays = true_delays(uncertainties ~= 0);
measured_delays = measured_delays(uncertainties ~= 0);
smoothing_by_delta_values = smoothing_by_delta_values(uncertainties ~= 0);
uncertainties = uncertainties(uncertainties ~= 0);

no_lightcurves_matching_selection_criterion = length(uncertainties(uncertainties ~= -11))

true_delays = true_delays(uncertainties > 0);
measured_delays = measured_delays(uncertainties > 0);
smoothing_by_delta_values = smoothing_by_delta_values(uncertainties > 0);
uncertainties = uncertainties(uncertainties > 0);

measured_delays = measured_delays(true_delays >= minimum_true_delay_threshold);
uncertainties = uncertainties(true_delays >= minimum_true_delay_threshold);
smoothing_by_delta_values = smoothing_by_delta_values(true_delays >= minimum_true_delay_threshold);
true_delays = true_delays(true_delays >= minimum_true_delay_threshold);

measured_delays = measured_delays(true_delays < maximum_true_delay_threshold);
uncertainties = uncertainties(true_delays < maximum_true_delay_threshold);
smoothing_by_delta_values = smoothing_by_delta_values(true_delays < maximum_true_delay_threshold);
true_delays = true_delays(true_delays < maximum_true_delay_threshold);

no_valid_measurements = length(true_delays)

precision_values_empirical = uncertainties./measured_delays*100;

true_delays = true_delays(precision_values_empirical <= precision_threshold);
measured_delays = measured_delays(precision_values_empirical <= precision_threshold);
uncertainties = uncertainties(precision_values_empirical <= precision_threshold);
smoothing_by_delta_values = smoothing_by_delta_values(precision_values_empirical <= precision_threshold);

number_precision_cut = length(true_delays)
precision_cut_percentage = number_precision_cut/length(precision_values_empirical)*100

true_delays = true_delays(smoothing_by_delta_values < smoothing_threshold);
measured_delays = measured_delays(smoothing_by_delta_values < smoothing_threshold);
uncertainties = uncertainties(smoothing_by_delta_values < smoothing_threshold);
smoothing_by_delta_values = smoothing_by_delta_values(smoothing_by_delta_values < smoothing_threshold);

number_smoothing_cut = length(true_delays)
smoothing_cut_percentage = number_smoothing_cut/number_precision_cut*100

success_fraction = length(true_delays)/no_lightcurves_true_delay_range;
fprintf('%s\n','Success fraction:')
fprintf('%0.3f\n\n',success_fraction)

chi_squared_values = ((measured_delays-true_delays)./uncertainties).^2; 
chi_squared = mean(chi_squared_values);
chi_squared_error = std(chi_squared_values)/sqrt(length(chi_squared_values));
fprintf('%s\n','Chi squared:')
fprintf('%0.3f %c %0.3f\n\n',chi_squared,char(177),chi_squared_error)

precision_values = uncertainties./true_delays;
precision = mean(precision_values);
precision_error = std(precision_values)/sqrt(length(precision_values));
fprintf('%s\n','Precision:')
fprintf('%0.3f %c %0.3f\n\n',precision,char(177),precision_error)

accuracy_values = (measured_delays-true_delays)./true_delays;
accuracy = mean(accuracy_values);
accuracy_error = std(accuracy_values)/sqrt(length(accuracy_values));
fprintf('%s\n','Accuracy:')
fprintf('%0.3f %c %0.3f\n\n',accuracy,char(177),accuracy_error)

discrepancies = measured_delays-true_delays; 

discrepancies_sigma = discrepancies./uncertainties;
max_discrepancy_sigma = max(abs(discrepancies_sigma));

set(0,'DefaultFigureWindowStyle','normal')

figure('units','normalized','outerposition',figure_outerposition)
hist(smoothing_by_delta_values,0:0.5:round(max(smoothing_by_delta_values)))
box on
xlim([0 1.1*max(smoothing_by_delta_values)])
ylim([0 20])
set(gca,'FontName','Times','fontsize',8,'fontweight','bold','XMinorTick','on')
xlabel('s/\delta')
ylabel('No. of occurences')

figure('units','normalized','outerposition',figure_outerposition)
scatter(true_delays,discrepancies,20,abs(discrepancies_sigma),'filled')
box on
colorbar;
xlim([minimum_true_delay_threshold maximum_true_delay_threshold])
ylim([-1.1*max(abs(discrepancies)) 1.1*max(abs(discrepancies))])
set(gca,'FontName','Times','fontsize',9,'fontweight','bold','XMinorTick','on','YMinorTick','on')
xlabel('True delay [day]')
ylabel('Measured delay - True delay [day]')
title(['Rung ',num2str(rung_no)])