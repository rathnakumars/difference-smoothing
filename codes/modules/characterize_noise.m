smoothed_a = zeros(length(t),1);
smoothed_b = zeros(length(t),1);

for j=1:length(t)
    smoothed_a(j) = sum(a.*gaussmf(t,[sampling(j) t(j)]))/sum(gaussmf(t,[sampling(j) t(j)]));
    smoothed_b(j) = sum(b.*gaussmf(t,[sampling(j) t(j)]))/sum(gaussmf(t,[sampling(j) t(j)]));
end

a_residuals = a-smoothed_a;
b_residuals = b-smoothed_b;

seasons = length(first_epochs);

a_noise = zeros(length(t),1);
b_noise = zeros(length(t),1);

for k=1:seasons
    season_epochs = first_epochs(k):last_epochs(k);
    a_residuals_season = a_residuals(season_epochs);
    b_residuals_season = b_residuals(season_epochs);
    
    for j=first_epochs(k):last_epochs(k)
        [sort_seps,sort_seps_indices] = sort(abs(t(j)-t(season_epochs)));
        a_noise(j) = std(a_residuals_season(sort_seps_indices(1:min(no_residuals,length(season_epochs)))));
        b_noise(j) = std(b_residuals_season(sort_seps_indices(1:min(no_residuals,length(season_epochs)))));
    end
    
    smoothed_a_season = smoothed_a(season_epochs);
    smoothed_b_season = smoothed_b(season_epochs);
    
    a_normalised_seasonal_variability(k) = std(smoothed_a_season)/std(a_residuals_season);
    b_normalised_seasonal_variability(k) = std(smoothed_b_season)/std(b_residuals_season);
end

a_NSV_max = max(a_normalised_seasonal_variability);
b_NSV_max = max(b_normalised_seasonal_variability);