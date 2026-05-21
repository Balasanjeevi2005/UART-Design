
module uart_tx #(
    parameter DATA_WIDTH = 8
)(
    input baud_clk,
    input sys_rst_l,

    input xmitH,

    input [DATA_WIDTH-1:0] xmit_dataH,

    output reg xmit_active,
    output reg xmit_doneH,
    output reg uart_XMIT_dataH
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

  reg [1:0] state;
  
  reg [DATA_WIDTH-1:0] temp_data;

  reg [$clog2(DATA_WIDTH)-1 : 0] data_index;
  
  reg [3:0]count;


  always @(posedge baud_clk or negedge sys_rst_l) begin

    if(!sys_rst_l) begin

        state <= IDLE;
      
        xmit_active <= 1'b0;
        xmit_doneH  <= 1'b1;
        uart_XMIT_dataH <= 1'b1;

        temp_data <= 0;
        data_index <= 0;
        count <= 0;

    end

    else begin

      case(state)

        IDLE: begin

            xmit_active <= 1'b0;
            xmit_doneH  <= 1'b1;
            uart_XMIT_dataH <= 1'b1;

            temp_data <= 0;
            data_index <= 0;
            count <= 0;

            if(xmitH) begin
              
              temp_data <= xmit_dataH;
		      state <= START;

            end
          
            else
              
              state <= IDLE;

        end
        

        START: begin
            
            xmit_active <= 1'b1;
            xmit_doneH  <= 1'b0;
            uart_XMIT_dataH <= 1'b0;

            if(count==4'hF)begin
              
              state <= DATA;
              count <= 0;
              
            end
          
            else begin
              
              count <= count + 1;
              state <= START;
            
            end

        end

        DATA: begin
          
          xmit_active <= 1'b1;
          xmit_doneH  <= 1'b0;
          uart_XMIT_dataH <= temp_data[0];

          if(count==4'hF) begin
            
            count <= 0;
            temp_data <= (temp_data >> 1);
            
            if(data_index == DATA_WIDTH-1)begin
              
              state <= STOP;
              data_index <= 0;
              
            end
            
            else begin
              
              state <= DATA;
              data_index <= data_index + 1;
            
            end
          end
          
          else begin
            
            count <= count + 1;
            state <= DATA;
            
          end     

        end

        STOP: begin
          
          uart_XMIT_dataH <= 1'b1;
          xmit_doneH  <= 1'b1;
          xmit_active <= 1'b0;

          if(count==4'hF) begin
           
            count<=0;
            xmit_active <= 1'b0;  // transmission complete
            xmit_doneH  <= 1'b1;
            state <= IDLE;
            
          end
            
          else begin
            
            count <= count + 1;
            state <= STOP;

          end

        end
        

        default: state <= IDLE;

        endcase

    end

end


endmodule
