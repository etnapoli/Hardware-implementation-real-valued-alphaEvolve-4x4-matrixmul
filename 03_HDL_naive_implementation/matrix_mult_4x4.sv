// SPDX-License-Identifier: CERN-OHL-NC-2.0
// Author: Ettore Napoli
// Affiliation: University of Salerno
// August 2025
// Description: Naive algorithm for real-valued matrix multiplication
module matrix_mult_4x4 #(parameter w = 8)(
    input  signed [w-1:0] A [0:3][0:3],
    input  signed [w-1:0] B [0:3][0:3],
    output signed [2*w+1:0] C [0:3][0:3]  //2*w +2 bits
);

    integer i, j, k;
    reg signed [2*w+1:0] result [0:3][0:3];

    always @(*) begin
        // Initialize result matrix to 0
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                result[i][j] = 0;
                for (k = 0; k < 4; k = k + 1) begin
                    result[i][j] = result[i][j] + A[i][k] * B[k][j];
                end
            end
        end
    end

    // Assign result to output
    genvar x, y;
    generate
        for (x = 0; x < 4; x = x + 1) begin : row
            for (y = 0; y < 4; y = y + 1) begin : col
                assign C[x][y] = result[x][y];
            end
        end
    endgenerate

endmodule
