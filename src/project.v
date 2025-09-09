/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_rr_arbiter4 (
    input  wire [7:0] ui_in,    // Dedicated inputs (req[3:0])
    output wire [7:0] uo_out,   // Dedicated outputs (gnt[3:0])
    input  wire [7:0] uio_in,   // IOs: not used
    output wire [7:0] uio_out,  // IOs: not used
    output wire [7:0] uio_oe,   // IOs: not used
    input  wire       ena,      // always 1 when design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal signals
    reg [3:0] gnt;
    reg [1:0] pointer;
    wire rst = ~rst_n;       // active-high reset
    wire [3:0] req = ui_in[3:0]; // take lower 4 bits as requests

    // Arbiter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gnt <= 4'b0000;
            pointer <= 2'b00;
        end else begin
            gnt <= 4'b0000; // default no grant
            case (pointer)
                2'b00: begin
                    if (req[0]) begin gnt <= 4'b0001; pointer <= 2'b01; end
                    else if (req[1]) begin gnt <= 4'b0010; pointer <= 2'b10; end
                    else if (req[2]) begin gnt <= 4'b0100; pointer <= 2'b11; end
                    else if (req[3]) begin gnt <= 4'b1000; pointer <= 2'b00; end
                end
                2'b01: begin
                    if (req[1]) begin gnt <= 4'b0010; pointer <= 2'b10; end
                    else if (req[2]) begin gnt <= 4'b0100; pointer <= 2'b11; end
                    else if (req[3]) begin gnt <= 4'b1000; pointer <= 2'b00; end
                    else if (req[0]) begin gnt <= 4'b0001; pointer <= 2'b01; end
                end
                2'b10: begin
                    if (req[2]) begin gnt <= 4'b0100; pointer <= 2'b11; end
                    else if (req[3]) begin gnt <= 4'b1000; pointer <= 2'b00; end
                    else if (req[0]) begin gnt <= 4'b0001; pointer <= 2'b01; end
                    else if (req[1]) begin gnt <= 4'b0010; pointer <= 2'b10; end
                end
                2'b11: begin
                    if (req[3]) begin gnt <= 4'b1000; pointer <= 2'b00; end
                    else if (req[0]) begin gnt <= 4'b0001; pointer <= 2'b01; end
                    else if (req[1]) begin gnt <= 4'b0010; pointer <= 2'b10; end
                    else if (req[2]) begin gnt <= 4'b0100; pointer <= 2'b11; end
                end
            endcase
        end
    end

    // Assign outputs
    assign uo_out  = {4'b0000, gnt}; // map grants to lower 4 bits
    assign uio_out = 8'b0;           // unused
    assign uio_oe  = 8'b0;           // unused

    // Prevent unused signal warnings
    wire _unused = &{ena, uio_in, 1'b0};

endmodule

