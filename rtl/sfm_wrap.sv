import hci_package::*;
import hwpe_ctrl_package::*;

module sfm_wrap #(
    parameter int unsigned  ID_WIDTH    = 8                     ,
    parameter int unsigned  N_CORES     = 8                     ,
    parameter int unsigned  DW          = 128                   ,
    parameter int unsigned  MP          = DW / 32               ,
    parameter int unsigned  FPFORMAT    = fpnew_pkg::FP16ALT    
) (
    // global signals
    input  logic                      clk_i               ,
    input  logic                      rst_ni              ,
    input  logic                      test_mode_i         ,
    // events
    output logic [N_CORES-1:0][1:0]   evt_o               ,
    output logic                      busy_o              ,
    // tcdm master ports  
    output logic [      MP-1:0]       tcdm_req_o          ,
    input  logic [      MP-1:0]       tcdm_gnt_i          ,
    output logic [      MP-1:0][31:0] tcdm_add_o          ,
    output logic [      MP-1:0]       tcdm_wen_o          ,
    output logic [      MP-1:0][ 3:0] tcdm_be_o           ,
    output logic [      MP-1:0][31:0] tcdm_data_o         ,
    input  logic [      MP-1:0][31:0] tcdm_r_data_i       ,
    input  logic [      MP-1:0]       tcdm_r_valid_i      ,
    input  logic                      tcdm_r_opc_i        ,
    input  logic                      tcdm_r_user_i       ,
    // periph slave port  
    input  logic                      periph_req_i        ,
    output logic                      periph_gnt_o        ,
    input  logic [        31:0]       periph_add_i        ,
    input  logic                      periph_wen_i        ,
    input  logic [         3:0]       periph_be_i         ,
    input  logic [        31:0]       periph_data_i       ,
    input  logic [ID_WIDTH-1:0]       periph_id_i         ,
    output logic [        31:0]       periph_r_data_o     ,
    output logic                      periph_r_valid_o    ,
    output logic [ID_WIDTH-1:0]       periph_r_id_o
);

    localparam int unsigned WIDTH   = fpnew_pkg::fp_width(FPFORMAT);

    hci_core_intf #(.DW(DW)) tcdm (.clk(clk_i));
    hwpe_ctrl_intf_periph #(.ID_WIDTH(ID_WIDTH)) periph (.clk(clk_i));

    for(genvar ii=0; ii<MP; ii++) begin: gen_tcdm_binding
        assign tcdm_req_o  [ii] = tcdm.req;
        assign tcdm_add_o  [ii] = tcdm.add + ii*4;
        assign tcdm_wen_o  [ii] = tcdm.wen;
        assign tcdm_be_o   [ii] = tcdm.be[(ii+1)*4-1:ii*4];
        assign tcdm_data_o [ii] = tcdm.data[(ii+1)*32-1:ii*32];
    end
    
    assign tcdm.gnt     = &(tcdm_gnt_i);
    assign tcdm.r_valid = &(tcdm_r_valid_i);
    assign tcdm.r_data  = { >> {tcdm_r_data_i} };
    assign tcdm.r_opc   = tcdm_r_opc_i;
    assign tcdm.r_user  = tcdm_r_user_i;

    always_comb begin
    /*assign*/ periph.req     = periph_req_i;
    /*assign*/ periph.add     = periph_add_i;
    /*assign*/ periph.wen     = periph_wen_i;
    /*assign*/ periph.be      = periph_be_i;
    /*assign*/ periph.data    = periph_data_i;
    /*assign*/ periph.id      = periph_id_i;
    /*assign*/ periph_gnt_o     = periph.gnt;
    /*assign*/ periph_r_data_o  = periph.r_data;
    /*assign*/ periph_r_valid_o = periph.r_valid;
    /*assign*/ periph_r_id_o    = periph.r_id;
    end

    sfm_top #(
        .FPFORMAT   (   FPFORMAT    ),
        .DATA_WIDTH (   DW          ),
        .N_CORES    (   N_CORES     )  
    ) i_top (
        .clk_i  (   clk_i   ),
        .rst_ni (   rst_ni  ),
        .busy_o (   busy_o  ),
        .evt_o  (   evt_o   ),
        .tcdm   (   tcdm    ),
        .periph (   periph  ) 
    );

endmodule