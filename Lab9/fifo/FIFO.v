module lab8_fifo(
    input clk,
    input reset,
    output reg [8:0] packet_count,

    // NetFPGA interface
    input [63:0] in_data,
    input [7:0] in_ctrl,
    input in_wr,
    output reg in_rdy,
    output reg [63:0] out_data,
    output reg [7:0] out_ctrl,
    output reg out_wr,
    input out_rdy,

    // Processor interface
    input [63:0] proc_data_in,
    input [7:0] proc_addr_in,
    output reg [63:0] proc_data_out,
    input proc_web,
    input proc_memEn,
    input pin_di, //processor data process request
    output reg p_en, //processor enable

    // Debugging pins for SW/HW register
    input [7:0] memAddressQuery,
    output [71:0] memDataOut
);
    // Timing testing
    reg [63:0] in_data_reg;
    reg [7:0] in_ctrl_reg;
    reg in_wr_reg;

    // Update input registers on clock edge
    always @(posedge clk) begin
        in_data_reg <= in_data;
        in_ctrl_reg <= in_ctrl;
        in_wr_reg <= in_wr;
    end

    // FSM state definitions
    parameter IDLE = 4'b0001,
              RX   = 4'b0010,
            //  PROCESS   = 4'b0100,
              RXDONE = 4'b0011,
              EX   = 4'b0100,
              TX   = 4'b1000;

    reg [3:0] state, next_state;
    reg [7:0] count;
    reg [7:0] wp, rp; // Write and read pointers
    reg p_di, count_pi; // Processor data indicators
    reg out_wr_w; // Output write working register

    // Interface and memory block signals
    reg [7:0] addrb;
    reg [71:0] dinb;
    wire [71:0] doutb;
    reg web, enb;
    wire control_nonzero;

    // Memory block instance
    MemBlock fifo1(
        .addra(memAddressQuery),
        .addrb(addrb),
        .clka(clk),
        .clkb(clk),
        .dina(72'b0),
        .dinb(dinb),
        .douta(memDataOut),
        .doutb(doutb),
        .enb(enb),
        .wea(1'b0),
        .web(web)
    );

    // Detect if any control signal is not zero
    assign control_nonzero = |in_ctrl[7:0];  //if 1: end of the packet

    // Update processor interface and counter
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            p_di <= 1'b0;
            count_pi <= 1'b0;
        end else begin
            p_di <= count_pi;
            if (pin_di) 
                count_pi <= 1'b1;  //processing done
            else if (~(count <= 1'b0))
                count_pi <= 1'b0;
        end
    end

    // FSM combinational logic
    always @(*) begin
        // Default assignments
        in_rdy = 1'b0;
        p_en = 1'b0;
        out_wr_w = 1'b0;
        web = 1'b0;
        enb = 1'b1;
        addrb = wp;
        dinb = {in_ctrl_reg, in_data_reg};
        {out_ctrl, out_data} = doutb;

        // FSM states
        case (state)
            IDLE: begin
                in_rdy = 1'b1;
                if (in_wr_reg) begin
                    next_state = RX;
                    web = 1'b1;
                end else next_state = IDLE;
            end
            RX: begin
                in_rdy = ~control_nonzero;
                if (in_wr_reg) begin
                    web = 1'b1;
                    next_state = control_nonzero ? RXDONE : RX; //if 1, end of the packet
                end else next_state = RX;
            end
            RXDONE: begin
                if(in_wr_reg) begin
                    web = 1'b1;
                    next_state = EX;
                end else next_state = RXDONE;
            end
            EX: begin
                p_en = ~p_di;
                addrb = proc_addr_in; 
                enb = proc_memEn; 
                web = proc_web;
                dinb = {8'b0, proc_data_in};
                proc_data_out = doutb[63:0];
                next_state = p_di ? TX : EX;
            end
            TX: begin
                addrb = rp; //read pointer as address
                enb = 1'b1; //enb may change by proc_memEN in EX stage
                if (out_rdy) begin
                    out_wr_w = 1'b1;
                    next_state = (count == 8'd1) ? IDLE : TX;
                end else next_state = TX;
            end
        endcase
    end

    // FSM sequential logic
    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            state <= IDLE;
            count <= 0;
            wp <= 0;
            rp <= 0;  
            packet_count <= 0;
        end else begin
            state <= next_state;
            // Update counters and pointers based on state
            case (state)
                IDLE: if (in_wr_reg) begin
                    count <= count + 1;
                    wp <= wp + 1;
                    packet_count <= packet_count + 1;
                end
                RX: if (in_wr_reg) begin
                    count <= count + 1;
                    wp <= wp + 1;
                    packet_count <= packet_count + 1;
                end
                RXDONE: if (in_wr_reg) begin
                    count <= count + 1;
                    wp <= wp + 1;
                    packet_count <= packet_count + 1;
                end
                TX: if (out_rdy) begin
                    rp <= rp + 1;
                    count <= count - 1;
                end
            endcase
        end
    end

    // Update output write signal
    always @(posedge clk or negedge reset) begin
        if (~reset)
            out_wr <= 1'b0;
        else
            out_wr <= out_wr_w;
    end
endmodule
