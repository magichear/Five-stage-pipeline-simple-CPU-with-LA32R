
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 18:15:08
// Design Name: 
// Module Name: DECODE
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


`define ADD                 5'B00000    
`define SUB                 5'B00010   
`define SLT                 5'B00100
`define SLTU                5'B00101
`define AND                 5'B01001
`define OR                  5'B01010
`define XOR                 5'B01011
`define SLL                 5'B01110   
`define SRL                 5'B01111    
`define SRA                 5'B10000  
`define SRC0                5'B10001
`define SRC1                5'B10010

module DECODER (
    input                   [31 : 0]            inst,

    output     reg          [ 4 : 0]            alu_op,

    output                  [ 3 : 0]            dmem_access,     // TODO:

    output     reg          [31 : 0]            imm,

    output                  [ 4 : 0]            rf_ra0,
    output                  [ 4 : 0]            rf_ra1,
    output                  [ 4 : 0]            rf_wa,
    output                  [ 0 : 0]            rf_we,
    output     reg          [ 1 : 0]            rf_wd_sel,      // TODO:
                                                                // 00: ALU    01: PC + 4
                                                                // 10: 存储器  11: 0

    output                  [ 0 : 0]            alu_src0_sel,   // 0:reg 1:PC
    output                  [ 0 : 0]            alu_src1_sel,   // 0:reg 1:imm

    output                  [ 3 : 0]            br_type
);
reg      [ 4 : 0]     temp_alu_op;
reg      [31 : 0]     temp_imm;
reg      [ 4 : 0]     temp_rf_ra0;
reg      [ 4 : 0]     temp_rf_ra1;
reg      [ 4 : 0]     temp_rf_wa;
reg      [ 0 : 0]     temp_rf_we;
reg      [ 0 : 0]     temp_alu_src0_sel;
reg      [ 0 : 0]     temp_alu_src1_sel;

reg      [ 3 : 0]     temp_br_type;
reg      [ 3 : 0]     temp_dmem_access;
reg      [ 1 : 0]     temp_rf_wd_sel;

