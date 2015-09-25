function [ indx ] = resampleMultinomial( w )

M = length(w);
Q = cumsum(w);
Q(M)=1; % Just in case...

i=1;
while (i<=M),
    sampl = rand(1,1);  % (0,1]
    j=1;
    while (Q(j)<sampl),
        j=j+1;
    end;
    indx(i)=j;
    i=i+1;
end


% t = rand(M+1);
% T = sort(t);
% 
% T(M+1) = 1; 
% i=1;
% j=1;
% 
% while (i<=M),
%     if (T(i)<Q(j)),
%         indx(i)=j;
%         i=i+1;
%     else
%         j=j+1;        
%     end
% end
% 
% 
