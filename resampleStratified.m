function [ indx ] = resampleStratified( w )

N = length(w);
Q = cumsum(w);

for i=1:N,
    T(i) = rand(1,1)/N + (i-1)/N;
end
T(N+1) = 1;

i=1;
j=1;

while (i<=N),
    if (T(i)<Q(j)),
        indx(i)=j;
        i=i+1;
    else
        j=j+1;        
    end
end


