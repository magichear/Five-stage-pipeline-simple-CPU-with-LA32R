
module DmemWE (
    input  [ 3 : 0] dmem_access,
    
    output [ 0 : 0] dmem_we
);
assign dmem_we = ((dmem_access == 4'b1001) || (dmem_access == 4'b0011) || (dmem_access == 4'b1100)) ? 1'b1 : 1'b0;

endmodule