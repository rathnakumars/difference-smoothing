function f = cost_function(trial_time_delay,t,a,a_error,b,b_error,delta,smoothing)

t_shift = t-trial_time_delay;

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
error_model = zeros(length(t),1);

for j=1:length(t)
    model(j) = sum(micro.*(gaussmf(t_micro,[smoothing t_micro(j)]).*error_micro.^-2))...
        /sum(gaussmf(t_micro,[smoothing t_micro(j)]).*error_micro.^-2);
    error_model(j) = sqrt(1/sum(gaussmf(t_micro,[smoothing t_micro(j)]).*error_micro.^-2));
end

f = sum((micro-model).^2./(error_micro.^2+error_model.^2))/sum(1./(error_micro.^2+error_model.^2));