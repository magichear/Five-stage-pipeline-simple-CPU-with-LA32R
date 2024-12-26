
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 15:17:10
// Design Name: 
// Module Name: Inter_Segment_RegF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Inter_Segment_RegF(
    // All     
    input                [ 0 : 0]       clk             ,
    input                [ 0 : 0]       rst             ,
    input                [ 0 : 0]       en              ,
    input                [ 0 : 0]       stall           ,
    input                [ 0 : 0]       flush           ,
    input                [ 0 : 0]       commit          ,
            
    input                [31 : 0]       pc_add4_in      ,
    input                [31 : 0]       pc_in           ,
    input                [31 : 0]       inst_in         ,
    input                [31 : 0]       rf_rd0_in       , 
    input                [31 : 0]       rf_rd1_in       ,
    input                [31 : 0]       imm_in          ,
    input                [ 4 : 0]       rf_wa_in        ,
    input                [ 4 : 0]       rf_ra0_in       ,
    input                [ 4 : 0]       rf_ra1_in       ,
    input                [ 0 : 0]       rf_we_in        ,
    input                [ 1 : 0]       rf_wd_sel_in    ,
    input                [31 : 0]       alu_res_in      ,
    input                [ 0 : 0]       alu_src0_sel_in ,  
    input                [ 0 : 0]       alu_src1_sel_in ,
    input                [ 4 : 0]       alu_op          ,
    input                [ 3 : 0]       br_type_in      ,
    input                [31 : 0]       dmem_rd_out_in  ,
    input                [ 3 : 0]       dmem_access_in  ,
    input                [ 0 : 0]       dmem_we_in      ,
    input                [31 : 0]       dmem_wdata_in   ,
            
    output      reg      [31 : 0]       pc_add4_out     ,
    output      reg      [31 : 0]       pc_out          ,
    output      reg      [31 : 0]       inst_out        ,
    output      reg      [31 : 0]       rf_rd0_out      ,
    output      reg      [31 : 0]       rf_rd1_out      ,
    output      reg      [31 : 0]       imm_out         ,
    output      reg      [ 4 : 0]       rf_wa_out       ,
    output      reg      [ 4 : 0]       rf_ra0_out      ,
    output      reg      [ 4 : 0]       rf_ra1_out      ,
    output      reg      [ 0 : 0]       rf_we_out       ,
    output      reg      [ 1 : 0]       rf_wd_sel_out   ,
    output      reg      [ 0 : 0]       alu_src0_sel_out,  
    output      reg      [ 0 : 0]       alu_src1_sel_out,
    output      reg      [31 : 0]       alu_res_out     ,
    output      reg      [ 4 : 0]       alu_op_out      ,
    output      reg      [ 3 : 0]       br_type_out     ,
    output      reg      [31 : 0]       dmem_rd_out_out ,
    output      reg      [ 3 : 0]       dmem_access_out ,
    output      reg      [ 0 : 0]       dmem_we_out     ,
    output      reg      [31 : 0]       dmem_wdata_out  ,
    output      reg      [ 0 : 0]       commit_out     
    );

always @(posedge clk) begin
    if (rst) begin
        // rst 操作的逻辑
        pc_add4_out             <=      32'H1c000000    ; 
        pc_out                  <=      32'H1c000000    ;
        inst_out                <=      32'h02800000    ;
        rf_rd0_out              <=      32'b0           ;
        rf_rd1_out              <=      32'b0           ;
        imm_out                 <=      32'b0           ;
        alu_res_out             <=      32'b0           ;
        alu_op_out              <=       5'b0           ;
        br_type_out             <=       4'b1111        ;
        alu_src0_sel_out        <=       1'b0           ;
        alu_src1_sel_out        <=       1'b1           ;
        dmem_rd_out_out         <=      32'b0           ;
        dmem_we_out             <=       1'b0           ;
        dmem_wdata_out          <=      32'b0           ;
        dmem_access_out         <=       4'b1111        ;
        rf_wa_out               <=       5'b0           ;
        rf_ra0_out              <=       5'b0           ;
        rf_ra1_out              <=       5'b0           ;
        rf_we_out               <=       1'b0           ;
        rf_wd_sel_out           <=       2'b0           ;
        commit_out              <=       1'b0           ;
    end
    else if (en) begin
        // flush 和 stall 操作的逻辑, flush 的优先级更高
        if(flush) begin
            pc_add4_out             <=      32'H1c000000    ; 
            pc_out                  <=      32'H1c000000    ;
            inst_out                <=      32'h02800000    ;
            rf_rd0_out              <=      32'b0           ;
            rf_rd1_out              <=      32'b0           ;
            imm_out                 <=      32'b0           ;
            alu_res_out             <=      32'b0           ;
            alu_op_out              <=       5'b0           ;
            br_type_out             <=       4'b1111        ;
            alu_src0_sel_out        <=       1'b0           ;
            alu_src1_sel_out        <=       1'b1           ;
            dmem_rd_out_out         <=      32'b0           ;
            dmem_we_out             <=       1'b0           ;
            dmem_wdata_out          <=      32'b0           ;
            dmem_access_out         <=       4'b1111        ;
            rf_wa_out               <=       5'b0           ;
            rf_ra0_out              <=       5'b0           ;
            rf_ra1_out              <=       5'b0           ;
            rf_we_out               <=       1'b0           ;
            rf_wd_sel_out           <=       2'b0           ;
            commit_out              <=       1'b0           ;
        end
        else if (!stall) begin
            pc_add4_out         <=      pc_add4_in      ;
            pc_out              <=      pc_in           ;
            inst_out            <=      inst_in         ;
            rf_rd0_out          <=      rf_rd0_in       ;
            rf_rd1_out          <=      rf_rd1_in       ;
            imm_out             <=      imm_in          ;
            alu_res_out         <=      alu_res_in      ;
            alu_op_out          <=      alu_op          ;
            br_type_out         <=      br_type_in      ;
            alu_src0_sel_out    <=      alu_src0_sel_in ;
            alu_src1_sel_out    <=      alu_src1_sel_in ;
            dmem_rd_out_out     <=      dmem_rd_out_in  ;
            dmem_access_out     <=      dmem_access_in  ;
            dmem_we_out         <=      dmem_we_in      ;
            dmem_wdata_out      <=      dmem_wdata_in   ;
            rf_wa_out           <=      rf_wa_in        ;
            rf_ra0_out          <=      rf_ra0_in       ;
            rf_ra1_out          <=      rf_ra1_in       ;
            rf_we_out           <=      rf_we_in        ;
            rf_wd_sel_out       <=      rf_wd_sel_in    ;
            commit_out          <=      commit          ;
        end
    end
