# Hardware Implementation of a AlphaEvolve Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication

Verilog code and MATLAB scripts for the hardware implementation of the **Real-valued 4×4 Rank-48 AlphaEvolve matrix multiplication algorithm described in [1]**. 

The provided code allows to reproduce the results provided in **[5]** and **[6]**.


## Contents

- `00_LRP_matrices/` — MATLAB implementation of the algorithm in [1] with the files containing the L, R, and P matrices. 
The algorithm is an evolution of the algorithm proposed by AlphaEvolve in **[3]**, and  **[4]**.

- `01_SLP` — Straight Line Program implementation of the algorithm taken from [1].  

- `02_HDL_proposed_circuit_wo_pipelining/` — SystemVerilog source files and testbenches for the complete matrix multiplication circuit. This version is fully combinatorial without I/O nor pipeline registers. **[5]** and **[6]**.

- `03_HDL_proposed_circuit_1_pipeline_level_AEDp1/` — SystemVerilog source files and testbenches for the complete matrix multiplication circuit.  This version contains I/O registers and one pipeline level.
It is the version proposed in  **[6]**.

- `04_HDL_proposed_circuit_2_pipeline_levels_AEDp2/` — SystemVerilog source files and testbenches for the complete matrix multiplication circuit. This version contains I/O registers and two pipeline level.  
It is the version proposed in  **[6]**.

- `05_HDL_naive_algorithm/` — SystemVerilog source files and testbenches for the implementation of the naive algorithm for matrix multiplication used as a baseline for the comparison with the proposed implementation.  
It is the version used in  **[5]** and **[6]**.

- `06_HDL_naive_algorithm/` — SystemVerilog source files and testbenches for the implementation of the naive algorithm for matrix multiplication used as a baseline for the comparison with the proposed implementation. 
It is the version used in  **[6]**.
 

- `LICENSE` — License file for the entire repository.  

- `README.md` — This file.  

## License

This project is licensed under the **CERN Open Hardware Licence v2 – Non-commercial (CERN-OHL-NC-2.0)**.  
You may use, modify, and share this work for personal, academic, or research purposes.  
Commercial use is prohibited without explicit permission from the author.  

- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## How to Cite

If you use this repository in your work, please cite it as: 
 
- Napoli E. *VLSI Implementation of AlphaEvolve Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication* 2026 IEEE 17th Latin American Symposium on Circuits & Systems (LASCAS), Arequipa, Peru. February 24-27 2026.
- Napoli E. *AlphaEvolve-Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication: 28 nm Implementation and Comparison with Strassen*. in IEEE Open Journal of Circuits and Systems, vol. XX, pp. xx-xx, 2026, doi: .
- Napoli, E. *Hardware Implementation of a AlphaEvolve Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication*. GitHub, 2025. Available at: [https://github.com/etnapoli/Hardware-implementation-real-valued-alphaEvolve-4x4-matrixmul](https://github.com/etnapoli/Hardware-implementation-real-valued-alphaEvolve-4x4-matrixmul)



## references
**[1]** J.-G. Dumas, C. Pernet, and A. Sedoglavic, “A non-commutative algorithm for multiplying 4×4 matrices using 48 non-complex multiplications,” arXiv preprint arXiv:2506.13242, June 16 2025.

**[2]** J.-G. Dumas, B. Grenet, C. Pernet, and A. Sedoglavic, 
 “Plinopt: A collection of C++ routines handling linear & bilinear programs,” 
  https://github.com/jgdumas/plinopt, Jan. 2024.
  
**[3]** A. Novikov, N. Vũ, M. Eisenberger, E. Dupont, P.-S. Huang, A. Z. Wagner, S. Shirobokov, B. Kozlovskii, F. J. R. Ruiz, A. Mehrabian, M. P. Kumar, A. See, S. Chaudhuri, G. Holland, A. Davies, S. Nowozin, P. Kohli, and M. Balog, “AlphaEvolve: A coding agent for scientific and algorithmic discovery,” 2025. [Online]. Available: https://arxiv.org/abs/2506.13131  

**[4]** Google DeepMind, “AlphaEvolve: Mathematical results,” 2025. [Online]. Available: https://colab.research.google.com/github/google-deepmind/alphaevolve_results/blob/master/mathematical_results.ipynb 

**[5]** Napoli E. *VLSI Implementation of AlphaEvolve Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication* 2026 IEEE 17th Latin American Symposium on Circuits & Systems (LASCAS), Arequipa, Peru, February 24-27 2026, pp. 1-4, doi: 10.1109/LASCAS67804.2026.11457084.

**[6]** Napoli E. *AlphaEvolve-Based Rank-48 Algorithm for 4×4 Real-Valued Matrix Multiplication: 28 nm Implementation and Comparison with Strassen*. in IEEE Open Journal of Circuits and Systems, vol. XX, pp. xx-xx, 2026, doi: 10.1109/OJCAS.2026.3727769.
