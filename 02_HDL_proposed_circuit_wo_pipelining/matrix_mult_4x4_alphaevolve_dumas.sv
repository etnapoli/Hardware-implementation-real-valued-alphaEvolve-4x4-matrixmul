module matrix_mult_4x4_alphaevolve_dumas #(parameter w = 8)(
    input  wire signed [w-1:0] A [0:3][0:3],
    input  wire signed [w-1:0] B [0:3][0:3],
    output wire signed [2*w+1:0] C [0:3][0:3] //2*w +2 bits
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
wire signed [ 1 * w - 1 + 4 : 0] l0;  // signal num: 53
wire signed [ 1 * w - 1 + 2 : 0] l1;  // signal num: 54
wire signed [ 1 * w - 1 + 2 : 0] l2;  // signal num: 55
wire signed [ 1 * w - 1 + 3 : 0] l3;  // signal num: 56
wire signed [ 1 * w - 1 + 4 : 0] l4;  // signal num: 57
wire signed [ 1 * w - 1 + 4 : 0] l5;  // signal num: 58
wire signed [ 1 * w - 1 + 2 : 0] l6;  // signal num: 59
wire signed [ 1 * w - 1 + 4 : 0] l7;  // signal num: 60
wire signed [ 1 * w - 1 + 3 : 0] l8;  // signal num: 61
wire signed [ 1 * w - 1 + 2 : 0] l9;  // signal num: 62
wire signed [ 1 * w - 1 + 4 : 0] l10;  // signal num: 63
wire signed [ 1 * w - 1 + 3 : 0] l11;  // signal num: 64
wire signed [ 1 * w - 1 + 2 : 0] l12;  // signal num: 65
wire signed [ 1 * w - 1 + 2 : 0] l13;  // signal num: 66
wire signed [ 1 * w - 1 + 3 : 0] l14;  // signal num: 67
wire signed [ 1 * w - 1 + 4 : 0] l15;  // signal num: 68
wire signed [ 1 * w - 1 + 3 : 0] l16;  // signal num: 69
wire signed [ 1 * w - 1 + 4 : 0] l17;  // signal num: 70
wire signed [ 1 * w - 1 + 3 : 0] l18;  // signal num: 71
wire signed [ 1 * w - 1 + 4 : 0] l19;  // signal num: 72
wire signed [ 1 * w - 1 + 2 : 0] l20;  // signal num: 73
wire signed [ 1 * w - 1 + 3 : 0] l21;  // signal num: 74
wire signed [ 1 * w - 1 + 2 : 0] l22;  // signal num: 75
wire signed [ 1 * w - 1 + 4 : 0] l23;  // signal num: 76
wire signed [ 1 * w - 1 + 3 : 0] l24;  // signal num: 77
wire signed [ 1 * w - 1 + 4 : 0] l25;  // signal num: 78
wire signed [ 1 * w - 1 + 2 : 0] l26;  // signal num: 79
wire signed [ 1 * w - 1 + 3 : 0] l27;  // signal num: 80
wire signed [ 1 * w - 1 + 4 : 0] l28;  // signal num: 81
wire signed [ 1 * w - 1 + 2 : 0] l29;  // signal num: 82
wire signed [ 1 * w - 1 + 2 : 0] l30;  // signal num: 83
wire signed [ 1 * w - 1 + 3 : 0] l31;  // signal num: 84
wire signed [ 1 * w - 1 + 4 : 0] l32;  // signal num: 85
wire signed [ 1 * w - 1 + 3 : 0] l33;  // signal num: 86
wire signed [ 1 * w - 1 + 3 : 0] l34;  // signal num: 87
wire signed [ 1 * w - 1 + 4 : 0] l35;  // signal num: 88
wire signed [ 1 * w - 1 + 2 : 0] l36;  // signal num: 89
wire signed [ 1 * w - 1 + 3 : 0] l37;  // signal num: 90
wire signed [ 1 * w - 1 + 2 : 0] l38;  // signal num: 91
wire signed [ 1 * w - 1 + 3 : 0] l39;  // signal num: 92
wire signed [ 1 * w - 1 + 4 : 0] l40;  // signal num: 93
wire signed [ 1 * w - 1 + 2 : 0] l41;  // signal num: 94
wire signed [ 1 * w - 1 + 2 : 0] l42;  // signal num: 95
wire signed [ 1 * w - 1 + 3 : 0] l43;  // signal num: 96
wire signed [ 1 * w - 1 + 4 : 0] l44;  // signal num: 97
wire signed [ 1 * w - 1 + 4 : 0] l45;  // signal num: 98
wire signed [ 1 * w - 1 + 2 : 0] l46;  // signal num: 99
wire signed [ 1 * w - 1 + 3 : 0] l47;  // signal num: 100
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
wire signed [ 1 * w - 1 + 1 : 0] r0;  // signal num: 123
wire signed [ 1 * w - 1 + 2 : 0] r1;  // signal num: 124
wire signed [ 1 * w - 1 + 1 : 0] r2;  // signal num: 125
wire signed [ 1 * w - 1 + 2 : 0] r3;  // signal num: 126
wire signed [ 1 * w - 1 + 3 : 0] r3_sl1;  // signal num: 126 Sh left 1
wire signed [ 1 * w - 1 + 3 : 0] r4;  // signal num: 127
wire signed [ 1 * w - 1 + 2 : 0] r5;  // signal num: 128
wire signed [ 1 * w - 1 + 1 : 0] r6;  // signal num: 129
wire signed [ 1 * w - 1 + 2 : 0] r7;  // signal num: 130
wire signed [ 1 * w - 1 + 4 : 0] r8;  // signal num: 131
wire signed [ 1 * w - 1 + 3 : 0] r9;  // signal num: 132
wire signed [ 1 * w - 1 + 2 : 0] r10;  // signal num: 133
wire signed [ 1 * w - 1 + 4 : 0] r11;  // signal num: 134
wire signed [ 1 * w - 1 + 3 : 0] r12;  // signal num: 135
wire signed [ 1 * w - 1 + 2 : 0] r13;  // signal num: 136
wire signed [ 1 * w - 1 + 1 : 0] r14;  // signal num: 137
wire signed [ 1 * w - 1 + 2 : 0] r14_sl1;  // signal num: 137 Sh left 1
wire signed [ 1 * w - 1 + 2 : 0] r15;  // signal num: 138
wire signed [ 1 * w - 1 + 2 : 0] r16;  // signal num: 139
wire signed [ 1 * w - 1 + 2 : 0] r17;  // signal num: 140
wire signed [ 1 * w - 1 + 4 : 0] r18;  // signal num: 141
wire signed [ 1 * w - 1 + 2 : 0] r19;  // signal num: 142
wire signed [ 1 * w - 1 + 2 : 0] r20;  // signal num: 143
wire signed [ 1 * w - 1 + 4 : 0] r21;  // signal num: 144
wire signed [ 1 * w - 1 + 3 : 0] r22;  // signal num: 145
wire signed [ 1 * w - 1 + 3 : 0] r23;  // signal num: 146
wire signed [ 1 * w - 1 + 4 : 0] r24;  // signal num: 147
wire signed [ 1 * w - 1 + 3 : 0] r25;  // signal num: 148
wire signed [ 1 * w - 1 + 2 : 0] r26;  // signal num: 149
wire signed [ 1 * w - 1 + 4 : 0] r27;  // signal num: 150
wire signed [ 1 * w - 1 + 1 : 0] r28;  // signal num: 151
wire signed [ 1 * w - 1 + 2 : 0] r29;  // signal num: 152
wire signed [ 1 * w - 1 + 2 : 0] r30;  // signal num: 153
wire signed [ 1 * w - 1 + 4 : 0] r31;  // signal num: 154
wire signed [ 1 * w - 1 + 2 : 0] r32;  // signal num: 155
wire signed [ 1 * w - 1 + 2 : 0] r33;  // signal num: 156
wire signed [ 1 * w - 1 + 4 : 0] r34;  // signal num: 157
wire signed [ 1 * w - 1 + 2 : 0] r35;  // signal num: 158
wire signed [ 1 * w - 1 + 3 : 0] r36;  // signal num: 159
wire signed [ 1 * w - 1 + 3 : 0] r37;  // signal num: 160
wire signed [ 1 * w - 1 + 1 : 0] r38;  // signal num: 161
wire signed [ 1 * w - 1 + 2 : 0] r39;  // signal num: 162
wire signed [ 1 * w - 1 + 3 : 0] r39_sl1;  // signal num: 162 Sh left 1
wire signed [ 1 * w - 1 + 2 : 0] r40;  // signal num: 163
wire signed [ 1 * w - 1 + 2 : 0] r41;  // signal num: 164
wire signed [ 1 * w - 1 + 1 : 0] r42;  // signal num: 165
wire signed [ 1 * w - 1 + 3 : 0] r43;  // signal num: 166
wire signed [ 1 * w - 1 + 1 : 0] r44;  // signal num: 167
wire signed [ 1 * w - 1 + 3 : 0] r45;  // signal num: 168
wire signed [ 1 * w - 1 + 2 : 0] r46;  // signal num: 169
wire signed [ 1 * w - 1 + 1 : 0] r47;  // signal num: 170
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
wire signed [ 2 * w - 1 + 3 : 0] p1;  // signal num: 215
wire signed [ 2 * w - 1 + 2 : 0] p2;  // signal num: 216
wire signed [ 2 * w - 1 + 4 : 0] p3;  // signal num: 217
wire signed [ 2 * w - 1 + 6 : 0] p4;  // signal num: 218
wire signed [ 2 * w - 1 + 5 : 0] p5;  // signal num: 219
wire signed [ 2 * w - 1 + 2 : 0] p6;  // signal num: 220
wire signed [ 2 * w - 1 + 5 : 0] p7;  // signal num: 221
wire signed [ 2 * w - 1 + 6 : 0] p8;  // signal num: 222
wire signed [ 2 * w - 1 + 4 : 0] p9;  // signal num: 223
wire signed [ 2 * w - 1 + 5 : 0] p10;  // signal num: 224
wire signed [ 2 * w - 1 + 6 : 0] p11;  // signal num: 225
wire signed [ 2 * w - 1 + 4 : 0] p12;  // signal num: 226
wire signed [ 2 * w - 1 + 3 : 0] p13;  // signal num: 227
wire signed [ 2 * w - 1 + 3 : 0] p14;  // signal num: 228
wire signed [ 2 * w - 1 + 5 : 0] p15;  // signal num: 229
wire signed [ 2 * w - 1 + 4 : 0] p16;  // signal num: 230
wire signed [ 2 * w - 1 + 5 : 0] p17;  // signal num: 231
wire signed [ 2 * w - 1 + 6 : 0] p18;  // signal num: 232
wire signed [ 2 * w - 1 + 5 : 0] p19;  // signal num: 233
wire signed [ 2 * w - 1 + 3 : 0] p20;  // signal num: 234
wire signed [ 2 * w - 1 + 6 : 0] p21;  // signal num: 235
wire signed [ 2 * w - 1 + 4 : 0] p22;  // signal num: 236
wire signed [ 2 * w - 1 + 6 : 0] p23;  // signal num: 237
wire signed [ 2 * w - 1 + 6 : 0] p24;  // signal num: 238
wire signed [ 2 * w - 1 + 6 : 0] p25;  // signal num: 239
wire signed [ 2 * w - 1 + 4 : 0] p26;  // signal num: 240
wire signed [ 2 * w - 1 + 6 : 0] p27;  // signal num: 241
wire signed [ 2 * w - 1 + 4 : 0] p28;  // signal num: 242
wire signed [ 2 * w - 1 + 3 : 0] p29;  // signal num: 243
wire signed [ 2 * w - 1 + 3 : 0] p30;  // signal num: 244
wire signed [ 2 * w - 1 + 6 : 0] p31;  // signal num: 245
wire signed [ 2 * w - 1 + 4 : 0] p32;  // signal num: 246
wire signed [ 2 * w - 1 + 4 : 0] p33;  // signal num: 247
wire signed [ 2 * w - 1 + 6 : 0] p34;  // signal num: 248
wire signed [ 2 * w - 1 + 5 : 0] p35;  // signal num: 249
wire signed [ 2 * w - 1 + 4 : 0] p36;  // signal num: 250
wire signed [ 2 * w - 1 + 5 : 0] p37;  // signal num: 251
wire signed [ 2 * w - 1 + 2 : 0] p38;  // signal num: 252
wire signed [ 2 * w - 1 + 4 : 0] p39;  // signal num: 253
wire signed [ 2 * w - 1 + 5 : 0] p40;  // signal num: 254
wire signed [ 2 * w - 1 + 3 : 0] p41;  // signal num: 255
wire signed [ 2 * w - 1 + 2 : 0] p42;  // signal num: 256
wire signed [ 2 * w - 1 + 5 : 0] p43;  // signal num: 257
wire signed [ 2 * w - 1 + 4 : 0] p44;  // signal num: 258
wire signed [ 2 * w - 1 + 6 : 0] p45;  // signal num: 259
wire signed [ 2 * w - 1 + 3 : 0] p46;  // signal num: 260
wire signed [ 2 * w - 1 + 3 : 0] p47;  // signal num: 261

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
	assign p0  = l0  * r0;
    assign p1  = l1  * r1;
    assign p2  = l2  * r2;
    assign p3  = l3  * r3;
    assign p4  = l4  * r4;
    assign p5  = l5  * r5;
    assign p6  = l6  * r6;
    assign p7  = l7  * r7;
    assign p8  = l8  * r8;
    assign p9  = l9  * r9;
    assign p10 = l10 * r10;
    assign p11 = l11 * r11;
    assign p12 = l12 * r12;
    assign p13 = l13 * r13;
    assign p14 = l14 * r14;
    assign p15 = l15 * r15;
    assign p16 = l16 * r16;
    assign p17 = l17 * r17;
    assign p18 = l18 * r18;
    assign p19 = l19 * r19;
    assign p20 = l20 * r20;
    assign p21 = l21 * r21;
    assign p22 = l22 * r22;
    assign p23 = l23 * r23;
    assign p24 = l24 * r24;
    assign p25 = l25 * r25;
    assign p26 = l26 * r26;
    assign p27 = l27 * r27;
    assign p28 = l28 * r28;
    assign p29 = l29 * r29;
    assign p30 = l30 * r30;
    assign p31 = l31 * r31;
    assign p32 = l32 * r32;
    assign p33 = l33 * r33;
    assign p34 = l34 * r34;
    assign p35 = l35 * r35;
    assign p36 = l36 * r36;
    assign p37 = l37 * r37;
    assign p38 = l38 * r38;
    assign p39 = l39 * r39;
    assign p40 = l40 * r40;
    assign p41 = l41 * r41;
    assign p42 = l42 * r42;
    assign p43 = l43 * r43;
    assign p44 = l44 * r44;
    assign p45 = l45 * r45;
    assign p46 = l46 * r46;
    assign p47 = l47 * r47;

	// P block
	assign q5  = $signed({p44,1'b0}) - $signed({p34,1'b0});
    assign q6  = $signed({p20,1'b0}) + $signed({p33,1'b0}) - $signed({p41,1'b0});
    assign q8  = $signed({p24,1'b0}) - $signed({p32,1'b0});
    assign q15 = $signed({p13,1'b0}) + $signed({p29,1'b0}) - $signed({p3,1'b0});

    //wire signed [ 2 * w - 1 + 4 : 0] $signed({p12,1'b0});  // signal num: 226
    wire signed [ 2 * w - 1 + 4 + 1 : 0] p12_sl1;  
    assign p12_sl1 = ($signed({p12,1'b0}) <<< 1);
    assign q17 = $signed({p15,1'b0}) + $signed({p40,1'b0}) + p12_sl1 + $signed({p11,1'b0});
    
    assign k71 = ($signed({p29,1'b0}) + $signed({p26,1'b0})) <<< 1;
    assign k69 = ($signed({p41,1'b0}) - $signed({p30,1'b0})) <<< 1;
    assign k68 = ($signed({p20,1'b0}) - $signed({p1,1'b0})) <<< 1;
    assign k67 = ($signed({p46,1'b0}) - $signed({p13,1'b0})) <<< 1;
    assign k66 = ($signed({p32,1'b0}) - $signed({p28,1'b0})) >>> 1;
    assign k65 = ($signed({p0,1'b0}) + $signed({p44,1'b0})) >>> 1;
    assign k63 = ($signed({p39,1'b0}) + $signed({p30,1'b0}) + $signed({p1,1'b0})) >>> 1;
    assign k60 = ($signed({p26,1'b0}) + $signed({p46,1'b0}) + $signed({p16,1'b0})) >>> 1;
    assign q19 = q8 - $signed({p28,1'b0}) - $signed({p8,1'b0});
    assign q21 = q5 - $signed({p45,1'b0});
    assign q26 = $signed({p18,1'b0}) - $signed({p31,1'b0}) - ($signed({p5,1'b0}) <<< 1) - k68 - k67;
    assign q27 = $signed({p47,1'b0}) + k66;
    assign q30 = ($signed({p2,1'b0}) <<< 1) + q15 + q6;
    assign k56 = (q15 - q6) >>> 1;
    assign q31 = k60 - k63;
    assign q37 = $signed({p5,1'b0}) - $signed({p18,1'b0}) - ($signed({p22,1'b0}) <<< 1) - q17 + q19;
    assign q42 = (($signed({p37,1'b0}) - $signed({p43,1'b0})) <<< 1) - (k56 <<< 2);
    assign q44 = q8 + q21 - q26;
    assign q46 = k63 + q27 + k60 - (q30 >>> 1);
    assign z43 = ($signed({p42,1'b0}) + q46 + k65) >>> 1;
    assign z42 = ($signed({p38,1'b0}) + q46) >>> 1;
    assign z41 = ($signed({p36,1'b0}) + $signed({p22,1'b0}) - $signed({p37,1'b0}) - q31 + k56) >>> 1;
    assign z40 = ($signed({p0,1'b0}) - $signed({p27,1'b0}) - q5 - (q17 <<< 1) + q19 - q42) >>> 3;
    assign z39 = ($signed({p25,1'b0}) + $signed({p45,1'b0}) + (($signed({p12,1'b0}) - $signed({p22,1'b0})) <<< 1) + q42) >>> 2;
    assign z38 = ($signed({p23,1'b0}) + ((-$signed({p12,1'b0}) - $signed({p22,1'b0})) <<< 1) + q44) >>> 2;
    assign z37 = (q26 - $signed({p21,1'b0}) - $signed({p11,1'b0}) - k71 - k69 - (($signed({p15,1'b0}) + q21) <<< 1)) >>> 3;
    assign z36 = ($signed({p17,1'b0}) + q37) >>> 2;
    assign z35 = ($signed({p14,1'b0}) - k65 - q27 + q30) >>> 2;
    assign z34 = ($signed({p9,1'b0}) + $signed({p43,1'b0}) - $signed({p12,1'b0}) + k56 + q31) >>> 1;
    assign z33 = ($signed({p7,1'b0}) + $signed({p15,1'b0}) + k69) >>> 2;
    assign z32 = ($signed({p6,1'b0}) + k66 - $signed({p2,1'b0})) >>> 1;
    assign q52 = (($signed({p4,1'b0}) + q44) >>> 2) + z37;
    assign z31 = z35 + z40;
    assign z30 = z40 - z35;
    assign q55 = (($signed({p5,1'b0}) + k68 - $signed({p10,1'b0})) >>> 2) - z32;
    assign q56 = z37 - z31;
    assign C42 = z36 - z30;
    assign z23 = z34 - z30;
    assign C32 = z30 - z32;
    assign C12 = z32 + z31;
    assign q57 = z31 + z42;
    assign C22 = z31 - z36;
    assign q58 = (($signed({p19,1'b0}) + k67 + q37) >>> 2) - q57;
    assign C11 = z34 - q57;
    assign C34 = q52 - q55 + z23;
    assign C31 = z42 + z23;
    assign q59 = (($signed({p35,1'b0}) + k71 - $signed({p40,1'b0})) >>> 2) + q56;
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
