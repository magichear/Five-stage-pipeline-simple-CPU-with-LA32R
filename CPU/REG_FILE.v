
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/02 20:20:23
// Design Name: 
// Module Name: REG_FILE
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


module REG_FILE (
    input       [ 0 : 0]        clk,        // 时钟信号

    input       [ 4 : 0]        rf_ra0,     // 读端口 0 地址
    input       [ 4 : 0]        rf_ra1,     // 读端口 1 地址
    input       [ 4 : 0]        rf_wa,      // 写端口地址
    input       [ 0 : 0]        rf_we,      // 写使能信号
    input       [31 : 0]        rf_wd,      // 写数据

    input       [ 4 : 0]        debug_reg_ra, // 调试寄存器读地址
    output      [31 : 0]        debug_reg_rd, // 调试寄存器读数据

    output reg  [31 : 0]        rf_rd0,     // 读端口 0 数据输出
    output reg  [31 : 0]        rf_rd1      // 读端口 1 数据输出
);

reg [31 : 0] reg_file [0 : 31];

// 用于初始化寄存器
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1)
        reg_file[i] = 0;
end

// 读端口 0
always @(*) begin
     if ((rf_we != 0) && (rf_wa == rf_ra0) && (rf_wa != 5'b00000)) begin
         rf_rd0 = rf_wd;               // 同时进行读写时，显示新的数据
     end
     else begin
         rf_rd0 = reg_file[rf_ra0];     
     end
end

// 读端口 1
always @(*) begin
     if ((rf_we != 0) && (rf_wa == rf_ra1)  && (rf_wa != 5'b00000)) begin
         rf_rd1 = rf_wd;               // 同时进行读写时，显示新的数据
     end
     else begin
         rf_rd1 = reg_file[rf_ra1];     
     end
end

// 写端口
always @(posedge clk) begin
    // 写使能有效（上升沿）
    // 零号寄存器硬编码
    if (rf_we && rf_wa != 0) begin
        reg_file[rf_wa] <= rf_wd;
    end
    else begin
        reg_file[0] <= 0;
    end
    
end

// 调试端口
assign debug_reg_rd = reg_file[debug_reg_ra];

endmodule
