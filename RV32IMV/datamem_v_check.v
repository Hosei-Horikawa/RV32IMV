module datamem_v_check (addr, datain, we, clk, dataout);
  input clk;
  input [3:0] we;
  input [31:0] addr, datain;
  output [31:0] dataout;
  reg [31:0] ram [0:31];
  assign dataout = ram[addr[7:2]];
  always @ (posedge clk)
    case (we)
      4'b1111: ram[addr[6:2]] = datain;
      4'b0011: ram[addr[5:2]] = datain;
      4'b0001: ram[addr[4:2]] = datain;
    endcase
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1)
      ram[i] = 0;
    //a
    ram[5'h04] = 32'h00000003;
    ram[5'h05] = 32'h00000005;
    ram[5'h06] = 32'hfffffff9;
    ram[5'h07] = 32'hfffffffb;
    //b
    ram[5'h08] = 32'h00000008;
    ram[5'h09] = 32'hfffffffd;
    ram[5'h0a] = 32'h0000000b;
    ram[5'h0b] = 32'hfffffff6;
    //c
    ram[6'h0c] = 32'h00000003;
    ram[6'h0d] = 32'h00000006;
    ram[6'h0e] = 32'hfffffffb;//(-5)
    ram[6'h0f] = 32'hfffffff9;//(-7)
    //d
    ram[6'h10] = 32'h00000005;
    ram[6'h11] = 32'hfffffffd;//(-3)
    ram[6'h12] = 32'h00000008;
    ram[6'h13] = 32'hfffffffa;//(-6)
    //e
    ram[6'h14] = 32'h0000000f;
    ram[6'h15] = 32'h80000007;
    ram[6'h16] = 32'h80000003;
    ram[6'h17] = 32'h00000001;
  end
endmodule