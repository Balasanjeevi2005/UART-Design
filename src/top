module top#(
  parameter DATA_WIDTH = 8,
  parameter clk_freq = 50_000_000,
  parameter baud_rate = 2400
)(
    input sys_clk,
    input sys_rst_l,
    input xmitH,
    input [DATA_WIDTH-1:0] xmit_dataH,
    output xmit_active,
    output xmit_doneH,
    output uart_XMIT_dataH,
 

    input uart_REC_dataH,
    output rec_readyH,
    output rec_busy,
    output [DATA_WIDTH-1:0] rec_dataH
);
  wire baud_clk;
  baud_clk_generator #(
        .clk_freq(clk_freq),
        .baud_rate(baud_rate)
  )
  b1(
        .baud_clk(baud_clk),
        .sys_clk(sys_clk),
        .sys_rst_l(sys_rst_l)
  );
  uart_rx #(
        .DATA_WIDTH(DATA_WIDTH)
  )
  rx1(
        .baud_clk(baud_clk),
        .rec_busy(rec_busy),
        .rec_dataH(rec_dataH),
        .rec_readyH(rec_readyH),
        .sys_rst_l(sys_rst_l),
        .uart_REC_dataH(uart_REC_dataH)
  );
  uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
  )
  tx1(
        .baud_clk(baud_clk),
        .sys_rst_l(sys_rst_l),
        .uart_XMIT_dataH(uart_XMIT_dataH),
        .xmitH(xmitH),
        .xmit_active(xmit_active),
        .xmit_dataH(xmit_dataH),
        .xmit_doneH(xmit_doneH)
  );
endmodule
