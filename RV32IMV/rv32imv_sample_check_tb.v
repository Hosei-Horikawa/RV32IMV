`timescale 1ns/1ns
module rv32imv_sample_check_tb;
  reg         clk, clrn;
  wire [31:0] inst, pc, alu, mem;
  rv32imv_sample_check rs(clk, clrn, inst, pc, alu, mem);
  
  initial begin
        clk  = 1;
        clrn     = 0;
        #10 clrn = 1;
        #20000 $stop;
    end
    always #10 clk = !clk;
endmodule