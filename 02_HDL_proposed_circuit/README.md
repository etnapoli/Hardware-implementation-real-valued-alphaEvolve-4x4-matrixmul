# HDL Directory

This folder contains the SystemVerilog source code for the implementation of the AlphaEvolve  algorithm for 4x4 real-valued matrix multiplication.

** CODE IS HIDDEN AND WILL BE RELEASED AFTER THE PAPER RELATED TO THIS WORK HAS BEEN ACCEPTED**

## Contents
- `matrix_mult_4x4_alphaevolve_dumas.sv` — SystemVerilog description of the proposed implementation of the AlphaEvolve algorithm for 4×4 real-valued matrix multiplication described in **[1]** and **[2]**.  
  The code is parameterized on **w**, which is the number of bits used for the 2's complement representation of the input matrix elements.  

- `tb_matrix_mult_4x4.sv` — testbench for simulation.  
  Tests have been run for **w** values of 4, 8, 16, 24, 32, 48, 53, and 64.  
  Please note that the provided testbench expects to find the test vector files **two directories above its location** (`../../`).  
  If this is not the case, correct line 50 of the testbench accordingly.     

- `Test_Vectors_files/` — directory containing the test vector files for the circuit.  
  Five files are provided, corresponding to different input bit-widths:  
  - `golden_values_04bit_ver_3019_test_vectors.txt` — 4-bit input elements  
  - `golden_values_08bit_ver_3035_test_vectors.txt` — 8-bit input elements  
  - `golden_values_16bit_ver_3067_test_vectors.txt` — 16-bit input elements  
  - `golden_values_24bit_ver_3099_test_vectors.txt` — 24-bit input elements  
  - `golden_values_32bit_ver_3131_test_vectors.txt` — 32-bit input elements  
  - `golden_values_48bit_ver_3195_test_vectors.txt` — 48-bit input elements  
  - `golden_values_53bit_ver_3215_test_vectors.txt` — 53-bit input elements  
  - `golden_values_64bit_ver_3259_test_vectors.txt` — 64-bit input elements  

- `README.md` — this file.  

## Notes
- Testbenches have been verified with:
  - **Questa Intel Starter FPGA Edition-64 2021.2** (bundled with **Quartus Prime 22.1 Lite**)  
  - **Cadence Xcelium Simulator 20.09-s001** (bundled with Cadence)


##  References
**[1]** J.-G. Dumas, C. Pernet, and A. Sedoglavic, “A non-commutative algorithm for multiplying 4×4 matrices using 48 non-complex multiplications,” arXiv preprint arXiv:2506.13242, June 16 2025.

**[2]** J.-G. Dumas, B. Grenet, C. Pernet, and A. Sedoglavic, 
 “Plinopt: A collection of C++ routines handling linear & bilinear programs,” 
  https://github.com/jgdumas/plinopt, Jan. 2024.

## License

This code is released under the **MIT License**. See the `LICENSE` file for details.  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
