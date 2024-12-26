// PC init/reset address
`define PC_INIT             32'H1c000000

`define HALT_INST           32'H80000000
module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata,
    output                  [ 0 : 0]            dmem_we,
    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_inst,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,   // TODO
    output                  [31 : 0]            debug_reg_rd    // TODO
);
/* Global */
wire [ 0 : 0] commit_if ;
wire [ 0 : 0] commit_id ;
wire [ 0 : 0] commit_ex ;
wire [ 0 : 0] commit_mem;
wire [ 0 : 0] commit_wb ;


wire [31: 0] pc_if          ;
wire [31: 0] pcadd4_if      ;
wire [31: 0] inst_if        ;
/* IF/ID */      
wire [31: 0] pcadd4_id      ;
wire [31: 0] pc_id          ;
wire [31: 0] inst_id        ;
wire [ 4: 0] alu_op_id      ;
wire [ 4: 0] rf_ra0_id      ;
wire [ 4: 0] rf_ra1_id      ;
wire [31: 0] rf_rd0_id      ;
wire [31: 0] rf_rd1_id      ;
wire [31: 0] imm_id         ;
wire [ 4: 0] rf_wa_id       ;
wire [ 0: 0] rf_we_id       ;
wire [ 1: 0] rf_wd_sel_id   ;
wire [ 0: 0] alu_src0_sel_id;
wire [ 0: 0] alu_src1_sel_id;

wire [ 3: 0] br_type_id     ;
wire [ 3: 0] dmem_access_id ;
/* ID/EX */
wire [31: 0] pc_ex          ;
wire [31: 0] pcadd4_ex      ;
wire [31: 0] inst_ex        ;

wire [ 4: 0] rf_ra0_ex      ;
wire [ 4: 0] rf_ra1_ex      ;
wire [31: 0] rf_rd0_raw_ex  ;
wire [31: 0] rf_rd1_raw_ex  ;
wire [31: 0] rf_rd0_ex      ;
wire [31: 0] rf_rd1_ex      ;

wire [ 1: 0] rf_rd0_fe      ;
wire [ 1: 0] rf_rd1_fe      ;


wire [ 0: 0] br_flush       ;
wire [ 0: 0] stall_pc       ;
wire [ 0: 0] stall_if_id    ;
wire [ 0: 0] flush_if_id    ;
wire [ 0: 0] flush_id_ex    ;


wire [31: 0] imm_ex         ;
wire [31: 0] npc_ex         ;
wire [ 4: 0] rf_wa_ex       ;
wire [ 0: 0] rf_we_ex       ;
wire [ 1: 0] rf_wd_sel_ex   ;
wire [ 4: 0] alu_op_ex      ;
wire [ 0: 0] alu_src0_sel_ex;
wire [ 0: 0] alu_src1_sel_ex;

wire [31: 0] alu_src0_ex    ;
wire [31: 0] alu_src1_ex    ;
wire [31: 0] alu_res        ;

wire [ 3: 0] br_type_ex     ;
wire [ 3: 0] dmem_access_ex ;
wire [ 1: 0] npc_sel_ex     ;
/* EX/MEM */
wire [31: 0] pc_mem         ;
wire [31: 0] pcadd4_mem     ;
wire [31: 0] inst_mem       ;
wire [ 3: 0] dmem_access_mem;
wire [31: 0] alu_res_mem    ;
wire [31: 0] rf_rd1_mem     ;
wire [ 4: 0] rf_wa_mem      ; 
wire [ 0: 0] rf_we_mem      ;
wire [ 1: 0] rf_wd_sel_mem  ;
wire [31: 0] dmem_rd_out_mem;
/* MEM/WB*/
wire [31: 0] pc_wb          ;
wire [31: 0] pcadd4_wb      ;
wire [31: 0] inst_wb        ;
wire [ 4: 0] rf_wa_wb       ; 
wire [ 0: 0] rf_we_wb       ;
wire [ 1: 0] rf_wd_sel_wb   ;
wire [31: 0] rf_wd_wb       ;
wire [31: 0] alu_res_wb     ;
wire [31: 0] dmem_rd_out_wb ;
wire [ 0: 0] dmem_we_wb     ;
wire [31: 0] dmem_addr_wb   ;
wire [31: 0] dmem_wdata_wb  ;

wire [ 1: 0] rf_wd_sel      ;

assign commit_if = 1'H1;    // 这个信号需要经过 IF/ID、ID/EX、EX/MEM、MEM/WB 段间寄存器，
                            // 最终连接到 commit_reg 上

