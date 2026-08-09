// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// May 2026
// Description: Testbench module. Strassen algorithm for real-valued 4x4 matrix multiplication
`timescale 1ns / 1ps

module tb_strassen_4x4();

    parameter w = 32;
    parameter WIDTH_OUT = 2*w + 2;

    logic signed [w-1:0] A [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [w-1:0] B [0:3][0:3];  // rows, columns. Matlab notation
    logic signed [WIDTH_OUT-1:0] C [0:3][0:3];

	 // 128 bit values read from file
    logic signed [127:0] A128 [0:3][0:3], B128 [0:3][0:3],golden_C128 [0:3][0:3];
    logic signed [WIDTH_OUT-1:0] golden_C [0:3][0:3];
    logic signed [127:0] tmp128;
	 
	 // internal nodes
    wire signed [w:0] S1[0:3], S2[0:3], S3[0:3], S4[0:3], S5[0:3];
    wire signed [w:0] T1[0:3], T2[0:3], T3[0:3], T4[0:3], T5[0:3];
	assign S1 = UUT.S1;
	assign S2 = UUT.S2;
	assign S3 = UUT.S3;
	assign S4 = UUT.S4;
	assign S5 = UUT.S5;
	assign T1 = UUT.T1;
	assign T2 = UUT.T2;
	assign T3 = UUT.T3;
	assign T4 = UUT.T4;
	assign T5 = UUT.T5;
	 wire signed [2*w+2:0] M1[0:3];
    wire signed [2*w+1:0] M2[0:3], M5[0:3], M6[0:3], M7[0:3];
    wire signed [2*w  :0] M3[0:3], M4[0:3];
	assign M1 = UUT.M1;
	assign M2 = UUT.M2;
	assign M3 = UUT.M3;
	assign M4 = UUT.M4;
	assign M5 = UUT.M5;
	assign M6 = UUT.M6;
	assign M7 = UUT.M7;
	wire signed [w:0] Amul2[0:3],Bmul2[0:3];  
	wire signed [2*w+2:0] Cmul2[0:3];  
	assign Amul2=UUT.mul2.A;
	assign Bmul2=UUT.mul2.B;
	assign Cmul2=UUT.mul2.C;
    wire signed [2*w+1:0] C11[0:3], C12[0:3], C21[0:3], C22[0:3];
	assign {C11[0],C11[1],C11[2],C11[3]}={UUT.C11[0],UUT.C11[1],UUT.C11[2],UUT.C11[3]};	
	
    // DUT instantiation
    strassen_4x4 #(.w(w)) UUT (
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
				$stop;
        end

		  // If test number is larger than 2033, display A, B, C, and golden_C
			if (test == 2036) begin
				$display("==== Test %0d ====", test);
				for (int i = 0; i < 4; i++) begin
					for (int j = 0; j < 4; j++) begin
						$display("A[%0d][%0d] = %0d", i, j, A[i][j]);
						$display("B[%0d][%0d] = %0d", i, j, B[i][j]);
						$display("C[%0d][%0d] = %0d", i, j, C[i][j]);
						$display("GOLDEN_C[%0d][%0d] = %0d", i, j, golden_C[i][j]);
					end
				end
			end

			if (test == 2037) begin
				$display("==== Test %0d ====", test);
				for (int i = 0; i < 4; i++) begin
					for (int j = 0; j < 4; j++) begin
						$display("A[%0d][%0d] = %0d", i, j, A[i][j]);
						$display("B[%0d][%0d] = %0d", i, j, B[i][j]);
						$display("C[%0d][%0d] = %0d", i, j, C[i][j]);
						$display("GOLDEN_C[%0d][%0d] = %0d", i, j, golden_C[i][j]);
					end
				end
			end

/*
$display("S1 = %0d %0d %0d %0d", S1[0], S1[1], S1[2], S1[3]);
$display("S2 = %0d %0d %0d %0d", S2[0], S2[1], S2[2], S2[3]);
$display("S3 = %0d %0d %0d %0d", S3[0], S3[1], S3[2], S3[3]);
$display("S4 = %0d %0d %0d %0d", S4[0], S4[1], S4[2], S4[3]);
$display("S5 = %0d %0d %0d %0d", S5[0], S5[1], S5[2], S5[3]);
$display("T1 = %0d %0d %0d %0d", T1[0], T1[1], T1[2], T1[3]);
$display("T2 = %0d %0d %0d %0d", T2[0], T2[1], T2[2], T2[3]);
$display("T3 = %0d %0d %0d %0d", T3[0], T3[1], T3[2], T3[3]);
$display("T4 = %0d %0d %0d %0d", T4[0], T4[1], T4[2], T4[3]);
$display("T5 = %0d %0d %0d %0d", T5[0], T5[1], T5[2], T5[3]);
$display("M1 = %0d %0d %0d %0d", M1[0], M1[1], M1[2], M1[3]);
$display("Amul2 = %0d %0d %0d %0d", Amul2[0], Amul2[1], Amul2[2], Amul2[3]);
$display("Bmul2 = %0d %0d %0d %0d", Bmul2[0], Bmul2[1], Bmul2[2], Bmul2[3]);
$display("Cmul2 = %0d %0d %0d %0d", Cmul2[0], Cmul2[1], Cmul2[2], Cmul2[3]);
$display("M2 = %0d %0d %0d %0d", M2[0], M2[1], M2[2], M2[3]);
$display("M3 = %0d %0d %0d %0d", M3[0], M3[1], M3[2], M3[3]);
$display("M4 = %0d %0d %0d %0d", M4[0], M4[1], M4[2], M4[3]);
$display("M5 = %0d %0d %0d %0d", M5[0], M5[1], M5[2], M5[3]);
$display("M6 = %0d %0d %0d %0d", M6[0], M6[1], M6[2], M6[3]);
$display("M7 = %0d %0d %0d %0d", M7[0], M7[1], M7[2], M7[3]);	
$display("C11 = %0d %0d %0d %0d", C11[0], C11[1], C11[2], C11[3]);	
	$stop;
*/
	end
	
	$fclose(file);
	if (error_count == 0)
		$display("All tests passed!");
	else
		$display("%0d mismatches found.", error_count);

	$stop;
end

endmodule
