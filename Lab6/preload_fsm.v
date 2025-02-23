module preload_fsm(
	input			clk,
	input			rst_n,  //asynchronous reset, low reset
	
	//signals from SW/HW register interface
	input			start_preload,
	input			mem_write,
	input	[9:0]	addr,   //memory write address
	input	[63:0]	data,	//memory write data
	input			mem_done,
	input			mem_load_done,
	
	//memory output control
	output	reg			mem_we,
	output	reg	[9:0]	mem_addr,
	output	reg	[63:0]	mem_data,
	
	//output reg processor_reset, high reset
	output 	reg			proc_reset,
	
	//preload done indication
	output	reg			preload_done
);

	
	//FSM state defination
	localparam	IDLE			=	3'd0;
	localparam	ASSERT_RESET	=	3'd1;
	localparam	WAIT_WRITE		=	3'd2;
	localparam	WRITE_MEMORY	=	3'd3;
	localparam	WAIT_MEM_DONE	=	3'd4;
	localparam	UNRESET_PROC	=	3'd5; //release reset
	localparam	DONE 			=	3'd6;
	
	reg		[2:0]	state, next_state;
	
	//state register
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)
			state <= IDLE;
		else
			state <= next_state;
	end
	
	//state transition logic
	always@(*)
		case (state)
			IDLE: begin
				if (start_preload)
					next_state = ASSERT_RESET;
				else
					next_state = IDLE;
			end
			
			//Enter the reset state to ensure the processor to stop running
			ASSERT_RESET: begin
				next_state = WAIT_WRITE;
			end
			
			//Wait for the write command of preload
			WAIT_WRITE: begin
				if (mem_write)
					next_state = WRITE_MEMORY;
				else if (mem_load_done)
					next_state = UNRESET_PROC;
				else
					next_state = WAIT_WRITE;
			end
			
			WRITE_MEMORY: begin
				next_state = WAIT_MEM_DONE;
			end
			
			WAIT_MEM_DONE: begin
				if (mem_done)
					next_state = WAIT_WRITE;
				else
					next_state = WAIT_MEM_DONE;
			end
			
			UNRESET_PROC: begin
				next_state = DONE;
			end
			
			DONE: begin
				next_state = IDLE;
			end
			
			default: next_state = IDLE;
		endcase
	end
	
	
	//output logic
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			proc_reset 	<= 1'b0;
			mem_we		<= 1'b0;
			mem_addr	<= 10'd0;
			mem_data	<= 32'd0;
			preload_done<= 1'b0;
		end
		else begin
			case (next_state)
				IDLE: begin
					proc_reset   <= 1'b0;
                    mem_we       <= 1'b0;
                    preload_done <= 1'b0;
                end
				
				ASSERT_RESET: begin
                    proc_reset   <= 1'b1;
                    mem_we       <= 1'b0;
                end
				
				WAIT_WRITE: begin
                    proc_reset   <= 1'b1;
                    mem_we       <= 1'b0;
                end
				
				WRITE_MEMORY: begin
                    mem_we       <= 1'b1;
                    mem_addr     <= addr;
                    mem_data     <= data;
                    proc_reset   <= 1'b1;
                end
				
				WAIT_MEM_DONE: begin
                    mem_we       <= 1'b0;
                    proc_reset   <= 1'b1;
                end
				
				UNRESET_PROC: begin
                    proc_reset   <= 1'b0;
                end
				
				DONE: begin
                    preload_done <= 1'b1;
                end

                default: begin
                    proc_reset   <= proc_reset;
                    mem_we       <= 1'b0;
                end
				
			endcase
		end
	end

endmodule