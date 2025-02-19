module riscv_i_vector_extend_m (clk,clrn,SEW,VLMAX,vleng,va,vb,a,simm5,vregfile_vd,vregfile0,
                                opcode,func3,func6,vm,vd,vs1,vs2,we,vc,vq,vr,sum_mask,cnt_vmul,cnt_vdiv,change_vmul,change_vdiv);
  
    input             clk, clrn, vm;           // clock and reset
    parameter         VLEN = 128;
    input      [31:0] a, SEW, VLMAX, vleng;
    input  [VLEN-1:0] va, vb; 
    input  [VLEN-1:0] vregfile_vd, vregfile0;
    input       [4:0] simm5, vd, vs1, vs2;
    input       [6:0] opcode;
    input       [5:0] func6;
    input       [2:0] func3;
    input       [7:0] we;
    output [VLEN-1:0] vc;
    output reg [VLEN-1:0] vq, vr;
    output reg  [31:0] sum_mask;
    output reg   [5:0] cnt_vmul; 
    output reg   [5:0] cnt_vdiv;
    output reg         change_vmul;
    output reg         change_vdiv;
  
  
    wire v_vredsumvs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000000);
    wire v_vredandvs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000001);
    wire v_vredorvs   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000010);
    wire v_vredxorvs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000011);
    wire v_vredminuvs = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000100);
    wire v_vredminvs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000101);
    wire v_vredmaxuvs = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000110);
    wire v_vredmaxvs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b000111);
    wire v_vslide1upvx   = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b001110);
    wire v_vslide1downvx = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b001111);
    wire v_vmvsx  = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b010000) & (vs2 == 5'b00000);
    wire v_vmvxs  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b010000) & (vs1 == 5'b00000);
    wire v_vcpopm = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b010000) & (vs1 == 5'b10000);
    wire v_vcompressvvm = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b010111);
    wire v_vmandnotmm = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011000) & (vm == 1'b1);
    wire v_vmandmm    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011001) & (vm == 1'b1);
    wire v_vmormm     = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011010) & (vm == 1'b1);
    wire v_vmxormm    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011011) & (vm == 1'b1);
    wire v_vmornotmm  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011100) & (vm == 1'b1);
    wire v_vmnandmm   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011101) & (vm == 1'b1);
    wire v_vmnormm    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011110) & (vm == 1'b1);
    wire v_vmxnormm   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b011111) & (vm == 1'b1);
    wire v_vdivuvv   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100000);
    wire v_vdivuvx   = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100000); 
    wire v_vdivvv    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100001); 
    wire v_vdivvx    = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100001);
    wire v_vremuvv   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100010);
    wire v_vremuvx   = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100010);
    wire v_vremvv    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100011);
    wire v_vremvx    = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100011);
    wire v_vmulvv    = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100101);
    wire v_vmulvx    = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100101);
    wire v_vmulhvv   = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100111);
    wire v_vmulhvx   = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100111);
    wire v_vmulhsuvv = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100110);
    wire v_vmulhsuvx = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100110);
    wire v_vmulhuvv  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b100100);
    wire v_vmulhuvx  = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b100100);
    wire v_vmaddvv  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b101001);
    wire v_vmaddvx  = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b101001);
    wire v_vnmsubvv = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b101011);
    wire v_vnmsubvx = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b101011);
    wire v_vmaccvv  = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b101101);
    wire v_vmaccvx  = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b101101);
    wire v_vnmsacvv = (opcode == 7'b1010111) & (func3 == 3'b010) & (func6 == 6'b101111);
    wire v_vnmsacvx = (opcode == 7'b1010111) & (func3 == 3'b110) & (func6 == 6'b101111);

    // vector register file, VLEN = 128 bits, ELEN = 32 bits
    wire             sew32 = (SEW == 32);
    reg  [VLEN-1:0]  vc_vmul;                         // for vmul
    reg  [31:0]      vc_vred;                         // for vred
    reg  [VLEN-1:0]  vc_iaom;                         // for integer arithmetic of mask
    reg  [VLEN-1:0]  vc_vma;                          // for vector multiply-add
    reg  [VLEN-1:0]  vc_sl;                           // for slide
    reg  [VLEN-1:0]  vc_com;                          // for compress
    reg  [31:0]      vc_vmv;                          // for vmv
    
    //vector
    wire     [5:0] cnt = cnt_vmul | cnt_vdiv;
    wire           ready_vmul = ~|cnt_vmul;    
    wire           ready_vdiv = ~|cnt_vdiv;
    wire           ready = ready_vmul & ready_vdiv; // ready = 1 if cnt = 0
    wire           change = change_vmul | change_vdiv;        // Orders needing counts
    reg     [31:0] vls_wide;

    //vmul
    reg             vmul_fuse;
    reg             re_vmul;
    wire            vmulvv32_st = v_vmulvv && !re_vmul && !ready_vmul && sew32;
    wire            vmulvx32_st = v_vmulvx && !re_vmul && !ready_vmul && sew32;
    wire            vmulhvv32   = v_vmulhvv && !ready_vmul && sew32;
    wire            vmulhvx32   = v_vmulhvx && !ready_vmul && sew32;
    wire            vmulhsuvv32 = v_vmulhsuvv && !ready_vmul && sew32;
    wire            vmulhsuvx32 = v_vmulhsuvx && !ready_vmul && sew32;
    wire            vmulhuvv32  = v_vmulhuvv && !ready_vmul && sew32;
    wire            vmulhuvx32  = v_vmulhuvx && !ready_vmul && sew32;
    wire            v_vmul      = v_vmulvv || v_vmulvx || v_vmulhvv || v_vmulhsuvv 
                                  || v_vmulhuvv || v_vmulhvx || v_vmulhsuvx || v_vmulhuvx;
    wire            vmulvv32    = vmulvv32_st || vmulhvv32 || vmulhsuvv32 || vmulhuvv32;
    wire            vmulvx32    = vmulvx32_st || vmulhvx32 || vmulhsuvx32 || vmulhuvx32;
    wire [VLEN-1:0] reg_va      = vmulvv32 ? va : reg_va;
    wire     [31:0] reg_a_vmul  = vmulvx32 ? a : reg_a_vmul;
    wire [VLEN-1:0] reg_vb      = (vmulvv32 || vmulvx32)? vb : reg_vb;
    wire            eq_va       = (reg_va == va) ? 1 : 0;
    wire            eq_vb       = (reg_vb == vb) ? 1 : 0;
    wire            vmulvv_re   = (v_vmulvv && eq_va) && re_vmul  && eq_vb && !ready_vmul;
    wire            vmulvx_re   = (v_vmulvx && eq_va) && re_vmul  && eq_vb && !ready_vmul;
    wire            vmul        = vmulvv32_st || vmulvv_re || vmulvx32_st || vmulvx_re || vmulhvv32
                                  || vmulhsuvv32 || vmulhuvv32 || vmulhvx32 || vmulhsuvx32 || vmulhuvx32;
    reg  [VLEN-1:0]  vcl;
    
    reg                vdiv_fuse;
    wire               v_vdivvv32  = v_vdivvv && sew32;
    wire               v_vdivvx32  = v_vdivvx && sew32;
    wire               v_vdivuvv32 = v_vdivuvv && sew32;
    wire               v_vdivuvx32 = v_vdivuvx && sew32;
    wire               v_vremvv32  = v_vremvv && sew32;
    wire               v_vremvx32  = v_vremvv && sew32;
    wire               v_vremuvv32 = v_vremuvv && sew32;
    wire               v_vremuvx32 = v_vremuvv && sew32;
    wire               is_vdrvv    = v_vdivvv32  || v_vremvv32;
    wire               is_vdruvv   = v_vdivuvv32 || v_vremuvv32;
    wire               is_vdrvx    = v_vdivvx32  || v_vremvx32;
    wire               is_vdruvx   = v_vdivuvx32 || v_vremuvx32;
    wire               is_vdr      = is_vdrvv  || is_vdrvx;
    wire               is_vdru     = is_vdruvv || is_vdruvx;
    wire               is_vrem     = v_vremvv  || v_vremvx;
    wire               is_vremu    = v_vremuvv || v_vremuvx;
    wire               vrem        = is_vrem   || is_vremu;
    reg          [1:0] stop_vdr;                               // 1 -> is_vdr stop, 2 -> is_vdru stop (& vq,vr hold)
    reg     [VLEN-1:0] reg_vb_n;
    reg  [VLEN-1+32:0] reg_vr_n;
    reg     [VLEN-1:0] reg_va_p, reg_vb_p;
    reg  [VLEN-1+32:0] reg_vr_p;
    reg         [31:0] va_si, vb_si;
    reg         [31:0] vbva_si;
    reg         [31:0] vbva_si_xor;
    reg          [7:0] not_zero;                               // dividend or divisor is zero
    reg          [7:0] q_zero;                                 // quotient zero
    
    // vred
    wire v_vredsumvs32  = v_vredsumvs && sew32;
    wire v_vredandvs32  = v_vredandvs && sew32;
    wire v_vredorvs32   = v_vredorvs && sew32;
    wire v_vredxorvs32  = v_vredxorvs && sew32;
    wire v_vredminuvs32 = v_vredminuvs && sew32;
    wire v_vredminvs32  = v_vredminvs && sew32;
    wire v_vredmaxuvs32 = v_vredmaxuvs && sew32;
    wire v_vredmaxvs32  = v_vredmaxvs && sew32;
    wire vred           = v_vredsumvs32 || v_vredandvs32 || v_vredorvs32 || v_vredxorvs32
                          || v_vredminuvs32 || v_vredminvs32 || v_vredmaxuvs32 || v_vredmaxvs32;

    
    // integer arithmetic of mask
    wire v_vmandnotmm32 = v_vmandnotmm && sew32;
    wire v_vmandmm32    = v_vmandmm && sew32;
    wire v_vmormm32     = v_vmormm && sew32;
    wire v_vmxormm32    = v_vmxormm && sew32;
    wire v_vmornotmm32  = v_vmornotmm && sew32;
    wire v_vmnandmm32   = v_vmnandmm && sew32;
    wire v_vmnormm32    = v_vmnormm && sew32;
    wire v_vmxnormm32   = v_vmxnormm && sew32;
    wire viaom          = v_vmandnotmm32 || v_vmandmm32 || v_vmormm32 || v_vmxormm32
                        || v_vmornotmm32 || v_vmnandmm32 || v_vmnormm32 || v_vmxnormm32;

    // vector multiply-add
    wire v_vmaddvv32  = v_vmaddvv && sew32;
    wire v_vmaddvx32  = v_vmaddvx && sew32;
    wire v_vnmsubvv32 = v_vnmsubvv && sew32;
    wire v_vnmsubvx32 = v_vnmsubvx && sew32;
    wire v_vmaccvv32  = v_vmaccvv && sew32;
    wire v_vmaccvx32  = v_vmaccvx && sew32;
    wire v_vnmsacvv32 = v_vnmsacvv && sew32;
    wire v_vnmsacvx32 = v_vnmsacvx && sew32;
    wire vmuad        = v_vmaddvv32 || v_vmaddvx32 || v_vnmsubvv32 || v_vnmsubvx32 
                        || v_vmaccvv32 || v_vmaccvx32 || v_vnmsacvv32 || v_vnmsacvx32;

    // slide
    reg  [VLEN-1:0] vf;
    reg  [VLEN-1:0] vl_sl;
    wire            v_vslide1upvx32   = v_vslide1upvx && sew32;
    wire            v_vslide1downvx32 = v_vslide1downvx && sew32;
    wire            vslide            = v_vslide1upvx32 || v_vslide1downvx32;


    // vector count population in mask
    wire        v_vcpopm32 = v_vcpopm && sew32;
    wire        cpop       = v_vcpopm32;

    // compress
    wire             v_vcompressvvm32 = v_vcompressvvm && sew32;
    wire             comp             = v_vcompressvvm32;
    reg  [VLEN-1:0]  press;
    reg  [VLEN-1:0]  ve_com;
	 
    // vmv
    wire v_vmvxs32 = v_vmvxs && sew32;
    wire vmv = v_vmvxs32 || v_vmvsx;
    
    wire [VLEN-1:0]  vc = (v_vmul) ? vc_vmul : 
                          (vred) ? vc_vred : 
                          (viaom) ? vc_iaom : 
                          (vmuad) ? vc_vma : 
                          (vslide) ? vc_sl : 
                          (comp) ? vc_com : 
                          (vmv) ? {96'b0,vc_vmv} : 0;
    
    // for count
    always @ (negedge clk or negedge clrn) begin
	      if (!clrn) begin
	          // vmul
            cnt_vmul  <= 0;
            
            // vdiv
            cnt_vdiv    <= 0;
            vdiv_fuse   <= 0;
            stop_vdr    <= 2'd0;
	          reg_vb_n    <= 0;
            reg_vr_n    <= 0;
            change_vdiv <= 0;
       end
       else begin
            // vmul
            if (v_vmul) cnt_vmul <= cnt_vmul == 1 ? 0 : cnt_vmul + 6'd1;

            // vdiv
            if (is_vdr | is_vdru) begin
	              change_vdiv = 0;
                if (cnt_vdiv == 6'd33 && is_vdru) begin      // 1 -> load, 2-33 -> 32 cycles for vdivu
                    cnt_vdiv <= 0;
                    vdiv_fuse <= 1;
                    stop_vdr  <= 2'd2;
                    change_vdiv = 1;
                end 
                else if (cnt_vdiv == 6'd33 && is_vdr) begin  // 2's complement for vdiv && non-negative
                    if (|vbva_si) begin                 // signed
                        reg_vb_n[ 31:  0] <= vbva_si_xor[0] ? ~reg_vb_p[ 31:  0] + 32'b1 : 0;
                        reg_vr_n[ 32:  0] <= vb[ 31] ? ~reg_vr_p[ 32:  0] + 33'b1 : 0;
                        reg_vb_n[ 63: 32] <= vbva_si_xor[1] ? ~reg_vb_p[ 63: 32] + 32'b1 : 0;
                        reg_vr_n[ 65: 33] <= vb[ 63] ? ~reg_vr_p[ 65: 33] + 33'b1 : 0;
                        reg_vb_n[ 95: 64] <= vbva_si_xor[2] ? ~reg_vb_p[ 95: 64] + 32'b1 : 0;
                        reg_vr_n[ 98: 66] <= vb[ 95]  ? ~reg_vr_p[ 98: 66] + 33'b1 : 0;
                        reg_vb_n[127: 96] <= vbva_si_xor[3] ? ~reg_vb_p[127: 96] + 32'b1 : 0;
                        reg_vr_n[131: 99] <= vb[127] ? ~reg_vr_p[131: 99] + 33'b1 : 0;
                        cnt_vdiv <= cnt_vdiv + 6'd1;
                    end  
                    else begin                           // unsigned
                        cnt_vdiv  <= 0;
                        vdiv_fuse <= 1;
                        stop_vdr  <= 2'd1;
                    end
                end 
                else if (cnt_vdiv == 6'd34 && is_vdr) begin    // 1 -> load, 2-34 -> 33 cycles for vdiv && non-negative
                    cnt_vdiv  <= 0;
                    vdiv_fuse <= 1;
                    stop_vdr  <= 2'd1;
                    change_vdiv = 1;
                end
                else if (cnt_vdiv == 6'd0 && |stop_vdr && vrem) begin
                    if ({stop_vdr == 2'd1 && is_vrem} || {stop_vdr == 2'd2 && is_vremu}) begin
                        change_vdiv = 1;
                        stop_vdr  <= 2'd0;
                    end
                end
                else cnt_vdiv <= cnt_vdiv + 6'd1;
            end
       end
    end

    // use count
    always @ (posedge clk or negedge clrn) begin
	      if (!clrn) begin
	          //vmul
	          vc_vmul <= 0;
	          vcl     <= 0;
	          re_vmul <= 0;
            change_vmul <= 0;

            //vdiv
            va_si       <= 0;
	          vb_si       <= 0;
            vbva_si     <= 0;
	          vbva_si_xor <= 0;
       	    not_zero    <= 0;
            q_zero      <= 0;
	      end
        else begin
            //vmul
            if(vmul) begin
                  if(vmulvv32_st) begin
                       re_vmul <= 0;
		                   change_vmul <= 1;
		                   vc_vmul[ 31:  0] <= (we[0]) ? va[ 31:  0] * vb[ 31:  0] : 0;
                       vc_vmul[ 63: 32] <= (we[1]) ? va[ 63: 32] * vb[ 63: 32] : 0;
                       vc_vmul[ 95: 64] <= (we[2]) ? va[ 95: 64] * vb[ 95: 64] : 0;
                       vc_vmul[127: 96] <= (we[3]) ? va[127: 96] * vb[127: 96] : 0;
                  end
                  if(vmulvx32_st) begin
                       vc_vmul[ 31:  0] <= a * vb[ 31:  0];
                       vc_vmul[ 63: 32] <= a * vb[ 63: 32];
                       vc_vmul[ 95: 64] <= a * vb[ 95: 64];
                       vc_vmul[127: 96] <= a * vb[127: 96];                                 
                       re_vmul <= 0;
		                   change_vmul <= 1;
                  end
                  if(vmulvv_re) begin
                       vc_vmul <= vcl;
                       change_vmul <= 1;
                       vmul_fuse <= 1;
                       re_vmul <= 0;
                  end
                  if(vmulvx_re) begin
                       vc_vmul <= vcl;
                       change_vmul <= 1;
                       vmul_fuse <= 1;
                       re_vmul <= 0;
                  end
                  if(vmulhvv32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= $signed(va[ 31:  0]) * $signed(vb[ 31:  0]);
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= $signed(va[ 63: 32]) * $signed(vb[ 63: 32]);
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= $signed(va[ 95: 64]) * $signed(vb[ 95: 64]);
                       {vc_vmul[127: 96],vcl[127: 96]} <= $signed(va[127: 96]) * $signed(vb[127: 96]);
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end
                  if(vmulhsuvv32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= $signed(vb[ 31:  0]) * $signed({1'b0,va[ 31:  0]});
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= $signed(vb[ 63: 32]) * $signed({1'b0,va[ 63: 32]});
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= $signed(vb[ 95: 64]) * $signed({1'b0,va[ 95: 64]});
                       {vc_vmul[127: 96],vcl[127: 96]} <= $signed(vb[127: 96]) * $signed({1'b0,va[127: 96]});
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end
                  if(vmulhuvv32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= va[ 31:  0] * vb[ 31:  0];
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= va[ 63: 32] * vb[ 63: 32];
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= va[ 95: 64] * vb[ 95: 64];
                       {vc_vmul[127: 96],vcl[127: 96]} <= va[127: 96] * vb[127: 96];
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end
                  if(vmulhvx32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= $signed(a) * $signed(vb[ 31:  0]);
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= $signed(a) * $signed(vb[ 63: 32]);
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= $signed(a) * $signed(vb[ 95: 64]);
                       {vc_vmul[127: 96],vcl[127: 96]} <= $signed(a) * $signed(vb[127: 96]);
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end
                  if(vmulhsuvx32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= $signed(vb[ 31:  0]) * $signed({1'b0,a});
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= $signed(vb[ 63: 32]) * $signed({1'b0,a});
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= $signed(vb[ 95: 64]) * $signed({1'b0,a});
                       {vc_vmul[127: 96],vcl[127: 96]} <= $signed(vb[127: 96]) * $signed({1'b0,a});
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end
                  if(vmulhuvx32) begin
                       {vc_vmul[ 31:  0],vcl[ 31:  0]} <= a * vb[ 31:  0];
                       {vc_vmul[ 63: 32],vcl[ 63: 32]} <= a * vb[ 63: 32];
                       {vc_vmul[ 95: 64],vcl[ 95: 64]} <= a * vb[ 95: 64];
                       {vc_vmul[127: 96],vcl[127: 96]} <= a * vb[127: 96];
                       re_vmul <= 1;
                       change_vmul <= 1;
                  end  
            end
            if (ready_vmul) begin
                change_vmul <= 0;
                vmul_fuse <= 0;
            end
            if (vmul_fuse) vmul_fuse <= 0;

            //vdiv
            if (is_vdr || is_vdru) begin
                if (cnt_vdiv == 6'd1) begin
                    reg_vr_p <= 0;
                    if (is_vdr) begin // v_vdivvv32 | v_vremvv32 | v_vdivvx32 | v_vremvx32
				                vb_si[0] <= vb[ 31];
                        reg_vb_p[ 31:  0] = {is_vdr && vb_si[0]} ? {~vb[ 31:  0] + 32'd1} : vb[ 31:  0];
                        vb_si[1] <= vb[ 63];
                        reg_vb_p[ 63: 32] = {is_vdr && vb_si[0]} ? {~vb[ 63: 32] + 32'd1} : vb[ 63: 32];
                        vb_si[2] <= vb[ 95];
                        reg_vb_p[ 95: 64] = {is_vdr && vb_si[0]} ? {~vb[ 95: 64] + 32'd1} : vb[ 95: 64];
                        vb_si[3] <= vb[127];
                        reg_vb_p[127: 96] = {is_vdr && vb_si[0]} ? {~vb[127: 96] + 32'd1} : vb[127: 96];
                        if (is_vdrvv) begin // v_vdivvv32 | v_vremvv32
                            va_si[0] <= va[ 31];
                            reg_va_p[ 31:  0] <= {is_vdr && va_si[0]} ? {~va[ 31:  0] + 32'd1} : va[ 31:  0];                                      
                            va_si[1] <= va[ 63];
                            reg_va_p[ 63: 32] <= {is_vdr && va_si[0]} ? {~va[ 63: 32] + 32'd1} : va[ 63: 32];                                      
                            va_si[2] <= va[ 95];    
                            reg_va_p[ 95: 64] <= {is_vdr && va_si[0]} ? {~va[ 95: 64] + 32'd1} : va[ 95: 64];                                      
                            va_si[3] <= va[127];
                            reg_va_p[127: 96] <= {is_vdr && va_si[0]} ? {~va[127: 96] + 32'd1} : va[127: 96];                                
                        end
                        else if (is_vdrvx) begin// v_vdivvx32 | v_vremvx32
                            if (a[31]) begin
                                va_si[7:0] <= 8'b11111111;
                                reg_va_p[31:0] <= ~a + 32'd1;
                            end 
                            else begin
					                      reg_va_p[ 31:  0] <= a[31:0];
                                reg_va_p[ 63: 32] <= a[31:0];
                                reg_va_p[ 95: 64] <= a[31:0];
                                reg_va_p[127: 96] <= a[31:0];
                            end
                            vbva_si     <= vb_si | va_si;
                            vbva_si_xor <= vb_si ^ va_si;
                        end
                    end
                    else if (is_vdru) begin // v_vdivuvv | v_vremuvv | v_vdivuvx | v_vremuvx
                        reg_vb_p = vb;
                        if (is_vdruvv) begin // v_vdivuvv | v_vremuvv
                            reg_va_p <= va;
                        end 
                        else if (is_vdruvx) begin// v_vdivuvx | v_vremuvx
                            reg_va_p[ 31:  0] <= a[31:0];
                            reg_va_p[ 63: 32] <= a[31:0];
                            reg_va_p[ 95: 64] <= a[31:0];
                            reg_va_p[127: 96] <= a[31:0];
                        end
                    end
			              not_zero[0] <= (|reg_va_p[ 31:  0] && |reg_vb_p[ 31:  0]) ?  1 : 0;
			              q_zero[0] <= (reg_vb_p[ 31:  0] < reg_va_p[ 31:  0]) ? 1 : 0;
                    not_zero[1] <= (|reg_va_p[ 63: 32] && |reg_vb_p[ 63: 32]) ?  1 : 0;
			              q_zero[1] <= (reg_vb_p[ 63: 32] < reg_va_p[ 63: 32]) ? 1 : 0;
                    not_zero[2] <= (|reg_va_p[ 95: 64] && |reg_vb_p[ 95: 64]) ?  1 : 0;
			              q_zero[2] <= (reg_vb_p[ 95: 64] < reg_va_p[ 95: 64]) ? 1 : 0;
                    not_zero[3] <= (|reg_va_p[127: 96] && |reg_vb_p[127: 96]) ?  1 : 0;
			              q_zero[3] <= (reg_vb_p[127: 96] < reg_va_p[127: 96]) ? 1 : 0;
                end
                else if (!ready_vdiv) begin
                    if ({cnt_vdiv == 6'd33 && is_vdru} || {cnt_vdiv == 6'd33 && is_vdr && ~|vbva_si}) begin // use reg_vb(r)_p
			                  vq[ 31:  0] <= (q_zero[0]) ? 32'h00            : reg_vb_p[ 31:  0];
                        vr[ 31:  0] <= (q_zero[0]) ? reg_vb_p[ 31:  0] : reg_vr_p[ 31:  0];
                        vq[ 63: 32] <= (q_zero[1]) ? 32'h00            : reg_vb_p[ 63: 32];
                        vr[ 63: 32] <= (q_zero[1]) ? reg_vb_p[ 63: 32] : reg_vr_p[ 64: 33];
                        vq[ 95: 64] <= (q_zero[2]) ? 32'h00            : reg_vb_p[ 95: 64];
                        vr[ 95: 64] <= (q_zero[2]) ? reg_vb_p[ 95: 64] : reg_vr_p[ 97: 66];
                        vq[127: 96] <= (q_zero[3]) ? 32'h00            : reg_vb_p[127: 96];
                        vr[127: 96] <= (q_zero[3]) ? reg_vb_p[127: 96] : reg_vr_p[130: 99];
                    end
                    else if (cnt_vdiv != 6'd34) begin
                        // vr = vrb_lshift - va
                        // vr is negative -> vquotient = 0, vr is non-negative -> vquotient = 1
                        // vr is negative -> vr = vr + va
				                if (not_zero[0] && !q_zero[0]) begin
                            reg_vr_p[ 32:  0] = {reg_vr_p[ 31:  0], reg_vb_p[ 31]} - {1'b0, reg_va_p[ 31:  0]};
                            reg_vb_p[ 31:  0] = {reg_vb_p[ 30:  0], ~reg_vr_p[ 32]};
                            reg_vr_p[ 32:  0] = reg_vr_p[ 32] ? reg_vr_p[ 32:  0] + {1'b0, reg_va_p[ 31:  0]} : reg_vr_p[ 32:  0];
                        end
                        if (not_zero[1] && !q_zero[1]) begin
                            reg_vr_p[ 65: 33] = {reg_vr_p[ 64: 33], reg_vb_p[ 63]} - {1'b0, reg_va_p[ 63: 32]};
                            reg_vb_p[ 63: 32] = {reg_vb_p[ 62: 32], ~reg_vr_p[ 65]};
                            reg_vr_p[ 65: 33] = reg_vr_p[ 65] ? reg_vr_p[ 65: 33] + {1'b0, reg_va_p[ 63: 32]} : reg_vr_p[ 65: 33];
                        end
                        if (not_zero[2] && !q_zero[2]) begin
                            reg_vr_p[ 98: 66] = {reg_vr_p[ 97: 66], reg_vb_p[ 95]} - {1'b0, reg_va_p[ 95: 64]};
                            reg_vb_p[ 95: 64] = {reg_vb_p[ 94: 64], ~reg_vr_p[ 98]};
                            reg_vr_p[ 98: 66] = reg_vr_p[ 98] ? reg_vr_p[ 98: 66] + {1'b0, reg_va_p[ 95: 64]} : reg_vr_p[ 98: 66];
                        end
                        if (not_zero[3] && !q_zero[3]) begin
                            reg_vr_p[131: 99] = {reg_vr_p[130: 99], reg_vb_p[127]} - {1'b0, reg_va_p[127: 96]};
                            reg_vb_p[127: 96] = {reg_vb_p[126: 96], ~reg_vr_p[131]};
                            reg_vr_p[131: 99] = reg_vr_p[131] ? reg_vr_p[131: 99] + {1'b0, reg_va_p[127: 96]} : reg_vr_p[131: 99];
                        end
                    end 
	                  if (cnt_vdiv == 6'd34 && is_vdr) begin // use reg_vb(r)_n
			                  vq[ 31:  0] <= (q_zero[0]) ? 32'h00            : reg_vb_n[ 31:  0];
                        vr[ 31:  0] <= (q_zero[0]) ? reg_vb_n[ 31:  0] : reg_vr_n[ 31:  0];
                        vq[ 63: 32] <= (q_zero[1]) ? 32'h00            : reg_vb_n[ 63: 32];
                        vr[ 63: 32] <= (q_zero[1]) ? reg_vb_n[ 63: 32] : reg_vr_n[ 64: 33];
                        vq[ 95: 64] <= (q_zero[2]) ? 32'h00            : reg_vb_n[ 95: 64];
                        vr[ 95: 64] <= (q_zero[2]) ? reg_vb_n[ 95: 64] : reg_vr_n[ 97: 66];
                        vq[127: 96] <= (q_zero[3]) ? 32'h00            : reg_vb_n[127: 96];
                        vr[127: 96] <= (q_zero[3]) ? reg_vb_n[127: 96] : reg_vr_n[130: 99];
                    end
                end 
                else if (ready_vdiv) begin // reset vq, vr
		                vq <= 0;
		                vr <= 0;
		            end
		            if (vdiv_fuse) vdiv_fuse <= 0;
	          end
        end
    end
    
    // not use count
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
          

            // vred
            vc_vred <= 0;
      
            // integer arithmetic of mask
            vc_iaom <= 0;

            // vector multiply-add
            vc_vma <= 0;

            // slide
            vf       <= 0;
	          vc_sl    <= 0;

            // vector count population in mask
            sum_mask <= 0;

            // compress
            press  <= 0;
	          vc_com <= 0;
            ve_com <= 0;
				
				    // vmv
				    vc_vmv <= 0;
        end
        else begin
            

            // vred
            if(vred) begin
                  if(v_vredsumvs32) begin // vd[0] = vs1[0] + (vs2[0] + ... &+vs2[vl-1])
                        vc_vred[31:0] = va[31:0] + vb[ 31:  0] + vb[ 63: 32] + vb[ 95: 64] + vb[127: 96];
                  end
                  if(v_vredandvs32) begin // vd[0] = vs1[0] & (vs2[0] & ... & vs2[vl-1])
                        vc_vred[31:0] = va[31:0] & vb[ 31:  0] & vb[ 63: 32] & vb[ 95: 64] & vb[127: 96];
                  end
                  if(v_vredorvs32) begin // vd[0] = vs1[0] | (vs2[0] | ... | vs2[vl-1])
                        vc_vred[31:0] = va[31:0] | vb[ 31:  0] | vb[ 63: 32] | vb[ 95: 64] | vb[127: 96];
                  end
                  if(v_vredxorvs32) begin // vd[0] = vs1[0] ^ (vs2[0] ^ ... ^ vs2[vl-1])
                        vc_vred[31:0] = va[31:0] ^ vb[ 31:  0] ^ vb[ 63: 32] ^ vb[ 95: 64] ^ vb[127: 96];
                  end
                  if(v_vredminuvs32) begin // vd[0] = minu(vs1[0] , (vs2[0] , ... , vs2[vl-1]))
                        if (we[0]) vc_vred[31:0] = ({1'b0,va[31:0]}      < {1'b0,vb[ 31:  0]}) ? va[31:0]      : vb[ 31:  0];
                        if (we[1]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} < {1'b0,vb[ 63: 32]}) ? vc_vred[31:0] : vb[ 63: 32];
                        if (we[2]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} < {1'b0,vb[ 95: 64]}) ? vc_vred[31:0] : vb[ 95: 64];
                        if (we[3]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} < {1'b0,vb[127: 96]}) ? vc_vred[31:0] : vb[127: 96];
                  end
                  if(v_vredminvs32) begin // vd[0] = min(vs1[0] , (vs2[0] , ... , vs2[vl-1]))
                        if (we[0]) vc_vred[31:0] = (va[31]      ^ vb[ 31]) ? (va[31])      ? va[31:0]      : vb[ 31:  0] 
                                   : ($signed(va[31:0])      < $signed(vb[ 31: 0]))  ? va[31:0]      : vb[31:0];
                        if (we[1]) vc_vred[31:0] = (vc_vred[31] ^ vb[ 63]) ? (vc_vred[31]) ? vc_vred[31:0] : vb[ 63: 32]
                                   : ($signed(vc_vred[31:0]) < $signed(vb[ 63: 32])) ? vc_vred[31:0] : vb[ 63: 32];
                        if (we[2]) vc_vred[31:0] = (vc_vred[31] ^ vb[ 95]) ? (vc_vred[31]) ? vc_vred[31:0] : vb[ 95: 64]
                                   : ($signed(vc_vred[31:0]) < $signed(vb[ 95: 64])) ? vc_vred[31:0] : vb[ 95: 64];
                        if (we[3]) vc_vred[31:0] = (vc_vred[31] ^ vb[127]) ? (vc_vred[31]) ? vc_vred[31:0] : vb[127: 96]
                                   : ($signed(vc_vred[31:0]) < $signed(vb[127: 96])) ? vc_vred[31:0] : vb[127: 96];
                  end
                  if(v_vredmaxuvs32) begin // vd[0] = maxu(vs1[0] , (vs2[0] , ... , vs2[vl-1]))
                        if (we[0]) vc_vred[31:0] = ({1'b0,va[31:0]}      > {1'b0,vb[ 31:  0]}) ? va[31:0]      : vb[ 31:  0];
                        if (we[1]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} > {1'b0,vb[ 63: 32]}) ? vc_vred[31:0] : vb[ 63: 32];
                        if (we[2]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} > {1'b0,vb[ 95: 64]}) ? vc_vred[31:0] : vb[ 95: 64];
                        if (we[3]) vc_vred[31:0] = ({1'b0,vc_vred[31:0]} > {1'b0,vb[127: 96]}) ? vc_vred[31:0] : vb[127: 96];
                  end
                  if(v_vredmaxvs32) begin // vd[0] = max(vs1[0] , (vs2[0] , ... , vs2[vl-1]))
                        if (we[0]) vc_vred[31:0] = (va[31]      ^ vb[ 31]) ? (vb[31]) ? va[31:0]      : vb[ 31:  0] 
                                   : ($signed(va[31:0]) > $signed(vb[ 31:  0])) ? va[31:0]      : vb[ 31:  0];
                        if (we[1]) vc_vred[31:0] = (vc_vred[31] ^ vb[ 63]) ? (vb[31]) ? vc_vred[31:0] : vb[ 63: 32]
                                   : ($signed(vc[31:0]) > $signed(vb[ 63: 32])) ? vc_vred[31:0] : vb[ 63: 32];
                        if (we[2]) vc_vred[31:0] = (vc_vred[31] ^ vb[ 95]) ? (vb[31]) ? vc_vred[31:0] : vb[ 95: 64]
                                   : ($signed(vc[31:0]) > $signed(vb[ 95: 64])) ? vc_vred[31:0] : vb[ 95: 64];
                        if (we[3]) vc_vred[31:0] = (vc_vred[31] ^ vb[127]) ? (vb[31]) ? vc_vred[31:0] : vb[127: 96]
                                   : ($signed(vc[31:0]) > $signed(vb[127: 96])) ? vc_vred[31:0] : vb[127: 96];
                   end
            end

            

            // integer arithmetic of mask
            if(viaom) begin 
                  if(v_vmandnotmm32) begin
                        vc_iaom[  0] <= !va[  0] && vb[  0];
                        vc_iaom[ 32] <= !va[ 32] && vb[ 32];
                        vc_iaom[ 64] <= !va[ 64] && vb[ 64];
                        vc_iaom[ 96] <= !va[ 96] && vb[ 96];
                  end
                  if(v_vmandmm32) begin
                        vc_iaom[  0] <= va[  0] && vb[  0];
                        vc_iaom[ 32] <= va[ 32] && vb[ 32];
                        vc_iaom[ 64] <= va[ 64] && vb[ 64];
                        vc_iaom[ 96] <= va[ 96] && vb[ 96];
                  end
                  if(v_vmormm32) begin
                        vc_iaom[  0] <= va[  0] || vb[  0];
                        vc_iaom[ 32] <= va[ 32] || vb[ 32];
                        vc_iaom[ 64] <= va[ 64] || vb[ 64];
                        vc_iaom[ 96] <= va[ 96] || vb[ 96];
                  end
                  if(v_vmxormm32) begin
                        vc_iaom[  0] <= va[  0] ^^ vb[  0];
                        vc_iaom[ 32] <= va[ 32] ^^ vb[ 32];
                        vc_iaom[ 64] <= va[ 64] ^^ vb[ 64];
                        vc_iaom[ 96] <= va[ 96] ^^ vb[ 96];
                  end
                  if(v_vmornotmm32) begin
                        vc_iaom[  0] <= !va[  0] || vb[  0];
                        vc_iaom[ 32] <= !va[ 32] || vb[ 32];
                        vc_iaom[ 64] <= !va[ 64] || vb[ 64];
                        vc_iaom[ 96] <= !va[ 96] || vb[ 96];
                  end
                  if(v_vmnandmm32) begin
                        vc_iaom[  0] <= !(va[  0] && vb[  0]);
                        vc_iaom[ 32] <= !(va[ 32] && vb[ 32]);
                        vc_iaom[ 64] <= !(va[ 64] && vb[ 64]);
                        vc_iaom[ 96] <= !(va[ 96] && vb[ 96]);
                  end
                  if(v_vmnormm32) begin
                        vc_iaom[  0] <= !(va[  0] || vb[  0]);
                        vc_iaom[ 32] <= !(va[ 32] || vb[ 32]);
                        vc_iaom[ 64] <= !(va[ 64] || vb[ 64]);
                        vc_iaom[ 96] <= !(va[ 96] || vb[ 96]);
                  end
                  if(v_vmxnormm32) begin
                        vc_iaom[  0] <= !(va[  0] ^^ vb[  0]);
                        vc_iaom[ 32] <= !(va[ 32] ^^ vb[ 32]);
                        vc_iaom[ 64] <= !(va[ 64] ^^ vb[ 64]);
                        vc_iaom[ 96] <= !(va[ 96] ^^ vb[ 96]);
                  end
            end

           
            
            

            // vector multiply-add
            if(vmuad) begin
                 if(v_vmaddvv32) begin
                       vc_vma[ 31:  0] <= (va[ 31:  0] * vregfile_vd[ 31:  0]) + vb[ 31:  0];
                       vc_vma[ 63: 32] <= (va[ 63: 32] * vregfile_vd[ 63: 32]) + vb[ 63: 32];
                       vc_vma[ 95: 64] <= (va[ 95: 64] * vregfile_vd[ 95: 64]) + vb[ 95: 64];
                       vc_vma[127: 96] <= (va[127: 96] * vregfile_vd[127: 96]) + vb[127: 96];
                 end
                 if(v_vmaddvx32) begin
                       vc_vma[ 31:  0] <= (a * vregfile_vd[ 31:  0]) + vb[ 31:  0];
                       vc_vma[ 63: 32] <= (a * vregfile_vd[ 63: 32]) + vb[ 63: 32];
                       vc_vma[ 95: 64] <= (a * vregfile_vd[ 95: 64]) + vb[ 95: 64];
                       vc_vma[127: 96] <= (a * vregfile_vd[127: 96]) + vb[127: 96];
                 end
                 if(v_vnmsubvv32) begin
                       vc_vma[ 31:  0] <= vb[ 31:  0] - (va[ 31:  0] * vregfile_vd[ 31:  0]);
                       vc_vma[ 63: 32] <= vb[ 63: 32] - (va[ 63: 32] * vregfile_vd[ 63: 32]);
                       vc_vma[ 95: 64] <= vb[ 95: 64] - (va[ 95: 64] * vregfile_vd[ 95: 64]);
                       vc_vma[127: 96] <= vb[127: 96] - (va[127: 96] * vregfile_vd[127: 96]);
                 end
                 if(v_vnmsubvx32) begin
                       vc_vma[ 31:  0] <= vb[ 31:  0] - (a * vregfile_vd[ 31:  0]);
                       vc_vma[ 63: 32] <= vb[ 63: 32] - (a * vregfile_vd[ 63: 32]);
                       vc_vma[ 95: 64] <= vb[ 95: 64] - (a * vregfile_vd[ 95: 64]);
                       vc_vma[127: 96] <= vb[127: 96] - (a * vregfile_vd[127: 96]);
                 end
                 if(v_vmaccvv32) begin
                       vc_vma[ 31:  0] <= (va[ 31:  0] * vb[ 31:  0]) + vregfile_vd[ 31:  0];
                       vc_vma[ 63: 32] <= (va[ 63: 32] * vb[ 63: 32]) + vregfile_vd[ 63: 32];
                       vc_vma[ 95: 64] <= (va[ 95: 64] * vb[ 95: 64]) + vregfile_vd[ 95: 64];
                       vc_vma[127: 96] <= (va[127: 96] * vb[127: 96]) + vregfile_vd[127: 96];
                 end
                 if(v_vmaccvx32) begin
                       vc_vma[ 31:  0] <= (a * vb[ 31:  0]) + vregfile_vd[ 31:  0];
                       vc_vma[ 63: 32] <= (a * vb[ 63: 32]) + vregfile_vd[ 63: 32];
                       vc_vma[ 95: 64] <= (a * vb[ 95: 64]) + vregfile_vd[ 95: 64];
                       vc_vma[127: 96] <= (a * vb[127: 96]) + vregfile_vd[127: 96];
                 end
                 if(v_vnmsacvv32) begin
                       vc_vma[ 31:  0] <= vregfile_vd[ 31:  0] - (va[ 31:  0] * vb[ 31:  0]);
                       vc_vma[ 63: 32] <= vregfile_vd[ 63: 32] - (va[ 63: 32] * vb[ 63: 32]);
                       vc_vma[ 95: 64] <= vregfile_vd[ 95: 64] - (va[ 95: 64] * vb[ 95: 64]);
                       vc_vma[127: 96] <= vregfile_vd[127: 96] - (va[127: 96] * vb[127: 96]);
                 end
                 if(v_vnmsacvx32) begin
                       vc_vma[ 31:  0] <= vregfile_vd[ 31:  0] - (a * vb[ 31:  0]);
                       vc_vma[ 63: 32] <= vregfile_vd[ 63: 32] - (a * vb[ 63: 32]);
                       vc_vma[ 95: 64] <= vregfile_vd[ 95: 64] - (a * vb[ 95: 64]);
                       vc_vma[127: 96] <= vregfile_vd[127: 96] - (a * vb[127: 96]);
                 end
            end
            
            // slide
            if(vslide) begin
                 if(v_vslide1upvx32) begin
                      vf = vb << 32;
                      vf[31:0] = a;
                      vc_sl = vf;
                 end
                 if(v_vslide1downvx32) begin
                      vf = vb >> 32;
                      vl_sl = (vleng-1) << 5;
                      vf[vl_sl+:32] = a;
                      vc_sl = vf;
                 end
            end
 
            // vector count population in mask
            if(cpop) begin
                  if(v_vcpopm32) begin 
                      sum_mask <= vb[  0] && vregfile0[  0]
                                + vb[ 32] && vregfile0[ 32]
                                + vb[ 64] && vregfile0[ 64]
                                + vb[ 96] && vregfile0[ 96];
                  end
            end
             
            // compress
            if(comp) begin
                 if(v_vcompressvvm32) begin
                       press = 0-1;
                       if (vregfile0[ 96]) begin
                           ve_com = {ve_com[95:0],va[127: 96]};
                           press = press << 32;
                       end
                       if (vregfile0[ 64]) begin
                           ve_com = {ve_com[95:0],va[ 95: 64]};
                           press = press << 32;
                       end
                       if (vregfile0[ 32]) begin
                           ve_com = {ve_com[95:0],va[ 63: 32]};
                           press = press << 32;
                       end
                       if (vregfile0[  0]) begin
                           ve_com = {ve_com[95:0],va[ 31:  0]};
                           press = press << 32;
                       end
                       vf = vb & press;
                       vc_com = ve_com | vf;
                 end
            end
				
            // vmv
			      if(vmv) begin
			           if(v_vmvxs32) vc_vmv = vb[31:0];
					       if(v_vmvsx)   vc_vmv = a;
			      end
        end
    end
    
endmodule




