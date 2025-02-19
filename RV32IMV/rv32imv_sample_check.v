module rv32imv_sample_check (clk, clrn, inst, pc, alu, mem);
  input         clk, clrn;           // clk: 50MHz
  output [31:0] inst, pc, alu, mem;
  wire    [3:0] wmem;
  wire   [31:0] alu_out, b;
  
  // clock 25mhz
  reg          clk25m = 1;
  always @(negedge clk) begin
      clk25m <= ~clk25m;              // clk25m: 25MHz
  end
  
  riscv_rv32im_v_cpu rrc (clk, clrn, inst, mem, pc, alu_out, b, wmem);
  
  instmem_v_check imem (pc,inst);
  
  datamem_v_check dmem (alu_out, b, wmem, clk, mem);
endmodule
