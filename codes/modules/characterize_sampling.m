% Identifying observing seasons.
gaps = t(2:length(t))-t(1:length(t)-1);
large_gap_cutoff = mean(gaps)+seasons_threshold*std(gaps);
season_last_epochs = find(gaps > large_gap_cutoff);
gaps_sub = gaps(gaps <= large_gap_cutoff);
seasons = length(season_last_epochs)+1;

mean_sampling = mean(gaps_sub)

delta = mean_sampling  % Free parameter called 'decorrelation length. 
% We set it equal to the mean sampling of the lightcurves computed after excluding seasonal gaps.

display(seasons)    % The number of observing seasons identified in the lightcurves. 
% If it does not match with the number of observing seasons you could count visually, 
% then you need to reduce the value of 'seasons_threshold' variable in 'display_lightcurves.m'!

no_gaps = 10;

first_epochs = zeros(length(seasons),1);
last_epochs = zeros(length(seasons),1);
sampling_seasons = zeros(length(seasons),1);

sampling = zeros(length(t),1);

for k=1:seasons
    if k==1
        first_epochs(k) = 1;
    else
        first_epochs(k) = season_last_epochs(k-1)+1;
    end;
    
    if k==seasons
        last_epochs(k) = length(t);
    else
        last_epochs(k) = season_last_epochs(k);
    end;
    
    gaps_season = gaps(first_epochs(k):last_epochs(k)-1);
    sampling_seasons(k) = mean(gaps_season);   % The mean sampling of the lightcurves estimated for individual seasons. 
    
    % To be used in producing synthetic lightcurves.
    for j=first_epochs(k):last_epochs(k)
        season_epochs = first_epochs(k):last_epochs(k);
        gaps_season_centers = (t(first_epochs(k):last_epochs(k)-1)+t(first_epochs(k)+1:last_epochs(k)))/2;  
        
        [sort_seps,sort_seps_indices] = sort(abs(t(j)-gaps_season_centers));
        sampling(j) = mean(gaps_season(sort_seps_indices(1:min(no_gaps,length(season_epochs)))));
    end
end

fprintf('\n%s\n\n    ','sampling of individual seasons:')
fprintf('%0.2f    ',sampling_seasons)
fprintf('\n\n')