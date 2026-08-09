// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// May 2026
// Description: Strassen algorithm for real-valued 4x4 matrix multiplication
module strassen_4x4 #(
    parameter w = 8
)(
    input  wire signed [w-1:0] A [0:3][0:3],
    input  wire signed [w-1:0] B [0:3][0:3],
    output wire signed [2*w+1:0] C [0:3][0:3]    // 2*w+2 bits
);
    // 2x2 submatrices 
    wire signed [w-1:0] A11[0:3], A12[0:3], A21[0:3], A22[0:3];
    wire signed [w-1:0] B11[0:3], B12[0:3], B21[0:3], B22[0:3];
	 
	 // 2x2 submatrice extended to W+1 bits
	 wire signed [w:0] B11_ext[0:3], A11_ext[0:3], A22_ext[0:3], B22_ext[0:3];
    
	 assign {A11[0], A11[1], A11[2], A11[3]} = {A[0][0], A[0][1], A[1][0], A[1][1]};
    assign {A12[0], A12[1], A12[2], A12[3]} = {A[0][2], A[0][3], A[1][2], A[1][3]};
    assign {A21[0], A21[1], A21[2], A21[3]} = {A[2][0], A[2][1], A[3][0], A[3][1]};
    assign {A22[0], A22[1], A22[2], A22[3]} = {A[2][2], A[2][3], A[3][2], A[3][3]};

    assign {B11[0], B11[1], B11[2], B11[3]} = {B[0][0], B[0][1], B[1][0], B[1][1]};
    assign {B12[0], B12[1], B12[2], B12[3]} = {B[0][2], B[0][3], B[1][2], B[1][3]};
    assign {B21[0], B21[1], B21[2], B21[3]} = {B[2][0], B[2][1], B[3][0], B[3][1]};
    assign {B22[0], B22[1], B22[2], B22[3]} = {B[2][2], B[2][3], B[3][2], B[3][3]};
	 

    // Intermediate results for M1-M7
    wire signed [2*w+2:0] M1[0:3];
    wire signed [2*w+1:0] M2[0:3], M5[0:3], M6[0:3], M7[0:3];
    wire signed [2*w  :0] M3[0:3], M4[0:3];
    // Intermediate results for M1-M7 extended to connect to strassen_2x2
    wire signed [2*w+2:0] M2_ext[0:3], M3_ext[0:3], M4_ext[0:3], M5_ext[0:3], M6_ext[0:3], M7_ext[0:3];
 	
    // Temporary results for adds/subs
    wire signed [w:0] S1[0:3], S2[0:3], S3[0:3], S4[0:3], S5[0:3];
    wire signed [w:0] T1[0:3], T2[0:3], T3[0:3], T4[0:3], T5[0:3];

    // M1 = (A11 + A22) * (B11 + B22)
    matrix_add_2x2 #(w) add1 (.A(A11), .B(A22), .C(S1));  // S1 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2]  
																			 // W 3bit A,B [-4,3] 	S1 in [-8,6]
    matrix_add_2x2 #(w) add2 (.A(B11), .B(B22), .C(T1));  // T1 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2]
    																		 // W 3bit A,B [-4,3] 	T1 in [-8,6]
    strassen_2x2 #(w+1) mul1 (.A(S1), .B(T1), .C(M1));  // M1 is on 2(W+1)+1 bits = 2W+3 bits
																		  // W 3bit S1,T1 [-8,6]  M1 [-96,128]  9bit
    // M2 = (A21 + A22) * B11
    matrix_add_2x2 #(w) add3 (.A(A21), .B(A22), .C(S2));  // S2 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2]  
																			 // W 3bit A,B [-4,3] 	S2 in [-8,6]
	 assign B11_ext[0] = $signed(B11[0]);
	 assign B11_ext[1] = $signed(B11[1]);
	 assign B11_ext[2] = $signed(B11[2]);
	 assign B11_ext[3] = $signed(B11[3]);																			 
    strassen_2x2 #(w+1) mul2 (.A(S2), .B(B11_ext), .C(M2_ext)); // M2 is on 2(W+1) bits = 2W+2 bits
		      															       // W 3bit S2 in [-8,6], B11 [-4,3]  M2 [-48,64] 8bit
	 assign M2[0]=M2_ext[0][2*w+1:0];	// cut one bit
	 assign M2[1]=M2_ext[1][2*w+1:0];	
	 assign M2[2]=M2_ext[2][2*w+1:0];	
	 assign M2[3]=M2_ext[3][2*w+1:0];
	 
    // M3 = A11 * (B12 - B22)
    matrix_sub_2x2 #(w) sub1 (.A(B12), .B(B22), .C(T2));  // T2 on W+1 bits but limited to [-2^W+1,2^W-1]
																			 // W 3bit A,B [-4,3] 	T2 in [-7,7]
	 assign A11_ext[0] = $signed(A11[0]);
	 assign A11_ext[1] = $signed(A11[1]);
	 assign A11_ext[2] = $signed(A11[2]);
	 assign A11_ext[3] = $signed(A11[3]);																			 
    strassen_2x2 #(w+1) mul3 (.A(A11_ext), .B(T2), .C(M3_ext));  // M3 is on 2(W+1)+1 bits = 2W+3 bits
																		           // W 3bit T2 in [-7,7], A11 [-4,3]  M3 [-56,56] 7bit
	 assign M3[0]=M3_ext[0][2*w  :0];	// cut two bits
	 assign M3[1]=M3_ext[1][2*w  :0];	
	 assign M3[2]=M3_ext[2][2*w  :0];	
	 assign M3[3]=M3_ext[3][2*w  :0];

    // M4 = A22 * (B21 - B11)
    matrix_sub_2x2 #(w) sub2 (.A(B21), .B(B11), .C(T3)); // T3 on W+1 bits but limited to [-2^W+1,2^W-1]
  																		   // W 3bit A,B [-4,3] 	T3 in [-7,7]
	 assign A22_ext[0] = $signed(A22[0]);
	 assign A22_ext[1] = $signed(A22[1]);
	 assign A22_ext[2] = $signed(A22[2]);
	 assign A22_ext[3] = $signed(A22[3]);																			 
    strassen_2x2 #(w+1) mul4 (.A(A22_ext), .B(T3), .C(M4_ext)); // M4 is on 2(W+1)+1 bits = 2W+3 bits
																		          // W 3bit T3 in [-7,7], A22 [-4,3] M4 [-56,56] 7bit
	 assign M4[0]=M4_ext[0][2*w  :0];	// cut two bits
	 assign M4[1]=M4_ext[1][2*w  :0];	
	 assign M4[2]=M4_ext[2][2*w  :0];	
	 assign M4[3]=M4_ext[3][2*w  :0];

    // M5 = (A11 + A12) * B22
    matrix_add_2x2 #(w) add4 (.A(A11), .B(A12), .C(S3)); // S3 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2] 
  																		   // W 3bit A,B [-4,3] 	S3 in [-8,6]
	 assign B22_ext[0] = $signed(B22[0]);
	 assign B22_ext[1] = $signed(B22[1]);
	 assign B22_ext[2] = $signed(B22[2]);
	 assign B22_ext[3] = $signed(B22[3]);																			 
    strassen_2x2 #(w+1) mul5 (.A(S3), .B(B22_ext), .C(M5_ext)); //  M5 is on 2(W+1) bits = 2W+2 bits
																		  // W 3bit S3 in [-8,6], B22 [-4,3] M5 [-48,64] 8bit

	 assign M5[0]=M5_ext[0][2*w+1:0];	// cut one bit
	 assign M5[1]=M5_ext[1][2*w+1:0];	
	 assign M5[2]=M5_ext[2][2*w+1:0];	
	 assign M5[3]=M5_ext[3][2*w+1:0];

    // M6 = (A21 - A11) * (B11 + B12)
    matrix_sub_2x2 #(w) sub3 (.A(A21), .B(A11), .C(S4)); // S4 on W+1 bits but limited to [-2^W+1,2^W-1]
																			// W 3bit A,B [-4,3] 	S4 in [-7,7] 	 
    matrix_add_2x2 #(w) add5 (.A(B11), .B(B12), .C(T4)); // T4 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2]
   																		// W 3bit A,B [-4,3] 	T4 in [-8,6]
    strassen_2x2 #(w+1) mul6 (.A(S4), .B(T4), .C(M6_ext));  //  M6 is on 2(W+1) bits = 2W+2 bits
																		// W 3bit T4 in [-8,6], S4 [-7,7] M5 [-112,112] 8bit 
	 assign M6[0]=M6_ext[0][2*w+1:0];	// cut one bit
	 assign M6[1]=M6_ext[1][2*w+1:0];	
	 assign M6[2]=M6_ext[2][2*w+1:0];	
	 assign M6[3]=M6_ext[3][2*w+1:0];

    // M7 = (A12 - A22) * (B21 + B22)
    matrix_sub_2x2 #(w) sub4 (.A(A12), .B(A22), .C(S5)); // S5 on W+1 bits but limited to [-2^W+1,2^W-1]
																			// W 3bit A,B [-4,3] 	S5 in [-7,7] 
    matrix_add_2x2 #(w) add6 (.A(B21), .B(B22), .C(T5)); // T5 on W+1 bits but limited to 2*[-2^(W-1),2^(W-1)-1]=[-2^W,2^W-2]
   																		// W 3bit A,B [-4,3] 	T5 in [-8,6]
    strassen_2x2 #(w+1) mul7 (.A(S5), .B(T5), .C(M7_ext));  //  M7 is on 2(W+1) bits = 2W+2 bits
																		// W 3bit T5 in [-8,6], S4 [-7,7] M7 [-112,112] 8bit

	 assign M7[0]=M7_ext[0][2*w+1:0];	// cut one bit
	 assign M7[1]=M7_ext[1][2*w+1:0];	
	 assign M7[2]=M7_ext[2][2*w+1:0];	
	 assign M7[3]=M7_ext[3][2*w+1:0];

    // Compute final submatrices
    wire signed [2*w+1:0] C11[0:3], C12[0:3], C21[0:3], C22[0:3];
	 // extended C values
    wire signed [2*w+2:0] C11_ext[0:3], C12_ext[0:3],  C22_ext[0:3];

    // C11 = M1 + M4 - M5 + M7
	 assign C11_ext[0] = M1[0] + M4[0] - M5[0] + M7[0];  // min: (-96)+(-56)-(+64)+(-112) =-328   max: 128+56-(-48)+112 = 344   w=3 => 10 bit. But since the values are correlated we know that [-48,64] w=3 => 8 bit
	 assign C11_ext[1] = M1[1] + M4[1] - M5[1] + M7[1];
	 assign C11_ext[2] = M1[2] + M4[2] - M5[2] + M7[2];
	 assign C11_ext[3] = M1[3] + M4[3] - M5[3] + M7[3];
 	 assign C11[0] = C11_ext[0][2*w+1:0];   
 	 assign C11[1] = C11_ext[1][2*w+1:0];   
 	 assign C11[2] = C11_ext[2][2*w+1:0];   
 	 assign C11[3] = C11_ext[3][2*w+1:0];   

	 // C12 = M3 + M5
	 assign C12_ext[0] = M3[0] + M5[0]; 
	 assign C12_ext[1] = M3[1] + M5[1];
	 assign C12_ext[2] = M3[2] + M5[2];
	 assign C12_ext[3] = M3[3] + M5[3];
 	 assign C12[0] = C12_ext[0][2*w+1:0];   
 	 assign C12[1] = C12_ext[1][2*w+1:0];   
 	 assign C12[2] = C12_ext[2][2*w+1:0];   
 	 assign C12[3] = C12_ext[3][2*w+1:0];   

    // C21 = M2 + M4
	 assign C21[0] = M2[0] + M4[0]; 
	 assign C21[1] = M2[1] + M4[1];
	 assign C21[2] = M2[2] + M4[2];
	 assign C21[3] = M2[3] + M4[3];

    // C22 = M1 - M2 + M3 + M6
	 assign C22_ext[0] = M1[0] - M2[0] + M3[0] + M6[0];
	 assign C22_ext[1] = M1[1] - M2[1] + M3[1] + M6[1];
	 assign C22_ext[2] = M1[2] - M2[2] + M3[2] + M6[2];
	 assign C22_ext[3] = M1[3] - M2[3] + M3[3] + M6[3];
 	 assign C22[0] = C22_ext[0][2*w+1:0];   
 	 assign C22[1] = C22_ext[1][2*w+1:0];   
 	 assign C22[2] = C22_ext[2][2*w+1:0];   
 	 assign C22[3] = C22_ext[3][2*w+1:0];   

    // Combine result into 4x4 matrix C
	 assign C[0][0] = C11[0];
	 assign C[0][1] = C11[1];
	 assign C[1][0] = C11[2];
	 assign C[1][1] = C11[3];

	 assign C[0][2] = C12[0];
	 assign C[0][3] = C12[1];
	 assign C[1][2] = C12[2];
	 assign C[1][3] = C12[3];

	 assign C[2][0] = C21[0];
	 assign C[2][1] = C21[1];
	 assign C[3][0] = C21[2];
	 assign C[3][1] = C21[3];

	 assign C[2][2] = C22[0];
	 assign C[2][3] = C22[1];
	 assign C[3][2] = C22[2];
	 assign C[3][3] = C22[3];

endmodule



module matrix_add_2x2 #(
    parameter w = 8
)(
    input  wire signed [w-1:0] A [0:3],
    input  wire signed [w-1:0] B [0:3],
    output wire signed [w:0]   C [0:3]  // Result width is w+1 to accommodate overflow
);
    assign C[0] = A[0] + B[0];
    assign C[1] = A[1] + B[1];
    assign C[2] = A[2] + B[2];
    assign C[3] = A[3] + B[3];
endmodule


module matrix_sub_2x2 #(
    parameter w = 8
)(
    input  wire signed [w-1:0] A [0:3],
    input  wire signed [w-1:0] B [0:3],
    output wire signed [w:0]   C [0:3]  // Result width is w+1 to accommodate overflow
);
    assign C[0] = A[0] - B[0];
    assign C[1] = A[1] - B[1];
    assign C[2] = A[2] - B[2];
    assign C[3] = A[3] - B[3];
endmodule
