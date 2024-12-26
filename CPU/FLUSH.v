
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/22 10:42:39
// Design Name: 
// Module Name: FLUSH
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


module FLUSH(
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [31 : 0]            pcadd4,
    input                   [31 : 0]            npc,
    input                   [ 1 : 0]            npc_sel,
    output     reg          [ 0 : 0]            flush_out
);
always @(*) begin
    flush_out = 1'b0;
    if (rst) begin
        flush_out = 1'b0;
    end
    else if (en) begin
        if ((npc_sel != 2'b00) && (pcadd4 != npc)) begin
            flush_out = 1'b1;
        end
        else begin
            flush_out = 1'b0;
        end
    end
end
endmodule