always @(*) begin
    // 默认不进行任何操作
    // 通过不向寄存器堆写内容完成
    // 之后可补充报错接口等
    temp_alu_op       = `SRC0;
    temp_imm          = 32'b0;
    temp_rf_we        = 1'b0;
    temp_alu_src0_sel = 1'b0;
    temp_alu_src1_sel = 1'b0;

    // 访存与分支信号
    temp_dmem_access       = 4'b1111;    // 用不满，故把最高位置位无效
    temp_br_type           = 4'b1111;
    temp_rf_wd_sel         = 2'b00;      // 默认为ALU结果

    // 寄存器位置固定
    temp_rf_ra0       = inst[ 9: 5];
    temp_rf_ra1       = inst[14:10];   
    temp_rf_wa        = inst[ 4: 0];      
        
    if (inst[31:20] == 12'b000000000001) begin
        temp_imm          = 32'b0;
        temp_rf_we        = 1'b1;
        temp_alu_src0_sel = 1'b0;
        temp_alu_src1_sel = 1'b0;
        if (inst[19:15] == 5'b00000) begin
        // add_w rd, rj, rk       整数加法          000000000001 00000, rk, rj, rd
            temp_alu_op       = `ADD;
        end
        else if (inst[19:15] == 5'b00010) begin
        // sub_w rd, rj, rk       整数减法          000000000001 00010, rk, rj, rd
            temp_alu_op       = `SUB;      
        end
        else if (inst[19:15] == 5'b00100) begin
        // slt rd, rj, rk         有符号整数比较     000000000001 00100, rk, rj, rd
            temp_alu_op       = `SLT;         
        end
        else if (inst[19:15] == 5'b00101) begin
        // sltu rd, rj, rk        无符号整数比较     000000000001 00101, rk, rj, rd
            temp_alu_op       = `SLTU;          
        end
        else if (inst[19:15] == 5'b01001) begin
        // and rd, rj, rk         按位与            000000000001 01001, rk, rj, rd
            temp_alu_op       = `AND;       
        end
        else if (inst[19:15] == 5'b01010) begin
        // or rd, rj, rk          按位或            000000000001 01010, rk, rj, rd
            temp_alu_op       = `OR;       
        end
        else if (inst[19:15] == 5'b01011) begin
        // xor rd, rk, rk         按位异或          000000000001 01011, rk, rj, rd
            temp_alu_op       = `XOR;  
        end
        else if (inst[19:15] == 5'b01110) begin
        // sll_w rd, rj, rk       逻辑左移          000000000001 01110, rk, rj, rd
            temp_alu_op       = `SLL;   
        end
        else if (inst[19:15] == 5'b01111) begin
        // srl_w rd, rj, rk       逻辑右移          000000000001 01111, rk, rj, rd
            temp_alu_op       = `SRL;  
        end
        else if (inst[19:15] == 5'b10000) begin
        // sra_w rd, rj, rk       算术右移          000000000001 10000, rk, rj, rd
            temp_alu_op       = `SRA;   
        end
    end
    else if (inst[31:20] == 12'b000000000100) begin
        temp_rf_we        = 1'b1;
        temp_alu_src0_sel = 1'b0;
        temp_alu_src1_sel = 1'b1; 
        temp_imm          = {27'b0,inst[14:10]};
        if (inst[19:18] == 2'b00) begin
        // slli_w rd, rj, ui5      逻辑左移           000000000100 00 001, ui5, rj, rd
            temp_alu_op       = `SLL;
        end
        else if (inst[19:18] == 2'b01) begin
        // srli_w rd, rj, ui5      逻辑右移           000000000100 01 001, ui5, rj, rd    
            temp_alu_op       = `SRL;
        end
        else begin
        // srai_w rd, rj, ui5      算术右移           000000000100 10 001, ui5, rj, rd  
            temp_alu_op       = `SRA;
        end
    end

        // ui 与 si 存疑！！！！！！    
    else if (inst[31:25] == 7'b0000001) begin
        temp_rf_we        = 1'b1;
        temp_alu_src0_sel = 1'b0;
        temp_alu_src1_sel = 1'b1; 
        if (inst[24:22] == 3'b000) begin
            // slti rd, rj, si12       有符号整数比较     0000001 000, si12, rj, rd
            temp_alu_op   = `SLT;
            temp_imm      = {{(20){inst[21]}},inst[21:10]};
        end
        else if (inst[24:22] == 3'b001) begin
            // sltui rd, rj, si12      无符号整数比较     0000001 001, si12, rj, rd
            temp_alu_op   = `SLTU;
            temp_imm      = {{(20){inst[21]}},inst[21:10]};
        end
        else if (inst[24:22] == 3'b010) begin
            // addi_w rd, rj, si12     整数加法           0000001 010, si12, rj, rd
            temp_alu_op   = `ADD;
            temp_imm      = {{(20){inst[21]}},inst[21:10]};   
        end
        else if (inst[24:22] == 3'b101) begin
            // andi rd, rj, ui12       按位与             0000001 101, si12, rj, rd
            temp_alu_op   = `AND;
            temp_imm      = {20'b0,inst[21:10]};   
        end
        else if (inst[24:22] == 3'b110) begin
            // ori rd, rj, ui12        按位或             0000001 110, si12, rj, rd
            temp_alu_op   = `OR;
            temp_imm      = {20'b0,inst[21:10]};    
        end
        else begin
            // xori rd, rj, ui12       按位异或           0000001 111, si12, rj, rd
            temp_alu_op   = `XOR;
            temp_imm      = {20'b0,inst[21:10]};   
        end
    end

    else if (inst[31:28] == 4'b0001) begin
        temp_rf_we        = 1'b1;   
        temp_alu_src1_sel = 1'b1;             
        if (inst[27:25] == 3'b010) begin
            // lu12i_w rd, si20        加载高二十位立即数           0001 010, si20, rd
            temp_alu_op       = `SRC1;
            temp_imm          = {inst[24: 5],12'b0};
            temp_alu_src0_sel = 1'b0;
        end
        else begin
            // pcaddu12i rd, si20      加载加上PC的高二十位立即数   0001 110, si20, rd
            temp_alu_op       = `ADD;
            temp_imm          = {inst[24: 5],12'b0};
            temp_alu_src0_sel = 1'b1;
        end
    end
    else if (inst[31:30] == 2'b01) begin    // 分支指令 B-Type
    temp_rf_ra1       = inst[4:0];
     
        if (inst[29] == 1'b1) begin
            temp_imm          = {{(14){inst[25]}},inst[25:10],2'b0};
            temp_rf_wd_sel    = 2'b11;      // 寄存器堆写入 0
            temp_rf_we        = 1'b0;

            temp_alu_op       = `SRC1;
            temp_alu_src1_sel = 1'b1;
            if (inst[28:26] == 3'b000) begin
            // blt rj, rd, label    有符号小于跳转          01 1000, offs[15:0], rj, rd 
                temp_br_type      = 4'b0000;                               
            end
            else if (inst[28:26] == 3'b001) begin
                // bge rj, rd, label    有符号大于等于跳转   01 1001, offs[15:0], rj, rd
                temp_br_type      = 4'b0001;
            end
            else if (inst[28:26] == 3'b010) begin
                // bltu rj, rd, label   无符号小于跳转       01 1010, offs[15:0], rj, rd
                temp_br_type      = 4'b0010;
            end
            else begin
                // bgeu rj, rd, label   无符号大于等于跳转   01 1011, offs[15:0], rj, rd
                temp_br_type      = 4'b0011;
            end
        end
        else if (inst[28:27] == 2'b11) begin
            temp_imm          = {{(14){inst[25]}},inst[25:10],2'b0};
            temp_rf_wd_sel    = 2'b11;      // 寄存器堆写入 0
            temp_rf_we        = 1'b0;

            temp_alu_op       = `SRC1;
            temp_alu_src1_sel = 1'b1;
            if (inst[26] == 1'b0) begin
                // beq rj, rd, label    相等跳转                  01 0110, offs[15:0], rj, rd
                temp_br_type      = 4'b0100;
            end
            else begin
                // bne rj, rd, label    不等跳转                  01 0111, offs[15:0], rj, rd
                temp_br_type      = 4'b0101;
            end
        end
        else begin
            if (inst[28] == 1'b0) begin
                temp_imm          = {{(14){inst[25]}},inst[25:10],2'b0};
                // jirl rd, rj, lable   间接相对跳转并链接         01 0011, offs[15:0], rj, rd
                temp_br_type          = 4'b0110;
                temp_rf_wd_sel        = 2'b01;     // 写入pc+4
                temp_rf_we            = 1'b1;      // 写使能打开
                temp_rf_ra0           = inst[9:5];
                temp_alu_op           = `ADD;
                temp_alu_src0_sel     = 1'b0;      // 寄存器堆
                temp_alu_src1_sel     = 1'b1;      // 立即数
            end
            else begin
                temp_imm = {{(4){inst[9]}},inst[9:0],inst[25:10],2'b0};
                temp_alu_op       = `SRC1;
                temp_alu_src1_sel = 1'b1;                
                if (inst[26] == 1'b0) begin
                    // b label              无条件跳转                01 0100, offs[15:0], offs[25:16]
                    temp_br_type      = 4'b0111;
                    // 跳转地址需要加上此时的PC值
                    temp_rf_wd_sel    = 2'b11;
                    temp_rf_we        = 1'b0;
                end
                else begin
                    // bl label             函数（子程序）调用并链接   01 0101, offs[15:0], offs[25:16]
                    temp_br_type      = 4'b1000;
                    temp_rf_wd_sel    = 2'b01;     // 写入pc+4
                    temp_rf_we        = 1'b1;      // 写使能打开
                    temp_rf_wa        = 5'b0001;   // 写入r1中
                end
            end
        end
    end
    else if (inst[31:26] == 6'b001010) begin  // 访存指令
        temp_imm    = {{(20){inst[21]}},inst[21:10]};     
        temp_alu_op       = `ADD;
        temp_alu_src0_sel = 1'b0;
        temp_alu_src1_sel = 1'b1;     
        if (inst[25] == 1'b1) begin
            temp_rf_we     = 1'b1;
            temp_rf_wd_sel = 2'b10;
            if (inst[22] == 1'b0) begin
                // ld_bu rd, rj, imm    无符号加载字节      001010 1000
                temp_dmem_access = 4'b0001;
            end
            else begin
                // ld_hu rd, rj, imm    无符号加载半字      001010 1001
                temp_dmem_access = 4'b0100;
            end
        end
        else begin
            if (inst[24] == 1'b0) begin
                temp_rf_we        = 1'b1;             
                temp_rf_wd_sel    = 2'b10;                
                if (inst[23:22] == 2'b00) begin
                    // ld_b rd, rj, imm     加载字节           001010 0000, si12, rj, rd
                    temp_dmem_access  = 4'b0010;
                end
                else if (inst[23:22] == 2'b01) begin
                    // ld_h rd, rj, imm     加载半字           001010 0001
                    temp_dmem_access = 4'b1000;
                end
                else begin
                    // ld_w rd, rj, imm     加载字             001010 0010
                    temp_dmem_access = 4'b0110;
                end
            end
            else begin
                temp_rf_ra1 = inst[4:0];
                if (inst[23:22] == 2'b00) begin
                    // st_b rd, rj, imm     存储字节           001010 0100
                    temp_dmem_access = 4'b0011;
                end
                else if (inst[23:22] == 2'b01) begin
                    // st_h rd, rj, imm     存储半字           001010 0101
                    temp_dmem_access = 4'b1100;
                end
                else begin
                    // st_w rd, rj, imm     存储字             001010 0110
                    temp_dmem_access = 4'b1001;
                end
            end
        end
    end
end
always @(*) alu_op    = temp_alu_op;
always @(*) imm       = temp_imm;
assign rf_ra0         = temp_rf_ra0;
assign rf_ra1         = temp_rf_ra1;
assign rf_wa          = temp_rf_wa;
assign rf_we          = temp_rf_we;
assign alu_src0_sel   = temp_alu_src0_sel;
assign alu_src1_sel   = temp_alu_src1_sel;

assign dmem_access    = temp_dmem_access;
assign br_type        = temp_br_type;
always @(*) rf_wd_sel = temp_rf_wd_sel;
endmodule
/*
需要设置访存类型信号，每个指令都设一个值就行

ld_b rd, rj, imm     加载字节           001010 0000, si12, rj, rd
ld_h rd, rj, imm     加载半字           001010 0001
ld_w rd, rj, imm     加载字             001010 0010

st_b rd, rj, imm     存储字节           001010 0100
st_h rd, rj, imm     存储半字           001010 0101
st_w rd, rj, imm     存储字             001010 0110

ld_bu rd, rj, imm    无符号加载字节      001010 1000
ld_hu rd, rj, imm    无符号加载半字      001010 1001
*/

/*
需要设置跳转类型信号，每个指令都设一个值就行

jirl rd, rj, lable   间接相对跳转并链接         01 0011, offs[15:0], rj, rd
b label              无条件跳转                01 0100, offs[15:0], offs[25:16]
bl label             函数（子程序）调用并链接   01 0101, offs[15:0], offs[25:16]


beq rj, rd, label    相等跳转                  01 0110, offs[15:0], rj, rd
bne rj, rd, label    不等跳转                  01 0111, offs[15:0], rj, rd
blt rj, rd, label    有符号小于跳转            01 1000, offs[15:0], rj, rd
bge rj, rd, label    有符号大于等于跳转         01 1001, offs[15:0], rj, rd
bltu rj, rd, label   无符号小于跳转            01 1010, offs[15:0], rj, rd
bgeu rj, rd, label   无符号大于等于跳转        01 1011, offs[15:0], rj, rd
*/