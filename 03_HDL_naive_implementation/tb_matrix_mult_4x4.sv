// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// August 2025
// Description: Naive algorithm for real-valued matrix multiplication
`timescale 1ns / 1ps

module tb_matrix_mult_4x4();

    parameter w = 32;
    parameter WIDTH_OUT = 2*w + 2;

    logic signed [w-1:0] A [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [w-1:0] B [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [WIDTH_OUT-1:0] C [0:3][0:3];

	 // 128 bit values read from file
    logic signed [127:0] A128 [0:3][0:3], B128 [0:3][0:3],golden_C128 [0:3][0:3];
    logic signed [WIDTH_OUT-1:0] golden_C [0:3][0:3];
    logic signed [127:0] tmp128;
	 

    // DUT instantiation
    matrix_mult_4x4 #(.w(w)) dut (
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
	file = $fopen("../../golden_values.txt", "r");
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

	// extract the 128 bit and 'w' bit values for A,B and golden_C
	for (i = 0; i < 4; i = i + 1)
		for (j = 0; j < 4; j = j + 1)
		begin
			substrA = line.substr(38+(i*668)+(j*167), 38+(i*668)+(j*167)+127);
			substrB = line.substr(2710+(i*668)+(j*167), 2710+(i*668)+(j*167)+127);
			substrC = line.substr(5382+(i*668)+(j*167), 5382+(i*668)+(j*167)+127);
			for (k = 0; k < 128; k++)
			begin
				if (substrA[k] == "1") 
					tmp128[127 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrA[k] == "0")	tmp128[127 - k] = 1'b0;
					else	tmp128[127 - k] = 1'bx;
			end
			A128[i][j]=tmp128;	
//			$display("A128[%0d][%0d]: %b", i, j, A128[i][j]);
			A[i][j]=A128[i][j][w-1:0];	
//			$display("A[%0d][%0d]: %b", i, j, A[i][j]);
						
			for (k = 0; k < 128; k++)
			begin
				if (substrB[k] == "1") 
					tmp128[127 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrB[k] == "0")	tmp128[127 - k] = 1'b0;
					else	tmp128[127 - k] = 1'bx;
			end
			B128[i][j]=tmp128;	
//			$display("B128[%0d][%0d]: %b", i, j, B128[i][j]);
			B[i][j]=B128[i][j][w-1:0];	
//			$display("B[%0d][%0d]: %b", i, j, B[i][j]);
			
			for (k = 0; k < 128; k++)
			begin
				if (substrC[k] == "1") 
					tmp128[127 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrC[k] == "0")	tmp128[127 - k] = 1'b0;
					else	tmp128[127 - k] = 1'bx;
			end
			golden_C128[i][j]=tmp128;	
//			$display("golden_C128[%0d][%0d]: %b", i, j, golden_C128[i][j]);
			golden_C[i][j]=golden_C128[i][j][WIDTH_OUT-1:0];	
//			$display("golden_C[%0d][%0d]: %b", i, j, golden_C[i][j]);
//			$stop;
		end	
	//  simulate
	#10;
	// Compare DUT output with golden_C
	for (int i = 0; i < 4; i++)
		for (int j = 0; j < 4; j++)
			if (C[i][j] !== golden_C[i][j])
			begin
				$display("Mismatch in test %0d at C[%0d][%0d]: DUT=%0d, GOLD=%0d", test, i, j, C[i][j], golden_C[i][j]);
				error_count++;
        end
	
	end
	
	$fclose(file);
	if (error_count == 0)
		$display("All tests passed!");
	else
		$display("%0d mismatches found.", error_count);

	$stop;
end

endmodule
