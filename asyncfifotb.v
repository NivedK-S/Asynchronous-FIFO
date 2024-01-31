`include "asyncfifo.v"
`timescale 1ps/1ps
module asyncfifotb();
/*input wrclk,
    input rdclk,
    input [7:0]wrdata,
    input wren,
    input rden,
    input rst,*/
reg wrclk,rdclk,wren,rden,rst;
reg [7:0]wrdata;
/*output reg[7:0]rdata,
    output reg full,
    output reg empty,
    output reg wrerr,
    output reg rderr*/
wire full,empty,wrerr,rderr;
wire [7:0]rdata;
asyncfifo DUT(.wrclk(wrclk),
              .rdclk(rdclk),
              .wren(wren),
              .rden(rden),
              .rst(rst),
              .wrdata(wrdata),
              .full(full),
              .empty(empty),
              .wrerr(wrerr),
              .rderr(rderr),
              .rdata(rdata)
  );
  initial forever begin
    #5 wrclk=~wrclk;
  end
  initial forever begin
    #10 rdclk=~rdclk;
  end
  initial begin
    wren=0;
    rden=0;
    wrclk=0;
    rdclk=0;
    rst=1;
    wrdata=0;
    #15 rst=0;
  end
  initial begin
    #1500 $finish;
  end
  initial begin
    #15;
    repeat(16) begin
      @(posedge wrclk);
      wrdata=$random;
      wren=1;
    end
    @(posedge wrclk);
    wren=0;
    repeat(16) begin
      @(posedge rdclk);
      rden=1;
    end
    @(posedge rdclk);
    rden=0;
  end
  initial begin
    $dumpvars;
    $dumpfile("asyncfifo.vcd");
    $monitor("Time=%t,rst=%b,wrdata=%d,wren=%b,rden=%b,rdata=%d",$time,rst,wrdata,wren,rden,rdata);
  end
 
endmodule