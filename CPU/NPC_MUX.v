
module NPC_MUX (
    input        [31: 0]        pc_add4,
    input        [31: 0]        pc_add4_cur,
    input        [31: 0]        pc_offset,
    input        [ 1: 0]        npc_sel,
    output       [31: 0]        npc
);


assign npc = (npc_sel == 2'b00) ? pc_add4                            :
             (npc_sel == 2'b11) ? (pc_add4_cur + pc_offset - 32'd4)  : 
             (npc_sel == 2'b01) ? (pc_add4_cur + pc_offset)          : (pc_offset); 
// 00 正常状态，无分支产生
// 11 判断大小的分支指令
// 01 JIRL 指令
// 10 B 与 BL 指令 

endmodule