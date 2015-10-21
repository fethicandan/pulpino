`include "config.sv"

module sp_ram_wrap
  #(
    parameter ADDR_WIDTH = 17,
    parameter NUM_WORDS  = 32768
  )(
    // Clock and Reset
    input  logic clk,

    input  logic                   en_i,
    input  logic [ADDR_WIDTH-1:0]  addr_i,
    input  logic [31:0]            wdata_i,
    output logic [31:0]            rdata_o,
    input  logic                   we_i,
    input  logic [3:0]             be_i,
    input  logic                   bypass_en_i
  );

`ifdef PULP_FPGA_EMUL
  xilinx_mem_32768x32
  sp_ram_i
  (
    .clka   ( clk                ),
    .rsta   ( 1'b0               ), // reset is active high

    .ena    ( en_i               ),
    .addra  ( addr_i             ),
    .dina   ( wdata_i            ),
    .douta  ( rdata_o            ),
    .wea    ( be_i & {4{we_i}}   )
  );
`elsif SYNTHESIS

   // RAM bypass logic
   logic [31:0] ram_out_int;

   assign rdata_o = (bypass_en_i) ? wdata_i : ram_out_int;   
   
   SHKA65_8192X8X4CM16
   sp_ram_i
   (
      .DO   ( ram_out_int       ),
      .A    ( addr_i            ),
      .DI   ( wdata_i           ),
      .WEB  ( be_i & {4{we_i}}  ),
      .DVSE ( 1'b0              ),
      .DVS  ( 3'b0              ),
      .CK   ( clk               ), 
      .CSB  ( bypass_en_i       )
    );
`else
  sp_ram
  #(
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .NUM_WORDS  ( NUM_WORDS  )
    )
  sp_ram_i
  (
    .clk     ( clk       ),

    .en_i    ( en_i      ),
    .addr_i  ( addr_i    ),
    .wdata_i ( wdata_i   ),
    .rdata_o ( rdata_o   ),
    .we_i    ( we_i      ),
    .be_i    ( be_i      )
  );
`endif

endmodule

