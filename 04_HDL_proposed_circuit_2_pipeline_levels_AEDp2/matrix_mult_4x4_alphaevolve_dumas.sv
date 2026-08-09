// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// May 2026
// Description: Naive algorithm for real-valued matrix multiplication. Uses two levels of pipelining.

module matrix_mult_4x4_alphaevolve_dumas #(parameter w = 64)(
    input  wire clk,
    input  wire reset,
    input  wire signed [w-1:0] A [0:3][0:3],
    input  wire signed [w-1:0] B [0:3][0:3],
    output wire signed [2*w+1:0] C [0:3][0:3] // 2*w + 2 bits
    );

    // --- Dichiarazione dei registri di pipeline ---
    
    // Registri per l'ingresso A (1 stadio)
    reg signed [w-1:0] A_reg1 [0:3][0:3];
    
    // Registri per l'ingresso B (1 stadio)
    reg signed [w-1:0] B_reg1 [0:3][0:3];
    
    // Rete per l'uscita del modulo con due livelli di pipe
    wire signed [2*w+1:0] C_pipe [0:3][0:3];
    
    // Registri per l'uscita C (1 stadio)
    reg signed [2*w+1:0] C_reg1 [0:3][0:3];
    
    // Variabili per i cicli for
    integer i, j;

    // --- Logica Sequenziale (Aggiornamento dei Registri) ---
    always @(posedge clk, posedge reset)
    begin
	if (reset)
            begin
		for (i = 0; i < 4; i = i + 1) begin
		    for (j = 0; j < 4; j = j + 1) begin
		        // Propagazione pipeline per A
		        A_reg1[i][j] <= {w{1'b0}};
		        // Propagazione pipeline per B
		        B_reg1[i][j] <= {w{1'b0}};
		        // Propagazione pipeline per C
		        C_reg1[i][j] <= {w{1'b0}};
		    end
		end
            end
	else
	    begin
		for (i = 0; i < 4; i = i + 1) begin
		    for (j = 0; j < 4; j = j + 1) begin
		        // Propagazione pipeline per A
		        A_reg1[i][j] <= A[i][j];
		        // Propagazione pipeline per B
		        B_reg1[i][j] <= B[i][j];
		        // Propagazione pipeline per C
		        C_reg1[i][j] <= C_pipe[i][j];
		    end
		end
	    end
    end

    // --- Istanziazione del modulo combinatorio ---
    matrix_mult_4x4_alphaevolve_dumas_pipe #(.w(w)) u_comb_mult (
        .A(A_reg1),  // Ingressi ritardati di 1 ciclo di clock
        .B(B_reg1),
        .C(C_pipe),  // Uscita con due livelli di pipe
	.ck(clk), .reset(reset)    
    );

    // --- Assegnazione all'uscita finale del modulo ---
    // L'uscita C prende il valore dal registro sull'uscita
    assign C = C_reg1;

endmodule

module matrix_mult_4x4_alphaevolve_dumas_pipe #(parameter w = 8)(
    input  wire signed [w-1:0] A [0:3][0:3],
    input  wire signed [w-1:0] B [0:3][0:3],
    output wire signed [2*w+1:0] C [0:3][0:3], //2*w +2 bits,
	 input wire reset,
    input wire ck
    );

/*  Number of bits for the results.
Assume the input is on 3 bits [-4,3]
When two real terms are multiplied you get a*b
The maximum of the result is a=-4, b=-4 giving: 16.
When multiplying a row and a column the term can be summed four times getting a maximum value : 64.
The minimum of the result is a=-4, b=+3 giving: -12.
When multiplying a row and a column the term can be summed four times getting a minimum value: -48.
The number of bits to handle the range is 8 [-128,+127] that is 2*n+2
with 2*n+1 bit the range is [-64,63] that does not contain the maximum.
*/


// unpack A
wire signed [w-1:0] A11, A12, A13, A14;
wire signed [w-1:0] A21, A22, A23, A24;
wire signed [w-1:0] A31, A32, A33, A34;
wire signed [w-1:0] A41, A42, A43, A44;
// Row 1
    assign A11 = A[0][0];
    assign A12 = A[0][1];
    assign A13 = A[0][2];
    assign A14 = A[0][3];
    // Row 2
    assign A21 = A[1][0];
    assign A22 = A[1][1];
    assign A23 = A[1][2];
    assign A24 = A[1][3];
    // Row 3
    assign A31 = A[2][0];
    assign A32 = A[2][1];
    assign A33 = A[2][2];
    assign A34 = A[2][3];
    // Row 4
    assign A41 = A[3][0];
    assign A42 = A[3][1];
    assign A43 = A[3][2];
    assign A44 = A[3][3];

// unpack B
wire signed [w-1:0] B11, B12, B13, B14;
wire signed [w-1:0] B21, B22, B23, B24;
wire signed [w-1:0] B31, B32, B33, B34;
wire signed [w-1:0] B41, B42, B43, B44;
// Row 1
    assign B11 = B[0][0];
    assign B12 = B[0][1];
    assign B13 = B[0][2];
    assign B14 = B[0][3];
    // Row 2
    assign B21 = B[1][0];
    assign B22 = B[1][1];
    assign B23 = B[1][2];
    assign B24 = B[1][3];
    // Row 3
    assign B31 = B[2][0];
    assign B32 = B[2][1];
    assign B33 = B[2][2];
    assign B34 = B[2][3];
    // Row 4
    assign B41 = B[3][0];
    assign B42 = B[3][1];
    assign B43 = B[3][2];
    assign B44 = B[3][3];

// define scalar C values
wire signed [2*w+1+1:0] C11, C12, C13, C14;
wire signed [2*w+1+1:0] C21, C22, C23, C24;
wire signed [2*w+1+1:0] C31, C32, C33, C34;
wire signed [2*w+1+1:0] C41, C42, C43, C44;

// internal signals
wire signed [ 1 * w - 1 + 1 : 0] x16;  // signal num: 1
wire signed [ 1 * w - 1 + 1 : 0] x17;  // signal num: 2
wire signed [ 1 * w - 1 + 1 : 0] x18;  // signal num: 3
wire signed [ 1 * w - 1 + 1 : 0] x19;  // signal num: 4
wire signed [ 1 * w - 1 + 1 : 0] x20;  // signal num: 5
wire signed [ 1 * w - 1 + 1 : 0] x21;  // signal num: 6
wire signed [ 1 * w - 1 + 1 : 0] x22;  // signal num: 7
wire signed [ 1 * w - 1 + 1 : 0] x23;  // signal num: 8
wire signed [ 1 * w - 1 + 1 : 0] x24;  // signal num: 9
wire signed [ 1 * w - 1 + 1 : 0] x25;  // signal num: 10
wire signed [ 1 * w - 1 + 1 : 0] x26;  // signal num: 11
wire signed [ 1 * w - 1 + 1 : 0] x27;  // signal num: 12
wire signed [ 1 * w - 1 + 1 : 0] x28;  // signal num: 13
wire signed [ 1 * w - 1 + 1 : 0] x29;  // signal num: 14
wire signed [ 1 * w - 1 + 1 : 0] x30;  // signal num: 15
wire signed [ 1 * w - 1 + 1 : 0] x31;  // signal num: 16
wire signed [ 1 * w - 1 + 2 : 0] x32;  // signal num: 17
wire signed [ 1 * w - 1 + 2 : 0] x33;  // signal num: 18
wire signed [ 1 * w - 1 + 2 : 0] x34;  // signal num: 19
wire signed [ 1 * w - 1 + 2 : 0] x35;  // signal num: 20
wire signed [ 1 * w - 1 + 2 : 0] x36;  // signal num: 21
wire signed [ 1 * w - 1 + 2 : 0] x37;  // signal num: 22
wire signed [ 1 * w - 1 + 2 : 0] x38;  // signal num: 23
wire signed [ 1 * w - 1 + 2 : 0] x39;  // signal num: 24
wire signed [ 1 * w - 1 + 2 : 0] x40;  // signal num: 25
wire signed [ 1 * w - 1 + 2 : 0] x41;  // signal num: 26
wire signed [ 1 * w - 1 + 2 : 0] x42;  // signal num: 27
wire signed [ 1 * w - 1 + 2 : 0] x43;  // signal num: 28
wire signed [ 1 * w - 1 + 1 : 0] x45;  // signal num: 29
wire signed [ 1 * w - 1 + 1 : 0] x46;  // signal num: 30
wire signed [ 1 * w - 1 + 1 : 0] x47;  // signal num: 31
wire signed [ 1 * w - 1 + 1 : 0] x50;  // signal num: 32
wire signed [ 1 * w - 1 + 1 : 0] x51;  // signal num: 33
wire signed [ 1 * w - 1 + 1 : 0] x52;  // signal num: 34
wire signed [ 1 * w - 1 + 1 : 0] x54;  // signal num: 35
wire signed [ 1 * w - 1 + 1 : 0] x55;  // signal num: 36
wire signed [ 1 * w - 1 + 2 : 0] x56;  // signal num: 37
wire signed [ 1 * w - 1 + 3 : 0] x57;  // signal num: 38
wire signed [ 1 * w - 1 + 3 : 0] x59;  // signal num: 39
wire signed [ 1 * w - 1 + 3 : 0] x60;  // signal num: 40
wire signed [ 1 * w - 1 + 3 : 0] x63;  // signal num: 41
wire signed [ 1 * w - 1 + 3 : 0] x66;  // signal num: 42
wire signed [ 1 * w - 1 + 3 : 0] x71;  // signal num: 43
wire signed [ 1 * w - 1 + 3 : 0] x72;  // signal num: 44
wire signed [ 1 * w - 1 + 2 : 0] x73;  // signal num: 45
wire signed [ 1 * w - 1 + 3 : 0] x75;  // signal num: 46
wire signed [ 1 * w - 1 + 3 : 0] x76;  // signal num: 47
wire signed [ 1 * w - 1 + 3 : 0] x77;  // signal num: 48
wire signed [ 1 * w - 1 + 3 : 0] x78;  // signal num: 49
wire signed [ 1 * w - 1 + 3 : 0] x80;  // signal num: 50
wire signed [ 1 * w - 1 + 2 : 0] x82;  // signal num: 51
wire signed [ 1 * w - 1 + 2 : 0] x83;  // signal num: 52
wire signed [ 1 * w - 1 + 4 : 0] l0;
reg  signed [ 1 * w - 1 + 4 : 0] l0_reg;
register #( .numBit(1 * w + 4)) l0_reg_inst (.d(l0) , .q(l0_reg), .r(reset), .ck(ck));  // pipeline register for l0
wire signed [ 1 * w - 1 + 2 : 0] l1;
reg  signed [ 1 * w - 1 + 2 : 0] l1_reg;
register #( .numBit(1 * w + 2)) l1_reg_inst (.d(l1) , .q(l1_reg), .r(reset), .ck(ck));  // pipeline register for l1
wire signed [ 1 * w - 1 + 2 : 0] l2;
reg  signed [ 1 * w - 1 + 2 : 0] l2_reg;
register #( .numBit(1 * w + 2)) l2_reg_inst (.d(l2) , .q(l2_reg), .r(reset), .ck(ck));  // pipeline register for l2
wire signed [ 1 * w - 1 + 3 : 0] l3;
reg  signed [ 1 * w - 1 + 3 : 0] l3_reg;
register #( .numBit(1 * w + 3)) l3_reg_inst (.d(l3) , .q(l3_reg), .r(reset), .ck(ck));  // pipeline register for l3
wire signed [ 1 * w - 1 + 4 : 0] l4;
reg  signed [ 1 * w - 1 + 4 : 0] l4_reg;
register #( .numBit(1 * w + 4)) l4_reg_inst (.d(l4) , .q(l4_reg), .r(reset), .ck(ck));  // pipeline register for l4
wire signed [ 1 * w - 1 + 4 : 0] l5;
reg  signed [ 1 * w - 1 + 4 : 0] l5_reg;
register #( .numBit(1 * w + 4)) l5_reg_inst (.d(l5) , .q(l5_reg), .r(reset), .ck(ck));  // pipeline register for l5
wire signed [ 1 * w - 1 + 2 : 0] l6;
reg  signed [ 1 * w - 1 + 2 : 0] l6_reg;
register #( .numBit(1 * w + 2)) l6_reg_inst (.d(l6) , .q(l6_reg), .r(reset), .ck(ck));  // pipeline register for l6
wire signed [ 1 * w - 1 + 4 : 0] l7;
reg  signed [ 1 * w - 1 + 4 : 0] l7_reg;
register #( .numBit(1 * w + 4)) l7_reg_inst (.d(l7) , .q(l7_reg), .r(reset), .ck(ck));  // pipeline register for l7
wire signed [ 1 * w - 1 + 3 : 0] l8;
reg  signed [ 1 * w - 1 + 3 : 0] l8_reg;
register #( .numBit(1 * w + 3)) l8_reg_inst (.d(l8) , .q(l8_reg), .r(reset), .ck(ck));  // pipeline register for l8
wire signed [ 1 * w - 1 + 2 : 0] l9;
reg  signed [ 1 * w - 1 + 2 : 0] l9_reg;
register #( .numBit(1 * w + 2)) l9_reg_inst (.d(l9) , .q(l9_reg), .r(reset), .ck(ck));  // pipeline register for l9
wire signed [ 1 * w - 1 + 4 : 0] l10;
reg  signed [ 1 * w - 1 + 4 : 0] l10_reg;
register #( .numBit(1 * w + 4)) l10_reg_inst (.d(l10) , .q(l10_reg), .r(reset), .ck(ck));  // pipeline register for l10
wire signed [ 1 * w - 1 + 3 : 0] l11;
reg  signed [ 1 * w - 1 + 3 : 0] l11_reg;
register #( .numBit(1 * w + 3)) l11_reg_inst (.d(l11) , .q(l11_reg), .r(reset), .ck(ck));  // pipeline register for l11
wire signed [ 1 * w - 1 + 2 : 0] l12;
reg  signed [ 1 * w - 1 + 2 : 0] l12_reg;
register #( .numBit(1 * w + 2)) l12_reg_inst (.d(l12) , .q(l12_reg), .r(reset), .ck(ck));  // pipeline register for l12
wire signed [ 1 * w - 1 + 2 : 0] l13;
reg  signed [ 1 * w - 1 + 2 : 0] l13_reg;
register #( .numBit(1 * w + 2)) l13_reg_inst (.d(l13) , .q(l13_reg), .r(reset), .ck(ck));  // pipeline register for l13
wire signed [ 1 * w - 1 + 3 : 0] l14;
reg  signed [ 1 * w - 1 + 3 : 0] l14_reg;
register #( .numBit(1 * w + 3)) l14_reg_inst (.d(l14) , .q(l14_reg), .r(reset), .ck(ck));  // pipeline register for l14
wire signed [ 1 * w - 1 + 4 : 0] l15;
reg  signed [ 1 * w - 1 + 4 : 0] l15_reg;
register #( .numBit(1 * w + 4)) l15_reg_inst (.d(l15) , .q(l15_reg), .r(reset), .ck(ck));  // pipeline register for l15
wire signed [ 1 * w - 1 + 3 : 0] l16;
reg  signed [ 1 * w - 1 + 3 : 0] l16_reg;
register #( .numBit(1 * w + 3)) l16_reg_inst (.d(l16) , .q(l16_reg), .r(reset), .ck(ck));  // pipeline register for l16
wire signed [ 1 * w - 1 + 4 : 0] l17;
reg  signed [ 1 * w - 1 + 4 : 0] l17_reg;
register #( .numBit(1 * w + 4)) l17_reg_inst (.d(l17) , .q(l17_reg), .r(reset), .ck(ck));  // pipeline register for l17
wire signed [ 1 * w - 1 + 3 : 0] l18;
reg  signed [ 1 * w - 1 + 3 : 0] l18_reg;
register #( .numBit(1 * w + 3)) l18_reg_inst (.d(l18) , .q(l18_reg), .r(reset), .ck(ck));  // pipeline register for l18
wire signed [ 1 * w - 1 + 4 : 0] l19;
reg  signed [ 1 * w - 1 + 4 : 0] l19_reg;
register #( .numBit(1 * w + 4)) l19_reg_inst (.d(l19) , .q(l19_reg), .r(reset), .ck(ck));  // pipeline register for l19
wire signed [ 1 * w - 1 + 2 : 0] l20;
reg  signed [ 1 * w - 1 + 2 : 0] l20_reg;
register #( .numBit(1 * w + 2)) l20_reg_inst (.d(l20) , .q(l20_reg), .r(reset), .ck(ck));  // pipeline register for l20
wire signed [ 1 * w - 1 + 3 : 0] l21;
reg  signed [ 1 * w - 1 + 3 : 0] l21_reg;
register #( .numBit(1 * w + 3)) l21_reg_inst (.d(l21) , .q(l21_reg), .r(reset), .ck(ck));  // pipeline register for l21
wire signed [ 1 * w - 1 + 2 : 0] l22;
reg  signed [ 1 * w - 1 + 2 : 0] l22_reg;
register #( .numBit(1 * w + 2)) l22_reg_inst (.d(l22) , .q(l22_reg), .r(reset), .ck(ck));  // pipeline register for l22
wire signed [ 1 * w - 1 + 4 : 0] l23;
reg  signed [ 1 * w - 1 + 4 : 0] l23_reg;
register #( .numBit(1 * w + 4)) l23_reg_inst (.d(l23) , .q(l23_reg), .r(reset), .ck(ck));  // pipeline register for l23
wire signed [ 1 * w - 1 + 3 : 0] l24;
reg  signed [ 1 * w - 1 + 3 : 0] l24_reg;
register #( .numBit(1 * w + 3)) l24_reg_inst (.d(l24) , .q(l24_reg), .r(reset), .ck(ck));  // pipeline register for l24
wire signed [ 1 * w - 1 + 4 : 0] l25;
reg  signed [ 1 * w - 1 + 4 : 0] l25_reg;
register #( .numBit(1 * w + 4)) l25_reg_inst (.d(l25) , .q(l25_reg), .r(reset), .ck(ck));  // pipeline register for l25
wire signed [ 1 * w - 1 + 2 : 0] l26;
reg  signed [ 1 * w - 1 + 2 : 0] l26_reg;
register #( .numBit(1 * w + 2)) l26_reg_inst (.d(l26) , .q(l26_reg), .r(reset), .ck(ck));  // pipeline register for l26
wire signed [ 1 * w - 1 + 3 : 0] l27;
reg  signed [ 1 * w - 1 + 3 : 0] l27_reg;
register #( .numBit(1 * w + 3)) l27_reg_inst (.d(l27) , .q(l27_reg), .r(reset), .ck(ck));  // pipeline register for l27
wire signed [ 1 * w - 1 + 4 : 0] l28;
reg  signed [ 1 * w - 1 + 4 : 0] l28_reg;
register #( .numBit(1 * w + 4)) l28_reg_inst (.d(l28) , .q(l28_reg), .r(reset), .ck(ck));  // pipeline register for l28
wire signed [ 1 * w - 1 + 2 : 0] l29;
reg  signed [ 1 * w - 1 + 2 : 0] l29_reg;
register #( .numBit(1 * w + 2)) l29_reg_inst (.d(l29) , .q(l29_reg), .r(reset), .ck(ck));  // pipeline register for l29
wire signed [ 1 * w - 1 + 2 : 0] l30;
reg  signed [ 1 * w - 1 + 2 : 0] l30_reg;
register #( .numBit(1 * w + 2)) l30_reg_inst (.d(l30) , .q(l30_reg), .r(reset), .ck(ck));  // pipeline register for l30
wire signed [ 1 * w - 1 + 3 : 0] l31;
reg  signed [ 1 * w - 1 + 3 : 0] l31_reg;
register #( .numBit(1 * w + 3)) l31_reg_inst (.d(l31) , .q(l31_reg), .r(reset), .ck(ck));  // pipeline register for l31
wire signed [ 1 * w - 1 + 4 : 0] l32;
reg  signed [ 1 * w - 1 + 4 : 0] l32_reg;
register #( .numBit(1 * w + 4)) l32_reg_inst (.d(l32) , .q(l32_reg), .r(reset), .ck(ck));  // pipeline register for l32
wire signed [ 1 * w - 1 + 3 : 0] l33;
reg  signed [ 1 * w - 1 + 3 : 0] l33_reg;
register #( .numBit(1 * w + 3)) l33_reg_inst (.d(l33) , .q(l33_reg), .r(reset), .ck(ck));  // pipeline register for l33
wire signed [ 1 * w - 1 + 3 : 0] l34;
reg  signed [ 1 * w - 1 + 3 : 0] l34_reg;
register #( .numBit(1 * w + 3)) l34_reg_inst (.d(l34) , .q(l34_reg), .r(reset), .ck(ck));  // pipeline register for l34
wire signed [ 1 * w - 1 + 4 : 0] l35;
reg  signed [ 1 * w - 1 + 4 : 0] l35_reg;
register #( .numBit(1 * w + 4)) l35_reg_inst (.d(l35) , .q(l35_reg), .r(reset), .ck(ck));  // pipeline register for l35
wire signed [ 1 * w - 1 + 2 : 0] l36;
reg  signed [ 1 * w - 1 + 2 : 0] l36_reg;
register #( .numBit(1 * w + 2)) l36_reg_inst (.d(l36) , .q(l36_reg), .r(reset), .ck(ck));  // pipeline register for l36
wire signed [ 1 * w - 1 + 3 : 0] l37;
reg  signed [ 1 * w - 1 + 3 : 0] l37_reg;
register #( .numBit(1 * w + 3)) l37_reg_inst (.d(l37) , .q(l37_reg), .r(reset), .ck(ck));  // pipeline register for l37
wire signed [ 1 * w - 1 + 2 : 0] l38;
reg  signed [ 1 * w - 1 + 2 : 0] l38_reg;
register #( .numBit(1 * w + 2)) l38_reg_inst (.d(l38) , .q(l38_reg), .r(reset), .ck(ck));  // pipeline register for l38
wire signed [ 1 * w - 1 + 3 : 0] l39;
reg  signed [ 1 * w - 1 + 3 : 0] l39_reg;
register #( .numBit(1 * w + 3)) l39_reg_inst (.d(l39) , .q(l39_reg), .r(reset), .ck(ck));  // pipeline register for l39
wire signed [ 1 * w - 1 + 4 : 0] l40;
reg  signed [ 1 * w - 1 + 4 : 0] l40_reg;
register #( .numBit(1 * w + 4)) l40_reg_inst (.d(l40) , .q(l40_reg), .r(reset), .ck(ck));  // pipeline register for l40
wire signed [ 1 * w - 1 + 2 : 0] l41;
reg  signed [ 1 * w - 1 + 2 : 0] l41_reg;
register #( .numBit(1 * w + 2)) l41_reg_inst (.d(l41) , .q(l41_reg), .r(reset), .ck(ck));  // pipeline register for l41
wire signed [ 1 * w - 1 + 2 : 0] l42;
reg  signed [ 1 * w - 1 + 2 : 0] l42_reg;
register #( .numBit(1 * w + 2)) l42_reg_inst (.d(l42) , .q(l42_reg), .r(reset), .ck(ck));  // pipeline register for l42
wire signed [ 1 * w - 1 + 3 : 0] l43;
reg  signed [ 1 * w - 1 + 3 : 0] l43_reg;
register #( .numBit(1 * w + 3)) l43_reg_inst (.d(l43) , .q(l43_reg), .r(reset), .ck(ck));  // pipeline register for l43
wire signed [ 1 * w - 1 + 4 : 0] l44;
reg  signed [ 1 * w - 1 + 4 : 0] l44_reg;
register #( .numBit(1 * w + 4)) l44_reg_inst (.d(l44) , .q(l44_reg), .r(reset), .ck(ck));  // pipeline register for l44
wire signed [ 1 * w - 1 + 4 : 0] l45;
reg  signed [ 1 * w - 1 + 4 : 0] l45_reg;
register #( .numBit(1 * w + 4)) l45_reg_inst (.d(l45) , .q(l45_reg), .r(reset), .ck(ck));  // pipeline register for l45
wire signed [ 1 * w - 1 + 2 : 0] l46;
reg  signed [ 1 * w - 1 + 2 : 0] l46_reg;
register #( .numBit(1 * w + 2)) l46_reg_inst (.d(l46) , .q(l46_reg), .r(reset), .ck(ck));  // pipeline register for l46
wire signed [ 1 * w - 1 + 3 : 0] l47;
reg  signed [ 1 * w - 1 + 3 : 0] l47_reg;
register #( .numBit(1 * w + 3)) l47_reg_inst (.d(l47) , .q(l47_reg), .r(reset), .ck(ck));  // pipeline register for l47
wire signed [ 1 * w - 1 + 1 : 0] y16;  // signal num: 101
wire signed [ 1 * w - 1 + 1 : 0] y17;  // signal num: 102
wire signed [ 1 * w - 1 + 1 : 0] y18;  // signal num: 103
wire signed [ 1 * w - 1 + 1 : 0] y21;  // signal num: 104
wire signed [ 1 * w - 1 + 1 : 0] y22;  // signal num: 105
wire signed [ 1 * w - 1 + 3 : 0] d48;  // signal num: 106
wire signed [ 1 * w - 1 + 3 : 0] d49;  // signal num: 107
wire signed [ 1 * w - 1 + 2 : 0] d50;  // signal num: 108
wire signed [ 1 * w - 1 + 3 : 0] d51;  // signal num: 109
wire signed [ 1 * w - 1 + 4 : 0] d51_sl1;  // signal num: 109 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] d52;  // signal num: 110
wire signed [ 1 * w - 1 + 4 : 0] d52_sl1;  // signal num: 110 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] d53;  // signal num: 111
wire signed [ 1 * w - 1 + 4 : 0] d53_sl1;  // signal num: 111 Sh left 1
wire signed [ 1 * w - 1 + 2 : 0] d55;  // signal num: 112
wire signed [ 1 * w - 1 + 3 : 0] d55_sl1;  // signal num: 112 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] d57;  // signal num: 113
wire signed [ 1 * w - 1 + 4 : 0] d57_sl1;  // signal num: 113 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] d61;  // signal num: 114
wire signed [ 1 * w - 1 + 1 : 0] d62;  // signal num: 115
wire signed [ 1 * w - 1 + 3 : 0] d63;  // signal num: 116
wire signed [ 1 * w - 1 + 1 : 0] d64;  // signal num: 117
wire signed [ 1 * w - 1 + 1 : 0] d65;  // signal num: 118
wire signed [ 1 * w - 1 + 3 : 0] d66;  // signal num: 119
wire signed [ 1 * w - 1 + 3 : 0] d67;  // signal num: 120
wire signed [ 1 * w - 1 + 1 : 0] d68;  // signal num: 121
wire signed [ 1 * w - 1 + 3 : 0] d69;  // signal num: 122
wire signed [ 1 * w - 1 + 1 : 0] r0;
reg  signed [ 1 * w - 1 + 1 : 0] r0_reg;
register #( .numBit(1 * w + 1)) r0_reg_inst (.d(r0) , .q(r0_reg), .r(reset), .ck(ck));  // pipeline register for r0
wire signed [ 1 * w - 1 + 2 : 0] r1;
reg  signed [ 1 * w - 1 + 2 : 0] r1_reg;
register #( .numBit(1 * w + 2)) r1_reg_inst (.d(r1) , .q(r1_reg), .r(reset), .ck(ck));  // pipeline register for r1
wire signed [ 1 * w - 1 + 1 : 0] r2;
reg  signed [ 1 * w - 1 + 1 : 0] r2_reg;
register #( .numBit(1 * w + 1)) r2_reg_inst (.d(r2) , .q(r2_reg), .r(reset), .ck(ck));  // pipeline register for r2
wire signed [ 1 * w - 1 + 2 : 0] r3;
reg  signed [ 1 * w - 1 + 2 : 0] r3_reg;
register #( .numBit(1 * w + 2)) r3_reg_inst (.d(r3) , .q(r3_reg), .r(reset), .ck(ck));  // pipeline register for r3
wire signed [ 1 * w - 1 + 3 : 0] r3_sl1;  // signal num: 126 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] r4;
reg  signed [ 1 * w - 1 + 3 : 0] r4_reg;
register #( .numBit(1 * w + 3)) r4_reg_inst (.d(r4) , .q(r4_reg), .r(reset), .ck(ck));  // pipeline register for r4
wire signed [ 1 * w - 1 + 2 : 0] r5;
reg  signed [ 1 * w - 1 + 2 : 0] r5_reg;
register #( .numBit(1 * w + 2)) r5_reg_inst (.d(r5) , .q(r5_reg), .r(reset), .ck(ck));  // pipeline register for r5
wire signed [ 1 * w - 1 + 1 : 0] r6;
reg  signed [ 1 * w - 1 + 1 : 0] r6_reg;
register #( .numBit(1 * w + 1)) r6_reg_inst (.d(r6) , .q(r6_reg), .r(reset), .ck(ck));  // pipeline register for r6
wire signed [ 1 * w - 1 + 2 : 0] r7;
reg  signed [ 1 * w - 1 + 2 : 0] r7_reg;
register #( .numBit(1 * w + 2)) r7_reg_inst (.d(r7) , .q(r7_reg), .r(reset), .ck(ck));  // pipeline register for r7
wire signed [ 1 * w - 1 + 4 : 0] r8;
reg  signed [ 1 * w - 1 + 4 : 0] r8_reg;
register #( .numBit(1 * w + 4)) r8_reg_inst (.d(r8) , .q(r8_reg), .r(reset), .ck(ck));  // pipeline register for r8
wire signed [ 1 * w - 1 + 3 : 0] r9;
reg  signed [ 1 * w - 1 + 3 : 0] r9_reg;
register #( .numBit(1 * w + 3)) r9_reg_inst (.d(r9) , .q(r9_reg), .r(reset), .ck(ck));  // pipeline register for r9
wire signed [ 1 * w - 1 + 2 : 0] r10;
reg  signed [ 1 * w - 1 + 2 : 0] r10_reg;
register #( .numBit(1 * w + 2)) r10_reg_inst (.d(r10) , .q(r10_reg), .r(reset), .ck(ck));  // pipeline register for r10
wire signed [ 1 * w - 1 + 4 : 0] r11;
reg  signed [ 1 * w - 1 + 4 : 0] r11_reg;
register #( .numBit(1 * w + 4)) r11_reg_inst (.d(r11) , .q(r11_reg), .r(reset), .ck(ck));  // pipeline register for r11
wire signed [ 1 * w - 1 + 3 : 0] r12;
reg  signed [ 1 * w - 1 + 3 : 0] r12_reg;
register #( .numBit(1 * w + 3)) r12_reg_inst (.d(r12) , .q(r12_reg), .r(reset), .ck(ck));  // pipeline register for r12
wire signed [ 1 * w - 1 + 2 : 0] r13;
reg  signed [ 1 * w - 1 + 2 : 0] r13_reg;
register #( .numBit(1 * w + 2)) r13_reg_inst (.d(r13) , .q(r13_reg), .r(reset), .ck(ck));  // pipeline register for r13
wire signed [ 1 * w - 1 + 1 : 0] r14;
reg  signed [ 1 * w - 1 + 1 : 0] r14_reg;
register #( .numBit(1 * w + 1)) r14_reg_inst (.d(r14) , .q(r14_reg), .r(reset), .ck(ck));  // pipeline register for r14
wire signed [ 1 * w - 1 + 2 : 0] r14_sl1;  // signal num: 137 Sh left 1
wire signed [ 1 * w - 1 + 2 : 0] r15;
reg  signed [ 1 * w - 1 + 2 : 0] r15_reg;
register #( .numBit(1 * w + 2)) r15_reg_inst (.d(r15) , .q(r15_reg), .r(reset), .ck(ck));  // pipeline register for r15
wire signed [ 1 * w - 1 + 2 : 0] r16;
reg  signed [ 1 * w - 1 + 2 : 0] r16_reg;
register #( .numBit(1 * w + 2)) r16_reg_inst (.d(r16) , .q(r16_reg), .r(reset), .ck(ck));  // pipeline register for r16
wire signed [ 1 * w - 1 + 2 : 0] r17;
reg  signed [ 1 * w - 1 + 2 : 0] r17_reg;
register #( .numBit(1 * w + 2)) r17_reg_inst (.d(r17) , .q(r17_reg), .r(reset), .ck(ck));  // pipeline register for r17
wire signed [ 1 * w - 1 + 4 : 0] r18;
reg  signed [ 1 * w - 1 + 4 : 0] r18_reg;
register #( .numBit(1 * w + 4)) r18_reg_inst (.d(r18) , .q(r18_reg), .r(reset), .ck(ck));  // pipeline register for r18
wire signed [ 1 * w - 1 + 2 : 0] r19;
reg  signed [ 1 * w - 1 + 2 : 0] r19_reg;
register #( .numBit(1 * w + 2)) r19_reg_inst (.d(r19) , .q(r19_reg), .r(reset), .ck(ck));  // pipeline register for r19
wire signed [ 1 * w - 1 + 2 : 0] r20;
reg  signed [ 1 * w - 1 + 2 : 0] r20_reg;
register #( .numBit(1 * w + 2)) r20_reg_inst (.d(r20) , .q(r20_reg), .r(reset), .ck(ck));  // pipeline register for r20
wire signed [ 1 * w - 1 + 4 : 0] r21;
reg  signed [ 1 * w - 1 + 4 : 0] r21_reg;
register #( .numBit(1 * w + 4)) r21_reg_inst (.d(r21) , .q(r21_reg), .r(reset), .ck(ck));  // pipeline register for r21
wire signed [ 1 * w - 1 + 3 : 0] r22;
reg  signed [ 1 * w - 1 + 3 : 0] r22_reg;
register #( .numBit(1 * w + 3)) r22_reg_inst (.d(r22) , .q(r22_reg), .r(reset), .ck(ck));  // pipeline register for r22
wire signed [ 1 * w - 1 + 3 : 0] r23;
reg  signed [ 1 * w - 1 + 3 : 0] r23_reg;
register #( .numBit(1 * w + 3)) r23_reg_inst (.d(r23) , .q(r23_reg), .r(reset), .ck(ck));  // pipeline register for r23
wire signed [ 1 * w - 1 + 4 : 0] r24;
reg  signed [ 1 * w - 1 + 4 : 0] r24_reg;
register #( .numBit(1 * w + 4)) r24_reg_inst (.d(r24) , .q(r24_reg), .r(reset), .ck(ck));  // pipeline register for r24
wire signed [ 1 * w - 1 + 3 : 0] r25;
reg  signed [ 1 * w - 1 + 3 : 0] r25_reg;
register #( .numBit(1 * w + 3)) r25_reg_inst (.d(r25) , .q(r25_reg), .r(reset), .ck(ck));  // pipeline register for r25
wire signed [ 1 * w - 1 + 2 : 0] r26;
reg  signed [ 1 * w - 1 + 2 : 0] r26_reg;
register #( .numBit(1 * w + 2)) r26_reg_inst (.d(r26) , .q(r26_reg), .r(reset), .ck(ck));  // pipeline register for r26
wire signed [ 1 * w - 1 + 4 : 0] r27;
reg  signed [ 1 * w - 1 + 4 : 0] r27_reg;
register #( .numBit(1 * w + 4)) r27_reg_inst (.d(r27) , .q(r27_reg), .r(reset), .ck(ck));  // pipeline register for r27
wire signed [ 1 * w - 1 + 1 : 0] r28;
reg  signed [ 1 * w - 1 + 1 : 0] r28_reg;
register #( .numBit(1 * w + 1)) r28_reg_inst (.d(r28) , .q(r28_reg), .r(reset), .ck(ck));  // pipeline register for r28
wire signed [ 1 * w - 1 + 2 : 0] r29;
reg  signed [ 1 * w - 1 + 2 : 0] r29_reg;
register #( .numBit(1 * w + 2)) r29_reg_inst (.d(r29) , .q(r29_reg), .r(reset), .ck(ck));  // pipeline register for r29
wire signed [ 1 * w - 1 + 2 : 0] r30;
reg  signed [ 1 * w - 1 + 2 : 0] r30_reg;
register #( .numBit(1 * w + 2)) r30_reg_inst (.d(r30) , .q(r30_reg), .r(reset), .ck(ck));  // pipeline register for r30
wire signed [ 1 * w - 1 + 4 : 0] r31;
reg  signed [ 1 * w - 1 + 4 : 0] r31_reg;
register #( .numBit(1 * w + 4)) r31_reg_inst (.d(r31) , .q(r31_reg), .r(reset), .ck(ck));  // pipeline register for r31
wire signed [ 1 * w - 1 + 2 : 0] r32;
reg  signed [ 1 * w - 1 + 2 : 0] r32_reg;
register #( .numBit(1 * w + 2)) r32_reg_inst (.d(r32) , .q(r32_reg), .r(reset), .ck(ck));  // pipeline register for r32
wire signed [ 1 * w - 1 + 2 : 0] r33;
reg  signed [ 1 * w - 1 + 2 : 0] r33_reg;
register #( .numBit(1 * w + 2)) r33_reg_inst (.d(r33) , .q(r33_reg), .r(reset), .ck(ck));  // pipeline register for r33
wire signed [ 1 * w - 1 + 4 : 0] r34;
reg  signed [ 1 * w - 1 + 4 : 0] r34_reg;
register #( .numBit(1 * w + 4)) r34_reg_inst (.d(r34) , .q(r34_reg), .r(reset), .ck(ck));  // pipeline register for r34
wire signed [ 1 * w - 1 + 2 : 0] r35;
reg  signed [ 1 * w - 1 + 2 : 0] r35_reg;
register #( .numBit(1 * w + 2)) r35_reg_inst (.d(r35) , .q(r35_reg), .r(reset), .ck(ck));  // pipeline register for r35
wire signed [ 1 * w - 1 + 3 : 0] r36;
reg  signed [ 1 * w - 1 + 3 : 0] r36_reg;
register #( .numBit(1 * w + 3)) r36_reg_inst (.d(r36) , .q(r36_reg), .r(reset), .ck(ck));  // pipeline register for r36
wire signed [ 1 * w - 1 + 3 : 0] r37;
reg  signed [ 1 * w - 1 + 3 : 0] r37_reg;
register #( .numBit(1 * w + 3)) r37_reg_inst (.d(r37) , .q(r37_reg), .r(reset), .ck(ck));  // pipeline register for r37
wire signed [ 1 * w - 1 + 1 : 0] r38;
reg  signed [ 1 * w - 1 + 1 : 0] r38_reg;
register #( .numBit(1 * w + 1)) r38_reg_inst (.d(r38) , .q(r38_reg), .r(reset), .ck(ck));  // pipeline register for r38
wire signed [ 1 * w - 1 + 2 : 0] r39;
reg  signed [ 1 * w - 1 + 2 : 0] r39_reg;
register #( .numBit(1 * w + 2)) r39_reg_inst (.d(r39) , .q(r39_reg), .r(reset), .ck(ck));  // pipeline register for r39
wire signed [ 1 * w - 1 + 3 : 0] r39_sl1;  // signal num: 162 Sh left 1
wire signed [ 1 * w - 1 + 2 : 0] r40;
reg  signed [ 1 * w - 1 + 2 : 0] r40_reg;
register #( .numBit(1 * w + 2)) r40_reg_inst (.d(r40) , .q(r40_reg), .r(reset), .ck(ck));  // pipeline register for r40
wire signed [ 1 * w - 1 + 2 : 0] r41;
reg  signed [ 1 * w - 1 + 2 : 0] r41_reg;
register #( .numBit(1 * w + 2)) r41_reg_inst (.d(r41) , .q(r41_reg), .r(reset), .ck(ck));  // pipeline register for r41
wire signed [ 1 * w - 1 + 1 : 0] r42;
reg  signed [ 1 * w - 1 + 1 : 0] r42_reg;
register #( .numBit(1 * w + 1)) r42_reg_inst (.d(r42) , .q(r42_reg), .r(reset), .ck(ck));  // pipeline register for r42
wire signed [ 1 * w - 1 + 3 : 0] r43;
reg  signed [ 1 * w - 1 + 3 : 0] r43_reg;
register #( .numBit(1 * w + 3)) r43_reg_inst (.d(r43) , .q(r43_reg), .r(reset), .ck(ck));  // pipeline register for r43
wire signed [ 1 * w - 1 + 1 : 0] r44;
reg  signed [ 1 * w - 1 + 1 : 0] r44_reg;
register #( .numBit(1 * w + 1)) r44_reg_inst (.d(r44) , .q(r44_reg), .r(reset), .ck(ck));  // pipeline register for r44
wire signed [ 1 * w - 1 + 3 : 0] r45;
reg  signed [ 1 * w - 1 + 3 : 0] r45_reg;
register #( .numBit(1 * w + 3)) r45_reg_inst (.d(r45) , .q(r45_reg), .r(reset), .ck(ck));  // pipeline register for r45
wire signed [ 1 * w - 1 + 2 : 0] r46;
reg  signed [ 1 * w - 1 + 2 : 0] r46_reg;
register #( .numBit(1 * w + 2)) r46_reg_inst (.d(r46) , .q(r46_reg), .r(reset), .ck(ck));  // pipeline register for r46
wire signed [ 1 * w - 1 + 1 : 0] r47;
reg  signed [ 1 * w - 1 + 1 : 0] r47_reg;
register #( .numBit(1 * w + 1)) r47_reg_inst (.d(r47) , .q(r47_reg), .r(reset), .ck(ck));  // pipeline register for r47
wire signed [ 2 * w - 1 + 7 : 0] q5;  // signal num: 171 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q6;  // signal num: 172 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 : 0] q8;  // signal num: 173 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q15;  // signal num: 174 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 : 0] q17;  // signal num: 175 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 : 0] q19;  // signal num: 176 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 : 0] q21;  // signal num: 177 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 5 : 0] q27;  // signal num: 178 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 5 : 0] q30;  // signal num: 179 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] q31;  // signal num: 180 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 : 0] q44;  // signal num: 181 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 5 : 0] q46;  // signal num: 182 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q52;  // signal num: 183 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q55;  // signal num: 184 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q56;  // signal num: 185 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] q57;  // signal num: 186 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] q58;  // signal num: 187 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 6 : 0] k71;  // signal num: 188 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 6 : 0] k69;  // signal num: 189 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 6 : 0] k68;  // signal num: 190 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 6 : 0] k67;  // signal num: 191 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] k66;  // signal num: 192 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] k65;  // signal num: 193 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] k63;  // signal num: 194 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] k60;  // signal num: 195 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] k56;  // signal num: 196 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z43;  // signal num: 197 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z42;  // signal num: 198 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z41;  // signal num: 199 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z40;  // signal num: 200 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 5 : 0] z39;  // signal num: 201 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 5 : 0] z38;  // signal num: 202 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] z37;  // signal num: 203 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z36;  // signal num: 204 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z35;  // signal num: 205 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] z34;  // signal num: 206 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] z33;  // signal num: 207 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z32;  // signal num: 208 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] z31;  // signal num: 209 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z30;  // signal num: 210 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] z23;  // signal num: 211 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z18;  // signal num: 212 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 3 : 0] z16;  // signal num: 213 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 4 : 0] p0;  // signal num: 214
reg signed [ 2 * w - 1 + 4 : 0] p0_reg;  // signal num: 214
register #( .numBit(2 * w  + 4)) p0_reg_inst (.d(p0), .q(p0_reg), .r(reset), .ck(ck));  // signal num: 214
wire signed [ 2 * w - 1 + 3 : 0] p1;  // signal num: 215
reg signed [ 2 * w - 1 + 3 : 0] p1_reg;  // signal num: 215
register #( .numBit(2 * w  + 3)) p1_reg_inst (.d(p1), .q(p1_reg), .r(reset), .ck(ck));  // signal num: 215
wire signed [ 2 * w - 1 + 2 : 0] p2;  // signal num: 216
reg signed [ 2 * w - 1 + 2 : 0] p2_reg;  // signal num: 216
register #( .numBit(2 * w  + 2)) p2_reg_inst (.d(p2), .q(p2_reg), .r(reset), .ck(ck));  // signal num: 216
wire signed [ 2 * w - 1 + 4 : 0] p3;  // signal num: 217
reg signed [ 2 * w - 1 + 4 : 0] p3_reg;  // signal num: 217
register #( .numBit(2 * w  + 4)) p3_reg_inst (.d(p3), .q(p3_reg), .r(reset), .ck(ck));  // signal num: 217
wire signed [ 2 * w - 1 + 6 : 0] p4;  // signal num: 218
reg signed [ 2 * w - 1 + 6 : 0] p4_reg;  // signal num: 218
register #( .numBit(2 * w  + 6)) p4_reg_inst (.d(p4), .q(p4_reg), .r(reset), .ck(ck));  // signal num: 218
wire signed [ 2 * w - 1 + 5 : 0] p5;  // signal num: 219
reg signed [ 2 * w - 1 + 5 : 0] p5_reg;  // signal num: 219
register #( .numBit(2 * w  + 5)) p5_reg_inst (.d(p5), .q(p5_reg), .r(reset), .ck(ck));  // signal num: 219
wire signed [ 2 * w - 1 + 2 : 0] p6;  // signal num: 220
reg signed [ 2 * w - 1 + 2 : 0] p6_reg;  // signal num: 220
register #( .numBit(2 * w  + 2)) p6_reg_inst (.d(p6), .q(p6_reg), .r(reset), .ck(ck));  // signal num: 220
wire signed [ 2 * w - 1 + 5 : 0] p7;  // signal num: 221
reg signed [ 2 * w - 1 + 5 : 0] p7_reg;  // signal num: 221
register #( .numBit(2 * w  + 5)) p7_reg_inst (.d(p7), .q(p7_reg), .r(reset), .ck(ck));  // signal num: 221
wire signed [ 2 * w - 1 + 6 : 0] p8;  // signal num: 222
reg signed [ 2 * w - 1 + 6 : 0] p8_reg;  // signal num: 222
register #( .numBit(2 * w  + 6)) p8_reg_inst (.d(p8), .q(p8_reg), .r(reset), .ck(ck));  // signal num: 222
wire signed [ 2 * w - 1 + 4 : 0] p9;  // signal num: 223
reg signed [ 2 * w - 1 + 4 : 0] p9_reg;  // signal num: 223
register #( .numBit(2 * w  + 4)) p9_reg_inst (.d(p9), .q(p9_reg), .r(reset), .ck(ck));  // signal num: 223
wire signed [ 2 * w - 1 + 5 : 0] p10;  // signal num: 224
reg signed [ 2 * w - 1 + 5 : 0] p10_reg;  // signal num: 224
register #( .numBit(2 * w  + 5)) p10_reg_inst (.d(p10), .q(p10_reg), .r(reset), .ck(ck));  // signal num: 224
wire signed [ 2 * w - 1 + 6 : 0] p11;  // signal num: 225
reg signed [ 2 * w - 1 + 6 : 0] p11_reg;  // signal num: 225
register #( .numBit(2 * w  + 6)) p11_reg_inst (.d(p11), .q(p11_reg), .r(reset), .ck(ck));  // signal num: 225
wire signed [ 2 * w - 1 + 4 : 0] p12;  // signal num: 226
reg signed [ 2 * w - 1 + 4 : 0] p12_reg;  // signal num: 226
register #( .numBit(2 * w  + 4)) p12_reg_inst (.d(p12), .q(p12_reg), .r(reset), .ck(ck));  // signal num: 226
wire signed [ 2 * w - 1 + 3 : 0] p13;  // signal num: 227
reg signed [ 2 * w - 1 + 3 : 0] p13_reg;  // signal num: 227
register #( .numBit(2 * w  + 3)) p13_reg_inst (.d(p13), .q(p13_reg), .r(reset), .ck(ck));  // signal num: 227
wire signed [ 2 * w - 1 + 3 : 0] p14;  // signal num: 228
reg signed [ 2 * w - 1 + 3 : 0] p14_reg;  // signal num: 228
register #( .numBit(2 * w  + 3)) p14_reg_inst (.d(p14), .q(p14_reg), .r(reset), .ck(ck));  // signal num: 228
wire signed [ 2 * w - 1 + 5 : 0] p15;  // signal num: 229
reg signed [ 2 * w - 1 + 5 : 0] p15_reg;  // signal num: 229
register #( .numBit(2 * w  + 5)) p15_reg_inst (.d(p15), .q(p15_reg), .r(reset), .ck(ck));  // signal num: 229
wire signed [ 2 * w - 1 + 4 : 0] p16;  // signal num: 230
reg signed [ 2 * w - 1 + 4 : 0] p16_reg;  // signal num: 230
register #( .numBit(2 * w  + 4)) p16_reg_inst (.d(p16), .q(p16_reg), .r(reset), .ck(ck));  // signal num: 230
wire signed [ 2 * w - 1 + 5 : 0] p17;  // signal num: 231
reg signed [ 2 * w - 1 + 5 : 0] p17_reg;  // signal num: 231
register #( .numBit(2 * w  + 5)) p17_reg_inst (.d(p17), .q(p17_reg), .r(reset), .ck(ck));  // signal num: 231
wire signed [ 2 * w - 1 + 6 : 0] p18;  // signal num: 232
reg signed [ 2 * w - 1 + 6 : 0] p18_reg;  // signal num: 232
register #( .numBit(2 * w  + 6)) p18_reg_inst (.d(p18), .q(p18_reg), .r(reset), .ck(ck));  // signal num: 232
wire signed [ 2 * w - 1 + 5 : 0] p19;  // signal num: 233
reg signed [ 2 * w - 1 + 5 : 0] p19_reg;  // signal num: 233
register #( .numBit(2 * w  + 5)) p19_reg_inst (.d(p19), .q(p19_reg), .r(reset), .ck(ck));  // signal num: 233
wire signed [ 2 * w - 1 + 3 : 0] p20;  // signal num: 234
reg signed [ 2 * w - 1 + 3 : 0] p20_reg;  // signal num: 234
register #( .numBit(2 * w  + 3)) p20_reg_inst (.d(p20), .q(p20_reg), .r(reset), .ck(ck));  // signal num: 234
wire signed [ 2 * w - 1 + 6 : 0] p21;  // signal num: 235
reg signed [ 2 * w - 1 + 6 : 0] p21_reg;  // signal num: 235
register #( .numBit(2 * w  + 6)) p21_reg_inst (.d(p21), .q(p21_reg), .r(reset), .ck(ck));  // signal num: 235
wire signed [ 2 * w - 1 + 4 : 0] p22;  // signal num: 236
reg signed [ 2 * w - 1 + 4 : 0] p22_reg;  // signal num: 236
register #( .numBit(2 * w  + 4)) p22_reg_inst (.d(p22), .q(p22_reg), .r(reset), .ck(ck));  // signal num: 236
wire signed [ 2 * w - 1 + 6 : 0] p23;  // signal num: 237
reg signed [ 2 * w - 1 + 6 : 0] p23_reg;  // signal num: 237
register #( .numBit(2 * w  + 6)) p23_reg_inst (.d(p23), .q(p23_reg), .r(reset), .ck(ck));  // signal num: 237
wire signed [ 2 * w - 1 + 6 : 0] p24;  // signal num: 238
reg signed [ 2 * w - 1 + 6 : 0] p24_reg;  // signal num: 238
register #( .numBit(2 * w  + 6)) p24_reg_inst (.d(p24), .q(p24_reg), .r(reset), .ck(ck));  // signal num: 238
wire signed [ 2 * w - 1 + 6 : 0] p25;  // signal num: 239
reg signed [ 2 * w - 1 + 6 : 0] p25_reg;  // signal num: 239
register #( .numBit(2 * w  + 6)) p25_reg_inst (.d(p25), .q(p25_reg), .r(reset), .ck(ck));  // signal num: 239
wire signed [ 2 * w - 1 + 4 : 0] p26;  // signal num: 240
reg signed [ 2 * w - 1 + 4 : 0] p26_reg;  // signal num: 240
register #( .numBit(2 * w  + 4)) p26_reg_inst (.d(p26), .q(p26_reg), .r(reset), .ck(ck));  // signal num: 240
wire signed [ 2 * w - 1 + 6 : 0] p27;  // signal num: 241
reg signed [ 2 * w - 1 + 6 : 0] p27_reg;  // signal num: 241
register #( .numBit(2 * w  + 6)) p27_reg_inst (.d(p27), .q(p27_reg), .r(reset), .ck(ck));  // signal num: 241
wire signed [ 2 * w - 1 + 4 : 0] p28;  // signal num: 242
reg signed [ 2 * w - 1 + 4 : 0] p28_reg;  // signal num: 242
register #( .numBit(2 * w  + 4)) p28_reg_inst (.d(p28), .q(p28_reg), .r(reset), .ck(ck));  // signal num: 242
wire signed [ 2 * w - 1 + 3 : 0] p29;  // signal num: 243
reg signed [ 2 * w - 1 + 3 : 0] p29_reg;  // signal num: 243
register #( .numBit(2 * w  + 3)) p29_reg_inst (.d(p29), .q(p29_reg), .r(reset), .ck(ck));  // signal num: 243
wire signed [ 2 * w - 1 + 3 : 0] p30;  // signal num: 244
reg signed [ 2 * w - 1 + 3 : 0] p30_reg;  // signal num: 244
register #( .numBit(2 * w  + 3)) p30_reg_inst (.d(p30), .q(p30_reg), .r(reset), .ck(ck));  // signal num: 244
wire signed [ 2 * w - 1 + 6 : 0] p31;  // signal num: 245
reg signed [ 2 * w - 1 + 6 : 0] p31_reg;  // signal num: 245
register #( .numBit(2 * w  + 6)) p31_reg_inst (.d(p31), .q(p31_reg), .r(reset), .ck(ck));  // signal num: 245
wire signed [ 2 * w - 1 + 4 : 0] p32;  // signal num: 246
reg signed [ 2 * w - 1 + 4 : 0] p32_reg;  // signal num: 246
register #( .numBit(2 * w  + 4)) p32_reg_inst (.d(p32), .q(p32_reg), .r(reset), .ck(ck));  // signal num: 246
wire signed [ 2 * w - 1 + 4 : 0] p33;  // signal num: 247
reg signed [ 2 * w - 1 + 4 : 0] p33_reg;  // signal num: 247
register #( .numBit(2 * w  + 4)) p33_reg_inst (.d(p33), .q(p33_reg), .r(reset), .ck(ck));  // signal num: 247
wire signed [ 2 * w - 1 + 6 : 0] p34;  // signal num: 248
reg signed [ 2 * w - 1 + 6 : 0] p34_reg;  // signal num: 248
register #( .numBit(2 * w  + 6)) p34_reg_inst (.d(p34), .q(p34_reg), .r(reset), .ck(ck));  // signal num: 248
wire signed [ 2 * w - 1 + 5 : 0] p35;  // signal num: 249
reg signed [ 2 * w - 1 + 5 : 0] p35_reg;  // signal num: 249
register #( .numBit(2 * w  + 5)) p35_reg_inst (.d(p35), .q(p35_reg), .r(reset), .ck(ck));  // signal num: 249
wire signed [ 2 * w - 1 + 4 : 0] p36;  // signal num: 250
reg signed [ 2 * w - 1 + 4 : 0] p36_reg;  // signal num: 250
register #( .numBit(2 * w  + 4)) p36_reg_inst (.d(p36), .q(p36_reg), .r(reset), .ck(ck));  // signal num: 250
wire signed [ 2 * w - 1 + 5 : 0] p37;  // signal num: 251
reg signed [ 2 * w - 1 + 5 : 0] p37_reg;  // signal num: 251
register #( .numBit(2 * w  + 5)) p37_reg_inst (.d(p37), .q(p37_reg), .r(reset), .ck(ck));  // signal num: 251
wire signed [ 2 * w - 1 + 2 : 0] p38;  // signal num: 252
reg signed [ 2 * w - 1 + 2 : 0] p38_reg;  // signal num: 252
register #( .numBit(2 * w  + 2)) p38_reg_inst (.d(p38), .q(p38_reg), .r(reset), .ck(ck));  // signal num: 252
wire signed [ 2 * w - 1 + 4 : 0] p39;  // signal num: 253
reg signed [ 2 * w - 1 + 4 : 0] p39_reg;  // signal num: 253
register #( .numBit(2 * w  + 4)) p39_reg_inst (.d(p39), .q(p39_reg), .r(reset), .ck(ck));  // signal num: 253
wire signed [ 2 * w - 1 + 5 : 0] p40;  // signal num: 254
reg signed [ 2 * w - 1 + 5 : 0] p40_reg;  // signal num: 254
register #( .numBit(2 * w  + 5)) p40_reg_inst (.d(p40), .q(p40_reg), .r(reset), .ck(ck));  // signal num: 254
wire signed [ 2 * w - 1 + 3 : 0] p41;  // signal num: 255
reg signed [ 2 * w - 1 + 3 : 0] p41_reg;  // signal num: 255
register #( .numBit(2 * w  + 3)) p41_reg_inst (.d(p41), .q(p41_reg), .r(reset), .ck(ck));  // signal num: 255
wire signed [ 2 * w - 1 + 2 : 0] p42;  // signal num: 256
reg signed [ 2 * w - 1 + 2 : 0] p42_reg;  // signal num: 256
register #( .numBit(2 * w  + 2)) p42_reg_inst (.d(p42), .q(p42_reg), .r(reset), .ck(ck));  // signal num: 256
wire signed [ 2 * w - 1 + 5 : 0] p43;  // signal num: 257
reg signed [ 2 * w - 1 + 5 : 0] p43_reg;  // signal num: 257
register #( .numBit(2 * w  + 5)) p43_reg_inst (.d(p43), .q(p43_reg), .r(reset), .ck(ck));  // signal num: 257
wire signed [ 2 * w - 1 + 4 : 0] p44;  // signal num: 258
reg signed [ 2 * w - 1 + 4 : 0] p44_reg;  // signal num: 258
register #( .numBit(2 * w  + 4)) p44_reg_inst (.d(p44), .q(p44_reg), .r(reset), .ck(ck));  // signal num: 258
wire signed [ 2 * w - 1 + 6 : 0] p45;  // signal num: 259
reg signed [ 2 * w - 1 + 6 : 0] p45_reg;  // signal num: 259
register #( .numBit(2 * w  + 6)) p45_reg_inst (.d(p45), .q(p45_reg), .r(reset), .ck(ck));  // signal num: 259
wire signed [ 2 * w - 1 + 3 : 0] p46;  // signal num: 260
reg signed [ 2 * w - 1 + 3 : 0] p46_reg;  // signal num: 260
register #( .numBit(2 * w  + 3)) p46_reg_inst (.d(p46), .q(p46_reg), .r(reset), .ck(ck));  // signal num: 260
wire signed [ 2 * w - 1 + 3 : 0] p47;  // signal num: 261
reg signed [ 2 * w - 1 + 3 : 0] p47_reg;  // signal num: 261
register #( .numBit(2 * w  + 3)) p47_reg_inst (.d(p47), .q(p47_reg), .r(reset), .ck(ck));  // signal num: 261

// manually added signals
wire signed [ 2 * w - 1 + 4 + 1 : 0] q59;  // signal num: 166 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 + 1 : 0] q42;  // signal num: 167 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 7 + 1 : 0] q26;  // signal num: 168 x2 to accommodate 1 frac bit
wire signed [ 2 * w - 1 + 6 + 1 : 0] q37;  // signal num: 169 x2 to accommodate 1 frac bit
// L block
    assign x16 = A13 + A24;
    assign x17 = A14 + A23;
    assign x18 = A12 - A21;
    assign x19 = A31 - A42;
    assign x20 = A33 + A44;
    assign x21 = A34 + A43;
    assign x22 = A22 - A11;
    assign x23 = A32 - A41;
    assign x24 = A13 - A23;
    assign x25 = A32 - A42;
    assign x26 = A33 + A43;
    assign x27 = A31 - A41;
    assign x28 = A34 + A44;
    assign x29 = A12 + A22;
    assign x30 = A11 + A21;
    assign x31 = A14 - A24;
    assign x32 = x23 - x19;
    assign x33 = x16 + x17;
    assign x34 = x20 - x21;
    assign x35 = x22 - x18;
    assign x36 = x20 + x21;
    assign x37 = x18 + x22;
    assign x38 = x16 - x17;
    assign x39 = x19 + x23;
    assign x40 = x29 + x30;
    assign x41 = x25 - x27;
    assign x42 = x26 - x28;
    assign x43 = x24 + x31;
    assign l8  = x32 - x43;
    assign x45 = A33 - A43;
    assign x46 = A31 + A41;
    assign x47 = A13 + A23;
    assign l34 = x34 + x40;
    assign l27 = x33 - x41;
    assign x50 = A32 + A42;
    assign x51 = A12 - A22;
    assign x52 = A14 + A24;
    assign l24 = x42 - x35;
    assign x54 = A34 - A44;
    assign x55 = A11 - A21;
    assign x56 = x17 + x18;
    assign x57 = x34 - x35;
    assign x59 = x37 + x32;
    assign x60 = x38 + x46 + x50;
    assign l38 = x29 - x25;
    assign x63 = x36 + x33;
    assign l2  = x26 - x24;
    assign x66 = x36 - x33;
    assign l6  = x28 - x31;
    assign l36 = x25 + x29;
    assign l12 = x24 + x26;
    assign x71 = x34 + x35;
    assign x72 = x39 - x38;
    assign x73 = x16 - x22;
    assign l22 = x28 + x31;
    assign x75 = x52 - x39 - x47;
    assign x76 = x38 + x39;
    assign x77 = x37 - x32;
    assign x78 = x55 + x36 - x51;
    assign l9  = x27 + x30;
    assign x80 = x45 + x54 - x37;
    assign l42 = x30 - x27;
    assign x82 = x19 + x20;
    assign x83 = x21 + x23;
    assign l0  = l27 - x80;
    assign l1  = x27 - x55;
    assign l3  = x42 - x33;
    assign l4  = l24 + x60;
    assign l5  = x57 - x76;
    assign l7  = x57 + x76;
    assign l10 = x71 + x72;
    assign l11 = x56 + x83;
    assign l13 = x47 - x26;
    assign l14 = l42 - l2;
    assign l15 = x72 - x71;
    assign l16 = x40 + x32;
    assign l17 = x77 - x66;
    assign l18 = x56 - x83;
    assign l19 = x66 + x77;
    assign l20 = x24 - x45;
    assign l21 = x73 + x82;
    assign l23 = x78 - l8;
    assign l25 = l27 + x80;
    assign l26 = x29 + x50;
    assign l28 = x78 + l8;
    assign l29 = x28 + x52;
    assign l30 = x25 + x51;
    assign l31 = x73 - x82;
    assign l32 = x60 - l24;
    assign l33 = x34 - x43;
    assign l35 = x63 - x59;
    assign l37 = l36 + l22;
    assign l39 = x35 - x41;
    assign l40 = x59 + x63;
    assign l41 = x31 + x54;
    assign l43 = l12 + l9;
    assign l44 = l34 + x75;
    assign l45 = l34 - x75;
    assign l46 = x46 - x30;
    assign l47 = l6 - l38;
//  R block
    assign y16 = B11 - B14;
    assign y17 = B31 - B34;
    assign y18 = B32 + B33;
    assign r6  = B22 - B42;
    assign r15 = y16 - y17;
    assign y21 = B43 - B41;
    assign y22 = B12 + B13;
    assign r2  = B12 + B32;
    assign r3  = y18 - y21;
    assign r7  = y16 + y17;
    assign r10 = B24 - B44 + r6;
    assign r12 = B33 + r15 - B13;
    assign r14 = B12 - B31;
    assign r19 = B23 - y21 - B21;
    assign r35 = y22 + y18;
    assign r38 = B41 - B21;
    assign r39 = B22 + B24 + y16;
    assign r40 = y22 - y18;
    assign r42 = B11 + B31;
    assign r44 = B41 - B31;
    assign r47 = B22 + B41;
    assign d48 = r19 + r35;
    assign d49 = r7 + r10;
    assign d50 = r15 - r44;
    assign d51 = r39 - r3;
    assign d52 = r2 + r12;
    assign d53 = d51 - d50;
    assign r31 = d49 - d48;
    assign d55 = r14 + r47;

    //wire signed [ 1 * w - 1 + 3 : 0] d53;
    //wire signed [ 1 * w - 1 + 3 +1 : 0 ] d53_sl1;
    assign d53_sl1 = (d53 <<< 1);
    assign r34 = d53_sl1 - r31;


    //wire signed [ 1 * w - 1 + 1 : 0] r14;
    //wire signed [ 1 * w - 1 + 1 + 1 : 0] r14_sl1;
    assign r14_sl1 = (r14 <<< 1);
    assign d57 = d52 - r14_sl1;


    //wire signed [ 1 * w - 1 + 2 : 0] d55;  // signal num: 112
    //wire signed [ 1 * w - 1 + 2 + 1 : 0] d55_sl1;
    assign d55_sl1 = (d55 <<< 1);
    assign r24 = d55_sl1 - r34;

    assign r16 = r3 - d48;
    assign r33 = r39 - d49;
    assign d61 = d50 - r40;
    assign d62 = r14 + r42;

    //wire signed [ 1 * w - 1 + 2 : 0] r39;  // signal num: 162
    //wire signed [ 1 * w - 1 + 2 + 1 : 0] r39_sl1;  
    assign r39_sl1 = (r39 <<< 1);

    assign d63 = r39_sl1 - d49;
    assign d64 = r47 - r38;
    assign d65 = r2 - r14;
    assign d66 = d52 - d55;
    assign d67 = d57 + r34;
    assign d68 = r47 - r6;

    //wire signed [ 1 * w - 1 + 2 : 0] r3;  // signal num: 126
    //wire signed [ 1 * w - 1 + 2 + 1 : 0] r3_sl1;  
    assign r3_sl1 = (r3 <<< 1);
    assign d69 = d48 - r3_sl1;

    //wire signed [ 1 * w - 1 + 3 : 0] d52;  // signal num: 110
    //wire signed [ 1 * w - 1 + 3 + 1 : 0] d52_sl1;
    assign d52_sl1 = (d52 <<< 1);
    assign r8  = d52_sl1 - r24;

    assign r25 = r35 - d49 + d53 + d57;

    //wire signed [ 1 * w - 1 + 3 : 0] d57;  // signal num: 113
    //wire signed [ 1 * w - 1 + 3 + 1 : 0] d57_sl1;
    assign d57_sl1 = (d57 <<< 1);
    assign r27 = r34 + d57_sl1;

    assign r45 = r10 - d53;
    assign r20 = r33 + d65;
    assign r13 = d65 - r3;
    assign r18 = d63 - d69;
    assign r9  = r42 - d57;
    assign r21 = d49 + d48;
    assign r1  = d62 - r39;
    assign r0  = d57 - d61;
    assign r41 = d68 - r33;
    assign r43 = d52 - r14;
    assign r26 = d64 - r16;
    assign r5  = d63 - r15;
    assign r29 = d68 - r3;
    assign r36 = d67 - r38;
    assign r46 = d62 + r16;

    //wire signed [ 1 * w - 1 + 3 : 0] d51;  // signal num: 109
    //wire signed [ 1 * w - 1 + 3 + 1 : 0] d51_sl1;
    assign d51_sl1 = (d51 <<< 1);
    assign r11 = r31 - d51_sl1;

    assign r17 = r40 - d69;
    assign r32 = r44 - d55;
    assign r28 = d61 - d66;
    assign r30 = r39 - d64;
    assign r23 = r19 + d53 + d66;
    assign r22 = r6 + d52 - r24;
    assign r4  = d48 + d53 - d55 - r7;
    assign r37 = d67 - r47;



	// The 48 binary multiplications
    assign p0  = l0_reg  * r0_reg;
    assign p1  = l1_reg  * r1_reg;
    assign p2  = l2_reg  * r2_reg;
    assign p3  = l3_reg  * r3_reg;
    assign p4  = l4_reg  * r4_reg;
    assign p5  = l5_reg  * r5_reg;
    assign p6  = l6_reg  * r6_reg;
    assign p7  = l7_reg  * r7_reg;
    assign p8  = l8_reg  * r8_reg;
    assign p9  = l9_reg  * r9_reg;
    assign p10 = l10_reg * r10_reg;
    assign p11 = l11_reg * r11_reg;
    assign p12 = l12_reg * r12_reg;
    assign p13 = l13_reg * r13_reg;
    assign p14 = l14_reg * r14_reg;
    assign p15 = l15_reg * r15_reg;
    assign p16 = l16_reg * r16_reg;
    assign p17 = l17_reg * r17_reg;
    assign p18 = l18_reg * r18_reg;
    assign p19 = l19_reg * r19_reg;
    assign p20 = l20_reg * r20_reg;
    assign p21 = l21_reg * r21_reg;
    assign p22 = l22_reg * r22_reg;
    assign p23 = l23_reg * r23_reg;
    assign p24 = l24_reg * r24_reg;
    assign p25 = l25_reg * r25_reg;
    assign p26 = l26_reg * r26_reg;
    assign p27 = l27_reg * r27_reg;
    assign p28 = l28_reg * r28_reg;
    assign p29 = l29_reg * r29_reg;
    assign p30 = l30_reg * r30_reg;
    assign p31 = l31_reg * r31_reg;
    assign p32 = l32_reg * r32_reg;
    assign p33 = l33_reg * r33_reg;
    assign p34 = l34_reg * r34_reg;
    assign p35 = l35_reg * r35_reg;
    assign p36 = l36_reg * r36_reg;
    assign p37 = l37_reg * r37_reg;
    assign p38 = l38_reg * r38_reg;
    assign p39 = l39_reg * r39_reg;
    assign p40 = l40_reg * r40_reg;
    assign p41 = l41_reg * r41_reg;
    assign p42 = l42_reg * r42_reg;
    assign p43 = l43_reg * r43_reg;
    assign p44 = l44_reg * r44_reg;
    assign p45 = l45_reg * r45_reg;
    assign p46 = l46_reg * r46_reg;
    assign p47 = l47_reg * r47_reg;

	// P block
	assign q5  = $signed({p44_reg,1'b0}) - $signed({p34_reg,1'b0});
    assign q6  = $signed({p20_reg,1'b0}) + $signed({p33_reg,1'b0}) - $signed({p41_reg,1'b0});
    assign q8  = $signed({p24_reg,1'b0}) - $signed({p32_reg,1'b0});
    assign q15 = $signed({p13_reg,1'b0}) + $signed({p29_reg,1'b0}) - $signed({p3_reg,1'b0});

    //wire signed [ 2 * w - 1 + 4 : 0] $signed({p12,1'b0});  // signal num: 226
    wire signed [ 2 * w - 1 + 4 + 1 : 0] p12_sl1;
    assign p12_sl1 = ($signed({p12_reg,1'b0}) <<< 1);
    assign q17 = $signed({p15_reg,1'b0}) + $signed({p40_reg,1'b0}) + p12_sl1 + $signed({p11_reg,1'b0});

    assign k71 = ($signed({p29_reg,1'b0}) + $signed({p26_reg,1'b0})) <<< 1;
    assign k69 = ($signed({p41_reg,1'b0}) - $signed({p30_reg,1'b0})) <<< 1;
    assign k68 = ($signed({p20_reg,1'b0}) - $signed({p1_reg,1'b0})) <<< 1;
    assign k67 = ($signed({p46_reg,1'b0}) - $signed({p13_reg,1'b0})) <<< 1;
    assign k66 = ($signed({p32_reg,1'b0}) - $signed({p28_reg,1'b0})) >>> 1;
    assign k65 = ($signed({p0_reg,1'b0}) + $signed({p44_reg,1'b0})) >>> 1;
    assign k63 = ($signed({p39_reg,1'b0}) + $signed({p30_reg,1'b0}) + $signed({p1_reg,1'b0})) >>> 1;
    assign k60 = ($signed({p26_reg,1'b0}) + $signed({p46_reg,1'b0}) + $signed({p16_reg,1'b0})) >>> 1;
    assign q19 = q8 - $signed({p28_reg,1'b0}) - $signed({p8_reg,1'b0});
    assign q21 = q5 - $signed({p45_reg,1'b0});
    assign q26 = $signed({p18_reg,1'b0}) - $signed({p31_reg,1'b0}) - ($signed({p5_reg,1'b0}) <<< 1) - k68 - k67;
    assign q27 = $signed({p47_reg,1'b0}) + k66;
    assign q30 = ($signed({p2_reg,1'b0}) <<< 1) + q15 + q6;
    assign k56 = (q15 - q6) >>> 1;
    assign q31 = k60 - k63;
    assign q37 = $signed({p5_reg,1'b0}) - $signed({p18_reg,1'b0}) - ($signed({p22_reg,1'b0}) <<< 1) - q17 + q19;
    assign q42 = (($signed({p37_reg,1'b0}) - $signed({p43_reg,1'b0})) <<< 1) - (k56 <<< 2);
    assign q44 = q8 + q21 - q26;
    assign q46 = k63 + q27 + k60 - (q30 >>> 1);
    assign z43 = ($signed({p42_reg,1'b0}) + q46 + k65) >>> 1;
    assign z42 = ($signed({p38_reg,1'b0}) + q46) >>> 1;
    assign z41 = ($signed({p36_reg,1'b0}) + $signed({p22_reg,1'b0}) - $signed({p37_reg,1'b0}) - q31 + k56) >>> 1;
    assign z40 = ($signed({p0_reg,1'b0}) - $signed({p27_reg,1'b0}) - q5 - (q17 <<< 1) + q19 - q42) >>> 3;
    assign z39 = ($signed({p25_reg,1'b0}) + $signed({p45_reg,1'b0}) + (($signed({p12_reg,1'b0}) - $signed({p22_reg,1'b0})) <<< 1) + q42) >>> 2;
    assign z38 = ($signed({p23_reg,1'b0}) + ((-$signed({p12_reg,1'b0}) - $signed({p22_reg,1'b0})) <<< 1) + q44) >>> 2;
    assign z37 = (q26 - $signed({p21_reg,1'b0}) - $signed({p11_reg,1'b0}) - k71 - k69 - (($signed({p15_reg,1'b0}) + q21) <<< 1)) >>> 3;
    assign z36 = ($signed({p17_reg,1'b0}) + q37) >>> 2;
    assign z35 = ($signed({p14_reg,1'b0}) - k65 - q27 + q30) >>> 2;
    assign z34 = ($signed({p9_reg,1'b0}) + $signed({p43_reg,1'b0}) - $signed({p12_reg,1'b0}) + k56 + q31) >>> 1;
    assign z33 = ($signed({p7_reg,1'b0}) + $signed({p15_reg,1'b0}) + k69) >>> 2;
    assign z32 = ($signed({p6_reg,1'b0}) + k66 - $signed({p2_reg,1'b0})) >>> 1;
    assign q52 = (($signed({p4_reg,1'b0}) + q44) >>> 2) + z37;
    assign z31 = z35 + z40;
    assign z30 = z40 - z35;
    assign q55 = (($signed({p5_reg,1'b0}) + k68 - $signed({p10_reg,1'b0})) >>> 2) - z32;
    assign q56 = z37 - z31;
    assign C42 = z36 - z30;
    assign z23 = z34 - z30;
    assign C32 = z30 - z32;
    assign C12 = z32 + z31;
    assign q57 = z31 + z42;
    assign C22 = z31 - z36;
    assign q58 = (($signed({p19_reg,1'b0}) + k67 + q37) >>> 2) - q57;
    assign C11 = z34 - q57;
    assign C34 = q52 - q55 + z23;
    assign C31 = z42 + z23;
    assign q59 = (($signed({p35_reg,1'b0}) + k71 - $signed({p40_reg,1'b0})) >>> 2) + q56;
    assign C14 = z34 + q55 + q56;
    assign z18 = z43 + C22;
    assign z16 = z43 + C42;
    assign C33 = z39 - z37 - q58;
    assign C13 = q58 - z37 - z38;
    assign C44 = z33 + q52 + z18;
    assign C41 = z18 - z41;
    assign C43 = q59 - z41 - z39;
    assign C23 = z41 + z38 + q59;
    assign C24 = z33 + z37 + z16;
    assign C21 = z41 + z16;




	// Pack the C output
	assign C[0][0] = C11>>>1;
    assign C[0][1] = C12>>>1;
    assign C[0][2] = C13>>>1;
    assign C[0][3] = C14>>>1;
	assign C[1][0] = C21>>>1;
    assign C[1][1] = C22>>>1;
    assign C[1][2] = C23>>>1;
    assign C[1][3] = C24>>>1;
	assign C[2][0] = C31>>>1;
    assign C[2][1] = C32>>>1;
    assign C[2][2] = C33>>>1;
    assign C[2][3] = C34>>>1;
	assign C[3][0] = C41>>>1;
    assign C[3][1] = C42>>>1;
    assign C[3][2] = C43>>>1;
    assign C[3][3] = C44>>>1;


endmodule


module register #( parameter numBit = 8)(d,q,r,ck);
input wire [numBit-1:0] d;
output reg [numBit-1:0] q;
input wire r,ck;

//always @(posedge ck, posedge r)
always @(posedge ck)
begin
if (r)
        q<={numBit{1'b0}};
else
        q<=d;
end
endmodule


