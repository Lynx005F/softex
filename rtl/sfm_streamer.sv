import hwpe_stream_package::*;
import hci_package::*;

module sfm_streamer #(
    parameter int unsigned  DATA_WIDTH  = 256   ,
    parameter int unsigned  ADDR_WIDTH  = 32    
) (
    input   logic                   clk_i               ,
    input   logic                   rst_ni              ,
    input   logic                   clear_i             ,
    input   logic                   enable_i            ,
    input   hci_streamer_ctrl_t     in_stream_ctrl_i    ,
    input   hci_streamer_ctrl_t     out_stream_ctrl_i   ,
    output  hci_streamer_flags_t    in_stream_flags_o   ,
    output  hci_streamer_flags_t    out_stream_flags_o  ,

    hwpe_stream_intf_stream.source  in_stream_o         ,
    hwpe_stream_intf_stream.sink    out_stream_i        ,

    hci_core_intf.master            tcdm                
);

    logic   stream_sel,
            stream_prio_cnt,
            stream_prio_cnt_en;

    logic [1:0] reqs,
                r_valids;

    hci_core_intf #(
        .DW (   DATA_WIDTH  ),
        .UW (   1           )
    ) ldst_tcdm ( 
        .clk    (   clk_i   ) 
    );

    hci_core_intf #(
        .DW (   DATA_WIDTH  ),
        .UW (   1           )
    ) mux_i_tcdm [1:0] (
        .clk    (   clk_i   )
    );

    hci_core_mux_ooo #(
        .NB_CHAN    (   2           ),
        .DW         (   DATA_WIDTH  ),
        .AW         (   ),
        .BW         (   ),
        .WW         (   ),
        .UW         (   ),
        .OW         (   )
    ) i_ldst_mux (
        .clk_i              (   clk_i       ),
        .rst_ni             (   rst_ni      ),
        .clear_i            (   clear_i     ),
        .priority_force_i   (   '0          ),
        .priority_i         (   '0          ),
        .in                 (   mux_i_tcdm  ),
        .out                (   ldst_tcdm   )
    );

    hci_core_r_valid_filter i_tcdm_filter (
        .clk_i       (  clk_i           ),
        .rst_ni      (  rst_ni          ),
        .clear_i     (  clear_i         ),
        .enable_i    (  1'b1            ),
        .tcdm_slave  (  ldst_tcdm       ),
        .tcdm_master (  tcdm            )
    );

    ///////////////////////////////////

    hci_core_intf #(
        .DW (   DATA_WIDTH  ),
        .UW (   1           )
    ) load_fifo (
        .clk    (   clk_i   )
    );

    hci_core_source #(
        .DATA_WIDTH             (   DATA_WIDTH  ),
        .MISALIGNED_ACCESSES    (   0           )
    ) i_stream_in (
        .clk_i          (   clk_i               ),
        .rst_ni         (   rst_ni              ),
        .test_mode_i    (   '0                  ),
        .clear_i        (   clear_i             ),
        .enable_i       (   enable_i            ),
        .tcdm           (   load_fifo           ),
        .stream         (   in_stream_o         ),
        .ctrl_i         (   in_stream_ctrl_i    ),
        .flags_o        (   in_stream_flags_o   )
    );

    hci_core_fifo #(
        .FIFO_DEPTH (   2           ),
        .DW         (   DATA_WIDTH  )
    ) i_load_fifo (
        .clk_i       (  clk_i           ),
        .rst_ni      (  rst_ni          ),
        .clear_i     (  clear_i         ),
        .flags_o     (                  ),
        .tcdm_slave  (  load_fifo       ),
        .tcdm_master (  mux_i_tcdm [0]  )
    );

    /////////////////////////////////

    hci_core_intf #(
        .DW (   DATA_WIDTH  ),
        .UW (   1           )
    ) store_fifo (
        .clk    (   clk_i   )
    );

    hci_core_sink #(
        .DATA_WIDTH             (   DATA_WIDTH  ),
        .MISALIGNED_ACCESSES    (   0           )
    ) i_stream_out (
        .clk_i          (   clk_i               ),
        .rst_ni         (   rst_ni              ),
        .test_mode_i    (   '0                  ),
        .clear_i        (   clear_i             ),
        .enable_i       (   enable_i            ),
        .tcdm           (   store_fifo          ),
        .stream         (   out_stream_i        ),
        .ctrl_i         (   out_stream_ctrl_i   ),
        .flags_o        (   out_stream_flags_o  )
    );

    hci_core_fifo #(
        .FIFO_DEPTH (   2           ),
        .DW         (   DATA_WIDTH  )
    ) i_store_fifo (
        .clk_i       (  clk_i           ),
        .rst_ni      (  rst_ni          ),
        .clear_i     (  clear_i         ),
        .flags_o     (                  ),
        .tcdm_slave  (  store_fifo      ),
        .tcdm_master (  mux_i_tcdm [1]  )
    ); 


endmodule