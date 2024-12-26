
module BRANCH(
    input                   [ 3 : 0]            br_type,

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel     // 00: PC + 4
                                                            // 11: pc + pc_offset
);
always @(*) begin
    case(br_type)
        4'b0000: begin
        // blt rj, rd, label    有符号小于跳转            01 1000, offs[15:0], rj, rd
            if(($signed(br_src0)) < ($signed(br_src1))) begin
                npc_sel = 2'b11;
            end
            else begin
                npc_sel = 2'b00;
            end
        end
        4'b0001: begin
        // bge rj, rd, label    有符号大于等于跳转         01 1001, offs[15:0], rj, rd
            if(($signed(br_src0)) >= ($signed(br_src1))) begin
                npc_sel = 2'b11;
            end
            else begin
                npc_sel = 2'b00;
            end
        end
        4'b0010: begin
        // bltu rj, rd, label   无符号小于跳转            01 1010, offs[15:0], rj, rd
            if (br_src0 < br_src1) begin
                npc_sel = 2'b11;
            end
            else begin
                npc_sel = 2'b00;
            end
        end
        4'b0011: begin
        // bgeu rj, rd, label   无符号大于等于跳转        01 1011, offs[15:0], rj, rd
            if(br_src0 >= br_src1) begin
                npc_sel = 2'b11;
            end
            else begin
                npc_sel = 2'b00;
            end
        end
        4'b0100: begin
        // beq rj, rd, label    相等跳转                  01 0110, offs[15:0], rj, rd
            if (br_src0 == br_src1) begin
                npc_sel = 2'b11;
            end
            else begin
                npc_sel = 2'b00;
            end
        end
        4'b0101: begin
        // bne rj, rd, label    不等跳转                  01 0111, offs[15:0], rj, rd
            if (br_src0 == br_src1) begin
                npc_sel = 2'b00;
            end
            else begin
                npc_sel = 2'b11;
            end
        end
        4'b0110: begin
        // jirl rd, rj, lable   间接相对跳转并链接         01 0011, offs[15:0], rj, rd
            npc_sel = 2'b10;
        end
        4'b0111: begin
        // b label              无条件跳转                01 0100, offs[15:0], offs[25:16]
            npc_sel = 2'b11;
        end
        4'b1000: begin
        // bl label             函数（子程序）调用并链接   01 0101, offs[15:0], offs[25:16]
            npc_sel = 2'b11;
        end
        default: begin
            npc_sel = 2'b00;
            // 非法指令
        end
    endcase
end
endmodule

/*
自上而下依序命名信号
blt rj, rd, label    有符号小于跳转            01 1000, offs[15:0], rj, rd
bge rj, rd, label    有符号大于等于跳转         01 1001, offs[15:0], rj, rd
bltu rj, rd, label   无符号小于跳转            01 1010, offs[15:0], rj, rd
bgeu rj, rd, label   无符号大于等于跳转        01 1011, offs[15:0], rj, rd

beq rj, rd, label    相等跳转                  01 0110, offs[15:0], rj, rd
bne rj, rd, label    不等跳转                  01 0111, offs[15:0], rj, rd

jirl rd, rj, lable   间接相对跳转并链接         01 0011, offs[15:0], rj, rd
b label              无条件跳转                01 0100, offs[15:0], offs[25:16]
bl label             函数（子程序）调用并链接   01 0101, offs[15:0], offs[25:16]
*/