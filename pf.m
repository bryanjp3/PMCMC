function [ output ] = pf( y, parameters, numParticles, dt)
%PF Summary of this function goes here
%   Detailed explanation goes here
numSteps = length(y);
omega = parameters(1);% higher, higher kurt
theta = parameters(2); % lower, higher kurt
eta = parameters(3);% higher, higher kurt
rho = parameters(4);
% dt = 1/250;


pd = makedist('Uniform', 'lower', .02, 'upper', .1);
x0 = random(pd, numParticles, 1);
x_n = x0;
wm1 = ones(numParticles, 1);
state = zeros(1, numSteps);
for i = 2:numSteps
    
    %propagate  x
    x_np1 = x_n + (omega-theta*x_n)*dt +...
        eta*rho*(y(i-1) - (0)*dt)+...
        randn(numParticles,1).*eta.*sqrt(x_n*(1-rho^2)*dt);
        
    x_np1(x_np1<0) = 0.01;
    % compute p(y|x)
    w = wm1.*normpdf( y(i), (0), sqrt(x_np1*dt));
    py(i) = sum(w)/numParticles/1;
    w = w/sum(w);
    
    Neff = 1/sum(w.*w);
    
    index = 1:numParticles;
    if Neff < numParticles*.9      
        index = resampleSystematic(w);        
        x_np1 = x_np1(index);
        w = w*0+1/numParticles;
    end
    
    state(i) = sum(x_np1.*w);
    x_n = x_np1(index);
    
end
state = state';

% hist(w)
% scatter(x_n, w)
% plot(cdf)
% plot([x, state])
% 
% RMSE = mean(abs(diff(x-state)))
py = py(2:end);
% log(py)
output = sum(log(py));
% plot(state)
end