PC my_pc (
    .clk    (clk        ),
    .rst    (rst        ),
    .en     (global_en  ),    // 当 global_en 为高电平时，PC 才会更新，CPU 才会执行指令。
    .stall  (stall_pc   ),
    .npc    (npc_ex     ),
    .pc     (pc_if      )
);
ADD4 add4(
    .in     (pc_if      ),
    .out    (pcadd4_if  )
);
assign inst_if = imem_rdata;
assign imem_raddr = pc_if;
Inter_Segment_RegF IF2ID(
    .clk                 (clk              ),
    .rst                 (rst              ),
    .en                  (global_en        ),
    .stall               (stall_if_id      ),
    .flush               (flush_if_id      ),
    .commit              (commit_if        ),
    .pc_add4_in          (pcadd4_if        ),
    .pc_in               (pc_if            ),
    .inst_in             (inst_if          ),
    .rf_rd0_in           (32'b0            ),
    .rf_rd1_in           (32'b0            ),
    .imm_in              (32'b0            ),
    .rf_wa_in            (5'b0             ),
    .rf_ra0_in           (5'b0             ),
    .rf_ra1_in           (5'b0             ),
    .rf_we_in            (1'b0             ),
    .rf_wd_sel_in        (2'b0             ),
    .alu_res_in          (32'b0            ),
    .alu_src0_sel_in     (1'b0             ),
    .alu_src1_sel_in     (1'b0             ),
    .alu_op              (5'b0             ),
    .br_type_in          (4'b0             ),
    .dmem_rd_out_in      (32'b0            ),
    .dmem_access_in      ( 4'b0            ),
    .dmem_we_in          ( 1'b0            ),
    .dmem_wdata_in       (32'b0            ),
    .pc_add4_out         (pcadd4_id        ),
    .pc_out              (pc_id            ),
    .inst_out            (inst_id          ),
    .rf_rd0_out          (                 ),
    .rf_rd1_out          (                 ),
    .imm_out             (                 ),
    .rf_wa_out           (                 ),
    .rf_ra0_out          (                 ),
    .rf_ra1_out          (                 ),
    .rf_we_out           (                 ),
    .rf_wd_sel_out       (                 ),
    .alu_src0_sel_out    (                 ),
    .alu_src1_sel_out    (                 ),
    .alu_res_out         (                 ),
    .alu_op_out          (                 ),
    .br_type_out         (                 ),
    .dmem_rd_out_out     (                 ),
    .dmem_access_out     (                 ),
    .dmem_we_out         (                 ),
    .dmem_wdata_out      (                 ),
    .commit_out          (commit_id        )
);
DECODER decoder(
    .inst                (inst_id          ),
    .alu_op              (alu_op_id        ),
    .imm                 (imm_id           ),
    .rf_ra0              (rf_ra0_id        ),
    .rf_ra1              (rf_ra1_id        ),
    .rf_wa               (rf_wa_id         ),
    .rf_we               (rf_we_id         ),
    .alu_src0_sel        (alu_src0_sel_id  ),
    .alu_src1_sel        (alu_src1_sel_id  ),
      
    .br_type             (br_type_id       ),
    .rf_wd_sel           (rf_wd_sel_id     ),
    .dmem_access         (dmem_access_id   )
);

REG_FILE global_regfile(
    .clk                 (clk              ),
    .rf_ra0              (rf_ra0_id        ),
    .rf_ra1              (rf_ra1_id        ),
    .rf_wa               (rf_wa_wb         ),
    .rf_we               (rf_we_wb         ),
    .rf_wd               (rf_wd_wb         ),
    .debug_reg_ra        (debug_reg_ra     ),
    .debug_reg_rd        (debug_reg_rd     ),
    .rf_rd0              (rf_rd0_id        ),
    .rf_rd1              (rf_rd1_id        )
);
Inter_Segment_RegF ID2EX(
    .clk                 (clk              ),
    .rst                 (rst              ),
    .en                  (global_en        ),
    .stall               (1'b0             ),
    .flush               (flush_id_ex      ),
    .commit              (commit_id        ),
    .pc_add4_in          (pcadd4_id        ),
    .pc_in               (pc_id            ),
    .inst_in             (inst_id          ),
    .rf_rd0_in           (rf_rd0_id        ),
    .rf_rd1_in           (rf_rd1_id        ),
    .imm_in              (imm_id           ),
    .rf_wa_in            (rf_wa_id         ),
    .rf_ra0_in           (rf_ra0_id        ),
    .rf_ra1_in           (rf_ra1_id        ),
    .rf_we_in            (rf_we_id         ),
    .rf_wd_sel_in        (rf_wd_sel_id     ),
    .alu_res_in          (32'b0            ),
    .alu_src0_sel_in     (alu_src0_sel_id  ),
    .alu_src1_sel_in     (alu_src1_sel_id  ),
    .alu_op              (alu_op_id        ),
    .br_type_in          (br_type_id       ),
    .dmem_rd_out_in      (32'b0            ),
    .dmem_access_in      (dmem_access_id   ),
    .dmem_we_in          ( 1'b0            ),
    .dmem_wdata_in       (32'b0            ),
    .pc_add4_out         (pcadd4_ex        ),
    .pc_out              (pc_ex            ),
    .inst_out            (inst_ex          ),
    .rf_rd0_out          (rf_rd0_raw_ex    ),
    .rf_rd1_out          (rf_rd1_raw_ex    ),
    .imm_out             (imm_ex           ),
    .rf_wa_out           (rf_wa_ex         ),
    .rf_ra0_out          (rf_ra0_ex        ),
    .rf_ra1_out          (rf_ra1_ex        ),
    .rf_we_out           (rf_we_ex         ),
    .rf_wd_sel_out       (rf_wd_sel_ex     ),
    .alu_src0_sel_out    (alu_src0_sel_ex  ),
    .alu_src1_sel_out    (alu_src1_sel_ex  ),
    .alu_res_out         (                 ),
    .alu_op_out          (alu_op_ex        ),
    .br_type_out         (br_type_ex       ),
    .dmem_rd_out_out     (                 ),
    .dmem_access_out     (dmem_access_ex   ),
    .dmem_we_out         (                 ),
    .dmem_wdata_out      (                 ),
    .commit_out          (commit_ex        )
);
Fowarding foward(
    .rf_we_mem           (rf_we_mem        ),
    .rf_we_wb            (rf_we_wb         ),
    .rf_wa_mem           (rf_wa_mem        ),
    .rf_wa_wb            (rf_wa_wb         ),
    .rf_ra0_ex           (rf_ra0_ex        ),
    .rf_ra1_ex           (rf_ra1_ex        ),
    .rf_rd0_fe           (rf_rd0_fe        ),
    .rf_rd1_fe           (rf_rd1_fe        )
);

MUX2 MuxFor_rfrd0(  // 在此处处理前递的寄存器堆读数据
    .src0                (rf_rd0_raw_ex    ),
    .src1                (alu_res_mem      ),
    .src2                (rf_wd_wb         ),
    .src3                (32'b0            ),
    .sel                 (rf_rd0_fe        ),
    .res                 (rf_rd0_ex        )   
);
MUX1 MuxFor_rf_pc(
    .src0                (rf_rd0_ex        ),
    .src1                (pc_ex            ),
    .sel                 (alu_src0_sel_ex  ),
    .res                 (alu_src0_ex      )
);
MUX2 MuxFor_rfrd1(
    .src0                (rf_rd1_raw_ex    ),
    .src1                (alu_res_mem      ),
    .src2                (rf_wd_wb         ),
    .src3                (32'b0            ),
    .sel                 (rf_rd1_fe        ),
    .res                 (rf_rd1_ex        )
);
MUX1 MuxFor_rf_imm(
    .src0                (rf_rd1_ex        ),
    .src1                (imm_ex           ),
    .sel                 (alu_src1_sel_ex  ),
    .res                 (alu_src1_ex      )
);
ALU alu(
    .alu_src0            (alu_src0_ex      ),
    .alu_src1            (alu_src1_ex      ),
    .alu_op              (alu_op_ex        ),
    .alu_res             (alu_res          )
);
BRANCH branch(
    .br_type             (br_type_ex       ),
    .br_src0             (rf_rd0_ex        ),
    .br_src1             (rf_rd1_ex        ),
    .npc_sel             (npc_sel_ex       )
);
NPC_MUX npc_mux1(
    .pc_add4             (pcadd4_if        ),
    .pc_add4_cur         (pcadd4_ex        ),    // Branch
    .pc_offset           (alu_res          ),
    .npc_sel             (npc_sel_ex       ),
    .npc                 (npc_ex           )
);

FLUSH flushmk(
    .rst                 (rst              ),
    .en                  (global_en        ),
    .pcadd4              (pcadd4_ex        ),
    .npc                 (npc_ex           ),    
    .npc_sel             (npc_sel_ex       ),
    .flush_out           (br_flush         )
);
SegCtrl segment_control(
    .rf_we_ex            (rf_we_ex         ),
    .rf_wd_sel_ex        (rf_wd_sel_ex     ),
    .rf_wa_ex            (rf_wa_ex         ),
    .rf_ra0_id           (rf_ra0_id        ),
    .rf_ra1_id           (rf_ra1_id        ),
    .npc_sel_ex          (npc_sel_ex       ),
    .stall_pc            (stall_pc         ),
    .stall_if_id         (stall_if_id      ),
    .flush_if_id         (flush_if_id      ),
    .flush_id_ex         (flush_id_ex      )
);
Inter_Segment_RegF EX2MEM(
    .clk                 (clk              ),
    .rst                 (rst              ),
    .en                  (global_en        ),
    .stall               (1'b0             ),
    .flush               (1'b0             ),
    .commit              (commit_ex        ),
    .pc_add4_in          (pcadd4_ex        ),
    .pc_in               (pc_ex            ),
    .inst_in             (inst_ex          ),
    .rf_rd0_in           (32'b0            ),
    .rf_rd1_in           (rf_rd1_ex        ),
    .imm_in              (32'b0            ),
    .rf_wa_in            (rf_wa_ex         ),
    .rf_ra0_in           (5'b0             ),
    .rf_ra1_in           (5'b0             ),
    .rf_we_in            (rf_we_ex         ),
    .rf_wd_sel_in        (rf_wd_sel_ex     ),
    .alu_res_in          (alu_res          ),
    .alu_src0_sel_in     ( 1'b0            ),
    .alu_src1_sel_in     ( 1'b0            ),
    .alu_op              ( 5'b0            ),
    .br_type_in          (4'b0             ),
    .dmem_rd_out_in      (32'b0            ),
    .dmem_access_in      (dmem_access_ex   ),
    .dmem_we_in          ( 1'b0            ),
    .dmem_wdata_in       (32'b0            ),
    .pc_add4_out         (pcadd4_mem       ),
    .pc_out              (pc_mem           ),
    .inst_out            (inst_mem         ),
    .rf_rd0_out          (                 ),
    .rf_rd1_out          (rf_rd1_mem       ),
    .imm_out             (                 ),
    .rf_wa_out           (rf_wa_mem        ),
    .rf_ra0_out          (                 ),
    .rf_ra1_out          (                 ),
    .rf_we_out           (rf_we_mem        ),
    .rf_wd_sel_out       (rf_wd_sel_mem    ),
    .alu_src0_sel_out    (                 ),
    .alu_src1_sel_out    (                 ),
    .alu_res_out         (alu_res_mem      ),
    .alu_op_out          (                 ),
    .br_type_out         (                 ),
    .dmem_rd_out_out     (                 ),
    .dmem_access_out     (dmem_access_mem  ),
    .dmem_we_out         (                 ),
    .dmem_wdata_out      (                 ),
    .commit_out          (commit_mem       )
);
SLU slu(
    .addr                (alu_res_mem      ),
    .dmem_access         (dmem_access_mem  ),
    .rd_in               (dmem_rdata       ),
    .wd_in               (rf_rd1_mem       ),
    .rd_out              (dmem_rd_out_mem  ),
    .wd_out              (dmem_wdata       )
);
DmemWE dmemwe(
    .dmem_access         (dmem_access_mem  ),
    .dmem_we             (dmem_we          )
);
assign dmem_addr = alu_res_mem;
Inter_Segment_RegF MEM2WB(
    .clk                 (clk              ),
    .rst                 (rst              ),
    .en                  (global_en        ),
    .stall               (1'b0             ),
    .flush               (1'b0             ),
    .commit              (commit_mem       ),
    .pc_add4_in          (pcadd4_mem       ),
    .pc_in               (pc_mem           ),
    .inst_in             (inst_mem         ),
    .rf_rd0_in           (32'b0            ),
    .rf_rd1_in           (32'b0            ),
    .imm_in              (32'b0            ),
    .rf_wa_in            (rf_wa_mem        ),
    .rf_ra0_in           (5'b0             ),
    .rf_ra1_in           (5'b0             ),
    .rf_we_in            (rf_we_mem        ),
    .rf_wd_sel_in        (rf_wd_sel_mem    ),
    .alu_res_in          (alu_res_mem      ),
    .alu_src0_sel_in     ( 1'b0            ),
    .alu_src1_sel_in     ( 1'b0            ),
    .alu_op              ( 5'b0            ),
    .br_type_in          (4'b0             ),
    .dmem_rd_out_in      (dmem_rd_out_mem  ),
    .dmem_access_in      (                 ),
    .dmem_we_in          (dmem_we          ),
    .dmem_wdata_in       (dmem_wdata       ),
    .pc_add4_out         (pcadd4_wb        ),
    .pc_out              (pc_wb            ),
    .inst_out            (inst_wb          ),
    .rf_rd0_out          (                 ),
    .rf_rd1_out          (                 ),
    .imm_out             (                 ),
    .rf_wa_out           (rf_wa_wb         ),
    .rf_ra0_out          (                 ),
    .rf_ra1_out          (                 ),
    .rf_we_out           (rf_we_wb         ),
    .rf_wd_sel_out       (rf_wd_sel_wb     ),
    .alu_src0_sel_out    (                 ),
    .alu_src1_sel_out    (                 ),
    .alu_res_out         (alu_res_wb       ),
    .alu_op_out          (                 ),
    .br_type_out         (                 ),
    .dmem_rd_out_out     (dmem_rd_out_wb   ),
    .dmem_access_out     (                 ),
    .dmem_we_out         (dmem_we_wb       ),
    .dmem_wdata_out      (dmem_wdata_wb    ),
    .commit_out          (commit_wb        )
);
assign dmem_addr_wb = alu_res_wb;
// 00: ALU    01: PC + 4
// 10: 存储器  11: 0
MUX2 RES_to_REG(
    .src0(alu_res_wb),
    .src1(pcadd4_wb),
    .src2(dmem_rd_out_wb),
    .src3(32'b0),
    .sel(rf_wd_sel_wb),
    .res(rf_wd_wb)
);
/* -------------------------------------------------------------------------- */
/*                                    Commit                                  */
/* -------------------------------------------------------------------------- */
    // Commit
    reg  [ 0 : 0]   commit_reg          ;
    reg  [31 : 0]   commit_pc_reg       ;
    reg  [31 : 0]   commit_inst_reg     ;
    reg  [ 0 : 0]   commit_halt_reg     ;
    reg  [ 0 : 0]   commit_reg_we_reg   ;
    reg  [ 4 : 0]   commit_reg_wa_reg   ;
    reg  [31 : 0]   commit_reg_wd_reg   ;
    reg  [ 0 : 0]   commit_dmem_we_reg  ;
    reg  [31 : 0]   commit_dmem_wa_reg  ;
    reg  [31 : 0]   commit_dmem_wd_reg  ;

always @(posedge clk) begin
    if (rst) begin
        commit_reg          <= 1'H0;
        commit_pc_reg       <= 32'H0;
        commit_inst_reg     <= 32'H0;
        commit_halt_reg     <= 1'H0;
        commit_reg_we_reg   <= 1'H0;
        commit_reg_wa_reg   <= 5'H0;
        commit_reg_wd_reg   <= 32'H0;
        commit_dmem_we_reg  <= 1'H0;
        commit_dmem_wa_reg  <= 32'H0;
        commit_dmem_wd_reg  <= 32'H0;
    end
    else if (global_en) begin
        // 这里右侧的信号都是 MEM/WB 段间寄存器的输出
        commit_reg          <= commit_wb;
        commit_pc_reg       <= pc_wb;
        commit_inst_reg     <= inst_wb;
        commit_halt_reg     <= inst_wb == `HALT_INST;
        commit_reg_we_reg   <= rf_we_wb;
        commit_reg_wa_reg   <= rf_wa_wb;
        commit_reg_wd_reg   <= rf_wd_wb;
        commit_dmem_we_reg  <= dmem_we_wb;
        commit_dmem_wa_reg  <= dmem_addr_wb;
        commit_dmem_wd_reg  <= dmem_wdata_wb;
    end
end

assign commit               = commit_reg;
assign commit_pc            = commit_pc_reg;
assign commit_inst          = commit_inst_reg;
assign commit_halt          = commit_halt_reg;
assign commit_reg_we        = commit_reg_we_reg;
assign commit_reg_wa        = commit_reg_wa_reg;
assign commit_reg_wd        = commit_reg_wd_reg;
assign commit_dmem_we       = commit_dmem_we_reg;
assign commit_dmem_wa       = commit_dmem_wa_reg;
assign commit_dmem_wd       = commit_dmem_wd_reg;


endmodule