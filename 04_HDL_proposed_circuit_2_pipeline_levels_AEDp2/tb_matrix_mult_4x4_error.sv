// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// May 2026
// Description: Testbench module. Naive algorithm for real-valued matrix multiplication. Uses two levels of pipelining.

`timescale 1ns / 1ps

module tb_matrix_mult_4x4();

    parameter w = 64;
    parameter WIDTH_OUT = 2*w + 2;
    localparam period=10000;

    reg clk, reset;
    logic signed [w-1:0] A [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [w-1:0] B [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [WIDTH_OUT-1:0] C [0:3][0:3];

	 // 550 bit values read from file
    logic signed [549:0] A550 [0:3][0:3], B550 [0:3][0:3],golden_C550 [0:3][0:3];
    logic signed [WIDTH_OUT-1:0] golden_C [0:3][0:3];
    logic signed [549:0] tmp550;
	 

    // DUT instantiation
    matrix_mult_4x4 #(.w(w)) dut (
        .A(A),
        .B(B),
        .C(C), .clk(clk), .reset(reset)
    ); 

int file, file_output;
string line;
string substrA,substrB,substrC;
int i,j,k;
int error_count;
int test;

always
begin
	clk = 1'b0; #(period/2.0);
	clk = 1'b1; #(period/2.0);
end

initial begin
	file = $fopen("../../golden_values_8bit_ver_3035_test_vectors.txt", "r");
	if (file == 0)
	begin
		$display("ERROR: Cannot open file.");
		$finish;
	end

	error_count = 0;
	test = 0;
	
	// initialize inputs and apply reset
	for (i = 0; i < 4; i = i + 1)
		for (j = 0; j < 4; j = j + 1)
		begin
			A[i][j]={w{1'b0}};	
			B[i][j]={w{1'b0}};	
		end
	reset = 1'b1;
	#period;
	// disable reset
	reset = 1'b0;
	#period


	// Loop until EOF
	while ($fgets(line, file))
	begin
	test = test +1;
	    if (test % 100 == 0)
        	$display("Progress: %0d tests completed at time %0t", test, $time);

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
			A[i][j]=A550[i][j][w-1:0];	
						
			for (k = 0; k < 550; k++)
			begin
				if (substrB[k] == "1") 
					tmp550[549 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrB[k] == "0")	tmp550[549 - k] = 1'b0;
					else	tmp550[549 - k] = 1'bx;
			end
			B550[i][j]=tmp550;	
			B[i][j]=B550[i][j][w-1:0];	
			
			for (k = 0; k < 550; k++)
			begin
				if (substrC[k] == "1") 
					tmp550[549 - k] = 1'b1;   // Store MSB at left (big endian)
				else 
					if (substrC[k] == "0")	tmp550[549 - k] = 1'b0;
					else	tmp550[549 - k] = 1'bx;
			end
			golden_C550[i][j]=tmp550;	
			golden_C[i][j]=golden_C550[i][j][WIDTH_OUT-1:0];	
		end	
	//  simulate.  Simulate a number of clock cycles equal or higher to the latency
	#(5*period);
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
	file_output = $fopen("./error_output.txt", "w");
	if (error_count == 0)
		 $fwrite(file_output,"All tests passed!\n");
	else
		 $fwrite(file_output,"%0d mismatches found.\n", error_count);
	$fclose(file_output);
	$finish;
end

endmodule
