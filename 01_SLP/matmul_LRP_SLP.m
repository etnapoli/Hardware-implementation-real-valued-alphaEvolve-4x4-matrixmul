% Author: Ettore Napoli, University of Salerno
% Date:   2025-08
%
% function that implements LRP multiplication using the SLP representation
% Test real valued alphaevolve algorithm on random matrices
% A,B     : input 4x4 real-valued matrices.
% C       : output of the function that is B*A
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
function C = matmul_LRP_SLP(A, B)
% Implements 4x4 matrix multiplication using an LRP representation
    %
    % A, B : input 4x4 matrices
    % Output:
    %   C = A*B (computed via SLP - Straight Line Program of the LRP algorithm)
    
    % Form the intermediate linear combinations
    u = rational_R(A);   % combinations of A
    v = rational_L(B);   % combinations of B

    % Elementwise multiplications (bilinear products)
    w = u .* v;

    % Recombine into output vector
    C = rational_P(w);
end
