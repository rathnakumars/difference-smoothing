% For MATLAB 2015/2016 ----------------------------------------------------

p = gcp('nocreate');    % If no pool, do not create new one.
if isempty(p)
    cores = 0;
else
    cores = p.NumWorkers
end
% -------------------------------------------------------------------------