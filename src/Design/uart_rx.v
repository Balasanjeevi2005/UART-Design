
module uart_rx #(
    parameter DATA_WIDTH = 8
)(
    input baud_clk,
    input sys_rst_l,

    input uart_REC_dataH,

    output reg rec_readyH,
    output reg rec_busy,
  
	output reg [DATA_WIDTH-1:0] rec_dataH 
);

  localparam IDLE  = 2'b00;
  localparam START = 2'b01;
  localparam DATA  = 2'b10;
  localparam STOP  = 2'b11;

  reg [1:0] state;
  
  reg [(DATA_WIDTH)-1:0] temp_data;

  reg [$clog2(DATA_WIDTH) - 1 : 0] data_index;

  reg [3:0]count;
  
  reg rx_sync1,rx_sync2;
  
  //syncronizer//

  always@(posedge baud_clk or negedge sys_rst_l)begin

    if(!sys_rst_l)begin
      
      rx_sync1<=1'b1;

      rx_sync2<=1'b1;
      
    end
    
    else begin
      
      rx_sync1 <= uart_REC_dataH;

      rx_sync2 <= rx_sync1;
    
    end

end   

  always @(posedge baud_clk or negedge sys_rst_l) begin

    if(!sys_rst_l) begin

        state <= IDLE;

        rec_readyH <= 1;
        rec_busy   <= 0;
		rec_dataH  <= {DATA_WIDTH{1'b0}};
		
        temp_data <= {DATA_WIDTH{1'b0}};
        data_index <= 0;

        count <= 0;

    end

    else begin

      case(state)

        IDLE: begin
            
            rec_readyH <= 1;
            rec_busy   <= 0;

            temp_data  <= 0;
            data_index <= 0;

            count <= 0;
            

            if(!rx_sync2) begin

			  rec_dataH  <= {DATA_WIDTH{1'b0}};
              state <= START;

            end

        end

        START: begin
          
          rec_readyH <= 1'b0;
          rec_busy <= 1'b1;
          
          if(count==4'd7)begin
            
            count <= 0;
            
            if( rx_sync2 ==0)
              
              state <= DATA;

            else
              
              state <= IDLE;
            
          end
          
          else
            
            count <= count + 1; 
            
        end

        DATA: begin
          
          rec_readyH <= 1'b0;
          rec_busy <= 1'b1;
          
          if(count == 4'hF) begin
            
            count <= 0;
            temp_data[data_index] <= rx_sync2;
            
            if(data_index == (DATA_WIDTH - 1)) begin
              
              data_index <= 0;
              state <= STOP;
              
            end
            
            else begin
              
              data_index <= data_index + 1;
              state <= DATA;
              
            end
            
          end
          
          else begin
            
            count <= count + 1;
            state <= DATA;
            
          end
        end
        STOP: begin
          rec_readyH <= 1'b0;
          rec_busy   <= 1'b1;
          rec_dataH  <= temp_data;
          if(count==4'hF) begin
            
            count <= 0;
            rec_busy <= 1'b0;
		    rec_readyH <= 1'b1;
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
