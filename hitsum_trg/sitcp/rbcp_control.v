/*******************************************************************************
*                                                                              *
* Module      : RBCP_REG                                                       *
* Version     : v 0.2.0 2010/03/31                                             *
*                                                                              *
* Description : Register file                                                  *
*                                                                              *
*                Copyright (c) 2010 Bee Beans Technologies Co.,Ltd.            *
*                All rights reserved                                           *
*                                                                              *
*******************************************************************************/

`define FPGA_VER 32'hEAAA_0601
`define SYN_DATE 32'h1711_1418
`define REG_INIT_X08 8'h08
`define REG_INIT_X09 8'h09
`define REG_INIT_X0A 8'h0A
`define REG_INIT_X0B 8'h0B
`define REG_INIT_X0C 8'h0C
`define REG_INIT_X0D 8'h0D
`define REG_INIT_X0E 8'h0E
`define REG_INIT_X0F 8'h0F

module rbcp_control(
  CLK,
  RST,
  RBCP_ACT,
  RBCP_ADDR,
  RBCP_WE,
  RBCP_WD,
  RBCP_RE,
  RBCP_RD,
  RBCP_ACK,
  srst_done,
  init_done
);

input CLK;
input RST;

input RBCP_ACT;
input [31:0] RBCP_ADDR;
input RBCP_WE;
input [7:0]	RBCP_WD;
input RBCP_RE;
output [7:0] RBCP_RD;
output RBCP_ACK;
output reg srst_done;
output reg init_done;

reg [31:0] irAddr;
reg irWe;
reg [7:0] irWd;
reg irRe;

always@ (posedge CLK or posedge RST) begin
  if(RST)begin
    irAddr[31:0]<=0;
    irWe<=0;
    irWd[7:0]<=0;
    irRe<=0;
  end else begin
    irAddr[31:0]<=RBCP_ADDR[31:0];
    irWe<=RBCP_WE;
    irWd[7:0]<=RBCP_WD[7:0];
    irRe<=RBCP_RE;
  end
end

reg regCs;
reg [23:0] regAddr;
reg [7:0]	regWd;
reg regWe;
reg regRe;

