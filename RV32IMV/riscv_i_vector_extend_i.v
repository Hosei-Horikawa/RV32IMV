module riscv_i_vector_extend_i (clk,clrn,SEW,VLMAX,va,vb,a,simm5,vregfile_vd,vregfile0,opcode,func3,func6,vm,vd,vc,cout,bout);
  
    input             clk, clrn, vm;           // clock and reset
    parameter         VLEN = 128;
    input      [31:0] a, SEW, VLMAX;
    input  [VLEN-1:0] va, vb; 
    input  [VLEN-1:0] vregfile_vd, vregfile0;
    input       [4:0] simm5;
    input       [6:0] opcode;
    input       [5:0] func6;
    input       [2:0] func3;
    input       [4:0] vd;
    output [VLEN-1:0] vc;
    output reg [VLEN:0] cout;  //carry out
    output reg [VLEN:0] bout;  //borrow out
  
    wire v_vaddvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000000);
    wire v_vaddvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000000);
    wire v_vaddvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b000000);
    wire v_vsubvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000010);
    wire v_vsubvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000010);
    wire v_vsubvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b000010);
    wire v_vrsubvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000011);
    wire v_vrsubvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b000011);
    wire v_vminuvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000100);
    wire v_vminuvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000100);
    wire v_vminvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000101);
    wire v_vminvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000101);
    wire v_vmaxuvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000110);
    wire v_vmaxuvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000110);
    wire v_vmaxvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b000111);
    wire v_vmaxvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b000111);
    wire v_vandvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b001001);
    wire v_vandvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001001);
    wire v_vandvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001001);
    wire v_vorvv   = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b001010);
    wire v_vorvx   = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001010);
    wire v_vorvi   = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001010);
    wire v_vxorvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b001011);
    wire v_vxorvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001011);
    wire v_vxorvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001011);
    wire v_vrgathervv   = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b001100);
    wire v_vrgathervx   = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001100);
    wire v_vrgathervi   = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001100);
    wire v_vslideupvx   = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001110);
    wire v_vslideupvi   = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001110);
    wire v_vslidedownvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b001111);
    wire v_vslidedownvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b001111);
    wire v_vadcvvm  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010000);
    wire v_vadcvxm  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010000);
    wire v_vadcvim  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b010000);
    wire v_vmadcvvm = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010001) & (vm == 1'b0);
    wire v_vmadcvxm = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010001) & (vm == 1'b0);
    wire v_vmadcvim = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b010001) & (vm == 1'b0);
    wire v_vmadcvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010001) & (vm == 1'b1);
    wire v_vmadcvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010001) & (vm == 1'b1);
    wire v_vmadcvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b010001) & (vm == 1'b1);
    wire v_vsbcvvm  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010010);
    wire v_vsbcvxm  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010010);
    wire v_vmsbcvvm = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010011) & (vm == 1'b0);
    wire v_vmsbcvxm = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010011) & (vm == 1'b0);
    wire v_vmsbcvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010011) & (vm == 1'b1);
    wire v_vmsbcvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010011) & (vm == 1'b1);
    wire v_vmergevvm = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b010111) & (vm == 1'b0);
    wire v_vmergevxm = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b010111) & (vm == 1'b0);
    wire v_vmergevim = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b010111) & (vm == 1'b0);
    wire v_vmseqvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011000);
    wire v_vmseqvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011000);
    wire v_vmseqvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011000);
    wire v_vmsnevv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011001);
    wire v_vmsnevx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011001);
    wire v_vmsnevi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011001);
    wire v_vmsltuvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011010);
    wire v_vmsltuvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011010);
    wire v_vmsltvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011011);
    wire v_vmsltvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011011);
    wire v_vmsleuvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011100);
    wire v_vmsleuvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011100);
    wire v_vmsleuvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011100);
    wire v_vmslevv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b011101);
    wire v_vmslevx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011101);
    wire v_vmslevi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011101);
    wire v_vmsgtuvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011110);
    wire v_vmsgtuvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011110);
    wire v_vmsgtvx  = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b011111);
    wire v_vmsgtvi  = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b011111);
    wire v_vsllvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b100101);
    wire v_vsllvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b100101);
    wire v_vsllvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b100101);
    wire v_vsrlvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b101000);
    wire v_vsrlvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b101000);
    wire v_vsrlvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b101000);
    wire v_vsravv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b101001);
    wire v_vsravx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b101001);
    wire v_vsravi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b101001); 
    

    // vector register file, VLEN = 128 bits, ELEN = 32 bits
    wire             sew32 = (SEW == 32);
    reg  [VLEN-1:0]  vc_ia;                           // integer arithmetic
    reg  [VLEN-1:0]  vc_gather;                       // for gather
    reg  [VLEN-1:0]  vc_shift;                       // for shift
    reg  [VLEN-1:0]  vc_cvi;                          // for carried vector integer
    reg  [VLEN-1:0]  vc_mer;                          // for merge
    reg  [VLEN-1:0]  vc_ivc;                          // for integer vector comparison 
    reg  [VLEN-1:0]  vc_sl;                           // for slide
    
    // integer arithmetic
    wire v_vaddvv32  = v_vaddvv && sew32;
    wire v_vaddvx32  = v_vaddvx && sew32;
    wire v_vaddvi32  = v_vaddvi && sew32;
    wire v_vsubvv32  = v_vsubvv && sew32;
    wire v_vsubvx32  = v_vsubvx && sew32;
    wire v_vsubvi32  = v_vsubvi && sew32;
    wire v_vandvv32  = v_vandvv && sew32;
    wire v_vandvx32  = v_vandvx && sew32;
    wire v_vandvi32  = v_vandvi && sew32;
    wire v_vorvv32   = v_vorvv && sew32;
    wire v_vorvx32   = v_vorvx && sew32;
    wire v_vorvi32   = v_vorvi && sew32;
    wire v_vxorvv32  = v_vxorvv && sew32;
    wire v_vxorvx32  = v_vxorvx && sew32;
    wire v_vxorvi32  = v_vxorvi && sew32;
    wire v_vrsubvx32 = v_vrsubvx && sew32;
    wire v_vrsubvi32 = v_vrsubvi && sew32;
    wire v_vminuvv32 = v_vminuvv && sew32;
    wire v_vminuvx32 = v_vminuvx && sew32;
    wire v_vminvv32  = v_vminvv && sew32;
    wire v_vminvx32  = v_vminvx && sew32;
    wire v_vmaxuvv32 = v_vmaxuvv && sew32;
    wire v_vmaxuvx32 = v_vmaxuvx && sew32;
    wire v_vmaxvv32  = v_vmaxvv && sew32;
    wire v_vmaxvx32  = v_vmaxvx && sew32;
    wire via         = v_vaddvv32 || v_vaddvx32 || v_vaddvi32 || v_vsubvv32 || v_vsubvx32 || v_vandvv32
                       || v_vandvx32 || v_vandvi32 || v_vorvv32 || v_vorvx32 || v_vorvi32 || v_vxorvv32 
                       || v_vxorvx32 || v_vxorvi32 || v_vrsubvx32 || v_vrsubvi32 || v_vminuvv32 
                       || v_vminuvx32 || v_vminvv32 || v_vminvx32 || v_vmaxuvv32 || v_vmaxuvx32 
                       || v_vmaxvv32 || v_vmaxvx32 || v_vsubvi32;
                       
    // shift
    wire v_vsllvv32 = v_vsllvv && sew32;
    wire v_vsllvx32 = v_vsllvx && sew32;
    wire v_vsllvi32 = v_vsllvi && sew32;
    wire v_vsrlvv32 = v_vsrlvv && sew32;
    wire v_vsrlvx32 = v_vsrlvx && sew32;
    wire v_vsrlvi32 = v_vsrlvi && sew32;
    wire v_vsravv32 = v_vsravv && sew32;
    wire v_vsravx32 = v_vsravx && sew32;
    wire v_vsravi32 = v_vsravi && sew32;
    wire vshift = v_vsllvv32 || v_vsllvx32 || v_vsllvi32 || v_vsrlvv32 || v_vsrlvx32 
                  || v_vsrlvi32 || v_vsravv32 || v_vsravx32 || v_vsravi32;
    
    // gather
    wire v_vrgathervv32 = v_vrgathervv && sew32;
    wire v_vrgathervx32 = v_vrgathervx && sew32;
    wire v_vrgathervi32 = v_vrgathervi && sew32;
    wire vgather        = v_vrgathervv32 || v_vrgathervx32 || v_vrgathervi32;

    

    // carried vector integer
    wire          v_vadcvvm32  = v_vadcvvm && sew32;
    wire          v_vadcvxm32  = v_vadcvxm && sew32;
    wire          v_vadcvim32  = v_vadcvim && sew32;
    wire          v_vmadcvvm32 = v_vmadcvvm && sew32;
    wire          v_vmadcvxm32 = v_vmadcvxm && sew32;
    wire          v_vmadcvim32 = v_vmadcvim && sew32;
    wire          v_vsbcvvm32  = v_vsbcvvm && sew32;
    wire          v_vsbcvxm32  = v_vsbcvxm && sew32;
    wire          v_vmsbcvvm32 = v_vmsbcvvm && sew32;
    wire          v_vmsbcvxm32 = v_vmsbcvxm && sew32;
    
    // no carry-in
    wire          v_vmadcvv32 = v_vmadcvv && sew32;
    wire          v_vmadcvx32 = v_vmadcvx && sew32;
    wire          v_vmadcvi32 = v_vmadcvi && sew32;
    wire          v_vmsbcvv32 = v_vmsbcvv && sew32;
    wire          v_vmsbcvx32 = v_vmsbcvx && sew32;
    wire          cvi         = v_vadcvvm32 || v_vadcvxm32 || v_vadcvim32 || v_vmadcvvm32 || v_vmadcvxm32 
                                || v_vmadcvim32 || v_vsbcvvm32 || v_vsbcvxm32 || v_vmsbcvvm32 || v_vmsbcvxm32 
                                || v_vmadcvv32 || v_vmadcvx32 || v_vmadcvi32 || v_vmsbcvv32 || v_vmsbcvx32;

    // merge
    wire v_vmergevvm32 = v_vmergevvm && sew32;
    wire v_vmergevxm32 = v_vmergevxm && sew32;
    wire v_vmergevim32 = v_vmergevim && sew32;
    wire vmerge        = v_vmergevvm32 || v_vmergevxm32 || v_vmergevim32;
 
    // integer vector comparison
    wire v_vmseqvv32  = v_vmseqvv && sew32;
    wire v_vmseqvx32  = v_vmseqvx && sew32;
    wire v_vmseqvi32  = v_vmseqvi && sew32;
    wire v_vmsnevv32  = v_vmsnevv && sew32;
    wire v_vmsnevx32  = v_vmsnevx && sew32;
    wire v_vmsnevi32  = v_vmsnevi && sew32; 
    wire v_vmsltuvv32 = v_vmsltuvv && sew32;
    wire v_vmsltuvx32 = v_vmsltuvx && sew32;
    wire v_vmsltvv32  = v_vmsltvv && sew32;
    wire v_vmsltvx32  = v_vmsltvx && sew32;
    wire v_vmsleuvv32 = v_vmsleuvv && sew32;
    wire v_vmsleuvx32 = v_vmsleuvx && sew32;
    wire v_vmsleuvi32 = v_vmsleuvi && sew32;
    wire v_vmslevv32  = v_vmslevv && sew32;
    wire v_vmslevx32  = v_vmslevx && sew32;
    wire v_vmslevi32  = v_vmslevi && sew32;
    wire v_vmsgtuvx32 = v_vmsgtuvx && sew32;
    wire v_vmsgtuvi32 = v_vmsgtuvi && sew32;
    wire v_vmsgtvx32  = v_vmsgtvx && sew32;
    wire v_vmsgtvi32  = v_vmsgtvi && sew32;
    wire ivc          = v_vmseqvv32 || v_vmseqvx32 || v_vmseqvi32 || v_vmsnevv32 || v_vmsnevx32 || v_vmsnevi32 || v_vmsltuvv32 
                        || v_vmsltuvx32 || v_vmsleuvi32 || v_vmsltvv32 || v_vmsltvx32 || v_vmsleuvv32 || v_vmsleuvx32 || v_vmslevv32
                        || v_vmslevx32 || v_vmslevi32 || v_vmsgtuvx32 || v_vmsgtuvi32 || v_vmsgtvx32 || v_vmsgtvi32;
    
    // slide
    wire [VLEN-1:0] a_32              = a << 5;
    wire [VLEN-1:0] simm5_32            = simm5 << 5;
    wire            v_vslideupvx32    = v_vslideupvx && sew32;
    wire            v_vslidedownvx32  = v_vslidedownvx && sew32;
    wire            v_vslideupvi32    = v_vslideupvi && sew32;
    wire            v_vslidedownvi32  = v_vslidedownvi && sew32;
    wire            vslide            = v_vslideupvx32 || v_vslideupvi32 || v_vslidedownvx32 || v_vslidedownvi32;


    wire [VLEN-1:0]  vc = (via) ? vc_ia : 
                          (vgather) ? vc_gather : 
                          (vshift) ? vc_shift : 
                          (cvi) ? vc_cvi : 
                          (vmerge) ? vc_mer : 
                          (ivc) ? vc_ivc : 
                          (vslide) ? vc_sl : 0;   // calculate result
    
    // not use count
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            // integer arithmetic
            vc_ia <= 0;
            
            // gather
            vc_gather <= 0;
            
            // shift
            vc_shift <= 0;

            // carried vector integer
            cout   <= 0;
            bout   <= 0;
	          vc_cvi <= 0;

            // merge
            vc_mer <= 0;
            
            // integer vector comparison
            vc_ivc <= 0;

            // slide
	          vc_sl    <= 0;
        end
        else begin
            // integer arithmetic
            if (via) begin
                  if(v_vaddvv32) begin
                        vc_ia[ 31:  0] = va[ 31:  0] + vb[ 31:  0];
                        vc_ia[ 63: 32] = va[ 63: 32] + vb[ 63: 32];
                        vc_ia[ 95: 64] = va[ 95: 64] + vb[ 95: 64];
                        vc_ia[127: 96] = va[127: 96] + vb[127: 96];
                  end
                  if(v_vaddvx32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] + a;
                        vc_ia[ 63: 32] = vb[ 63: 32] + a;
                        vc_ia[ 95: 64] = vb[ 95: 64] + a;
                        vc_ia[127: 96] = vb[127: 96] + a;
                  end
                  if(v_vaddvi32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] + simm5;
                        vc_ia[ 63: 32] = vb[ 63: 32] + simm5;
                        vc_ia[ 95: 64] = vb[ 95: 64] + simm5;
                        vc_ia[127: 96] = vb[127: 96] + simm5;
                  end
                  if(v_vsubvv32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] - va[ 31:  0];
                        vc_ia[ 63: 32] = vb[ 63: 32] - va[ 63: 32];
                        vc_ia[ 95: 64] = vb[ 95: 64] - va[ 95: 64];
                        vc_ia[127: 96] = vb[127: 96] - va[127: 96];
                  end
                  if(v_vsubvx32)  begin
                        vc_ia[ 31:  0] = vb[ 31:  0] - a;
                        vc_ia[ 63: 32] = vb[ 63: 32] - a;
                        vc_ia[ 95: 64] = vb[ 95: 64] - a;
                        vc_ia[127: 96] = vb[127: 96] - a;
                  end
                  if(v_vsubvi32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] - simm5;
                        vc_ia[ 63: 32] = vb[ 63: 32] - simm5;
                        vc_ia[ 95: 64] = vb[ 95: 64] - simm5;
                        vc_ia[127: 96] = vb[127: 96] - simm5;
                  end
                  if(v_vrsubvx32) begin
                        vc_ia[ 31:  0] = a - vb[ 31:  0];
                        vc_ia[ 63: 32] = a - vb[ 63: 32];
                        vc_ia[ 95: 64] = a - vb[ 95: 64];
                        vc_ia[127: 96] = a - vb[127: 96];
                  end
                  if(v_vrsubvi32) begin
                        vc_ia[ 31:  0] = simm5 - vb[ 31:  0];
                        vc_ia[ 63: 32] = simm5 - vb[ 63: 32];
                        vc_ia[ 95: 64] = simm5 - vb[ 95: 64];
                        vc_ia[127: 96] = simm5 - vb[127: 96];
                  end
                  if(v_vminuvv32) begin
                        vc_ia[ 31:  0] = ({1'b0,vb[ 31:  0]} < {1'b0,va[ 31:  0]}) ? vb[ 31:  0] : va[ 31:  0];
                        vc_ia[ 63: 32] = ({1'b0,vb[ 63: 32]} < {1'b0,va[ 63: 32]}) ? vb[ 63: 32] : va[ 63: 32];
                        vc_ia[ 95: 64] = ({1'b0,vb[ 95: 64]} < {1'b0,va[ 95: 64]}) ? vb[ 95: 64] : va[ 95: 64];
                        vc_ia[127: 96] = ({1'b0,vb[127: 96]} < {1'b0,va[127: 96]}) ? vb[127: 96] : va[127: 96];
                  end
                  if(v_vminuvx32) begin
                        vc_ia[ 31:  0] = ({1'b0,vb[ 31:  0]} < {1'b0,a}) ? vb[ 31:  0] : a;
                        vc_ia[ 63: 32] = ({1'b0,vb[ 63: 32]} < {1'b0,a}) ? vb[ 63: 32] : a;
                        vc_ia[ 95: 64] = ({1'b0,vb[ 95: 64]} < {1'b0,a}) ? vb[ 95: 64] : a;
                        vc_ia[127: 96] = ({1'b0,vb[127: 96]} < {1'b0,a}) ? vb[127: 96] : a;
                  end
                  if(v_vminvv32) begin
                        vc_ia[ 31:  0] = ($signed(vb[ 31:  0]) < $signed(va[ 31:  0])) ? vb[ 31:  0] : va[ 31:  0];
                        vc_ia[ 63: 32] = ($signed(vb[ 63: 32]) < $signed(va[ 63: 32])) ? vb[ 63: 32] : va[ 63: 32];
                        vc_ia[ 95: 64] = ($signed(vb[ 95: 64]) < $signed(va[ 95: 64])) ? vb[ 95: 64] : va[ 95: 64];
                        vc_ia[127: 96] = ($signed(vb[127: 96]) < $signed(va[127: 96])) ? vb[127: 96] : va[127: 96];
                  end
                  if(v_vminvx32) begin
                        vc_ia[ 31:  0] = ($signed(vb[ 31:  0]) < $signed(a)) ? vb[ 31:  0] : a;
                        vc_ia[ 63: 32] = ($signed(vb[ 63: 32]) < $signed(a)) ? vb[ 63: 32] : a;
                        vc_ia[ 95: 64] = ($signed(vb[ 95: 64]) < $signed(a)) ? vb[ 95: 64] : a;
                        vc_ia[127: 96] = ($signed(vb[127: 96]) < $signed(a)) ? vb[127: 96] : a;
                  end
                  if(v_vmaxuvv32) begin
                        vc_ia[ 31:  0] = ({1'b0,vb[ 31:  0]} > {1'b0,va[ 31:  0]}) ? vb[ 31:  0] : va[ 31:  0];
                        vc_ia[ 63: 32] = ({1'b0,vb[ 63: 32]} > {1'b0,va[ 63: 32]}) ? vb[ 63: 32] : va[ 63: 32];
                        vc_ia[ 95: 64] = ({1'b0,vb[ 95: 64]} > {1'b0,va[ 95: 64]}) ? vb[ 95: 64] : va[ 95: 64];
                        vc_ia[127: 96] = ({1'b0,vb[127: 96]} > {1'b0,va[127: 96]}) ? vb[127: 96] : va[127: 96];
                  end
                  if(v_vmaxuvx32) begin
                        vc_ia[ 31:  0] = ({1'b0,vb[ 31:  0]} > {1'b0,a}) ? vb[ 31:  0] : a;
                        vc_ia[ 63: 32] = ({1'b0,vb[ 63: 32]} > {1'b0,a}) ? vb[ 63: 32] : a;
                        vc_ia[ 95: 64] = ({1'b0,vb[ 95: 64]} > {1'b0,a}) ? vb[ 95: 64] : a;
                        vc_ia[127: 96] = ({1'b0,vb[127: 96]} > {1'b0,a}) ? vb[127: 96] : a;
                  end
                  if(v_vmaxvv32) begin
                        vc_ia[ 31:  0] = ($signed(vb[ 31:  0]) > $signed(va[ 31:  0])) ? vb[ 31:  0] : va[ 31:  0];
                        vc_ia[ 63: 32] = ($signed(vb[ 63: 32]) > $signed(va[ 63: 32])) ? vb[ 63: 32] : va[ 63: 32];
                        vc_ia[ 95: 64] = ($signed(vb[ 95: 64]) > $signed(va[ 95: 64])) ? vb[ 95: 64] : va[ 95: 64];
                        vc_ia[127: 96] = ($signed(vb[127: 96]) > $signed(va[127: 96])) ? vb[127: 96] : va[127: 96];
                  end
                  if(v_vmaxvx32) begin
                        vc_ia[ 31:  0] = ($signed(vb[ 31:  0]) > $signed(a)) ? vb[ 31:  0] : a;
                        vc_ia[ 63: 32] = ($signed(vb[ 63: 32]) > $signed(a)) ? vb[ 63: 32] : a;
                        vc_ia[ 95: 64] = ($signed(vb[ 95: 64]) > $signed(a)) ? vb[ 95: 64] : a;
                        vc_ia[127: 96] = ($signed(vb[127: 96]) > $signed(a)) ? vb[127: 96] : a;
                  end
                  if(v_vandvx32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] & a;
                        vc_ia[ 63: 32] = vb[ 63: 32] & a;
                        vc_ia[ 95: 64] = vb[ 95: 64] & a;
                        vc_ia[127: 96] = vb[127: 96] & a;
                  end
                  if(v_vandvv32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] & va[ 31:  0];
                        vc_ia[ 63: 32] = vb[ 63: 32] & va[ 63: 32];
                        vc_ia[ 95: 64] = vb[ 95: 64] & va[ 95: 64];
                        vc_ia[127: 96] = vb[127: 96] & va[127: 96];
                  end
                  if(v_vandvi32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] & simm5;
                        vc_ia[ 63: 32] = vb[ 63: 32] & simm5;
                        vc_ia[ 95: 64] = vb[ 95: 64] & simm5;
                        vc_ia[127: 96] = vb[127: 96] & simm5;
                  end
                  if(v_vorvx32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] | a;
                        vc_ia[ 63: 32] = vb[ 63: 32] | a;
                        vc_ia[ 95: 64] = vb[ 95: 64] | a;
                        vc_ia[127: 96] = vb[127: 96] | a;
                  end
                  if(v_vorvv32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] | va[ 31:  0];
                        vc_ia[ 63: 32] = vb[ 63: 32] | va[ 63: 32];
                        vc_ia[ 95: 64] = vb[ 95: 64] | va[ 95: 64];
                        vc_ia[127: 96] = vb[127: 96] | va[127: 96];
                  end
                  if(v_vorvi32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] | simm5;
                        vc_ia[ 63: 32] = vb[ 63: 32] | simm5;
                        vc_ia[ 95: 64] = vb[ 95: 64] | simm5;
                        vc_ia[127: 96] = vb[127: 96] | simm5;
                  end
                  if(v_vxorvx32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] ^ a;
                        vc_ia[ 63: 32] = vb[ 63: 32] ^ a;
                        vc_ia[ 95: 64] = vb[ 95: 64] ^ a;
                        vc_ia[127: 96] = vb[127: 96] ^ a;
                  end
                  if(v_vxorvv32) begin
                        vc_ia = va ^ vb;
                        vc_ia[ 31:  0] = vb[ 31:  0] ^ va[ 31:  0];
                        vc_ia[ 63: 32] = vb[ 63: 32] ^ va[ 63: 32];
                        vc_ia[ 95: 64] = vb[ 95: 64] ^ va[ 95: 64];
                        vc_ia[127: 96] = vb[127: 96] ^ va[127: 96];
                  end
                  if(v_vxorvi32) begin
                        vc_ia[ 31:  0] = vb[ 31:  0] ^ simm5;
                        vc_ia[ 63: 32] = vb[ 63: 32] ^ simm5;
                        vc_ia[ 95: 64] = vb[ 95: 64] ^ simm5;
                        vc_ia[127: 96] = vb[127: 96] ^ simm5;
                  end    
            end

            

            // gather
            if (vgather) begin
                  if(v_vrgathervv32) begin
                        vc_gather[ 31:  0] <= (va[ 31:  0] >= VLMAX) ? 0 : vb[(va[ 31:  0] * 32) +: 32];
                        vc_gather[ 63: 32] <= (va[ 63: 32] >= VLMAX) ? 0 : vb[(va[ 63: 32] * 32) +: 32];
                        vc_gather[ 95: 64] <= (va[ 95: 64] >= VLMAX) ? 0 : vb[(va[ 95: 64] * 32) +: 32];
                        vc_gather[127: 96] <= (va[127: 96] >= VLMAX) ? 0 : vb[(va[127: 96] * 32) +: 32];
                  end
                  if(v_vrgathervx32) begin
                        vc_gather[ 31:  0] <= (a >= VLMAX) ? 0 : vb[a * 32 +: 32];
                        vc_gather[ 63: 32] <= (a >= VLMAX) ? 0 : vb[a * 32 +: 32];
                        vc_gather[ 95: 64] <= (a >= VLMAX) ? 0 : vb[a * 32 +: 32];
                        vc_gather[127: 96] <= (a >= VLMAX) ? 0 : vb[a * 32 +: 32];
                  end
                  if(v_vrgathervi32) begin
                        vc_gather[ 31:  0] <= (simm5 >= VLMAX) ? 0 : vb[simm5 * 32 +: 32];
                        vc_gather[ 63: 32] <= (simm5 >= VLMAX) ? 0 : vb[simm5 * 32 +: 32];
                        vc_gather[ 95: 64] <= (simm5 >= VLMAX) ? 0 : vb[simm5 * 32 +: 32];
                        vc_gather[127: 96] <= (simm5 >= VLMAX) ? 0 : vb[simm5 * 32 +: 32];
                  end
            end

            // shift
            if (vshift) begin
                if(v_vsllvv32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] << va[ 31:  0];
                    vc_shift[ 63: 32] <= vb[ 63: 32] << va[ 63: 32];
                    vc_shift[ 95: 64] <= vb[ 95: 64] << va[ 95: 64];
                    vc_shift[127: 96] <= vb[127: 96] << va[127: 96];
                end
                if(v_vsllvx32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] << a;
                    vc_shift[ 63: 32] <= vb[ 63: 32] << a;
                    vc_shift[ 95: 64] <= vb[ 95: 64] << a;
                    vc_shift[127: 96] <= vb[127: 96] << a;
                end
                if(v_vsllvi32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] << simm5;
                    vc_shift[ 63: 32] <= vb[ 63: 32] << simm5;
                    vc_shift[ 95: 64] <= vb[ 95: 64] << simm5;
                    vc_shift[127: 96] <= vb[127: 96] << simm5;
                end
                if(v_vsrlvv32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] >> va[ 31:  0];
                    vc_shift[ 63: 32] <= vb[ 63: 32] >> va[ 63: 32];
                    vc_shift[ 95: 64] <= vb[ 95: 64] >> va[ 95: 64];
                    vc_shift[127: 96] <= vb[127: 96] >> va[127: 96];
                end
                if(v_vsrlvx32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] >> a;
                    vc_shift[ 63: 32] <= vb[ 63: 32] >> a;
                    vc_shift[ 95: 64] <= vb[ 95: 64] >> a;
                    vc_shift[127: 96] <= vb[127: 96] >> a;
                end
                if(v_vsrlvi32) begin
                    vc_shift[ 31:  0] <= vb[ 31:  0] >> simm5;
                    vc_shift[ 63: 32] <= vb[ 63: 32] >> simm5;
                    vc_shift[ 95: 64] <= vb[ 95: 64] >> simm5;
                    vc_shift[127: 96] <= vb[127: 96] >> simm5;
                end
                if(v_vsravv32) begin
                    vc_shift[ 31:  0] <= $signed(vb[ 31:  0]) >>> va[ 31:  0];
                    vc_shift[ 63: 32] <= $signed(vb[ 63: 32]) >>> va[ 63: 32];
                    vc_shift[ 95: 64] <= $signed(vb[ 95: 64]) >>> va[ 95: 64];
                    vc_shift[127: 96] <= $signed(vb[127: 96]) >>> va[127: 96];
                end
                if(v_vsravx32) begin
                    vc_shift[ 31:  0] <= $signed(vb[ 31:  0]) >>> a;
                    vc_shift[ 63: 32] <= $signed(vb[ 63: 32]) >>> a;
                    vc_shift[ 95: 64] <= $signed(vb[ 95: 64]) >>> a;
                    vc_shift[127: 96] <= $signed(vb[127: 96]) >>> a;
                end 
                if(v_vsravi32) begin
                    vc_shift[ 31:  0] <= $signed(vb[ 31:  0]) >>> simm5;
                    vc_shift[ 63: 32] <= $signed(vb[ 63: 32]) >>> simm5;
                    vc_shift[ 95: 64] <= $signed(vb[ 95: 64]) >>> simm5;
                    vc_shift[127: 96] <= $signed(vb[127: 96]) >>> simm5;
                end
            end

            // carried vector integer
            if (cvi) begin
                  if(v_vadcvvm32) begin
                        vc_cvi[ 31:  0] <= va[ 31:  0] + vb[ 31:  0] + vregfile0[  0];
                        vc_cvi[ 63: 32] <= va[ 63: 32] + vb[ 63: 32] + vregfile0[ 32];
                        vc_cvi[ 95: 64] <= va[ 95: 64] + vb[ 95: 64] + vregfile0[ 64];
                        vc_cvi[127: 96] <= va[127: 96] + vb[127: 96] + vregfile0[ 96];
                  end
                  if(v_vadcvxm32) begin
                        vc_cvi[ 31:  0] <= vb[ 31:  0] + a + vregfile0[  0];
                        vc_cvi[ 63: 32] <= vb[ 63: 32] + a + vregfile0[ 32];
                        vc_cvi[ 95: 64] <= vb[ 95: 64] + a + vregfile0[ 64];
                        vc_cvi[127: 96] <= vb[127: 96] + a + vregfile0[ 96];
                  end
                  if(v_vadcvim32) begin
                        vc_cvi[ 31:  0] <= vb[ 31:  0] + simm5 + vregfile0[  0];
                        vc_cvi[ 63: 32] <= vb[ 63: 32] + simm5 + vregfile0[ 32];
                        vc_cvi[ 95: 64] <= vb[ 95: 64] + simm5 + vregfile0[ 64];
                        vc_cvi[127: 96] <= vb[127: 96] + simm5 + vregfile0[ 96];
                  end
                  if(v_vmadcvvm32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,va[ 31:  0]} + {1'b0,vb[ 31:  0]} + {32'b0,vregfile0[  0]};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,va[ 63: 32]} + {1'b0,vb[ 63: 32]} + {32'b0,vregfile0[ 32]};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,va[ 95: 64]} + {1'b0,vb[ 95: 64]} + {32'b0,vregfile0[ 64]};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,va[127: 96]} + {1'b0,vb[127: 96]} + {32'b0,vregfile0[ 96]};
                  end
                  if(v_vmadcvxm32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} + {1'b0,a} + {32'b0,vregfile0[  0]};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} + {1'b0,a} + {32'b0,vregfile0[ 32]};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} + {1'b0,a} + {32'b0,vregfile0[ 64]};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} + {1'b0,a} + {32'b0,vregfile0[ 96]};
                  end
                  if(v_vmadcvim32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} + {1'b0,simm5} + {32'b0,vregfile0[  0]};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} + {1'b0,simm5} + {32'b0,vregfile0[ 32]};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} + {1'b0,simm5} + {32'b0,vregfile0[ 64]};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} + {1'b0,simm5} + {32'b0,vregfile0[ 96]};
                  end
                  if(v_vsbcvvm32) begin
                        vc_cvi[ 31:  0] <= vb[ 31:  0] - va[ 31:  0] - vregfile0[  0];
                        vc_cvi[ 63: 32] <= vb[ 63: 32] - va[ 63: 32] - vregfile0[ 32];
                        vc_cvi[ 95: 64] <= vb[ 95: 64] - va[ 95: 64] - vregfile0[ 64];
                        vc_cvi[127: 96] <= vb[127: 96] - va[127: 96] - vregfile0[ 96];
                  end
                  if(v_vsbcvxm32) begin
                        vc_cvi[ 31:  0] <= vb[ 31:  0] - a - vregfile0[  0];
                        vc_cvi[ 63: 32] <= vb[ 63: 32] - a - vregfile0[ 32];
                        vc_cvi[ 95: 64] <= vb[ 95: 64] - a - vregfile0[ 64];
                        vc_cvi[127: 96] <= vb[127: 96] - a - vregfile0[ 96];
                  end
                  if(v_vmsbcvvm32) begin
                        {bout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} - {1'b0,va[ 31:  0]} - {32'b0,vregfile0[  0]};
                        {bout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} - {1'b0,va[ 63: 32]} - {32'b0,vregfile0[ 32]};
                        {bout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} - {1'b0,va[ 95: 64]} - {32'b0,vregfile0[ 64]};
                        {bout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} - {1'b0,va[127: 96]} - {32'b0,vregfile0[ 96]};
                  end
                  if(v_vmsbcvxm32) begin
                        {bout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} - {1'b0,a} - {32'b0,vregfile0[  0]};
                        {bout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} - {1'b0,a} - {32'b0,vregfile0[ 32]};
                        {bout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} - {1'b0,a} - {32'b0,vregfile0[ 64]};
                        {bout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} - {1'b0,a} - {32'b0,vregfile0[ 96]};
                  end
                  if(v_vmadcvv32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,va[ 31:  0]} + {1'b0,vb[ 31:  0]};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,va[ 63: 32]} + {1'b0,vb[ 63: 32]};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,va[ 95: 64]} + {1'b0,vb[ 95: 64]};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,va[127: 96]} + {1'b0,vb[127: 96]};
                  end
                  if(v_vmadcvx32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} + {1'b0,a};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} + {1'b0,a};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} + {1'b0,a};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} + {1'b0,a};
                  end
                  if(v_vmadcvi32) begin
                       {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} + {1'b0,simm5};
                       {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} + {1'b0,simm5};
                       {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} + {1'b0,simm5};
                       {cout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} + {1'b0,simm5};
                  end
                  if(v_vmsbcvv32) begin
                        {bout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} - {1'b0,va[ 31:  0]};
                        {bout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} - {1'b0,va[ 63: 32]};
                        {bout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} - {1'b0,va[ 95: 64]};
                        {bout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} - {1'b0,va[127: 96]};
                  end
                  if(v_vmsbcvx32) begin
                        {cout[ 32],vc_cvi[ 31:  0]} <= {1'b0,vb[ 31:  0]} - {1'b0,a};
                        {cout[ 64],vc_cvi[ 63: 32]} <= {1'b0,vb[ 63: 32]} - {1'b0,a};
                        {cout[ 96],vc_cvi[ 95: 64]} <= {1'b0,vb[ 95: 64]} - {1'b0,a};
                        {cout[128],vc_cvi[127: 96]} <= {1'b0,vb[127: 96]} - {1'b0,a};
                  end
            end
            
            // merge
            if(vmerge) begin
                 if(v_vmergevvm32) begin
                       vc_mer[ 31:  0] <= vregfile0[  0] ? va[ 31:  0] : vb[ 31:  0];
                       vc_mer[ 63: 32] <= vregfile0[ 32] ? va[ 63: 32] : vb[ 63: 32];
                       vc_mer[ 95: 64] <= vregfile0[ 64] ? va[ 95: 64] : vb[ 95: 64];
                       vc_mer[127: 96] <= vregfile0[ 96] ? va[127: 96] : vb[127: 96];
                 end
                 if(v_vmergevxm32) begin
                       vc_mer[ 31:  0] <= vregfile0[  0] ? a : vb[ 31:  0];
                       vc_mer[ 63: 32] <= vregfile0[ 32] ? a : vb[ 63: 32];
                       vc_mer[ 95: 64] <= vregfile0[ 64] ? a : vb[ 95: 64];
                       vc_mer[127: 96] <= vregfile0[ 96] ? a : vb[127: 96];
                 end
                 if(v_vmergevim32) begin
                       vc_mer[ 31:  0] <= vregfile0[  0] ? simm5 : vb[ 31:  0];
                       vc_mer[ 63: 32] <= vregfile0[ 32] ? simm5 : vb[ 63: 32];
                       vc_mer[ 95: 64] <= vregfile0[ 64] ? simm5 : vb[ 95: 64];
                       vc_mer[127: 96] <= vregfile0[ 96] ? simm5 : vb[127: 96];
                 end
            end
      
            // integer vector comparison
            if(ivc) begin
                 if(v_vmseqvv32) begin
                       vc_ivc[  0] <= (va[ 31:  0] == vb[ 31:  0]) ? 1 : 0;
                       vc_ivc[ 32] <= (va[ 63: 32] == vb[ 63: 32]) ? 1 : 0;
                       vc_ivc[ 64] <= (va[ 95: 64] == vb[ 95: 64]) ? 1 : 0;
                       vc_ivc[ 96] <= (va[127: 96] == vb[127: 96]) ? 1 : 0;
                 end
                 if(v_vmseqvx32) begin
                       vc_ivc[  0] <= (vb[ 31:  0] == a) ? 1 : 0;
                       vc_ivc[ 32] <= (vb[ 63: 32] == a) ? 1 : 0;
                       vc_ivc[ 64] <= (vb[ 95: 64] == a) ? 1 : 0;
                       vc_ivc[ 96] <= (vb[127: 96] == a) ? 1 : 0;
                 end
                 if(v_vmseqvi32) begin
                       vc_ivc[  0] <= (vb[ 31:  0] == simm5) ? 1 : 0;
                       vc_ivc[ 32] <= (vb[ 63: 32] == simm5) ? 1 : 0;
                       vc_ivc[ 64] <= (vb[ 95: 64] == simm5) ? 1 : 0;
                       vc_ivc[ 96] <= (vb[127: 96] == simm5) ? 1 : 0;
                 end
                 if(v_vmsnevv32) begin
                       vc_ivc[  0] <= (va[ 31:  0] != vb[ 31:  0]) ? 1 : 0;
                       vc_ivc[ 32] <= (va[ 63: 32] != vb[ 63: 32]) ? 1 : 0;
                       vc_ivc[ 64] <= (va[ 95: 64] != vb[ 95: 64]) ? 1 : 0;
                       vc_ivc[ 96] <= (va[127: 96] != vb[127: 96]) ? 1 : 0;
                 end
                 if(v_vmsnevx32) begin
                       vc_ivc[  0] <= (vb[ 31:  0] != a) ? 1 : 0;
                       vc_ivc[ 32] <= (vb[ 63: 32] != a) ? 1 : 0;
                       vc_ivc[ 64] <= (vb[ 95: 64] != a) ? 1 : 0;
                       vc_ivc[ 96] <= (vb[127: 96] != a) ? 1 : 0;
                 end
                 if(v_vmsnevi32) begin
                       vc_ivc[  0] <= (vb[ 31:  0] != simm5) ? 1 : 0;
                       vc_ivc[ 32] <= (vb[ 63: 32] != simm5) ? 1 : 0;
                       vc_ivc[ 64] <= (vb[ 95: 64] != simm5) ? 1 : 0;
                       vc_ivc[ 96] <= (vb[127: 96] != simm5) ? 1 : 0;
                 end
                 if(v_vmsltuvv32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} < {1'b0,va[ 31:  0]}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} < {1'b0,va[ 63: 32]}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} < {1'b0,va[ 95: 64]}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} < {1'b0,va[127: 96]}) ? 1 : 0;
                 end
                 if(v_vmsltuvx32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} < {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} < {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} < {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} < {1'b0,a}) ? 1 : 0;
                 end
                 if(v_vmsltvv32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) < $signed(va[ 31:  0])) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) < $signed(va[ 63: 32])) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) < $signed(va[ 95: 64])) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) < $signed(va[127: 96])) ? 1 : 0;
                 end
                 if(v_vmsltvx32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) < $signed(a)) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) < $signed(a)) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) < $signed(a)) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) < $signed(a)) ? 1 : 0;
                 end
                 if(v_vmsleuvv32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} <= {1'b0,va[ 31:  0]}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} <= {1'b0,va[ 63: 32]}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} <= {1'b0,va[ 95: 64]}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} <= {1'b0,va[127: 96]}) ? 1 : 0;
                 end
                 if(v_vmsleuvx32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} <= {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} <= {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} <= {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} <= {1'b0,a}) ? 1 : 0;
                 end
                 if(v_vmsleuvi32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} <= {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} <= {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} <= {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} <= {1'b0,simm5}) ? 1 : 0;
                 end
                 if(v_vmslevv32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) <= $signed(va[ 31:  0])) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) <= $signed(va[ 63: 32])) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) <= $signed(va[ 95: 64])) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) <= $signed(va[127: 96])) ? 1 : 0;
                 end
                 if(v_vmslevx32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) <= $signed(a)) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) <= $signed(a)) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) <= $signed(a)) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) <= $signed(a)) ? 1 : 0;
                 end
                 if(v_vmslevi32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) <= $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) <= $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) <= $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) <= $signed(simm5)) ? 1 : 0;
                 end
                 if(v_vmsgtuvx32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} > {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} > {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} > {1'b0,a}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} > {1'b0,a}) ? 1 : 0;
                 end
                 if(v_vmsgtuvi32) begin
                       vc_ivc[  0] <= ({1'b0,vb[ 31:  0]} > {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 32] <= ({1'b0,vb[ 63: 32]} > {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 64] <= ({1'b0,vb[ 95: 64]} > {1'b0,simm5}) ? 1 : 0;
                       vc_ivc[ 96] <= ({1'b0,vb[127: 96]} > {1'b0,simm5}) ? 1 : 0;
                 end
                 if(v_vmsgtvx32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) > $signed(a)) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) > $signed(a)) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) > $signed(a)) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) > $signed(a)) ? 1 : 0;
                 end
                 if(v_vmsgtvi32) begin
                       vc_ivc[  0] <= ($signed(vb[ 31:  0]) > $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 32] <= ($signed(vb[ 63: 32]) > $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 64] <= ($signed(vb[ 95: 64]) > $signed(simm5)) ? 1 : 0;
                       vc_ivc[ 96] <= ($signed(vb[127: 96]) > $signed(simm5)) ? 1 : 0;
                 end
            end
            
            // slide
            if(vslide) begin
                 if(v_vslideupvx32) begin
                      vc_sl = vb << a_32;
                 end
                 if(v_vslidedownvx32) begin
                      vc_sl = vb >> a_32;
                 end
                 if(v_vslideupvi32) begin
                      vc_sl = vb << simm5_32;
                 end
                 if(v_vslidedownvi32) begin
                      vc_sl= vb >> simm5_32;
                 end
            end
 
        end
    end
endmodule



