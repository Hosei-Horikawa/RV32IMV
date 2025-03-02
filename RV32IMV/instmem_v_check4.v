module instmem_v_check4 (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:63];
    assign rom[7'h00] = 32'b11111111110000010000000100010011; // addi        sp, sp, -4
    assign rom[7'h01] = 32'b00000000000100010010001000100011; // sw          ra, 4(sp)
    assign rom[7'h02] = 32'b00000000010000000000010100010011; // addi        a0, 0, a
    assign rom[7'h03] = 32'b00000001010000000000010110010011; // addi        a1, 0, b
    assign rom[7'h04] = 32'b00000000010000000000011000010011; // addi        a2, 0, 4
    assign rom[7'h05] = 32'b00000000010100000000011010010011; // addi        a3, 0, 5
    assign rom[7'h06] = 32'b00000001000001100111010001010111; // vsetvli     s0, a2, e32, m1, tu, mu
    assign rom[7'h07] = 32'b00000010000001010110000010000111; // vle32.v     v1, (a0)
    assign rom[7'h08] = 32'b00000010000001011110000100000111; // vle32.v     v2, (a1)
    assign rom[7'h09] = 32'b10000000000100010010000111010111; // vdivu.vv    v3, v1, v2
    assign rom[7'h0a] = 32'b10001000000100010010001001010111; // vremu.vv    v4, v1, v2
    assign rom[7'h0b] = 32'b10000000000101100110000111010111; // vdivu.vx    v3, v1, a2
    assign rom[7'h0c] = 32'b10001000000101100110001001010111; // vremu.vx    v4, v1, a2
    assign rom[7'h0d] = 32'b10000100000100010010000111010111; // vdiv.vv     v3, v1, v2
    assign rom[7'h0e] = 32'b10001100000100010010001001010111; // vrem.vv     v4, v1, v2
    assign rom[7'h0f] = 32'b10000100000101100110000111010111; // vdiv.vx     v3, v1, a2
    assign rom[7'h10] = 32'b10001100000101100110001001010111; // vrem.vx     v4, v1, a2
    assign rom[7'h11] = 32'b10000100000101100110000111010111; // vdiv.vx     v3, v1, a3
    assign rom[7'h12] = 32'b10001100000101100110001001010111; // vrem.vx     v4, v1, a3
    assign rom[7'h13] = 32'b10010000000100010010000111010111; // vmulhu.vv   v3, v1, v2
    assign rom[7'h14] = 32'b10010100000100010010001001010111; // vmul.vv     v4, v1, v2
    assign rom[7'h15] = 32'b10010000000101100110000111010111; // vmulhu.vx   v3, v1, a2
    assign rom[7'h16] = 32'b10010100000101100110001001010111; // vmul.vx     v4, v1, a2
    assign rom[7'h17] = 32'b10011000000100010010000111010111; // vmulhsu.vv  v3, v1, v2
    assign rom[7'h18] = 32'b10010100000100010010001001010111; // vmul.vv     v4, v1, v2
    assign rom[7'h19] = 32'b10011000000101100110000111010111; // vmulhsu.vx  v3, v1, a2
    assign rom[7'h1a] = 32'b10010100000101100110001001010111; // vmul.vx     v4, v1, a2
    assign rom[7'h1b] = 32'b10011100000100010010000111010111; // vmulh.vv    v3, v1, v2
    assign rom[7'h1c] = 32'b10010100000100010010001001010111; // vmul.vv     v4, v1, v2
    assign rom[7'h1d] = 32'b10011100000101100110000111010111; // vmulh.vx    v3, v1, a2
    assign rom[7'h1e] = 32'b10010100000101100110001001010111; // vmul.vx     v4, v1, a2
    assign rom[7'h1f] = 32'b10011100000101100110000111010111; // vmulh.vx    v3, v1, a3
    assign rom[7'h20] = 32'b10010100000101100110001001010111; // vmul.vx     v4, v1, a3
    assign rom[7'h21] = 32'b00000010010000000000011100010011; // addi        a4, 0, c
    assign rom[7'h22] = 32'b00000010000001110110001010000111; // vle32.v     v5, (a4)
    assign rom[7'h23] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h24] = 32'b10100100000100010010001101010111; // vmadd.vv    v6, v2, v1
    assign rom[7'h25] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h26] = 32'b10100100000101100110001101010111; // vmadd.vx    v6, a2, v1
    assign rom[7'h27] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h28] = 32'b10101100000100010010001101010111; // vnmsub.vv   v6, v2, v1
    assign rom[7'h29] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h2a] = 32'b10101100000101100110001101010111; // vnmsub.vx   v6, a2, v1
    assign rom[7'h2b] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h2c] = 32'b10110100000100010010001101010111; // vmacc.vv    v6, v2, v1
    assign rom[7'h2d] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h2e] = 32'b10110100000101100110001101010111; // vmacc.vx    v6, a2, v1
    assign rom[7'h2f] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h30] = 32'b10111100000100010010001101010111; // vnmsac.vv   v6, v2, v1
    assign rom[7'h31] = 32'b00100100010100101000001101010111; // vand.vv     v6, v5, v5
    assign rom[7'h32] = 32'b10111100000101100110001101010111; // vnmsac.vx   v6, a2, v1
    assign rom[7'h33] = 32'b00000000000000000000000000000000; // 
    assign inst = rom[a[8:2]];
endmodule