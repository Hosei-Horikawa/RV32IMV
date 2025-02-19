// Do not use the syscall functions provided in this simulator.
// code:
module instmem_v_check3 (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:63];
    assign rom[7'h00] = 32'b11111111110000010000000100010011; // addi           sp, sp, -4
    assign rom[7'h01] = 32'b00000000000100010010001000100011; // sw             ra, 4(sp)
    assign rom[7'h02] = 32'b00000000010000000000010100010011; // addi           a0, a
    assign rom[7'h03] = 32'b00000001010000000000010110010011; // addi           a1, b
    assign rom[7'h04] = 32'b00000000010000000000011000010011; // addi           a2, 0, 4
    assign rom[7'h05] = 32'b00000000001100000000011010010011; // addi           a3, 0, 3
    assign rom[7'h06] = 32'b00000001000001100111010001010111; // vsetvli        s0, a2, e32, m1, tu, mu
    assign rom[7'h07] = 32'b00000010000001010110000010000111; // vle32.v        v1, (a0)
    assign rom[7'h08] = 32'b00000010000001011110000100000111; // vle32.v        v2, (a1)
    assign rom[7'h09] = 32'b01100000000100010000000001010111; // vmseq.vvm      v0, v1, v2
    assign rom[7'h0a] = 32'b01100000000101101100000001010111; // vmseq.vxm      v0, v1, a3
    assign rom[7'h0b] = 32'b01100000001000110011000001010111; // vmseq.vim      v0, v2, 6
    assign rom[7'h0c] = 32'b01100100000100010000000001010111; // vmsne.vvm      v0, v1, v2
    assign rom[7'h0d] = 32'b01100100000101101100000001010111; // vmsne.vxm      v0, v1, a3
    assign rom[7'h0e] = 32'b01100100001000110011000001010111; // vmsne.vim      v0, v2, 6
    assign rom[7'h0f] = 32'b01101000000100010000000001010111; // vmsltu.vvm     v0, v1, v2
    assign rom[7'h10] = 32'b01011100000100010000000111010111; // vmerge.vvm     v3, v1, v2, v0
    assign rom[7'h11] = 32'b01101000000101101100000001010111; // vmsltu.vxm     v0, v1, a3
    assign rom[7'h12] = 32'b01101100000100010000000001010111; // vmslt.vvm      v0, v1, v2
    assign rom[7'h13] = 32'b01101100000101101100000001010111; // vmslt.vxm      v0, v1, a3
    assign rom[7'h14] = 32'b01110000000100010000000001010111; // vmsleu.vvm     v0, v1, v2
    assign rom[7'h15] = 32'b01110000000101101100000001010111; // vmsleu.vxm     v0, v1, a3
    assign rom[7'h16] = 32'b01011100000101101100000111010111; // vmerge.vxm     v3, v1, a3, v0
    assign rom[7'h17] = 32'b01110000001000110011000001010111; // vmsleu.vim     v0, v2, 6
    assign rom[7'h18] = 32'b01110100000100010000000001010111; // vmsle.vvm      v0, v1, v2
    assign rom[7'h19] = 32'b01110100000101101100000001010111; // vmsle.vxm      v0, v1, a3
    assign rom[7'h1a] = 32'b01110100001000110011000001010111; // vmsle.vxi      v0, v2, 6
    assign rom[7'h1b] = 32'b01011100001000110011000111010111; // vmerge.vvi     v3, v2, 6, v0
    assign rom[7'h1c] = 32'b01111000000101101100000001010111; // vmsgtu.vxm     v0, v1, a3
    assign rom[7'h1d] = 32'b01111000001000110011000001010111; // vmsgtu.vim     v0, v2, 6
    assign rom[7'h1e] = 32'b01111100000101101100000001010111; // vmsgt.vxm      v0, v1, a3
    assign rom[7'h1f] = 32'b01111100001000110011000001010111; // vmsgt.vim      v0, v2, 6
    assign rom[7'h20] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h21] = 32'b00111000001001100100001001010111; // vslideup.vx    v4, v2, a2
    assign rom[7'h22] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h23] = 32'b00111000001000010011001001010111; // vslideup.vi    v4, v2, 2
    assign rom[7'h24] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h25] = 32'b00111000001001100110001001010111; // vslide1up.vx   v4, v2, a2
    assign rom[7'h26] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h27] = 32'b00111100001001100100001001010111; // vslidedown.vx  v4, v2, a2
    assign rom[7'h28] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h29] = 32'b00111100001000010011001001010111; // vslidedown.vi  v4, v2, 2
    assign rom[7'h2a] = 32'b00100100000100001000001001010111; // vand.vv        v4, v1, v1
    assign rom[7'h2b] = 32'b00111100001001100110001001010111; // vslide1down.vx v4, v2, a2
    assign rom[7'h2c] = 32'b00110000000100010000001011010111; // vrgather.vv    v5, v1, v2
    assign rom[7'h2d] = 32'b00110000000101100100001011010111; // vrgather.vx    v5, v1, a2
    assign rom[7'h2e] = 32'b00110000000100011011001011010111; // vrgather.vi    v5, v1, 3
    assign rom[7'h2f] = 32'b01011100000100010010001101010111; // vcompress.vv   v6, v1, v2
    assign rom[7'h30] = 32'b00000000000000000000000000000000; // 
    assign inst = rom[a[8:2]];
endmodule

