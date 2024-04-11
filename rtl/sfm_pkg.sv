import fpnew_pkg::*;

package sfm_pkg;
    //Register file indexes
    parameter int unsigned  IN_ADDR     = 0;
    parameter int unsigned  OUT_ADDR    = 1;
    parameter int unsigned  TOT_LEN     = 2;
    parameter int unsigned  COMMANDS    = 3;

    parameter int unsigned  CMD_ACC_ONLY    = 0;
    parameter int unsigned  CMD_DIV_ONLY    = 1;
    parameter int unsigned  CMD_LAST        = 2;

    parameter int unsigned  STATE_SLOT_OFFS = 16;

    typedef enum int unsigned   { BEFORE, AFTER, AROUND }   regs_config_t;
    typedef enum logic          { MIN, MAX }                min_max_mode_t;
    typedef enum logic          { ADD, MUL }                operation_t;

    typedef struct packed {
        logic           reducing;
        logic           acc_done;
        logic           inv_done;

        logic [31 : 0]  denominator;
        logic [31 : 0]  reciprocal;
    } accumulator_flags_t;

    typedef struct packed {
        logic           acc_finished;
        logic           acc_only;
        logic           load_reciprocal;

        logic [31 : 0]  reciprocal;
    } accumulator_ctrl_t;

    typedef struct packed {
        logic               datapath_busy;

        logic [31 : 0]      max;

        accumulator_flags_t accumulator_flags;
    } datapath_flags_t;

    typedef struct packed {
        logic               disable_max;
        logic               dividing;
        logic               clear_regs;
        logic               load_max;
        logic               load_denominator;

        logic [31 : 0]      max;
        logic [31 : 0]      denominator;

        accumulator_ctrl_t  accumulator_ctrl;
    } datapath_ctrl_t;

    function sfm_to_cvfpu(sfm_pkg::regs_config_t arg);
        fpnew_pkg::pipe_config_t res;

        unique case (arg)
            sfm_pkg::BEFORE :   res = fpnew_pkg::BEFORE;
            sfm_pkg::AFTER  :   res = fpnew_pkg::AFTER;
            sfm_pkg::AROUND :   res = fpnew_pkg::DISTRIBUTED;
        endcase

        return res;
    endfunction
endpackage