`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 10:38:58 AM
// Design Name: 
// Module Name: proc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//parameter IF=3'b000,ID=3'b001,EXE=3,MEM,WRBK;
module regfile( input clk, input [4:0] ra1,ra2, wa3, input we3 , input [31:0] wd3,output [31:0] rd1,rd2);
reg [31:0] rf[31:0];
always @(posedge clk)
if(we3) rf[wa3]<=wd3;
assign rd1= rf[ra1];
assign rd2= rf[ra2];
endmodule
module ALU (
    input [2:0] ALUcontrol,
    input [31:0] a, b,
    output reg [31:0] ALUout,
    output zero
);
  assign zero = (ALUout == 32'b0);

  always @(*) begin
    case (ALUcontrol)
  3'b010: ALUout <= a + b;        // ADD
  3'b110: ALUout <= a - b;        // SUB
  3'b000: ALUout <= a & b;        // AND
  3'b001: ALUout <= a | b;        // OR
  3'b111: ALUout <= a << b[4:0];  // SLL
  3'b100: ALUout <= a >> b[4:0];  // SRL
  3'b101: ALUout <= $signed(a) >>> b[4:0]; // SRA
  default: ALUout <= 32'b0;
endcase

    
  end
endmodule




module adder(input [31:0] a,b,
             output [31:0] y);
             assign y=a+b;
endmodule
module signext(input [15:0] a,
               output [31:0] y);
               assign y={{16{a[15]}}, a};
endmodule
module immgen (
  input [31:0] instr,
  output reg [31:0] imm
);
  wire [6:0] opcode = instr[6:0];

  always @(*) begin
    case (opcode)
      7'b0010011,
      7'b0000011, 
      7'b1100111:
        imm = {{20{instr[31]}}, instr[31:20]};

      7'b0100011: 
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

      7'b1100011: 
        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        
      7'b0110111, 7'b0010111: begin
        imm = {instr[31:12], 12'b0};
      end
      

      
      7'b1101111: begin
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end

      default:
        imm = 32'b0;
    endcase
  end
endmodule
module comparator(input [31:0] in1,in2,
                  input [1:0] Btype,
                  output reg out);
                  always@(*)
                  begin
                  case(Btype)
                  2'b00:out=(in1==in2);
                  2'b01:out=(in1!=in2);
                  2'b10:out=($signed(in1) < $signed(in2));
                  2'b11:out=(in1<in2);
                  endcase
                  end
                  
endmodule
module imem(input [5:0] addr,
            output [31:0] rd);
            reg  [31:0]  imem [63:0];
            assign rd=imem[addr];
            endmodule               
module dmem(input clk,
            input [31:0] addr,
            input wen,
            input [31:0] writedata,                     
            output [31:0] rd);
            reg [31:0] dmem[63:0];
            assign rd=dmem[addr[5:0]];
            always@(posedge clk)
            if(wen) dmem[addr[5:0]]<=writedata;
endmodule
module if_id_reg (input clear,
input clk, 
input stall,input [31:0] readdata , 
input [31:0] pcplus4 , 
output reg [31:0] InstrD ,
output reg [31:0] pcplus4d);

always @(posedge clk)
if(clear)
begin
InstrD<=32'b0;
pcplus4d<=32'b0;
end
else if(stall)
begin
InstrD<=InstrD;
pcplus4d <= pcplus4d;
end
else begin
InstrD<=readdata;
pcplus4d <= pcplus4;

end
endmodule
//module control_unit( input [6:0] opcode ,input [2:0] funct3,input [6:0] funct7,
    //                 output [1:0] ALUSrcAD,
      //               output reg RegwriteD, MemtoRegD,MemwriteD,ALUsrcBD,RegDstD,BranchD,JumpRegD,JumpD,JalrD,
          //           output reg [2:0] ALUcontrolD,output reg [1:0] Btype);
                     
                     
//endmodule
module id_ie_reg( input clk,clear,
                  input [31:0] rd1, rd2,immD,pcplus4D,
                  input [4:0] RsD,RtD,RdD,
                  input [1:0] ALUSrcAD,
                  input RegwriteD,MemtoRegD,MemwriteD,ALUSrcBD,RegDstD,JumpRegD,
                  input [2:0] ALUcontrolD,
                  output reg [1:0] ALUSrcAE,
                  output reg RegwriteE,MemtoRegE,MemwriteE,ALUSrcBE,RegDstE,JumpRegE,
                  output reg [2:0] ALUcontrolE,
                  output  reg [4:0] RsE,RtE,RdE,
                  output reg [31:0] rd1e,rd2e,immE,pcplus4E );
 always@(posedge clk or posedge clear)
 begin 
 if(clear)
 begin
 rd1e<=32'b0;
 rd2e<=32'b0;
 RsE<=5'b0;
 RtE<=5'b0;
 RdE<=5'b0;
 immE<=32'b0;
 pcplus4E<=32'b0;
 end
 else
 begin 
 rd1e<=rd1;
 rd2e<=rd2;
 RsE<=RsD;
 RtE<=RtD;
 RdE<=RdD;
 immE<=immD;
 pcplus4E<=pcplus4D;
 RegwriteE<=RegwriteD;
 MemtoRegE<= MemtoRegD;
 MemwriteE<=MemwriteD;
 ALUSrcBE<=ALUSrcBD;
 ALUSrcAE<=ALUSrcAD;
 RegDstE<= RegDstD;
 JumpRegE<=JumpRegD;
 end
 end
 endmodule
module ie_mem_reg(input clk,clear,
                 input  RegwriteE,MemtoRegE,MemwriteE,JumpRegE,
                 input [31:0] ALUoutE,pcplus4E,
                 input zero_flag_E,
                 input [31:0] writedata_E,
                 input [4:0] writereg_E,
                 output reg RegWriteM,MemtoRegM,MemWriteM,JumpRegM,
                 output reg [31:0] ALUOutM,pcplus4M,
                 output reg zero_flag_M,
                 output reg [31:0] writedata_M,
                 output reg [4:0] writereg_M);
                 
       always@(posedge clk or posedge clear)
       begin
       if(clear) begin 
       ALUOutM<=32'b0;
       writedata_M<=32'b0;
       writereg_M<=5'b0;
       end
       else begin
      RegWriteM<=RegwriteE;
      MemtoRegM<=MemtoRegE;
      MemWriteM<=MemwriteE;
      writedata_M<=writedata_E;
      ALUOutM<=ALUoutE;
      zero_flag_M<=zero_flag_E;
      writereg_M<=writereg_E;
      JumpRegM<=JumpRegE;
      pcplus4M<=pcplus4E;
      
      end
      end
endmodule
module mem_wb_reg(input clk,input clear,
                  input RegWriteM,MemtoRegM,JumpRegM,
                  input [31:0] readdataM,ALUOutM,pcplus4M,
                  input [4:0] writeregM,
                  output reg RegWriteW,MemtoRegW,JumpRegW,
                  output reg [31:0] readdataW,ALUOutW,pcplus4W,
                  output reg [4:0] writeregW
                  );
                  always@(posedge clk or posedge clear)
                  begin
                  if(clear) begin
                  readdataW<=32'b0;
                  ALUOutW<=32'b0;
                  writeregW<=5'b0;
                  end
                  else  begin
                  RegWriteW<=RegWriteM;
                  MemtoRegW<=MemtoRegM;
                  readdataW<=readdataM;
                  ALUOutW<=ALUOutM;
                  writeregW<=writeregM;
                  JumpRegW<=JumpRegM;
                  pcplus4W<=pcplus4M;
                  end
                  end
endmodule            
module IF(input clk,en,clear,
          input [1:0] pcsrc,
          input [31:0] pcbranch,pcplus4,Jumptarget,
          output reg [31:0] pcF,
          output [31:0] rd,
         output [31:0] pcplus4F);
          
          reg [31:0] pc;
          wire [31:0] pcplus;
          always@(*)begin
          case(pcsrc)
          2'b00:pc=pcplus4;
          2'b01:pc=pcbranch;
          2'b10:pc=pcbranch;
          2'b11:pc=Jumptarget;
          endcase
          end
          
          always@(posedge clk or  posedge clear)
          begin
          if(clear) begin
          pcF<=32'b0;
          //pcplus4F<=32'b0;
          end
          else if(en) begin
          pcF<=pc;
          end
          end
          adder add0(pcF,32'd4,pcplus4);
          assign pcplus4F=pcplus4;
          imem imem(pcF[5:0],rd);
          
          
endmodule 
module ID(input clk,
          input [31:0] Instr,
          input [31:0] pcplus4F,
          input [1:0] ForwardAD,ForwardBD,
          input [31:0] writedata,
          input [4:0] writeaddr,
          input wen,
          output [1:0] Btype,
          input [31:0] ALUOutM,
          output [4:0] RsD,RtD,RdD,
          output [31:0] immD,
          output [31:0] rd1,rd2,
          output [31:0] pcbranch,Jumptarget,ResultW,
          output pcsrc,
          output RegtoMemD,MemtoRegD,MemwriteD,ALUsrcD,RegDstD,BranchD,JumpRegD,JumpD,JalrD,
          output [2:0] AlUcontrol,output [1:0] ALUSrcAD
          );
         wire [31:0] in1,in2,rd1f,rd2f;
         wire  Branch  ;
         reg [31:0] in_1,in_2;
         control_unit control_unit(Instr[6:0],Instr[14:12],Instr[31:25],RegtoMemD,MemtoRegD,MemwriteD,ALUsrcD,RegDstD,BranchD,JumpRegD,JumpD,JalrD,ALUcontrol,Btype);
         regfile regfile(clk,Instr[19:15],Instr[24:20],writeaddr,wen,writedata,rd1f,rd2f);
         immgen immgen(Instr,immD);
        assign rd1=rd1f;
        assign rd2=rd2f;
    
        always@(*) begin
        case(ForwardAD)
        2'b00:in_1=rd1;
        2'b01:in_1=ALUOutM;
        2'b10:in_1=ResultW;
        endcase
        case(ForwardBD)
        2'b00:in_2=rd2;
        2'b01:in_2=ALUOutM;
        2'b10:in_2=ResultW;
        endcase
        end
        assign in1=in_1;
        assign in2=in_2;        
         comparator comp(in1,in2,Btype,Branch);
         assign Jumptarget=(rd1+immD)&~1;
         
         assign pcsrc = (JumpD && JalrD) ? 2'b11 :  
               (JumpD && !JalrD) ? 2'b10 : 
               (BranchD && Branch) ? 2'b01 : 
               2'b00;

         assign pcbranch=immD+pcplus4F;
         assign RsD=Instr[19:15];
         assign RtD=Instr[24:20];
         assign RdD=Instr[11:7];       
  endmodule      
module IE(input [2:0] ALUcontrolE,
          input ALUSrcBE,
          input [1:0] ALUSrcAE,
          input RegDstE,
          input [4:0] RtE,RdE,
          input [31:0] rd1,rd2,
          input [31:0] immE,
          input [31:0] pcplus4E,
          input [31:0] resultw,aluoutm,
          input [1:0] ForwardAE,ForwardBE,
          output [31:0] ALUOutE,
          output [4:0] writeregE,
          output [31:0] writedataE,
          
          output   zeroflag);
           reg [31:0] SrcA,SrcB,SRcA;
           wire [31:0]  SrcAE,SrcBE;
           
           //assign writeregE=RegDstE?RtE:RdE;
           always@(*) begin
           case(ForwardAE)
           2'b00:SrcA=rd1;
           2'b01:SrcA=aluoutm;
           2'b10:SrcA=resultw;
           2'b11:SrcA=32'bx;
           endcase
           case(ForwardBE)
           2'b00:SrcB=rd2;
           2'b01:SrcB=aluoutm;
           2'b10:SrcB=resultw;
           2'b11:SrcB=32'bx;
           endcase
           case(ALUSrcAE)
           2'b00:SRcA=SrcA;
           2'b01:SRcA=pcplus4E;
           2'b10:SRcA=32'b0;
           2'b11:SRcA=32'bx;
           endcase
           end
           assign SrcAE=SRcA;
           assign SrcBE=ALUSrcBE?immE:SrcB;
           assign writedataE=SrcB;
           ALU alu(ALUcontrolE,SrcAE,SrcBE,ALUOutE,zeroflag);
endmodule
module MEM(input clk,
           input [31:0] ALUOutM,WritedataM,
           input we,
           output [31:0] rd1);
           //output [31:0]  ALUoutM);
           
           dmem dmem(clk,ALUOutM,we,WritedataM,rd1);
           //assign ALUoutM=ALUOutM;
           
endmodule
module WB( input [31:0] ReaddataW,
           input [31:0] ALUOutW,pcplus4W,
           input MemtoReg,JumpRegW,
           output [31:0] ResultW);
           
           assign ResultW=JumpRegW?pcplus4W:MemtoReg?ReaddataW:ALUOutW;
 endmodule      
 module control_unit (
  input [6:0] opcode,
  input [2:0] funct3,
  input [6:0] funct7,
  output reg [1:0] ALUSrcAD,
  output reg RegwriteD, MemtoRegD, MemwriteD, ALUsrcBD,
  output reg RegDstD, BranchD, JumpRegD, JumpD, JalrD,
  output reg [2:0] ALUcontrolD,
  output reg [1:0] Btype
);

  always @(*) begin
    // Defaults
    RegwriteD = 0;
    MemtoRegD = 0;
    MemwriteD = 0;
    ALUsrcBD = 0;
    RegDstD = 0;
    BranchD = 0;
    JumpD = 0;
    JalrD = 0;
    JumpRegD = 0;
    ALUcontrolD = 3'b000;
    ALUSrcAD = 2'b00;
    Btype = 2'b00;

    case (opcode)
      // R-type
      7'b0110011: begin
        RegwriteD = 1;
        ALUsrcBD = 0;
        ALUSrcAD = 2'b00;
        RegDstD = 1;
        case ({funct7, funct3})
  10'b0000000000: ALUcontrolD = 3'b010; // ADD
  10'b0100000000: ALUcontrolD = 3'b110; // SUB
  10'b0000000111: ALUcontrolD = 3'b000; // AND
  10'b0000000110: ALUcontrolD = 3'b001; // OR
  10'b0000000001: ALUcontrolD = 3'b111; // SLL
  10'b0000000101: ALUcontrolD = 3'b100; // SRL
  10'b0100000101: ALUcontrolD = 3'b101; // SRA
  default:        ALUcontrolD = 3'bxxx;
endcase

      end

      // I-type (immediate ALU ops)
      7'b0010011: begin
        RegwriteD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b00;
        RegDstD = 1;
        case (funct3)
          3'b000: ALUcontrolD = 3'b010; // ADDI
          3'b111: ALUcontrolD = 3'b000; // ANDI
          3'b110: ALUcontrolD = 3'b001; // ORI
          3'b101: begin
          
          if (funct7 == 7'b0000000) ALUcontrolD = 3'b101; // SRLI
          else if (funct7 == 7'b0100000) ALUcontrolD = 3'b100; // SRAI
  
          end
          default: ALUcontrolD = 3'bxxx;
        endcase
      end

      // Load
      7'b0000011: begin
        RegwriteD = 1;
        MemtoRegD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b00;
        RegDstD = 1;
        ALUcontrolD = 3'b010; // ADD
      end

      // Store
      7'b0100011: begin
        MemwriteD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b00;
        ALUcontrolD = 3'b010; // ADD
      end

      // Branches
      7'b1100011: begin
        BranchD = 1;
        ALUsrcBD = 0;
        ALUSrcAD = 2'b00;
        ALUcontrolD = 3'b110; // SUB for comparison
        case (funct3)
          3'b000: Btype = 2'b00; // BEQ
          3'b001: Btype = 2'b01; // BNE
          3'b100: Btype = 2'b10; // BLT
          //3'b101: Btype = 2'b10; // BGE
          3'b110: Btype = 2'b11; // BLTU
         // 3'b111: Btype = 2'b11; // BGEU
          default: Btype = 2'b00;
        endcase
      end

      // JAL
      7'b1101111: begin
        RegwriteD = 1;
        JumpD = 1;
        JalrD=0;
        MemtoRegD = 0;
        ALUSrcAD = 2'b01; // pc + imm
        ALUsrcBD = 0;
        ALUcontrolD = 3'b010; // add
      end

      // JALR
      7'b1100111: begin
        RegwriteD = 1;
        JalrD = 1;
        JumpD=1;
        JumpRegD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b00; // rs1
        ALUcontrolD = 3'b010; // add rs1 + imm
      end

      // LUI
      7'b0110111: begin
        RegwriteD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b10; // SrcA = 0
        ALUcontrolD = 3'b010; // passthrough
      end

      // AUIPC
      7'b0010111: begin
        RegwriteD = 1;
        ALUsrcBD = 1;
        ALUSrcAD = 2'b01; // SrcA = PC
        ALUcontrolD = 3'b010; // add
      end

      default: begin
        // leave default values
      end
    endcase
  end
endmodule

module hazardunit(input [31:0] RsD,RtD,RsE,RtE,RdM,RdW,RdE,
                  input jump,jalr,branch,RegWriteM,RegWriteW,MemtoRegE,
                  output reg [1:0] ForwardAE,ForwardBE,
                  output reg [1:0] ForwardAD,ForwardBD,
                  output reg StallD,StallF,FlushE,FlushF);
always@(*)begin                 
if (RsE!=0&&(RsE==RdM)&&RegWriteM) ForwardAE=2'b01;
else if ((RsE==RdW)&&RegWriteW) ForwardAE=2'b10;
else ForwardAE=2'b00;
end
always@(*) begin
if (RtE!=0&&(RtE==RdM)&&RegWriteM) ForwardBE=2'b01;
else if ((RtE==RdW)&&RegWriteW) ForwardBE=2'b10;
else ForwardBE=2'b00;
end
always@(*) begin
if (RsD!=0&&(RsD==RdM)&&RegWriteM&&branch) ForwardAD=2'b01;
else if ((RsD==RdW)&&RegWriteW&&branch&&RsD!=0) ForwardAD=2'b10;
else ForwardAD=2'b00;
if (RtD!=0&&(RtD==RdM)&&RegWriteM&&branch) ForwardBD=2'b01;
else if ((RtD==RdW)&&RegWriteW&&branch&&RtD!=0) ForwardBD=2'b10;
else ForwardBD=2'b00;
end
always@(*) begin
 if(MemtoRegE && ((RsD==RdE || RtD==RdE))) begin
 StallD=1;
 StallF=1;
 FlushE=1; end
 else if (jump || branch) begin
  //StallD=1;
  FlushF=1;end

end

endmodule


// Top-level pipelined processor datapath
module datapath(input clk, reset);
  // Wires between stages
  wire [31:0] pcF, instrF, pcplus4F;
  wire [31:0] instrD, pcplus4D;
  wire [31:0] rd1D, rd2D, immD;
  wire [31:0] aluoutE, writedataE;
  wire [31:0] aluoutM, readdataM, writedataM;
  wire [31:0] resultW;

  wire [4:0] rsD, rtD, rdD, rsE, rtE, rdE;
  wire [4:0] writeregE, writeregM, writeregW;

  wire [31:0] pcbranchD, jumptargetD;
  wire [1:0] btypeD, pcsrcD;

  // Control signals
  wire memwriteD, memtoregD, alusrcD, regwriteD, regdstD;
  wire branchD, jumpD, jalrD, jumpregD;
  wire [2:0] alucontrolD;
  wire [1:0] alusrcaD;

  wire memwriteE, memtoregE, regwriteE;
  wire jumpregE;
  wire [2:0] alucontrolE;
  wire [1:0] alusrcaE;
  wire alusrcbE, regdstE;
  wire [31:0] rd1E, rd2E, immE, pcplus4E;

  wire zeroE, zeroM;

  wire memwriteM, memtoregM, regwriteM, jumpregM;
  wire [31:0] pcplus4M;

  wire memtoregW, regwriteW, jumpregW;
  wire [31:0] pcplus4W;

  // Hazard unit control
  wire [1:0] forwardAE, forwardBE, forwardAD, forwardBD;
  wire stallD, stallF, flushE, flushF;

  // IF Stage
  IF if_stage(clk, ~stallF, reset, pcsrcD, pcbranchD, pcplus4F, jumptargetD, pcF, instrF, pcplus4F);

  // IF/ID Register
  if_id_reg if_id_reg_inst((reset | flushF), clk, stallD, instrF, pcplus4F, instrD, pcplus4D);

  // ID Stage
  ID id_stage(clk, instrD, pcplus4D, forwardAD, forwardBD, resultW, writeregW, regwriteW,
              btypeD, aluoutM, rsD, rtD, rdD, immD, rd1D, rd2D, pcbranchD, jumptargetD, resultW,
              pcsrcD, memwriteD, memtoregD, alusrcD, regdstD, branchD, jumpregD, jumpD, jalrD,
              alucontrolD, alusrcaD);

  // ID/EX Register
  id_ie_reg id_ex_reg(clk, reset, rd1D, rd2D, immD, pcplus4D, rsD, rtD, rdD, alusrcaD,
                      regwriteD, memtoregD, memwriteD, alusrcD, regdstD, jumpregD, alucontrolD,
                      alusrcaE, regwriteE, memtoregE, memwriteE, alusrcbE, regdstE, jumpregE,
                      alucontrolE, rsE, rtE, rdE, rd1E, rd2E, immE, pcplus4E);

  // EXE Stage
  IE exe_stage(alucontrolE, alusrcbE, alusrcaE, regdstE, rtE, rdE, rd1E, rd2E, immE, pcplus4E,
               resultW, aluoutM, forwardAE, forwardBE, aluoutE, writeregE, writedataE, zeroE);

  // EX/MEM Register
  ie_mem_reg ex_mem_reg(clk, reset, regwriteE, memtoregE, memwriteE, jumpregE,
                        aluoutE, pcplus4E, zeroE, writedataE, writeregE,
                        regwriteM, memtoregM, memwriteM, jumpregM,
                        aluoutM, pcplus4M, zeroM, writedataM, writeregM);

  // MEM Stage
  MEM mem_stage(clk, aluoutM, writedataM, memwriteM, readdataM);

  // MEM/WB Register
  mem_wb_reg mem_wb_reg_inst(clk, reset, regwriteM, memtoregM, jumpregM,
                             readdataM, aluoutM, pcplus4M, writeregM,
                             regwriteW, memtoregW, jumpregW,
                             readdataW, aluoutW, pcplus4W, writeregW);

  // WB Stage
  WB wb_stage(readdataW, aluoutW, pcplus4W, memtoregW, jumpregW, resultW);

  // Hazard Unit
  hazardunit hzd_unit(rsD, rtD, rsE, rtE, writeregM, writeregW, rdE,
                     jumpD, jalrD, branchD, regwriteM, regwriteW, memtoregE,
                     forwardAE, forwardBE, forwardAD, forwardBD,
                     stallD, stallF, flushE, flushF);
endmodule

