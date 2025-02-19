module riscv_rv32im_v_cpu (clk,clrn,inst,mem,pc,alu_out,b,wmem);
  
    input             clk, clrn;           // clock and reset
    input      [31:0] inst;                // instruction
    input      [31:0] mem;                 // load data
    output     [31:0] pc;                  // program counter
    output reg [31:0] alu_out;             // alu output
    output     [31:0] b;
    output reg  [3:0] wmem;

    // control signals
    reg           wreg;                    // write regfile
    reg           rmem;                    // write/read memory
    reg    [31:0] mem_out;                 // mem output
    reg    [31:0] m_addr;                  // mem address
    reg    [31:0] next_pc;                 // next pc
    reg    [31:0] d_t_mem;
    wire   [31:0] pc_plus_4 = pc + 4;      // pc + 4
    
    //matrix register   horizontal[vertical]
    parameter     VLEN = 128;                   // bits, hardware implementation
    integer       LMUL;                         // number of vector registers used in one instruction
    reg    [31:0] SEW;                          // selected element width
    reg    [31:0] VLMAX;                      // maximum number of elements that can be executed in one instruction
    integer       AVL;                          // number of elements specified
    wire [31:0] wire_vlen = VLEN;
    reg  [31:0] c = 0;
    reg  [31:0] d = 0;

    // instruction format
    wire    [6:0] opcode = inst[6:0];   //
    wire    [2:0] func3  = inst[14:12]; //
    wire    [6:0] func7  = inst[31:25]; //
    wire    [4:0] rd     = inst[11:7];  //
    wire    [4:0] rs     = inst[19:15]; // = rs1
    wire    [4:0] rt     = inst[24:20]; // = rs2
    wire    [4:0] shamt  = inst[24:20]; // == rs2
    wire          sign   = inst[31];
    wire   [11:0] imm    = inst[31:20];
    wire    [5:0] func6  = inst[31:26]; //
    wire   [10:0] zimm   = inst[30:20];
    wire    [4:0] lsumop = inst[24:20];
    wire    [2:0] mop    = inst[28:26];
    wire    [2:0] width  = inst[14:12];
    wire    [4:0] vs1    = inst[19:15];
    wire    [4:0] vs2    = inst[24:20];
    wire    [4:0] vd     = inst[11:7];
    wire    [4:0] simm5  = inst[19:15];
    wire          vm     = inst[25];   // vector mask
    

    // branch offset            31:13          12      11       10:5         4:1     0
    wire   [31:0] broffset  = {{19{sign}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   // beq, bne,  blt,  bge,   bltu, bgeu
    wire   [31:0] simm      = {{20{sign}},inst[31:20]};                                    // lw,  addi, slti, sltiu, xori, ori,  andi, jalr
    wire   [31:0] stimm     = {{20{sign}},inst[31:25],inst[11:7]};                         // sw
    wire   [31:0] uimm      = {inst[31:12],12'h0};                                         // lui, auipc
    wire   [31:0] jaloffset = {{11{sign}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // jal
    // jal target               31:21          20       19:12       11       10:1      0

    // instruction decode
    wire i_auipc   = (opcode == 7'b0010111);
    wire i_lui     = (opcode == 7'b0110111);
    wire i_jal     = (opcode == 7'b1101111);
    wire i_jalr    = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq     = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne     = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_blt     = (opcode == 7'b1100011) & (func3 == 3'b100);
    wire i_bge     = (opcode == 7'b1100011) & (func3 == 3'b101);
    wire i_bltu    = (opcode == 7'b1100011) & (func3 == 3'b110);
    wire i_bgeu    = (opcode == 7'b1100011) & (func3 == 3'b111);
    wire i_lb      = (opcode == 7'b0000011) & (func3 == 3'b000);
    wire i_lh      = (opcode == 7'b0000011) & (func3 == 3'b001);
    wire i_lw      = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_lbu     = (opcode == 7'b0000011) & (func3 == 3'b100);
    wire i_lhu     = (opcode == 7'b0000011) & (func3 == 3'b101);
    wire i_sb      = (opcode == 7'b0100011) & (func3 == 3'b000);
    wire i_sh      = (opcode == 7'b0100011) & (func3 == 3'b001);
    wire i_sw      = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi    = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_slti    = (opcode == 7'b0010011) & (func3 == 3'b010);
    wire i_sltiu   = (opcode == 7'b0010011) & (func3 == 3'b011);
    wire i_xori    = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori     = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi    = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_csrrw   = (opcode == 7'b1110011) & (func3 == 3'b001);
    wire i_slli    = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli    = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai    = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_sll     = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_slt     = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_sltu    = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000000);
    wire i_xor     = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_srl     = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_sra     = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_or      = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and     = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);
    wire m_mul     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire m_mulh    = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire m_mulhsu  = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire m_mulhu   = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire m_div     = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire m_divu    = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire m_rem     = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire m_remu    = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);
    wire v_vle32   = (opcode == 7'b0000111) & (width == 3'b110) & (lsumop == 5'b00000) & (mop == 3'b000);
    wire v_vlse32  = (opcode == 7'b0000111) & (width == 3'b110) & (|lsumop == 1) & (mop == 3'b010);
    wire v_vse32   = (opcode == 7'b0100111) & (width == 3'b110) & (lsumop == 5'b00000) & (mop == 3'b000);
    wire v_vsetvl  = (opcode == 7'b1010111) & (func3 == 3'b111) & (sign  == 1'b1);
    wire v_vsetvli = (opcode == 7'b1010111) & (func3 == 3'b111) & (sign  == 1'b0);
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
    wire v_vsllvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b100101);
    wire v_vsllvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b100101);
    wire v_vsllvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b100101);
    wire v_vsrlvv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b101000);
    wire v_vsrlvx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b101000);
    wire v_vsrlvi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b101000);
    wire v_vsravv = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b101001);
    wire v_vsravx = (opcode == 7'b1010111) & (func3 == 3'b100) & (func6 == 6'b101001);
    wire v_vsravi = (opcode == 7'b1010111) & (func3 == 3'b011) & (func6 == 6'b101001);
    
    // data written to register file
    wire        i_load = i_lw | i_lb | i_lbu | i_lh | i_lhu | i_csrrw;
    wire [31:0] data_2_rf = i_load ? mem_out : alu_out;
    
    wire        v_vstore = v_vse32;              // | ... (other v stores)

    // register file
    reg    [31:0] regfile [0:31];                          // x0 - x31, should be [0:31]
    wire   [31:0] a = (rs==0) ? 0 : regfile[rs];           // read port
    wire   [31:0] b = (v_vstore) ? c : (rt==0) ? 0 : regfile[rt];           // read port
    reg    [31:0] wide_b; // for vlse
    integer       h;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            for (h = 0; h < 32; h = h + 1)
                 regfile[h] = 0;
        end else begin
            if (wreg && |rd) 
                regfile[rd] <= data_2_rf;                  // write port
        end
    end
    
    reg            wpc; 
    reg      [7:0] we;                                     // write enable
    
    //vector
    wire     [9:0] wid = {zimm,1'b0};     // width of data per element
    reg      [2:0] vlmul;
    reg      [2:0] vsew;
    reg            vta;
    reg            vma;
    integer        vleng;       // = vector length
    
    reg      [5:0] cnt_mul;               // count
    reg      [5:0] cnt_div;
    wire     [5:0] cnt_vmul; 
    wire     [5:0] cnt_vdiv;
    reg      [5:0] cnt_vls;
    wire     [5:0] cnt_vls_minus_1 = cnt_vls - 1;
    wire     [5:0] cnt_vls_minus_2 = cnt_vls - 2;
    wire     [5:0] cnt = cnt_mul | cnt_div | cnt_vmul | cnt_vdiv | cnt_vls;
    wire           ready_mul  = ~|cnt_mul;                    // ready = 1 if cnt_mul = 0
    wire           ready_div  = ~|cnt_div;
    wire           ready_vmul = ~|cnt_vmul;    
    wire           ready_vdiv = ~|cnt_vdiv;
    wire           ready_vls  = ~|cnt_vls;
    wire           ready = ready_mul & ready_div & ready_vmul & ready_vdiv & ready_vls; // ready = 1 if cnt = 0
    reg            change_mul;
    reg            change_div;
    wire           change_vmul;
    wire           change_vdiv;
    wire           change = change_mul | change_div | change_vmul | change_vdiv;        // Orders needing counts
    reg     [31:0] vls_wide;
    
    // pc
    reg    [31:0]  pc;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) pc <= 0;
        else if (ready) pc <= next_pc;
    end
    
    //vset
    wire   is_vsetvl  = v_vsetvl | v_vsetvli;
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
	          LMUL <= 0;
            SEW <= 0; 
            VLMAX <= 0; 
            AVL <= 0;
        end 
        else begin
            if (is_vsetvl) begin
                if (~|rs == 1) begin       // rs = 0 -> 1 == 1 
                    if (~|rd == 1) begin   // rs = 0, rd = 0
                    //chage the vtype
                    end 
                    else begin             // rs = 0, rd = !0
                        vleng = VLMAX;
                    end 
                end 
                else begin                // rs = !0, rd = *
                    AVL = a;
                    //VLMAX = VLEN * LMUL / SEW;
                    case (vlmul)
                          3'b000: begin
                                  LMUL = 1;
                                  VLMAX = wire_vlen;
                          end
                          3'b001: begin
                                  LMUL = 2;
                                  VLMAX = wire_vlen << 1;
                          end
                          3'b010: begin
                                  LMUL = 4;
                                  VLMAX = wire_vlen << 2;
                          end
                    endcase
                    case (vsew)
                          3'b000: begin
                                  SEW = 8;
                                  VLMAX = VLMAX >> 3;
                          end
                          3'b001: begin
                                  SEW = 16;
                                  VLMAX = VLMAX >> 4;
                          end
                          3'b010: begin
                                  SEW = 32;
                                  VLMAX = VLMAX >> 5;
                          end
                    endcase
                    if (AVL <= VLMAX) vleng = AVL;
                    // vleng = AVL / 2 + AVL % 2
                    else if (AVL < (VLMAX << 2)) vleng = AVL >> 1 + AVL[0];
                    else if (AVL >= (VLMAX << 2)) vleng = VLMAX;
                end
    		          d = vleng;
                we = 0;                           // initialization for wvreg
                case (vleng)
                      1: we <= 1'b1;
                      2: we <= 2'b11;
                      3: we <= 3'b111;
                      4: we <= 4'b1111;
                endcase
            end
        end
    end

    // vector register file, VLEN = 128 bits, ELEN = 32 bits
    wire             v_vload = v_vle32 | v_vlse32;    // | ... (other v loads)
    reg  [VLEN-1:0]  vregfile [0:31];                 // v0 - v31, 128 bits for each
    reg  [VLEN-1:0]  vregfile_shift;
    wire             sew32 = (SEW == 32);
    wire [VLEN-1:0]  va = vregfile[vs1];              // read port 1
    wire [VLEN-1:0]  vb = vregfile[vs2];              // read port 2
    wire [VLEN-1:0]  vc_i;                            // calculate result for i of v
    wire [VLEN-1:0]  vc_m;                            // calculate result for m of v      
    reg  [VLEN-1:0]  vcl;                             // calculate low result for vmulh or vmulhsu or vmulhu
    reg  [VLEN-1:0]  v_mem_out;
    reg  [VLEN-1:0]  pre_v_mem; // preserve mem_out
    reg  [VLEN-1:0]  v_alu_out;
    wire [VLEN-1:0]  v_data_2_rf = v_vload ? v_mem_out : v_alu_out;
	 
    //[SEW-1:0] <- error
    integer i;
    
    always @ (posedge clk or negedge clrn) begin  //load
        if (!clrn) begin
            for (i = 0; i < 32; i = i + 1)
                 vregfile[i] <= 0;
        end else begin
	          if (wpc) begin
                case (SEW)
                      32: begin  // write port
                          if(we[0]) vregfile[vd][ 31:  0] <= v_data_2_rf[ 31:  0];
                          if(we[1]) vregfile[vd][ 63: 32] <= v_data_2_rf[ 63: 32];
                          if(we[2]) vregfile[vd][ 95: 64] <= v_data_2_rf[ 95: 64];
                          if(we[3]) vregfile[vd][127: 96] <= v_data_2_rf[127: 96];
                      end
                endcase
            end
        end
    end
    
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            cnt_vls <= 0;
            wide_b  <= 0;
        end 
        else begin
            // v_vload
            if (v_vle32) begin
                if (cnt_vls == vleng + 1) cnt_vls <= 0;
                else cnt_vls <= cnt_vls + 6'd1;
            end
            else if (v_vlse32) begin
                if (cnt_vls == vleng + 1) begin 
                    cnt_vls <= 0;
                    wide_b <= 0;
                end
                else begin 
                    cnt_vls <= cnt_vls + 6'd1;
                    if (cnt_vls > 0) wide_b <= wide_b + b;
                end
            end
            // v_vstore
 	          if (v_vse32) begin
                if (cnt_vls == vleng + 1) cnt_vls <= 0;
                else cnt_vls <= cnt_vls + 6'd1;
	          end
	      end
    end
    
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
	          pre_v_mem <= 0;
	          vls_wide <= 0;
        end else begin
            // v_vload
	          if (v_vload && cnt_vls == vleng + 1) begin
                vls_wide = 0;
                pre_v_mem = 0;
            end 
            else if (v_vload && cnt_vls != 0) begin
                pre_v_mem[vls_wide+:32] = mem[31:0];
		            vls_wide = vls_wide + 7'd32;
            end
            // v_vstore
	          if (v_vse32) begin
                if (cnt_vls == vleng + 1) begin
                    vls_wide = 0;
                    vregfile_shift = 0;
                end 
                else if (cnt_vls != 0) begin
                    vregfile_shift = vregfile[vd] >> vls_wide;
                    c[31:0] = vregfile_shift[31:0];
                    vls_wide = vls_wide + 7'd32;
                end
	          end
        end
    end
  
    //mul
    reg    [63:0] mr;                                     // multiplication result
    reg           mul_fuse;
    wire          is_mul = m_mulh | m_mulhsu | m_mulhu;
    reg           re_mul;                                 // re_mul = 1 => not calculate of m_mul
    reg    [31:0] reg_a;
    reg    [31:0] reg_b;
    wire          eq_a = (reg_a == a) ? 1 : 0;
    wire          eq_b = (reg_b == b) ? 1 : 0;
    
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            cnt_mul  <= 0;
            mul_fuse <= 0;
        end
        else begin
            if (is_mul | {m_mul && !re_mul}) begin
                if (cnt_mul == 6'd1 && {is_mul | m_mul}) begin
                    cnt_mul  <= 0;
                    mul_fuse <= 1;
                end
                else cnt_mul <= cnt_mul + 6'd1;
            end
	    else if (mul_fuse)  mul_fuse <= 0;
        end
    end
    
    always @ (posedge clk or negedge clrn) begin
	      if (!clrn) begin
            re_mul   <= 0;
            mr       <= 0;
            reg_a    <= 0;
            reg_b    <= 0;
        end
	      else begin
            if (!ready_mul) begin
		            change_mul = 0;
                if (m_mul && !re_mul) begin
                    mr = a * b;
                    change_mul = 1;
                end
                else if (is_mul) begin
                    case (is_mul)
                          m_mulh   : mr = $signed(a) * $signed(b);
                          m_mulhsu : mr = $signed(a) * $signed({1'b0,b});
                          m_mulhu  : mr = a * b;
                    endcase
                    re_mul <= 1;
                    change_mul = 1;
                end
            end
 	          else if (!mul_fuse && re_mul) re_mul <= 0;
	          else change_mul = 0;
        end
    end
    
    //div
    reg    [31:0] q, r;                                  // quotient, remainder
    reg           div_fuse;
    wire          is_dr  = m_div | m_rem;
    wire          is_dru = m_divu | m_remu;
    reg     [1:0] stop_dr;                               // 1 -> is_dr stop, 2 -> is_dru stop
    reg    [31:0] reg_a_n;                               // for neg clk
    reg    [32:0] reg_r_n;
    reg    [31:0] reg_a_p, reg_b_p;                      // for pos clk
    reg    [32:0] reg_r_p;
    wire          a_si   = a[31], b_si = b[31];          // signed
    wire          ab_si  = a_si | b_si;

    
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            cnt_div  <= 0;
            div_fuse <= 0;
            stop_dr  <= 2'd0;
	          reg_a_n  <= 0;
            reg_r_n  <= 0;
        end 
        else begin
            if ({is_dr | is_dru} && ~|stop_dr) begin
                if (cnt_div == 6'd33 && is_dru) begin        // 1 -> load, 2-33 -> 32 cycles for divu
                    cnt_div <= 0;
                    div_fuse <= 1;
                    stop_dr  <= 2'd2;
                end 
                else if (cnt_div == 6'd33 && is_dr) begin
                    if (ab_si) begin                     // 2's complement for div && non-negative
                        if (a_si ^ b_si) reg_a_n = ~reg_a_p + 32'b1; 
                        if (a_si) reg_r_n = ~reg_r_p + 32'b1;
                        cnt_div <= cnt_div + 6'd1;
                    end  
                    else begin                           // 1 -> load, 2-33 -> 32 cycles for div && negative
                        cnt_div  <= 0;
                        div_fuse <= 1;
                        stop_dr  <= 2'd1;
                    end
                end 
                else if (cnt_div == 6'd34 && is_dr) begin    // 1 -> load, 2-34 -> 33 cycles for div && non-negative
                    cnt_div  <= 0;
                    div_fuse <= 1;
                    stop_dr  <= 2'd1;
                end 
                else cnt_div <= cnt_div + 6'd1;
            end
	          else if (div_fuse) div_fuse <= 0;
            else if (!div_fuse && |stop_dr) stop_dr  <= 2'd0;
        end
    end

    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
	          reg_a_p  <= 0;
	          reg_b_p  <= 0;
	          reg_r_p  <= 0;
        end
        else begin
            if (is_dr || is_dru) begin
                if (cnt_div == 6'd1) begin
                    reg_a_p = {is_dr && a_si} ? {~a + 32'd1} : a;
                    reg_b_p = {is_dr && b_si} ? {~b + 32'd1} : b;
                    reg_r_p = 33'b0; 
                end
                else if (!ready_div) begin
                    if ({cnt_div == 6'd33 && is_dru} || {cnt_div == 6'd33 && is_dr && !ab_si}) begin
                        q = reg_a_p;
                        r = reg_r_p;
                    end
                    else if (cnt_div != 6'd34) begin
                        // r = ra_lshift - b
                        reg_r_p = {reg_r_p[31:0], reg_a_p[31]} - {1'b0, reg_b_p};
                        // r is negative -> quotient = 0, r is non-negative -> quotient = 1
                        reg_a_p = {reg_a_p[30:0], ~reg_r_p[32]};
                        // r is negative -> r = r + b
                        reg_r_p = reg_r_p[32] ? reg_r_p + {1'b0, reg_b_p} : reg_r_p;
                    end
		                if (cnt_div == 6'd34 && is_dr) begin 
		                    q = reg_a_n;
                        r = reg_r_n;
		                end
                end
            end
	      end
    end 
    
    wire    [VLEN:0] cout;  //carry out
    wire    [VLEN:0] bout;  //borrow out
    wire  [VLEN-1:0] vq, vr;                                 // quotient, remainder
    wire      [31:0] sum_mask;
    
    riscv_i_vector_extend_i rivei(clk, clrn, SEW, VLMAX, va, vb, a, simm5, vregfile[vd], vregfile[0], 
                                  opcode, func3, func6, vm, vd, vc_i, cout, bout);
    
    riscv_i_vector_extend_m rivem(clk, clrn, SEW, VLMAX, vleng, va, vb, a, simm5, vregfile[vd],vregfile[0], opcode, func3, func6, 
                                  vm, vd, vs1, vs2, we, vc_m, vq, vr, sum_mask, cnt_vmul, cnt_vdiv, change_vmul, change_vdiv);

    
    // control signals, will be combinational circuit
    always @(*) begin                                      // 38 instructions
        alu_out = 0;                                       // alu output
        mem_out = 0;                                       // mem output
        m_addr  = 0;                                       // memory address
        wreg    = 0;                                       // write regfile
        wmem    = 4'b0000;                                 // write memory (sw)
        rmem    = 0;                                       // read  memory (lw)
        d_t_mem = b;
        wpc     = 0;
        next_pc = pc_plus_4;
        v_alu_out = 0;                                     // alu output for vector
		    v_mem_out = (cnt_vls == 0) ? 0 : v_mem_out; 
        case (1'b1)
            i_add: begin                                   // add
                alu_out = a + b;
                wreg    = 1; end
            i_sub: begin                                   // sub
                alu_out = a - b;
                wreg    = 1; end
            i_and: begin                                   // and
                alu_out = a & b;
                wreg    = 1; end
            i_or: begin                                    // or
                alu_out = a | b;
                wreg    = 1; end
            i_xor: begin                                   // xor
                alu_out = a ^ b;
                wreg    = 1; end
            i_sll: begin                                   // sll
                alu_out = a << b[4:0];
                wreg    = 1; end
            i_srl: begin                                   // srl
                alu_out = a >> b[4:0];
                wreg    = 1; end
            i_sra: begin                                   // sra
                alu_out = $signed(a) >>> b[4:0];
                wreg    = 1; end
            i_slli: begin                                  // slli
                alu_out = a << shamt;
                wreg    = 1; end
            i_srli: begin                                  // srli
                alu_out = a >> shamt;
                wreg    = 1; end
            i_srai: begin                                  // srai
                alu_out = $signed(a) >>> shamt;
                wreg    = 1; end
            i_slt: begin                                   // slt
                if ($signed(a) < $signed(b)) 
                  alu_out = 1; end
            i_sltu: begin                                  // sltu
                if ({1'b0,a} < {1'b0,b}) //??
                  alu_out = 1; end
            i_addi: begin                                  // addi
                alu_out = a + simm;
                wreg    = 1; end
            i_andi: begin                                  // andi
                alu_out = a & simm;
                wreg    = 1; end
            i_ori: begin                                   // ori
                alu_out = a | simm;
                wreg    = 1; end
            i_xori: begin                                  // xori
                alu_out = a ^ simm;
                wreg    = 1; end
            i_slti: begin                                  // slti
                if ($signed(a) < $signed(simm)) 
                  alu_out = 1; end
            i_sltiu: begin                                 // sltiu
                if ({1'b0,a} < {1'b0,simm}) 
                  alu_out = 1; end
            i_lw: begin                                    // lw
                alu_out = a + simm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                rmem    = 1;
                mem_out = mem;
                wreg    = 1; end
            i_lbu: begin                                   // lbu
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {24'h0,mem[ 7: 0]};
                  2'b01: mem_out = {24'h0,mem[15: 8]};
                  2'b10: mem_out = {24'h0,mem[23:16]};
                  2'b11: mem_out = {24'h0,mem[31:24]};
                endcase
                wreg    = 1; end
            i_lb: begin                                    // lb
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {{24{mem[ 7]}},mem[ 7: 0]};
                  2'b01: mem_out = {{24{mem[15]}},mem[15: 8]};
                  2'b10: mem_out = {{24{mem[23]}},mem[23:16]};
                  2'b11: mem_out = {{24{mem[31]}},mem[31:24]};
                endcase
                wreg    = 1; end
            i_lhu: begin                                   // lhu
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                       case(m_addr[1])
                  1'b0: mem_out = {16'h0,mem[15: 0]};
                  1'b1: mem_out = {16'h0,mem[31:16]};
                endcase
                wreg    = 1; end
            i_lh: begin                                    // lh
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                case(m_addr[1])
                  1'b0: mem_out = {{16{mem[15]}},mem[15: 0]};
                  1'b1: mem_out = {{16{mem[31]}},mem[31:16]};
                endcase
                wreg    = 1; end
            i_sb: begin                                    // sb
                alu_out = a + stimm;
                m_addr  = alu_out;
                wmem    = 4'b0001 << alu_out[1:0]; end
            i_sh: begin                                    // sh
                alu_out = a + stimm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                wmem    = 4'b0011 << {alu_out[1],1'b0}; end
            i_sw: begin                                    // sw
                alu_out = a + stimm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                wmem    = 4'b1111; end
            i_beq: begin                                   // beq
                if (a == b) 
                  next_pc = pc + broffset; end
            i_bne: begin                                   // bne
                if (a != b) 
                  next_pc = pc + broffset; end
            i_blt: begin                                   // blt
                if ($signed(a) < $signed(b)) 
                  next_pc = pc + broffset; end
            i_bge: begin                                   // bge
                if ($signed(a) >= $signed(b)) 
                  next_pc = pc + broffset; end
            i_bltu: begin                                  // bltu
                if ({1'b0,a} < {1'b0,b}) 
                  next_pc = pc + broffset; end
            i_bgeu: begin                                  // bgeu
                if ({1'b0,a} >= {1'b0,b}) 
                  next_pc = pc + broffset; end
            i_auipc: begin                                 // auipc
                alu_out = pc + uimm;
                wreg    = 1; end
            i_lui: begin                                   // lui
                alu_out = uimm;
                wreg    = 1; end
            i_jal: begin                                   // jal
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = pc + jaloffset; end
            i_jalr: begin                                  // jalr
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = (a + simm) & 32'hfffffffe; end
            i_csrrw: begin                                 // csrrw
                m_addr  = {20'h0,imm};
                if (rd != 0) begin
                    mem_out = mem;
                    wreg    = 1;
                end
                if (rs != 0) begin
                    d_t_mem = a;
                end
            end
            m_mul: begin
              alu_out = mr[31:0];
              if (change_mul) wreg = 1; end
            m_mulh: begin          //signed x signed
              alu_out = mr[63:32];
              wreg = 1; end
            m_mulhsu: begin        //signed x unsigned
              alu_out = mr[63:32];
              wreg = 1; end
            m_mulhu: begin         //unsigned x unsigned
              alu_out = mr[63:32];
              wreg = 1; end
            m_div: begin           //signed / signed
              alu_out = q;
              wreg = 1; end
            m_divu: begin          //unsigned / unsigned
              alu_out = q;
              wreg = 1; end
            m_rem: begin           //signed % signed
              alu_out = r;
              wreg = 1; end
            m_remu: begin          //unsigned % unsigned
              alu_out = r;
              wreg = 1; end
            v_vsetvli: begin
              vlmul [2:0] = zimm[2:0];
              vsew  [2:0] = zimm[5:3];
              vta         = zimm[6];
              vma         = zimm[7]; 
				      alu_out = d;
				      wreg = 1;end
            v_vle32: begin
              alu_out = a + (cnt_vls_minus_1 << 2);
              m_addr  = {alu_out[31:2],2'b00};      // alu_out[1:0] != 0, exception
              rmem    = 1;
              if (cnt_vls == vleng + 1) begin
                  v_mem_out = pre_v_mem;
                  wpc = 1;
              end 
				    end
            v_vlse32: begin
              alu_out = a + wide_b;
              m_addr  = {alu_out[31:2],2'b00};      // alu_out[1:0] != 0, exception
              rmem    = 1;
              if (cnt_vls == vleng + 1) begin
				          v_mem_out = pre_v_mem;
				          wpc = 1; 
				      end
				    end
            v_vse32: begin
              alu_out = a + (cnt_vls_minus_2 << 2);
              m_addr  = {alu_out[31:2],2'b00};      // alu_out[1:0] != 0, exception
              if (!ready_vls && cnt_vls_minus_1 != 0) wmem = 4'b1111;
            end
            v_vaddvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vaddvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vaddvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsubvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsubvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsubvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vrsubvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vrsubvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vminuvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vminuvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vminvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vminvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmaxuvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmaxuvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmaxvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmaxvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vandvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vandvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vandvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vorvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vorvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vorvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vxorvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vxorvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vxorvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vrgathervv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vrgathervx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vrgathervi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vslideupvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vslideupvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vslidedownvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vslidedownvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmulvv: begin
              v_alu_out = vc_m;
              wpc = change_vmul ? 1 : 0; end
            v_vmulvx: begin
              v_alu_out = vc_m; 
              if (change_vmul) wpc = 1; end
            v_vmulhvv: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vmulhvx: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vmulhsuvv: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vmulhsuvx: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vmulhuvv: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vmulhuvx: begin
              v_alu_out = vc_m;
              if (change_vmul) wpc = 1; end
            v_vdivvv: begin     //signed / signed
              v_alu_out = vq;
              if (change_vdiv) wpc = 1; end
            v_vdivvx: begin
              v_alu_out = vq;
              if (change_vdiv) wpc = 1; end
            v_vdivuvv: begin    //unsigned / unsigned
              v_alu_out = vq;
              if (change_vdiv) wpc = 1; end
            v_vdivuvx: begin
              v_alu_out = vq;
              if (change_vdiv) wpc = 1; end
            v_vremvv: begin     //signed % signed
              v_alu_out = vr;
              if (change_vdiv) wpc = 1; end
            v_vremvx: begin
              v_alu_out = vr;
              if (change_vdiv) wpc = 1; end
            v_vremuvv: begin    //unsigned % unsigned
              v_alu_out = vr;
              if (change_vdiv) wpc = 1; end
            v_vremuvx: begin
              v_alu_out = vr;
              if (change_vdiv) wpc = 1; end
            v_vmvxs: begin
              alu_out = vc_m[31:0];
              wreg = 1; end
            v_vmvsx: begin
              v_alu_out = vc_m;
              wpc = 1; end
            v_vredsumvs:begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredandvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredorvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredxorvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredminuvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredminvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredmaxuvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vredmaxvs: begin
              v_alu_out = vc_m[31:0];
              wpc = 1; end
            v_vslide1upvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vslide1downvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vadcvvm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vadcvxm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vadcvim: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmadcvvm: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vmadcvxm: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vmadcvim: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vmadcvv: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vmadcvx: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vmadcvi: begin
              v_alu_out = cout; 
              wpc = 1; end
            v_vsbcvvm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsbcvxm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsbcvvm: begin
              v_alu_out = bout; 
              wpc = 1; end
            v_vmsbcvxm: begin
              v_alu_out = bout; 
              wpc = 1; end
            v_vmsbcvv: begin
              v_alu_out = bout; 
              wpc = 1; end
            v_vmsbcvx: begin
              v_alu_out = bout; 
              wpc = 1; end
            v_vmergevvm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmergevxm: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmergevim: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmseqvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmseqvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmseqvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsnevv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsnevx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsnevi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsltuvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsltuvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsltvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsltvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsleuvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsleuvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsleuvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmslevv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmslevx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmslevi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsgtuvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsgtuvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsgtvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vmsgtvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vcpopm: begin
              alu_out = sum_mask;
              wreg = 1; end
            v_vcompressvvm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmandnotmm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmandmm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmormm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmxormm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmornotmm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmnandmm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmnormm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmxnormm: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmaddvv: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmaddvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vnmsubvv: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vnmsubvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmaccvv: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vmaccvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vnmsacvv: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vnmsacvx: begin
              v_alu_out = vc_m; 
              wpc = 1; end
            v_vsllvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsllvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsllvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsrlvv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsrlvx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsrlvi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsravv: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsravx: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            v_vsravi: begin
              v_alu_out = vc_i; 
              wpc = 1; end
            default: ;
        endcase
    end
endmodule
