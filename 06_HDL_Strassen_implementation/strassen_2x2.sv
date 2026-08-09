// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// May 2026
// Description: Strassen algorithm for real-valued 2x2 matrix multiplication
module strassen_2x2 #(
    parameter W = 32
)(
    input  wire signed [W-1:0] A[0:3],
    input  wire signed [W-1:0] B[0:3],
    output wire signed [2*W:0] C[0:3]  // allow for full overflow range. Output on 2*W+1 bits
);
    // Local declarations for matrix elements
    wire signed [W-1:0] a11 = A[0];
    wire signed [W-1:0] a12 = A[1];
    wire signed [W-1:0] a21 = A[2];
    wire signed [W-1:0] a22 = A[3];

    wire signed [W-1:0] b11 = B[0];
    wire signed [W-1:0] b12 = B[1];
    wire signed [W-1:0] b21 = B[2];
    wire signed [W-1:0] b22 = B[3];
	 //  C extended by one bit
	 wire signed [2*W+1:0] C_ext[0:3];
	 
    // Intermediate products (2*W bits + 2)
    wire signed [2*W+1:0] M1; // w=3 inputs [-4,3] output max: (-4-4)*(-4-4)=64, min (-4-4)*(3+3)=-48 => 8 bit  
    // Intermediate products (2*W bits + 1)
    wire signed [2*W:0] M2; // w=3 inputs [-4,3] output max: (-4+(-4))*(-4)=32, min (-4+(-4))*(3)=-24 => 7 bit  
    wire signed [2*W:0] M5; // w=3 inputs [-4,3] output max: (-4+(-4))*(-4)=32, min (-4+(-4))*(3)=-24 => 7 bit
    wire signed [2*W:0] M6; // w=3 inputs [-4,3] output max: (-4-(+3))*(-4-4)=56, min (3-(-4))*(-4-4)=-56 => 7 bit  
    wire signed [2*W:0] M7; // w=3 inputs [-4,3] output max: (-4-(+3))*(-4-4)=56, min (3-(-4))*(-4-4)=-56 => 7 bit
    // Intermediate products (2*W bits)
	 wire signed [2*W-1:0] M3; // w=3 inputs [-4,3] output max: (-4)*(-4-(+3))=28, min (-4)*(3-(-4))=-28 => 6 bit
    wire signed [2*W-1:0] M4; // w=3 inputs [-4,3] output max: (-4)*(-4-(+3))=28, min (-4)*(3-(-4))=-28 => 6 bit  

    assign M1 = (a11 + a22) * (b11 + b22);
    assign M2 = (a21 + a22) * b11;
    assign M3 = a11 * (b12 - b22);
    assign M4 = a22 * (b21 - b11);
    assign M5 = (a11 + a12) * b22;
    assign M6 = (a21 - a11) * (b11 + b12);
    assign M7 = (a12 - a22) * (b21 + b22);

    // Final result computation (2W+1 bits)
    assign C_ext[0] = M1 + M4 - M5 + M7;  // w 3bit max:  (-4)*(-4)+(-4)*(-4)=32   min: (-4)*(+3)+(-4)*(+3)=-24 => 7 bit 
    assign C_ext[1] = M3 + M5;
    assign C_ext[2] = M2 + M4;
    assign C_ext[3] = M1 - M2 + M3 + M6;

    assign C[0] = C_ext[0][2*W:0];  
    assign C[1] = C_ext[1][2*W:0];  
    assign C[2] = C_ext[2][2*W:0];  
    assign C[3] = C_ext[3][2*W:0];  

endmodule
