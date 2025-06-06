`timescale 1ns / 1ps
module univ_sync_fifo_tb;
    // Testbench variables
    localparam FIFO_DEPTH = 8;
    localparam DATA_WIDTH = 32;

    reg clk, rst_n, cs, wr_en, rd_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire empty, full;

    integer i;

    // Instantiate the DUT
    univ_sync_fifo
        #(.FIFO_DEPTH(FIFO_DEPTH),
          .DATA_WIDTH(DATA_WIDTH))
        FIFO0
        (.clk     (clk     ),
         .rst_n   (rst_n   ),
         .cs      (cs      ),
         .wr_en   (wr_en   ),
         .rd_en   (rd_en   ),
         .data_in (data_in ),
         .data_out(data_out),
         .empty   (empty   ),
         .full    (full    ));

    task write_data(input [DATA_WIDTH-1:0] d_in);
    begin
        @(posedge clk); // sync to positive edge of clock
        wr_en = 1;
        data_in = d_in;
        $display($time, " write_data data_in = %0d", data_in);
        #5 wr_en = 0;
    end
    endtask

    task read_data();
    begin
        @(posedge clk);  // sync to positive edge of clock
        rd_en = 1;
        $display($time, " read_data data_out = %0d", data_out);
        #5 rd_en = 0;
    end
    endtask

    // Create the clock signal
    always #5 clk = ~clk;

    // Create stimulus
    initial
    begin
        clk = 1'b0;
        #10 {rst_n, wr_en, rd_en} = 0;
        #5 {rst_n, cs} = 2'b11;
        $display($time, "\n SCENARIO 1");
        write_data(1);
        write_data(10);
        write_data(100);
        repeat(3) read_data();

        $display($time, "\n SCENARIO 2");
        for(i=0; i<FIFO_DEPTH; i=i+1)
        begin
            write_data(2**i);
            read_data();
        end

        $display($time, "\n SCENARIO 3");
        for(i=0; i<=FIFO_DEPTH; i=i+1)
            write_data(2**i);
        for(i=0; i<FIFO_DEPTH; i=i+1)
            read_data();

        #20 $stop;
    end
endmodule
