
clc
clear all
format compact
close all

% rng default
% rng(15367)

omega = .04;% higher, higher kurt
theta = 5.14; % lower, higher kurt
eta = .16;% higher, higher kurt
rho = -.70;
dt = 1/250;

numSteps = 2e2;
w1 = randn(numSteps, 1);
w2 = randn(numSteps, 1);

x = zeros(numSteps, 1);

x(1) = .021;
for i = 2:numSteps
    
    noise(i) = eta*rho*w1(i)*sqrt(x(i-1)*dt)+  eta*sqrt((1-rho^2)*x(i-1)*dt)*w2(i);
    x(i) = x(i-1) + (omega-theta*x(i-1))*dt + noise(i);
    if x(i) < 0 
        x(i) = .01;
    end
end

y = (0) + w1.*sqrt(x*dt);
rhos = -.8:.01:.1;
% rhos = .2:.0051:.45; %eta
% rhos = .01:.01:.2;%omega
% rhos = .51:.3:5;
for i = 1:length(rhos)
    p = [omega, theta, eta, rhos(i)];    
    numParticles = 9e3;    
    py=  pf(y, p, numParticles, dt);
    zz(i) = py;
    i/length(rhos)*100
end
zz = exp(zz-max(zz));
scatter(rhos, zz)

fit = polyfit(rhos, zz, 2);
y1 = polyval(fit, rhos);

plot(rhos ,zz,'o')
hold on
plot(rhos, y1)
mean(abs(y1-zz))
[c, index]=max(y1)
fittedMax = rhos(index)

[c, index]=max(zz)
MLE = rhos(index)
break
















