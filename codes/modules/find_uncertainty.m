function [unproblematic_measurements,random_error,systematic_error,min_delay_values,max_delay_values] = find_uncertainty...
    (t,a_simu,b_simu,a_noise,b_noise,a_error,b_error,no_trials,delta,smoothing,mindelay,maxdelay,time_delay,increment,delay_no,mean_sampling)

simu_delay = time_delay+increment;

comment = sprintf('%s %0.2f     %s %0.0f','Simulated delay:',simu_delay,'Simulation #',delay_no);

delay_values = zeros(no_trials,1);

parfor simu=1:no_trials
    trial = simu;
    display(trial)
    fprintf('%s\n',comment)
    
    a = a_simu+a_noise.*randn(length(t),1);
    b = b_simu+b_noise.*randn(length(t),1);
        
    delay = fminbnd(@(delay) optimise_delay(delay,t,a,a_error,b,b_error,delta,smoothing),mindelay,maxdelay);

    display(delay)
            
    delay_values(simu) = delay;
end

delay_values_all = delay_values;

for k=1:100
    cutoff_sigma = 4;
    min_cutoff = mean(delay_values)-cutoff_sigma*std(delay_values);
    max_cutoff = mean(delay_values)+cutoff_sigma*std(delay_values);

    j = 1;
    for i=1:length(delay_values)
        if delay_values(i) > max_cutoff || delay_values(i) < min_cutoff
            continue
        end;
        delay_values_sub(j) = delay_values(i);
        j = j+1;
    end
    length_delay_values_sub(k) = length(delay_values_sub);

    random_error = std(delay_values_sub);
    systematic_error = mean(delay_values_sub)-simu_delay;

    min_delay_values = min(delay_values_sub);
    max_delay_values = max(delay_values_sub);
    
    if k > 1
        if length_delay_values_sub(k) == length_delay_values_sub(k-1)
            unproblematic_measurements = length_delay_values_sub(k);
            break
        end;
    end;
    
    delay_values = delay_values_sub;
    clear delay_values_sub
end

binsize = mean_sampling/5;

fprintf('%s\n',comment)
display(length_delay_values_sub)
display(random_error)
display(systematic_error)

n = hist(delay_values_all,min(delay_values_all):binsize:max(delay_values_all));

% For MATLAB 2015/2016 ----------------------------------------------------
fontsize = 10;
%--------------------------------------------------------------------------

set(0,'DefaultFigureWindowStyle','normal')

figure_outerposition = [0.5 0.25 0.35 0.6];

figure('units','normalized','outerposition',figure_outerposition)
hist(delay_values_all,min(delay_values_all):binsize:max(delay_values_all))
set(gca,'XMinorTick','on','FontName','Times','FontWeight','bold','FontSize',fontsize)
line([min_cutoff min_cutoff],[0 no_trials],'color','r')
line([max_cutoff max_cutoff],[0 no_trials],'color','r')
xlim([min(delay_values_all)-binsize max(delay_values_all)+binsize])
ylim([0 max(n)+1])
xlabel('Time delay [days]')
ylabel('No. of occurences')
title(comment)