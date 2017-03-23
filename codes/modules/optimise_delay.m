function f = optimise_delay(delay,t,a,a_error,b,b_error,delta,smoothing)

fa = cost_function(delay,t,a,a_error,b,b_error,delta,smoothing);

fb = cost_function(-delay,t,b,b_error,a,a_error,delta,smoothing);

f = (fa+fb)/2;