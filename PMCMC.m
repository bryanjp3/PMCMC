% TODO:
% implement method to remove stickiness
% parallelize code
% check out postdoc resampling methods
% test over more parameters rho and multi dimensions

clc
clear all
format compact
close all

rng default

kappa = 15;% higher, higher kurt
theta = .03; % lower, higher kurt
eta = .5;% higher, higher kurt
rho = -.5;
dt = 1/250;


if 2*kappa*theta < eta^2
    display('fix parameters')
    2*kappa*theta
    eta^2
    return
end

numSteps = 500;
w1 = randn(numSteps, 1);
w2 = randn(numSteps, 1);

x = zeros(numSteps, 1);

x(1) = theta;
for i = 2:numSteps
    
    noise(i) = eta*rho*w1(i)*sqrt(x(i-1)*dt)+  eta*sqrt((1-rho^2)*x(i-1)*dt)*w2(i);
    x(i) = x(i-1) + kappa*(theta - x(i-1))*dt + noise(i);
    if(x(i)<0)
       x(i) = .01; 
    end
end

plot(x)
if sum(x<0) > 1
    display('bad run')
    return
end
% scatter(noise, w1)
% hist(x*dt)
% hist(w1*dt, 20)

y = (0 - x*dt) + w1.*sqrt(x*dt);

% y = load('y.mat');
% 
% y = y.y;
% y = diff(log(y));

% qqplot(y)
% hist(y)
p = [kappa, theta, eta, rho];


numParticles = 1000;%2^12;

kappaDistribution = makedist('Uniform', 'lower', -1, 'upper', 0);
kappa0 = -.2;% random(kappaDistribution, 1, 1);


p = [kappa, theta, eta, kappa0];
initialProb = pf(y, p, numParticles, dt);

numSteps = 1000;
LL = zeros(numSteps, 1);
LL(1) = initialProb;

kappas = zeros(numSteps, 1);
kappas(1) = kappa0;

lessThanZero = false;
for i = 2:numSteps    
    
    rhoProposal = kappas(i-1) + .1*randn(1);
    
    p = [kappa, theta, eta, rhoProposal];
    py = pf(y, p, numParticles, dt);    
    
    accept = exp(py-LL(i-1));
    accept = accept > rand(1);
        
    % code to prevent sticking
    if i > 100
        if LL(i-1) == LL(i-99)
            accept = 1;
            display('stuck')
        end
    end
    
    if abs(rhoProposal) > 1
       accept = 0; 
    end
    
    if accept == 1
        i
        rhoProposal
        kappas(i) = rhoProposal;
        LL(i) = py;        
    else
        kappas(i) = kappas(i-1);
        LL(i) = LL(i-1);
    end
    if mod(i ,50) == 0
        hist(kappas(1:i));        
        drawnow
    end

end
% figure
subplot(2,1,1)
hist(kappas, 25)
% hist(kappas(50:end), 55)

subplot(2,1,2)
plot(kappas)

mean(kappas)
median(kappas)
% 
% if length(kappas > 1000)
%     mean(kappas(1000:end))
%     mode(kappas(1000:end))    
% end



























