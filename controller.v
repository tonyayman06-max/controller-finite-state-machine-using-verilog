module controller #(parameter width = 8,parameter op_width = 3)
    (

    input wire clk ,
    input wire rst ,
    input wire zero , 
    input wire [op_width-1:0] opcode,
    input wire phase ,
    input wire rd_phase ,

    input wire [width-1:0] in_a ,
    input wire [width-1:0] in_b ,

    output reg  sel , 
    output reg  rd ,
    output reg  ld_ir , 
    output reg  halt , 
    output reg  inc_pc ,
    output reg  ld_ac ,
    output reg  ld_pc ,
    output reg  wr , 
    output reg  data_e,

    output reg [width:0] alu_out

); 

reg [2:0] cs ,ns;
reg clked_phase ;

reg HLT ;
reg SKZ ;
reg ALUOP ;
reg STO ;
reg JMP ;

localparam  INST_ADDR = 3'b000,
            INST_FETCH  = 3'b001,
            INST_LOAD =  3'b010 ,
            IDLE = 3'b011 ,
            OP_ADDR = 3'b100,
            OP_FETCH = 3'b101 ,
            ALU_OP = 3'b110,
            STORE = 3'b111 ;


always @(*) begin
    case (opcode)
        3'b000 : begin
            alu_out = in_a;
            HLT = 1; SKZ = 0; ALUOP = 0; STO = 0; JMP = 0;
        end

        3'b001 : begin
            alu_out = in_a;
            HLT = 0; SKZ = 1; ALUOP = 0; STO = 0; JMP = 0;
        end

        3'b010 : begin
            alu_out = in_a + in_b;
            HLT = 0; SKZ = 0; ALUOP = 1; STO = 0; JMP = 0;
        end

        3'b011 : begin
            alu_out = in_a & in_b;
            HLT = 0; SKZ = 0; ALUOP = 1; STO = 0; JMP = 0;
        end

        3'b100 : begin
            alu_out = in_a ^ in_b;
            HLT = 0; SKZ = 0; ALUOP = 1; STO = 0; JMP = 0;
        end

        3'b101 : begin
            alu_out = in_b;
            HLT = 0; SKZ = 0; ALUOP = 1; STO = 0; JMP = 0;
        end

        3'b110 : begin
            alu_out = in_a;
            HLT = 0; SKZ = 0; ALUOP = 0; STO = 1; JMP = 0;
        end

        3'b111 : begin
            alu_out = in_a;
            HLT = 0; SKZ = 0; ALUOP = 0; STO = 0; JMP = 1;
        end

        default : begin 
            alu_out = in_a;

             HLT = 0;
             SKZ = 0;
             ALUOP = 0;
             STO = 0;
             JMP = 0;

        end 
    endcase
    
end

always @(posedge clk)begin

    if(rd_phase)begin
        cs <= phase ;
    end

    else begin
        if(rst)begin
            cs <= INST_ADDR ; 
        end
        else begin
            cs <= cs +1 ;
        end
    end

end

always @(*) begin
    case (cs)

        INST_ADDR : begin

            sel = 1;
            rd = 0;
            ld_ir = 0; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;

        end

        INST_FETCH : begin

            sel = 1;
            rd = 1;
            ld_ir = 0; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;
            
        end

        INST_LOAD : begin

            sel = 1;
            rd = 1;
            ld_ir = 1; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;

        end

        IDLE : begin

            sel = 1;
            rd = 1;
            ld_ir = 1; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;
        end

        OP_ADDR : begin

            sel = 0;
            rd = 0;
            ld_ir = 0; 
            halt = HLT ;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;
        end

        OP_FETCH : begin

            sel = 0;
            rd = ALUOP ;
            ld_ir = 0; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = 0;
            ld_pc = 0;
            wr = 0;
            data_e = 0;

        end

        ALU_OP : begin

            //still not adjusted 
            sel = 0;
            rd = ALUOP ;
            ld_ir = 0; 
            halt  = 0;
            inc_pc = (SKZ && zero);
            ld_ac = 0;
            ld_pc = JMP;
            wr = 0;
            data_e = STO;
        end

        STORE : begin

            //still not adjusted 
            sel = 0;
            rd = ALUOP ;
            ld_ir = 0; 
            halt  = 0;
            inc_pc = 0;
            ld_ac = ALUOP;
            ld_pc = JMP;
            wr = STO;
            data_e = STO;
        end

        default : ns = INST_ADDR;

    endcase
end
    
endmodule