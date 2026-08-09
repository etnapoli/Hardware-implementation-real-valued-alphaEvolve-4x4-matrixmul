# Test_Vectors_files Directory

This folder contains the files with the test vectors for the implementation of the naive algorithm for 4x4 real-valued matrix multiplication.
In this directory only one STUB file is provided to reduce the dimension of the repository.
The complete set of test vectors for all the tested **w** values are in the directory 
`\02_HDL_proposed_circuit_wo_pipelining\Test_Vectors_files`.


## Contents
- `golden_values_4bit_STUB.txt` — STUB file with test vectors for the **w** value of 4.

In the directory containing the complete set of files nine test vectorfiles are provided corresponding to different input bit-widths **w**. 
  - `golden_values_04bit_ver_3019_test_vectors.txt` — 4-bit input elements  
  - `golden_values_08bit_ver_3035_test_vectors.txt` — 8-bit input elements  
  - `golden_values_16bit_ver_3067_test_vectors.txt` — 16-bit input elements  
  - `golden_values_24bit_ver_3099_test_vectors.txt` — 24-bit input elements  
  - `golden_values_32bit_ver_3131_test_vectors.txt` — 32-bit input elements  
  - `golden_values_48bit_ver_3195_test_vectors.txt` — 48-bit input elements  
  - `golden_values_53bit_ver_3215_test_vectors.txt` — 53-bit input elements  
  - `golden_values_64bit_ver_3259_test_vectors.txt` — 64-bit input elements  
  - `golden_values_128bit_ver_3515_test_vectors.txt` — 128-bit input elements  

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
