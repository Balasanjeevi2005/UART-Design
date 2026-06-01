module baud_clk_generator#(
  parameter clk_freq = 50_000_000,
  parameter baud_rate = 2400
)(
  input sys_clk,sys_rst_l,
  output reg baud_clk 
);
localparam integer  CLK_DIV=clk_freq/(baud_rate*16*2);
reg [$clog2(CLK_DIV) - 1:0]count=0;

always@(posedge sys_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        count<=0;
        baud_clk<=0;
    end
    else
    begin
        if(count==CLK_DIV-1)
        begin
            count<=0;
            baud_clk<=~baud_clk;
        end
        else 
            count<=count+1;
    end
end   
endmodule
