# Matlab implementation of the Straight Line Program of the AlphaEvolve Algorithm for 4x4 real-Valued Matrix Multiplication proposed in [1] 

This directory contains the matlab implementation of SLP reported in **[1], [2]**.  

## Overview

The implemented algorithm performs 4x4 real-valued matrix multiplication using a modified version of the algorithm proposed in **[3]** and **[4]**.  
The matlab code implements the SLP algorithm and provides a test script.

## Contents

- `rational_L.m`,`rational_R.m`, `rational_P.m`  
  The matlab implementation of the transformations implemented by the L, Rl, and P, matrices.
  
- `matmul_LRP_SLP.m`  
  The matlab function that implements the SLP for the matrix multiplication.

- `test_LRP_SLP.m`  
  The matlab script that tests the algorithm feeding random inputs.

- `README.md` — this file.  

## Running in matlab
- **Modify the script:**  
  Set the number of random test in `test_LRP_SLP.m` and comment the appropriate lines to choose between integer or real input values.

- **Run the script**  
  At the matlab command prompt, while being the in directory where `rational_L`, `rational_R`, `rational_P`,  `matmul_LRP_SLP.m` and `test_LRP_SLP.m`  files are located run:
  test_LRP_SLP


## References

**[1]** J.-G. Dumas, C. Pernet, and A. Sedoglavic, “A non-commutative algorithm for multiplying 4×4 matrices using 48 non-complex multiplications,” arXiv preprint arXiv:2506.13242, June 16 2025.

**[2]** J.-G. Dumas, B. Grenet, C. Pernet, and A. Sedoglavic, 
 “Plinopt: A collection of C++ routines handling linear & bilinear programs,” 
  https://github.com/jgdumas/plinopt, Jan. 2024.
  
**[3]** A. Novikov, N. Vũ, M. Eisenberger, E. Dupont, P.-S. Huang, A. Z. Wagner, S. Shirobokov, B. Kozlovskii, F. J. R. Ruiz, A. Mehrabian, M. P. Kumar, A. See, S. Chaudhuri, G. Holland, A. Davies, S. Nowozin, P. Kohli, and M. Balog, “AlphaEvolve: A coding agent for scientific and algorithmic discovery,” 2025. [Online]. Available: https://arxiv.org/abs/2506.13131  

**[4]** Google DeepMind, “AlphaEvolve: Mathematical results,” 2025. [Online]. Available: https://colab.research.google.com/github/google-deepmind/alphaevolve_results/blob/master/mathematical_results.ipynb  

## License

This code is released under the **MIT License**. See the `LICENSE` file for details.  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