always@ (posedge CLK) begin
  regCs<=(irAddr[31:8]==24'd0);
  regAddr[23:0]<=(irWe | irRe ? irAddr[23:0] : regAddr[23:0]);
  regWd[7:0]<=(irWe ? irWd[7:0] : regWd[7:0]);
  regWe<=irWe;
  regRe<=irRe;
end

reg [15:8] regBe;

always@ (posedge CLK) begin
  regBe[8]<=regCs & regWe & (regAddr[4:0] == 5'h8);
  regBe[9]<=regCs & regWe & (regAddr[4:0] == 5'h9);
  regBe[10]<=regCs & regWe & (regAddr[4:0] == 5'hA);
  regBe[11]<=regCs & regWe & (regAddr[4:0] == 5'hB);
  regBe[12]<=regCs & regWe & (regAddr[4:0] == 5'hC);
  regBe[13]<=regCs & regWe & (regAddr[4:0] == 5'hD);
  regBe[14]<=regCs & regWe & (regAddr[4:0] == 5'hE);
  regBe[15]<=regCs & regWe & (regAddr[4:0] == 5'hF);
end

reg [7:0] regX08Data;
reg [7:0] regX09Data;
reg [7:0] regX0AData;
reg [7:0] regX0BData;
reg [7:0] regX0CData;
reg [7:0] regX0DData;
reg [7:0] regX0EData;
reg [7:0] regX0FData;

always@ (posedge CLK or posedge RST) begin
  if(RST)begin
    regX08Data[7:0]<=`REG_INIT_X08;
    regX09Data[7:0]<=`REG_INIT_X09;
    regX0AData[7:0]<=`REG_INIT_X0A;
    regX0AData[7:0]<=`REG_INIT_X0B;
    regX0CData[7:0]<=`REG_INIT_X0C;
    regX0DData[7:0]<=`REG_INIT_X0D;
    regX0EData[7:0]<=`REG_INIT_X0E;
    regX0FData[7:0]<=`REG_INIT_X0F;
  end else begin
    if(regBe[8])begin
      regX08Data[7:0]<=regWd[7:0];
    end
    if(regBe[9])begin
      regX09Data[7:0]<=regWd[7:0];
    end
    if(regBe[10])begin
      regX0AData[7:0]<=regWd[7:0];
    end
    if(regBe[11])begin
      regX0BData[7:0]<=regWd[7:0];
    end
    if(regBe[12])begin
      regX0CData[7:0]<=regWd[7:0];
    end
    if(regBe[13])begin
      regX0DData[7:0]<=regWd[7:0];
    end
    if(regBe[14])begin
      regX0EData[7:0]<=regWd[7:0];
    end
    if(regBe[15])begin
      regX0FData[7:0]<=regWd[7:0];
    end
  end
end

wire [7:0] X00Data;
wire [7:0] X01Data;
wire [7:0] X02Data;
wire [7:0] X03Data;
wire [7:0] X04Data;
wire [7:0] X05Data;
wire [7:0] X06Data;
wire [7:0] X07Data;
wire [7:0] X08Data;
wire [7:0] X09Data;
wire [7:0] X0AData;
wire [7:0] X0BData;
wire [7:0] X0CData;
wire [7:0] X0DData;
wire [7:0] X0EData;
wire [7:0] X0FData;

assign  {X00Data[7:0],X01Data[7:0],X02Data[7:0],X03Data[7:0]}=`FPGA_VER;
assign  {X04Data[7:0],X05Data[7:0],X06Data[7:0],X07Data[7:0]}=`SYN_DATE;

assign  X08Data[7:0]=regX08Data[7:0];
assign  X09Data[7:0]=regX09Data[7:0];
assign  X0AData[7:0]=regX0AData[7:0];
assign  X0BData[7:0]=regX0BData[7:0];
assign  X0CData[7:0]=regX0CData[7:0];
assign  X0DData[7:0]=regX0DData[7:0];
assign  X0EData[7:0]=regX0EData[7:0];
assign  X0FData[7:0]=regX0FData[7:0];

always@ (posedge CLK) begin
  if(irRe)begin
    srst_done<=0;
    init_done<=0;
  end else begin
    if(regBe[8])begin
      srst_done<=1;
      init_done<=0;
    end
    if(regBe[9])begin
      srst_done<=0;
      init_done<=1;
    end
    if(regBe[10])begin
      srst_done<=0;
      init_done<=0;
    end
  end
end

reg [7:0] muxRegDataA;
reg muxRegAck;

always@ (posedge CLK) begin
  case(regAddr[3:0])
    4'h0: muxRegDataA[7:0]<=X00Data[7:0];
    4'h1: muxRegDataA[7:0]<=X01Data[7:0];
    4'h2: muxRegDataA[7:0]<=X02Data[7:0];
    4'h3: muxRegDataA[7:0]<=X03Data[7:0];
    4'h4: muxRegDataA[7:0]<=X04Data[7:0];
    4'h5: muxRegDataA[7:0]<=X05Data[7:0];
    4'h6: muxRegDataA[7:0]<=X06Data[7:0];
    4'h7: muxRegDataA[7:0]<=X07Data[7:0];
    4'h8: muxRegDataA[7:0]<=X08Data[7:0];
    4'h9: muxRegDataA[7:0]<=X09Data[7:0];
    4'hA: muxRegDataA[7:0]<=X0AData[7:0];
    4'hB: muxRegDataA[7:0]<=X0BData[7:0];
    4'hC: muxRegDataA[7:0]<=X0CData[7:0];
    4'hD: muxRegDataA[7:0]<=X0DData[7:0];
    4'hE: muxRegDataA[7:0]<=X0EData[7:0];
    default: muxRegDataA[7:0]<=X0FData[7:0];
  endcase
  muxRegAck<=regCs & (regRe | regWe);
end

reg orAck;
reg [7:0] orRd;

always@ (posedge CLK) begin
 orAck<=muxRegAck;
 orRd[7:0]<=(muxRegAck ? muxRegDataA[7:0] : 8'd0);
end

wire RBCP_ACK;
wire [7:0]	RBCP_RD;

assign RBCP_ACK=orAck;
assign RBCP_RD[7:0]=orRd[7:0];

endmodule
