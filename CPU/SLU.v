module SLU (
    input                   [31 : 0]                addr,
    input                   [ 3 : 0]                dmem_access,

    input                   [31 : 0]                rd_in,
    input                   [31 : 0]                wd_in,

    output      reg         [31 : 0]                rd_out,
    output      reg         [31 : 0]                wd_out
);
// 可能出错处：  读取的值可能是以addr为起始位置的“字”

always @(*) begin
    rd_out = 32'b0;
    wd_out = 32'b0;
    if (dmem_access == 4'b1001) begin
        // st_w rd, rj, imm     存储字
        wd_out = wd_in;
    end
    else if (dmem_access == 4'b0110) begin
        // ld_w rd, rj, imm     加载字
        rd_out = rd_in;
    end
    else if (dmem_access[3:2] == 2'b00) begin   // 字节
        case(addr[1:0])
            2'b00: begin
                if (dmem_access[1:0] == 2'b01) begin
                    // ld_bu rd, rj, imm    无符号加载字节
                    rd_out = {24'b0,rd_in[7:0]};
                end
                else if (dmem_access[1:0] == 2'b10) begin
                    // ld_b rd, rj, imm     加载字节
                    rd_out = {{(24){rd_in[7]}},rd_in[7:0]};
                end
                else begin
                    // st_b rd, rj, imm     存储字节
                    wd_out = {rd_in[31:8],wd_in[7:0]};
                end
            end
            2'b01: begin
                if (dmem_access[1:0] == 2'b01) begin
                    // ld_bu rd, rj, imm    无符号加载字节
                    rd_out = {24'b0,rd_in[15:8]};
                end
                else if (dmem_access[1:0] == 2'b10) begin
                    // ld_b rd, rj, imm     加载字节
                    rd_out = {{(24){rd_in[15]}},rd_in[15:8]};
                end
                else begin
                    wd_out = {rd_in[31:16],wd_in[7:0],rd_in[7:0]};
                end
            end
            2'b10: begin
                if (dmem_access[1:0] == 2'b01) begin
                    // ld_bu rd, rj, imm    无符号加载字节
                    rd_out = {24'b0,rd_in[23:16]};
                end
                else if (dmem_access[1:0] == 2'b10) begin
                    // ld_b rd, rj, imm     加载字节
                    rd_out = {{(24){rd_in[23]}},rd_in[23:16]};
                end
                else begin
                    wd_out = {rd_in[31:24],wd_in[7:0],rd_in[15:0]};
                end
            end
            2'b11: begin
                if (dmem_access[1:0] == 2'b01) begin
                    // ld_bu rd, rj, imm    无符号加载字节
                    rd_out = {24'b0,rd_in[31:24]};
                end
                else if (dmem_access[1:0] == 2'b10) begin
                    // ld_b rd, rj, imm     加载字节
                    rd_out = {{(24){rd_in[31]}},rd_in[31:24]};
                end
                else begin
                    wd_out = {wd_in[7:0],rd_in[23:0]};
                end
            end
        endcase
    end
    else begin
        case(addr[1:0])
            2'b00: begin
                if (dmem_access[3:2] == 2'b01) begin
                    // ld_hu rd, rj, imm    无符号加载半字
                    rd_out = {16'b0,rd_in[15:0]};
                end
                else if (dmem_access[3:2] == 2'b10) begin
                    // ld_h rd, rj, imm     加载半字
                    rd_out = {{(16){rd_in[15]}},rd_in[15:0]};
                end
                else begin
                    // st_h rd, rj, imm     存储半字
                    wd_out = {rd_in[31:16],wd_in[15:0]};
                end
            end
            2'b10: begin
                if (dmem_access[3:2] == 2'b01) begin
                    // ld_hu rd, rj, imm    无符号加载半字
                    rd_out = {16'b0,rd_in[31:16]};
                end
                else if (dmem_access[3:2] == 2'b10) begin
                    // ld_h rd, rj, imm     加载半字
                    rd_out = {{(16){rd_in[31]}},rd_in[31:16]};
                end
                else begin
                    // st_h rd, rj, imm     存储半字
                    wd_out = {wd_in[15:0],rd_in[15:0]};
                end
            end
            default: begin// 非法
                wd_out = rd_in;
                rd_out = wd_in;
            end
        endcase
    end
end

endmodule

/*
// dmem_access[3:0] 信号设计逻辑
存取字节指令占有低两位，共三条信号

存取半字指令占有高两位，共三条信号

存取整字指令分别占有中间两位和头尾两位，共两条信号
*/


/*
访存控制单元主要是用于实现非整字访存指令的。
例如：如果我们想要带符号地读取 0x5 地址上的字节的值，
我们就需要先读取 0x4 开始的四个字节上的数据，
再取出其中的第 8~15 位，右移 8 位并符号扩展之后写入目标寄存器，总结起来就是：

x[rd] = {{24{(M[0x4])[15]}}, (M[0x4])[15:8]}

如果我们想要向 0x5 地址上写入一个字节的数据 0x12，
为了不影响其余字节的数据，就需要先将它们读出，
与待写入的数据拼接之后再写回。因此，实际执行的操作就是：

M[0x4] = {(M[0x4])[31:16], (x[rd])[7:0], (M[0x4])[7:0]}
*/