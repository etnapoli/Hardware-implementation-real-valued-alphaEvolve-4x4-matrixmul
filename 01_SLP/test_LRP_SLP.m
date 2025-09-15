% Author: Ettore Napoli, University of Salerno
% Date:   2025-09
%
% matlab script that tests the SLP representation of the 
% LRP matrix multiplication algorithm
%
% -------------------------------------------------------------------------
% License:
% This code is released under the MIT License.
% 
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the "Software"), 
% to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the 
% Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% -------------------------------------------------------------------------

err=0;
max_err=0;
for ii=1:1000000
% A = randi(100000,4,4)-100000/2;
% B = randi(100000,4,4)-100000/2;
A = (rand(4,4)-0.5)*10^6;
B = (rand(4,4)-0.5)*10^6;

C1 = A*B;
C2 = matmul_LRP_SLP(B, A);
ne=abs(norm(C1 - C2,'fro'));
err=err + ne;
if (ne>max_err)
    disp("A=");
    disp(A);
    disp("B=");
    disp(B);
    disp("C1=");
    disp(C1);
    disp("C2=");
    disp(C2);
    disp("diff=");
    disp(C2-C1);
    max_err=ne;
end
    
    
end
disp(err/10000000);
