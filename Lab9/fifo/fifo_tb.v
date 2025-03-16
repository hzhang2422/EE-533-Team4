'timescale 1ns/1ps

module fifo_tb;

reg clk;
reg reset;
wire [8:0] packet_count;

//Netfpga input
reg [7:0]  in_ctrl;
reg [63:0] in_data;
reg in_wr;
reg out_rdy;
//Netfpga output
wire [7:0]  out_ctrl;
wire [63:0] out_data;
wire out_wr;
wire in_rdy;

//Processor input
reg [63:0] proc_data_in;
reg [7:0]  proc_addr_in;
reg proc_web;
reg proc_memEn;
reg pin_di;
//Processor output
wire [63:0] proc_data_out;
wire p_en;

//Debugging pins for SW/HW register
reg [7:0] memAddressQuery;
wire [71:0] memDataOut;

FIFO uut(
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .in_ctrl(in_ctrl),
    .in_wr(in_wr),
    .out_rdy(out_rdy),
    .proc_data_in(proc_data_in),
    .proc_addr_in(proc_addr_in),
    .proc_web(proc_web),
    .proc_memEn(proc_memEn),
    .pin_di(pin_di),
    .packet_count(packet_count),
    .out_ctrl(out_ctrl),
    .out_data(out_data),
    .out_wr(out_wr),
    .in_rdy(in_rdy),
    .proc_data_out(proc_data_out),
    .p_en(p_en),
    .memAddressQuery(memAddressQuery),
    .memDataOut(memDataOut)
)

always #5 clk = ~clk;

task Initialize;
  begin
    clk = 0;
    reset = 0;
    in_ctrl = 8'b0;
    in_data = 64'b0;
    in_wr = 0;
    out_rdy = 0;
    proc_data_in = 64'b0;
    proc_addr_in = 8'b0;
    proc_web = 0;
    proc_memEn = 0;
    pin_di = 0;
    memAddressQuery = 8'b0;

    //release reset
    #10;
    reset = 1;

    $display("Initialize complete at %t", $time);
  end
endtask

task send_packet;
    input [4:0] packet_size;
    input [63:0] base_packet;
    integer i;
  begin
    wait(in_rdy);//wait for IDLE
    //send the first few packets
    for(i=0; i<packet_size-1; i=i+1) 
      begin
        @(posedge clk);
        in_wr = 1;
        in_ctrl = 8'h00; //good packet
        in_data = base_packet + i;
//        @(posedge clk);
        while (!in_rdy) begin
            @(posedge clk);
        end
      end

    //send the last packet  
    @(posedge clk);
    in_ctrl = 8'h01;
    in_data = base_packet + packet_size - 1;
    in_wr = 1;
    @(posedge clk);
    @(posedge clk);
    in_wr = 0;

    $display("Send packet with %0d words at %t", packet_size, $time);
  end
endtask

task process_packet;
  input [7:0] start_address;
  input [4:0] packet_size;
  integer i;
  begin
    wait(p_en); //wait for EX stage
    for(i=0; i<packet_size; i=i+1)
      begin
        @(posedge clk);
        proc_addr_in = start_address+i;
        proc_memEn = 1'b1; //read data from sram
        proc_web = 1'b0;

        @(posedge clk); // read data occurs in next clk
   
        //modify data then write back to sram
        @(posedge clk);
        proc_data_in = proc_data_out + 64'h0000_0000_0000_1000;
        proc_web = 1'b1;

        @(posedge clk);
        proc_memEn = 1'b0;
        proc_web = 1'b0;
      end

      @(posedge clk);
      pin_di = 1'b1;  //processing done
      @(posedge clk);
      pin_di = 1'b0;
  end
endtask

task recieve_packet;
  input [4:0] packet_size; //the number of reception data
  integer i;
  begin
    out_rdy = 1'b1;

    for(i=0; i<packet_size; i=i+1)
      begin
        wait(out_wr);
        @(posedge clk);
      end

    out_rdy = 1'b0;
  end
endtask

initial begin

    Initialize;
    #10;
    send_packet(5'd5, 64'h0000_0000_0000_0002);
    #10;
    process_packet(8'h00, 5'd5);
    #10;
    recieve_packet(5'd5);
    #20;

end

endmodule