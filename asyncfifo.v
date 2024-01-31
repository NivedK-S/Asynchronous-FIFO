module asyncfifo(
    input wrclk,
    input rdclk,
    input [7:0]wrdata,
    input wren,
    input rden,
    input rst,
    output reg[7:0]rdata,
    output reg full,
    output reg empty,
    output reg wrerr,
    output reg rderr
);
reg [7:0]fifo[15:0];
reg [3:0] wrptr;
reg [3:0]rdptr;
reg [3:0]wrptr_rdclk;
reg [3:0]rdptr_wrclk;
reg [3:0]wrptr_gray;
reg [3:0]rdptr_gray;
reg wrtoggle,rdtoggle;
reg wrtoggle_rdclk,rdtoggle_wrclk;
integer i;

always@(posedge wrclk or posedge rst) begin
  if(rst) begin
    wrptr<=0;
    rdptr<=0;
    wrptr_rdclk<=0;
    rdptr_wrclk<=0;
    wrerr<=0;
    rderr<=0;
    full<=0;
    empty<=0;
    rdata<=0;
    wrptr_gray<=0;
    rdptr_gray<=0;
    wrtoggle_rdclk<=0;
    wrtoggle<=0;
    rdtoggle<=0;
    rdtoggle_wrclk<=0;
    for(i=0;i<16;i=i+1) begin
      fifo[i]<=0;
    end
  end
  else begin
    if(wren==1) begin
      if(full) begin
        wrerr<=0;
      end
      else begin
        if(wrptr==15) begin
          fifo[wrptr]<=wrdata;
          wrtoggle<=~wrtoggle;
          wrptr<=0;
        end
        else begin
          fifo[wrptr]<=wrdata;
          wrptr<=wrptr+1;
        end
        wrptr_gray<=wrptr^(wrptr>>1);
      end
    end
  end
end
always @(posedge rdclk) begin
    if(rden) begin
      if(empty) begin
        rderr<=1;
      end
      else begin
        if(rdptr==15) begin
          rdata<=fifo[rdptr];
          rdtoggle=~rdtoggle;
          rdptr<=0;
        end
        else begin
          rdata<=fifo[rdptr];
          rdptr<=rdptr+1;
        end
        rdptr_gray<=rdptr^(rdptr>>1);
      end
    end 
end
always @(rdclk) begin
    wrptr_rdclk<=wrptr_gray; 
    wrtoggle_rdclk<=wrtoggle;
end

always @(wrclk) begin
    rdptr_wrclk<=rdptr_gray;
    rdtoggle_wrclk<=rdtoggle;  
end

always @(*) begin
    full=0;
    empty=0;
    if(wrptr==rdptr_wrclk) begin
      if(wrtoggle!=rdtoggle_wrclk) begin
        full<=1;
      end
    end
    if(rdptr==wrptr_rdclk) begin
      if(rdtoggle==wrtoggle_rdclk) begin
        empty<=1;
      end
    end
end



endmodule