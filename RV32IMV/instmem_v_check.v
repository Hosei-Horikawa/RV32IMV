// Do not use the syscall functions provided in this simulator.
// code:
module instmem_v_check (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:63];
    assign rom[6'h00] = 32'b11111111110000010000000100010011; // addi      sp, sp, -4
    assign rom[6'h01] = 32'b00000000000100010010001000100011; // sw        ra, 4(sp)
    assign rom[6'h02] = 32'b00000001000000000000010100010011; // addi      a0, a
    assign rom[6'h03] = 32'b00000010000000000000010110010011; // addi      a1, b
    assign rom[6'h04] = 32'b00000000000000001010001000000111; // flw       f1, (a) 
    assign rom[6'h05] = 32'b00000000000000002010001010000111; // flw       f2, (b) 
    assign rom[6'h06] = 32'b00000000001000001000000111010011; // fadd      f3, f1, f2
    assign rom[6'h07] = 32'b00001000001000001000001001010011; // fsub      f4, f1, f2
    assign rom[6'h08] = 32'b00010000001000001000001011010011; // fmul      f5, f1, f2
    assign rom[6'h09] = 32'b00011000001000001000001101010011; // fdiv      f6, f1, f2
    assign rom[6'h0a] = 32'b00100000001000001000001111010011; // fsqrt     f7, f1
    assign rom[6'h0b] = 32'b00101000001000001000010001010011; // fmin      f8, f1, f2
    assign rom[6'h0c] = 32'b00101000001000001001010011010011; // fmax      f9, f1, f2
    assign rom[6'h0d] = 32'b10100000001000001010011001010011; // feq       a2, f1, f2
    assign rom[6'h0e] = 32'b10100000011000001010011011010011; // feq       a3, f1, f6
    assign rom[6'h0f] = 32'b10100000001000001001011101010011; // flt       a4, f1, f2
    assign rom[6'h10] = 32'b10100000000100010001011111010011; // flt       a5, f2, f1
    assign rom[6'h11] = 32'b10100000001000001000100001010011; // fle       a6, f1, f2
    assign rom[6'h12] = 32'b10100000011000001000100011010011; // fle       a7, f1, f6
    assign rom[6'h13] = 32'b00100000001000001000010101000011; // fmadd     f10, f1, f2, f4
    assign rom[6'h14] = 32'b00100000001000001000010111000011; // fmsub     f11, f1, f2, f4
    assign rom[6'h15] = 32'b00100000001000001000011001000011; // fnmadd    f12, f1, f2, f4
    assign rom[6'h16] = 32'b00100000001000001000011011000011; // fnsub     f13, f1, f2, f4
    assign rom[6'h17] = 32'b11100000000000001000100101010011; // fmv       s2, f1
    assign rom[6'h18] = 32'b00000000000000000000000000000000; // nop
    assign inst = rom[a[7:2]];
endmodule