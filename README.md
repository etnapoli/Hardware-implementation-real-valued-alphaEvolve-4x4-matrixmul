# VLSI Implementation of a AlphaEvolve Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication

Verilog code and MATLAB scripts for the hardware implementation of the **Real-valued 4×4 Rank-48 AlphaEvolve matrix multiplication algorithm described in [1]**.  

## Contents

- `00_LRP_matrices/` — MATLAB implementation of the algorithm in [1] with files with the RLP matrices.  

- `01_SLP` — Straight Line Program implementation of the algorithm takne by [1].  

- `02_HDL_proposed_circuit/` — SystemVerilog source files and testbenches for the complete matrix multiplication circuit.   

- `03_HDL_naive_algorithm/` — SystemVerilog source files and testbenches for the implementation of the naive algorithm for matrix multiplication used as a base test for the proposed implementation.  

- `LICENSE` — License file for the entire repository.  

- `README.md` — This file.  

## License

This project is licensed under the **CERN Open Hardware Licence v2 – Non-commercial (CERN-OHL-NC-2.0)**.  
You may use, modify, and share this work for personal, academic, or research purposes.  
Commercial use is prohibited without explicit permission from the author.  

- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## How to Cite

If you use this repository in your work, please cite it as:  

- Napoli, E. *Hardware Implementation of the AlphaEvolve 4×4 Matrix Multiplication Algorithm*. GitHub, 2025. Available at: [https://github.com/etnapoli/Hardware-implementation-real-valued-alphaEvolve-4x4-matrixmul](https://github.com/etnapoli/Hardware-implementation-real-valued-alphaEvolve-4x4-matrixmul)


## references
[1] J.-G. Dumas, C. Pernet, and A. Sedoglavic, “A non-commutative algorithm for multiplying 4×4 matrices using 48 non-complex multiplications,” arXiv preprint arXiv:2506.13242, June 16 2025.