end



endmodule
/*
从最简单的角度来说，它只需要在每个时钟上升沿将输入传递到输出，
不过，为了方便后续的操作，
我们需要额外添加四个接口，即 rst、en、stall 和 flush：
*/

/*
对于stall，有两种处理方法

一种是将“输入传递到输出”的分支增加一个“else if (!stall)”的判断条件，
而对于“stall = 1”的情况不做处理，由于输出都是寄存器，所以值不会被更改

另一种更麻烦且消耗资源更多，
即为每个输出都指定一个副本寄存器用于存储上一个周期的状态，
然后在stall有效时为输出赋值

reg      [31 : 0]       befo_pc_add4_out     ;
reg      [31 : 0]       befo_pc_out          ;
reg      [31 : 0]       befo_inst_out        ;
reg      [31 : 0]       befo_rf_rd0_out      ;
reg      [31 : 0]       befo_rf_rd1_out      ;
reg      [31 : 0]       befo_imm_out         ;
reg      [ 4 : 0]       befo_rf_wa_out       ;
reg      [ 4 : 0]       befo_rf_ra0_out      ;
reg      [ 4 : 0]       befo_rf_ra1_out      ;
reg      [ 0 : 0]       befo_rf_we_out       ;
reg      [ 1 : 0]       befo_rf_wd_sel_out   ;
reg      [ 0 : 0]       befo_alu_src0_sel_out;
reg      [ 0 : 0]       befo_alu_src1_sel_out;
reg      [31 : 0]       befo_alu_res_out     ;
reg      [ 4 : 0]       befo_alu_op_out      ;
reg      [ 3 : 0]       befo_br_type_out     ;
reg      [31 : 0]       befo_dmem_rd_out_out ;
reg      [ 3 : 0]       befo_dmem_access_out ;
reg      [ 0 : 0]       befo_dmem_we_out     ;
reg      [31 : 0]       befo_dmem_wdata_out  ;
reg      [ 0 : 0]       befo_commit_out      ;

        else if (stall) begin
            pc_add4_out         <=       befo_pc_add4_out       ;   
            pc_out              <=       befo_pc_out            ;
            inst_out            <=       befo_inst_out          ;
            rf_rd0_out          <=       befo_rf_rd0_out        ;
            rf_rd1_out          <=       befo_rf_rd1_out        ;
            imm_out             <=       befo_imm_out           ;
            alu_res_out         <=       befo_alu_res_out       ;
            alu_op_out          <=       befo_alu_op_out        ;
            br_type_out         <=       befo_br_type_out       ;
            alu_src0_sel_out    <=       befo_alu_src0_sel_out  ;
            alu_src1_sel_out    <=       befo_alu_src1_sel_out  ;
            dmem_rd_out_out     <=       befo_dmem_rd_out_out   ;
            dmem_we_out         <=       befo_dmem_we_out       ;
            dmem_wdata_out      <=       befo_dmem_wdata_out    ;
            dmem_access_out     <=       befo_dmem_access_out   ;
            rf_wa_out           <=       befo_rf_wa_out         ;
            rf_ra0_out          <=       befo_rf_ra0_out        ;
            rf_ra1_out          <=       befo_rf_ra1_out        ;
            rf_we_out           <=       befo_rf_we_out         ;
            rf_wd_sel_out       <=       befo_rf_wd_sel_out     ;
            commit_out          <=       befo_commit_out        ;  
        end

always @(posedge clk) begin
    befo_pc_add4_out         <=       pc_add4_out       ;   
    befo_pc_out              <=       pc_out            ;
    befo_inst_out            <=       inst_out          ;
    befo_rf_rd0_out          <=       rf_rd0_out        ;
    befo_rf_rd1_out          <=       rf_rd1_out        ;
    befo_imm_out             <=       imm_out           ;
    befo_alu_res_out         <=       alu_res_out       ;
    befo_alu_op_out          <=       alu_op_out        ;
    befo_br_type_out         <=       br_type_out       ;
    befo_alu_src0_sel_out    <=       alu_src0_sel_out  ;
    befo_alu_src1_sel_out    <=       alu_src1_sel_out  ;
    befo_dmem_rd_out_out     <=       dmem_rd_out_out   ;
    befo_dmem_we_out         <=       dmem_we_out       ;
    befo_dmem_wdata_out      <=       dmem_wdata_out    ;
    befo_dmem_access_out     <=       dmem_access_out   ;
    befo_rf_wa_out           <=       rf_wa_out         ;
    befo_rf_ra0_out          <=       rf_ra0_out        ;
    befo_rf_ra1_out          <=       rf_ra1_out        ;
    befo_rf_we_out           <=       rf_we_out         ;
    befo_rf_wd_sel_out       <=       rf_wd_sel_out     ;
    befo_commit_out          <=       commit_out        ;  
end
*/