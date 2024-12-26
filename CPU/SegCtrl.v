
module SegCtrl (
    input        [ 0: 0]       rf_we_ex      ,
    input        [ 1: 0]       rf_wd_sel_ex  ,    // 10: 存储器
    input        [ 4: 0]       rf_wa_ex      ,
    input        [ 4: 0]       rf_ra0_id     ,
    input        [ 4: 0]       rf_ra1_id     ,

    input        [ 1: 0]       npc_sel_ex    ,   // 出现控制冒险

    output reg   [ 0: 0]       stall_pc      ,
    output reg   [ 0: 0]       stall_if_id   ,
    output reg   [ 0: 0]       flush_if_id   ,   // 控制冒险
    output reg   [ 0: 0]       flush_id_ex
);

always @(*) begin
    stall_pc    = 1'b0;
    stall_if_id = 1'b0;
    flush_if_id = 1'b0;
    flush_id_ex = 1'b0;
    // 读取-使用冒险    
    if ((rf_we_ex) && (rf_wd_sel_ex == 2'b10)) begin
        if ((rf_wa_ex != 5'b00000) && ((rf_wa_ex == rf_ra0_id) || (rf_wa_ex == rf_ra1_id))) begin
            stall_pc    = 1'b1;
            stall_if_id = 1'b1;
            flush_id_ex = 1'b1;
        end
    end
    // 控制冒险
    if (npc_sel_ex != 2'b00) begin
        flush_if_id = 1'b1;
        flush_id_ex = 1'b1;
    end    
end
endmodule