// Do not use the syscall functions provided in this simulator.
// code:
module instmem_v_check2 (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:63];
    assign rom[7'h00] = 32'b11111111110000010000000100010011; // addi        sp, sp, -4
    assign rom[7'h01] = 32'b00000000000100010010001000100011; // sw          ra, 4(sp)
    assign rom[7'h02] = 32'b00000000010000000000010100010011; // addi        a0, a
    assign rom[7'h03] = 32'b00000001110000000000010110010011; // addi        a1, b
    assign rom[7'h04] = 32'b00000000011000000000011000010011; // addi        a2, 6
    assign rom[7'h05] = 32'b00000000100000000000011010010011; // addi        a3, 8
    assign rom[7'h06] = 32'b00000001000001100111010001010111; // vsetvli     s0, a2, e32, m1, tu, mu
    assign rom[7'h07] = 32'b00000010000001010110000010000111; // vle32.v     v1, (a0)
    assign rom[7'h08] = 32'b00000010000001011110000100000111; // vle32.v     v2, (a1)
    assign rom[7'h09] = 32'b01000100000100010000001101010111; // vmadc.vvm   v6, v1, v2, v0
    assign rom[7'h0a] = 32'b01000000000100010000000111010111; // vadc.vvm    v3, v1, v2, v0
    assign rom[7'h0b] = 32'b01100110011000110010000001010111; // vmand.mm    v0, v6, v6
    assign rom[7'h0c] = 32'b01000000000100010000001001010111; // vadc.vvm    v4, v1, v2, v0
    assign rom[7'h0d] = 32'b01101110000000000010000001010111; // vmxor.mm    v0, v0, v0
    assign rom[7'h0e] = 32'b01000100000101101100001101010111; // vmadc.vxm   v6, v1, a3, v0
    assign rom[7'h0f] = 32'b01000000000101101100000111010111; // vadc.vxm    v3, v1, a3, v0
    assign rom[7'h10] = 32'b01100110011000110010000001010111; // vmand.mm    v0, v6, v6
    assign rom[7'h11] = 32'b01000000000101101100001001010111; // vadc.vxm    v4, v1, a3, v0
    assign rom[7'h12] = 32'b01101110000000000010000001010111; // vmxor.mm    v0, v0, v0
    assign rom[7'h13] = 32'b01000100000100111011001101010111; // vmadc.vim   v6, v1, 7, v0
    assign rom[7'h14] = 32'b01000000000100111011000111010111; // vadc.vim    v3, v1, 7, v0
    assign rom[7'h15] = 32'b01100110011000110010000001010111; // vmand.mm    v0, v6, v6
    assign rom[7'h16] = 32'b01000000000100111011001001010111; // vadc.vim    v4, v1, 7, v0
    assign rom[7'h17] = 32'b01101110000000000010000001010111; // vmxor.mm    v0, v0, v0
    assign rom[7'h18] = 32'b01001110000100010000001111010111; // vmsbc.vvm   v7, v1, v2, v0
    assign rom[7'h19] = 32'b01001000000100010000000111010111; // vsbc.vvm    v3, v1, v2, v0
    assign rom[7'h1a] = 32'b01100110011100111010000001010111; // vmand.mm    v0, v7, v7
    assign rom[7'h1b] = 32'b01001000000100010000001001010111; // vsbc.vvm    v4, v1, v2, v0
    assign rom[7'h1c] = 32'b01101110000000000010000001010111; // vmxor.mm    v0, v0, v0
    assign rom[7'h1d] = 32'b01001110000101101100001111010111; // vmsbc.vxm   v7, v1, a3, v0
    assign rom[7'h1e] = 32'b01001000000101101100000111010111; // vsbc.vxm    v3, v1, a3, v0
    assign rom[7'h1f] = 32'b01100110011100111010000001010111; // vmand.mm    v0, v7, v7
    assign rom[7'h20] = 32'b01001000000101101100001001010111; // vsbc.vxm    v4, v1, a3, v0
    assign rom[7'h21] = 32'b01101110000000000010000001010111; // vmxor.mm    v0, v0, v0
    assign rom[7'h22] = 32'b01100010011000111010001011010111; // vmandnot.mm v5, v6, v7
    assign rom[7'h23] = 32'b01101010011000111010001011010111; // vmor.mm     v5, v6, v7
    assign rom[7'h24] = 32'b01110010011000111010001011010111; // vmornot.mm  v5, v6, v7
    assign rom[7'h25] = 32'b01111010011000111010001011010111; // vmnor.mm    v5, v6, v7
    assign rom[7'h26] = 32'b01110110011100111010001011010111; // vmnand.mm   v5, v7, v7
    assign rom[7'h27] = 32'b01111110000000000010000001010111; // vmxnor.mm   v0, v0, v0
    assign rom[7'h28] = 32'b01000010000100010000001101010111; // vmadc.vv    v6, v1, v2
    assign rom[7'h29] = 32'b01000010000101101100001101010111; // vmadc.vx    v6, v1, a3
    assign rom[7'h2a] = 32'b01000010000100111011001101010111; // vmadc.vi    v6, v1, 7
    assign rom[7'h2b] = 32'b01000110000100010000001101010111; // vmsbc.vv    v7, v1, v2
    assign rom[7'h2c] = 32'b01000110000101101100001101010111; // vmsbc.vx    v7, v1, a3
    assign rom[7'h2d] = 32'b00000000000000000000000000000000; // 
    assign inst = rom[a[8:2]];
endmodule
