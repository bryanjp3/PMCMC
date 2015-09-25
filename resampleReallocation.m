function [indx ] = resampleReallocation( w, N )
% [ W,indx ] = resampleReallocation( w, N )
% Reallocation method for resampling for particle filtering. 
% Author: Tiancheng Li, Ref:
% T. Li, M. Bolic, P. Djuric, Resampling methods for particle filtering, 
% submit to IEEE Signal Processing Magazine, August 2013

% Input:
%       w    the input weight sequence 
%       N    the desired length of the output sequence
%            (i.e. the desired number of resampled particles)
% Output:
%       indx the resampled index according to the weight sequence
%       W    the outout weight sequence

if nargin ==1
  N = length(w);
end
M = length(w);
w = w./sum(w);
Ns = floor(N*w);
indx = zeros(1,N);
W = zeros(1,N);

i = 1;
j = 0;
while j < M
    j = j + 1;
    if Ns(j) >= 1
      counter = 1;
      wtemp = w(j)/Ns(j);
      while counter <= Ns(j)
        W(i)= wtemp;
        indx(i) = j;
        i = i + 1; counter = counter + 1;
      end;
    else
        u = rand/N;
        if w(j) > u
            W(i) = 1/N;
            indx(i) = j;
            i= i + 1;
        end
    end
end
W = W/sum(W);
% % since the number of output sample size is adaptive
% indx(i:end) = [];
% W(i:end) = [];

