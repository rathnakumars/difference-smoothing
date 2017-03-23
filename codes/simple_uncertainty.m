% We compute "simple" uncertainty of the measured time delay. The program terminates 
% if some of the delays measured from the synthetic lightcurves are at the edge 
% of the trial time delay range specified in 'find_time_delay.m'. 

clear all
close all
clc

load data
load time_delay

no_trials = 500     % The number of simulations per simulated delay.

filename_chunks = strsplit(filename,'_');
filepath = ['../crash_testing/results_' filename_chunks{2} '.txt'];   % The path to the results file for writing summary.

current_path = pwd;
addpath(strcat(current_path, '/modules'))

parallel_processing

tic;    % Starting stop-watch in order to estimate computation time.

plots = 0;

delay_no = 1;

increment = 0;

make_plots = 0;

[a_simu1,b_simu1,a_noise1,b_noise1,norm_residuals_a1,norm_residuals_b1,no_residuals] = simulate_lightcurves(t,a,a_error,b,b_error,...
    first_epochs,last_epochs,sampling,delta,time_delay,smoothing,increment,make_plots,figure_outerposition,figure_position,all_plots);

[a_simu2,b_simu2,a_noise2,b_noise2,norm_residuals_a2,norm_residuals_b2,no_residuals] = simulate_lightcurves(t,b,b_error,a,a_error,...
    first_epochs,last_epochs,sampling,delta,-time_delay,smoothing,-increment,make_plots,figure_outerposition,figure_position,all_plots);

[a_simu,b_simu] = symmetrise_simulation(t,a_simu1,b_simu1,a_simu2,b_simu2,a_noise1,b_noise1,make_plots,figure_outerposition,all_plots);

[unproblematic_measurements,random_error,systematic_error,min_delay_values,max_delay_values] = find_uncertainty...
    (t,a_simu,b_simu,a_noise1,b_noise1,a_error,b_error,no_trials,delta,smoothing,mindelay,maxdelay,time_delay,increment,delay_no,mean_sampling);

if abs(min_delay_values-mindelay)<0.1 || abs(max_delay_values-maxdelay)<0.1
    display('Some of the measured delays seem to be at the edge of range!')
    display('Hence the uncertainty estimation is invalid!')
    error('So I terminated the program!');
end;

non_catastrophic_failures = unproblematic_measurements;

corrected_delay = time_delay-systematic_error;
uncertainty = sqrt(random_error^2+systematic_error^2);

elapsed_time = toc;     % Stopping stop-watch.
uncertainty_estimation_time = elapsed_time/60;  % Computation time expressed in minutes.

seasons = length(first_epochs);

display('Here are the final numbers!')
display(non_catastrophic_failures)

fprintf('%s\n',filename)
for i=1:length(filename)
    fprintf('%s','-')
end
fprintf('\n')

fprintf('%s = %0.2f     ','measured delay',time_delay,'delta',delta)
fprintf('%s = %0.1f     ','smoothing',smoothing)
fprintf('%s = [%0.0f %0.0f]\n','trial delay range',mindelay,maxdelay)
fprintf('%s = %0.2f     ','corrected delay',corrected_delay)
fprintf('%s = %0.2f (%s: %0.2f, %s: %0.2f)\n\n','uncertainty',uncertainty,'random',random_error,'systematic',abs(systematic_error))

if length(mask) > 0
    fprintf('%21s\t','mask:')
    fprintf('%0.0f\t',mask)
    fprintf('\n')
end;
if length(seasonal_mask) > 0
    fprintf('%21s\t','seasonal mask:')
    fprintf('%0.0f\t',seasonal_mask)
    fprintf('\n')
end;
if length(secondary_mask) > 0
    fprintf('%21s\t','secondary mask:')
    fprintf('%0.0f\t',secondary_mask)
    fprintf('\n')
end;
if max([length(mask) length(seasonal_mask) length(secondary_mask)]) > 0 
    fprintf('\n')
end;

fprintf('%s = %0.0f     ','trials',no_trials)
fprintf('%s ~ %0.1f %s     ','run time',uncertainty_estimation_time,'min')
fprintf('%s     ',datestr(now))
fprintf('%s = %0.0f     ','seasons',seasons)
fprintf('%s = %0.3f\n','max ratio',max_ratio)
fprintf('%s %s,%s     ','investigator,machine:',investigator,machine)
fprintf('%s = %0.0f     ','cores',cores)
fprintf('%s %0.0f,%0.0f     ','gaps,residuals:',no_gaps,no_residuals)
fprintf('%s = %0.3f,%0.3f\n\n','max NSV A,B',a_NSV_max,b_NSV_max)

% Writing to the results file ---------------------------------------------
fileID = fopen(filepath,'a');

fprintf(fileID,'%s\n',filename);
for i=1:length(filename)
    fprintf(fileID,'%s','-');
end
fprintf(fileID,'\n');

fprintf(fileID,'%s = %0.2f     ','measured delay',time_delay,'delta',delta);
fprintf(fileID,'%s = %0.1f     ','smoothing',smoothing);
fprintf(fileID,'%s = [%0.0f %0.0f]\n','trial delay range',mindelay,maxdelay);
fprintf(fileID,'%s = %0.2f     ','corrected delay',corrected_delay);
fprintf(fileID,'%s = %0.2f (%s: %0.2f, %s: %0.2f)\n\n','uncertainty',uncertainty,'random',random_error,'systematic',abs(systematic_error));

if length(mask) > 0
    fprintf(fileID,'%21s\t','mask:');
    fprintf(fileID,'%0.0f\t',mask);
    fprintf(fileID,'\n');
end;
if length(seasonal_mask) > 0
    fprintf(fileID,'%21s\t','seasonal mask:');
    fprintf(fileID,'%0.0f\t',seasonal_mask);
    fprintf(fileID,'\n');
end;
if length(secondary_mask) > 0
    fprintf(fileID,'%21s\t','secondary mask:');
    fprintf(fileID,'%0.0f\t',secondary_mask);
    fprintf(fileID,'\n');
end;
if max([length(mask) length(seasonal_mask) length(secondary_mask)]) > 0 
    fprintf(fileID,'\n');
end;

fprintf(fileID,'%s = %0.0f     ','trials',no_trials);
fprintf(fileID,'%s ~ %0.1f %s     ','run time',uncertainty_estimation_time,'min');
fprintf(fileID,'%s     ',datestr(now));
fprintf(fileID,'%s = %0.0f     ','seasons',seasons);
fprintf(fileID,'%s = %0.3f\n','max ratio',max_ratio);
fprintf(fileID,'%s %s,%s     ','investigator,machine:',investigator,machine);
fprintf(fileID,'%s = %0.0f     ','cores',cores);
fprintf(fileID,'%s %0.0f,%0.0f     ','gaps,residuals:',no_gaps,no_residuals);
fprintf(fileID,'%s = %0.3f,%0.3f\n\n','max NSV A,B',a_NSV_max,b_NSV_max);

fclose(fileID);

fprintf('%s ''%s''\n\n','I''ve also written the above summary to',filepath)
% -------------------------------------------------------------------------

fprintf('%s %c %s:','corrected delay',char(177),'uncertainty')
fprintf('  %s:','random','systematic','delta','smoothing','measured delay','max ratio')
fprintf('\n')
fprintf('%0.2f  ',corrected_delay,uncertainty,random_error,abs(systematic_error),delta)
fprintf('%0.1f  ',smoothing)
fprintf('%0.2f  ',time_delay)
fprintf('%0.3f\n\n',max_ratio)