module alu_32 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [32:0] sum
);
    assign sum = {1'b0, a} + {1'b0, b};

endmodule
