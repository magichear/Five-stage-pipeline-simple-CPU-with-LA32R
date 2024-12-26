
`define RFRD            2'b00
`define ALU_RES_MEM     2'b01
`define RDWD_WB         2'b10

module Fowarding(
    input       [ 0 : 0]      rf_we_mem         ,
    input       [ 0 : 0]      rf_we_wb          ,

    input       [ 4 : 0]      rf_wa_mem         ,
    input       [ 4 : 0]      rf_wa_wb          ,

    input       [ 4 : 0]      rf_ra0_ex         ,
    input       [ 4 : 0]      rf_ra1_ex         ,

    output reg  [ 1 : 0]      rf_rd0_fe         ,
    output reg  [ 1 : 0]      rf_rd1_fe         
);
wire [1 : 0] we_mw;
assign we_mw = {rf_we_mem, rf_we_wb};

always @(*) begin
    rf_rd0_fe = `RFRD;
    rf_rd1_fe = `RFRD;
    case(we_mw)
        2'b00: begin    // 不发生前递
            rf_rd0_fe = `RFRD;
            rf_rd1_fe = `RFRD;
        end
        2'b01: begin    // wb 段检测到写使能
            if ((rf_wa_wb == rf_ra0_ex) && (rf_ra0_ex != 5'b00000)) begin
                rf_rd0_fe = `RDWD_WB;           // 需要读取才替换结果
            end
            if ((rf_wa_wb == rf_ra1_ex) && (rf_ra1_ex != 5'b00000)) begin
                rf_rd1_fe = `RDWD_WB;           // 两个读地址分开判断（无相关关系）
            end
        end
        2'b10: begin    // mem 段检测到写使能
            if ((rf_wa_mem == rf_ra0_ex) && (rf_ra0_ex != 5'b00000)) begin
                rf_rd0_fe = `ALU_RES_MEM;
            end
            if ((rf_wa_mem == rf_ra1_ex) && (rf_ra1_ex != 5'b00000)) begin
                rf_rd1_fe = `ALU_RES_MEM;
            end
        end
        2'b11: begin    // 此时优先取最新的写结果
            if (rf_wa_mem == rf_wa_wb) begin       // 两个写地址相同
                if ((rf_wa_mem == rf_ra0_ex) && (rf_ra0_ex != 5'b00000)) begin
                    rf_rd0_fe = `ALU_RES_MEM;
                end
                if ((rf_wa_mem == rf_ra1_ex) && (rf_ra1_ex != 5'b00000)) begin
                    rf_rd1_fe = `ALU_RES_MEM;
                end                
            end
            else begin
                if ((rf_wa_mem == rf_ra0_ex) && (rf_ra0_ex != 5'b00000)) begin
                    rf_rd0_fe = `ALU_RES_MEM;
                end
                else if ((rf_wa_wb == rf_ra0_ex) && (rf_ra0_ex != 5'b00000)) begin
                    rf_rd0_fe = `RDWD_WB;
                end

                if ((rf_wa_mem == rf_ra1_ex) && (rf_ra1_ex != 5'b00000)) begin
                    rf_rd1_fe = `ALU_RES_MEM;
                end
                else if ((rf_wa_wb == rf_ra1_ex) && (rf_ra1_ex != 5'b00000)) begin
                    rf_rd1_fe = `RDWD_WB;
                end
            end

        end
    endcase
end

endmodule
// 当mem与wb同时需要前递时，取mem的结果，wb的结果直接放弃
/*  
addi x1, x0, 1   IF ID EX ME WB
addi x1, x1, 1      IF ID EX ME WB
addi x2, x1, 1         IF ID EX ME WB
*/