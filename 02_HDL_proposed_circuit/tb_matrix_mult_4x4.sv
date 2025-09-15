// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// September 2025
// Description: Naive algorithm for real-valued matrix multiplication
`timescale 1ns / 1ps

module tb_matrix_mult_4x4();

    parameter w = 8;
    parameter WIDTH_OUT = 2*w + 2;
	localparam period=10000;

    logic signed [w-1:0] A [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [w-1:0] B [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [WIDTH_OUT-1:0] C [0:3][0:3];

	 // 550 bit values read from file
    logic signed [549:0] A550 [0:3][0:3], B550 [0:3][0:3],golden_C550 [0:3][0:3];
    logic signed [WIDTH_OUT-1:0] golden_C [0:3][0:3];
    logic signed [549:0] tmp550;
	 

    // DUT instantiation
    matrix_mult_4x4_alphaevolve_dumas #(.w(w)) dut (
        .A(A),
        .B(B),
        .C(C)
    );

int file;
string line,substrA,substrB,substrC;
int i,j,k;
int error_count;
int test;

initial begin
	file = $fopen("../../golden_values_8bit_ver_3035_test_vectors.txt", "r");
	if (file == 0)
	begin
		$display("ERROR: Cannot open file.");
		$finish;
	end

	error_count = 0;
	test = 0;
	// Loop until EOF
	while ($fgets(line, file))
	begin
	test ++;
	$display("Test n.: %0d", test);
//	$display("Line read as string: %s", line);

	// extract the 550 bit and 'w' bit values for A,B and golden_C
	for (i = 0; i < 4; i = i + 1)
		for (j = 0; j < 4; j = j + 1)
		begin
			substrA = line.substr(209+(i*3040)+(j*760), 209+(i*3040)+(j*760)+549);
			substrB = line.substr(12369+(i*3040)+(j*760), 12369+(i*3040)+(j*760)+549);
			substrC = line.substr(24529+(i*3040)+(j*760), 24529+(i*3040)+(j*760)+549);
			for (k = 0; k < 550; k++)
			begin
				if (substrA[k] == "1") 
					tmp550[549 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrA[k] == "0")	tmp550[549 - k] = 1'b0;
					else	tmp550[549 - k] = 1'bx;
			end
			A550[i][j]=tmp550;	
//			$display("A550[%0d][%0d]: %b", i, j, A550[i][j]);
			A[i][j]=A550[i][j][w-1:0];	
//			$display("A[%0d][%0d]: %b", i, j, A[i][j]);
						
			for (k = 0; k < 550; k++)
			begin
				if (substrB[k] == "1") 
					tmp550[549 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrB[k] == "0")	tmp550[549 - k] = 1'b0;
					else	tmp550[549 - k] = 1'bx;
			end
			B550[i][j]=tmp550;	
//			$display("B550[%0d][%0d]: %b", i, j, B550[i][j]);
			B[i][j]=B550[i][j][w-1:0];	
//			$display("B[%0d][%0d]: %b", i, j, B[i][j]);
			
			for (k = 0; k < 550; k++)
			begin
				if (substrC[k] == "1") 
					tmp550[549 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrC[k] == "0")	tmp550[549 - k] = 1'b0;
					else	tmp550[549 - k] = 1'bx;
			end
			golden_C550[i][j]=tmp550;	
//			$display("golden_C550[%0d][%0d]: %b", i, j, golden_C550[i][j]);
			golden_C[i][j]=golden_C550[i][j][WIDTH_OUT-1:0];	
//			$display("golden_C[%0d][%0d]: %b", i, j, golden_C[i][j]);
//			$stop;
		end	
	//  simulate
	#period;
	// Compare DUT output with golden_C
	for (int i = 0; i < 4; i++)
		for (int j = 0; j < 4; j++)
			if (C[i][j] !== golden_C[i][j])
			begin
				$display("Mismatch in test %0d at C[%0d][%0d]: DUT=%0d, GOLD=%0d", test, i, j, C[i][j], golden_C[i][j]);
				error_count++;
        end
		/*=========================================
		if ((test==2)|(test==1))
		begin
			$display("line: %s",line);
			for (int i = 0; i < 4; i++)
					begin
						$display("A[%0d][1:3]: %0d, %0d , %0d , %0d ", i,
						A[i][0],A[i][1],A[i][2],A[i][3]);
					end
			for (int i = 0; i < 4; i++)
					begin
						$display("B[%0d][1:3]: %0d, %0d , %0d , %0d ", i,
						B[i][0],B[i][1],B[i][2],B[i][3]);
					end
			for (int i = 0; i < 4; i++)
					begin
						$display("C[%0d][1:3]: %0d, %0d , %0d , %0d ", i,
						C[i][0],C[i][1],C[i][2],C[i][3]);
					end
			for (int i = 0; i < 4; i++)
					begin
						$display("golden_C[%0d][1:3]: %0d , %0d , %0d , %0d ", i,
						golden_C[i][0],golden_C[i][1],golden_C[i][2],golden_C[i][3]);
					end
		end */ 
//		if (test==2) $stop;		

	end
	
	$fclose(file);
	if (error_count == 0)
		$display("All tests passed!");
	else
		$display("%0d mismatches found.", error_count);

	$stop;
end

endmodule
