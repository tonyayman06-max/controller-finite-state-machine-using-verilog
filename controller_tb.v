module controller_tb ;

      reg              clk;
      reg              rst;
     reg              zero;
     reg [2:0]        opcode;
     reg [2:0]        phase;
     reg              rd_phase;

     reg [7:0]  in_a;
     reg [7:0]  in_b;

     wire              sel;
     wire             rd;
     wire              ld_ir;
     wire              halt;
     wire              inc_pc;
     wire               ld_ac;
     wire             ld_pc;
     wire               wr;
     wire               data_e;

     wire [8:0]    alu_out;



controller #(.width(8), .op_width(3)) u_controller (
    .clk     (clk),
    .rst     (rst),
    .zero    (zero),
    .opcode  (opcode),
    .phase   (phase),
    .rd_phase (rd_phase),

    .in_a    (in_a),
    .in_b    (in_b),

    .sel     (sel),
    .rd      (rd),
    .ld_ir   (ld_ir),
    .halt    (halt),
    .inc_pc  (inc_pc),
    .ld_ac   (ld_ac),
    .ld_pc   (ld_pc),
    .wr      (wr),
    .data_e  (data_e),

    .alu_out (alu_out)
);

/*reg sel_gd;
reg rd_gd;
reg ld_ir_gd;
reg halt_gd;
reg inc_pc_gd ;
reg ld_ac_gd ;
reg ld_pc_gd ;
reg wr_gd ;
reg data_e_gd ;

reg alu_gd;*/

initial begin
    clk = 0;
    forever begin 
        #5 clk = ~clk;   
    end
end

integer i ;

task generate_stim ;
    begin
        for ( i = 0; i<10000 ; i = i+1)begin
        
            rst = 0;
            in_a = $random ;
            in_b = $random ;
            opcode = $random ;
            phase = $random ;
            rd_phase = $random ;
            zero = $random ;

            repeat(10)@(posedge clk);
        end
    end
endtask

/*task autrandomatic golden_model(input in_a ,input in_b , input opcode , input phase , input zero);
    if(clk)begin
        if(rst)begin
            sel_gd = 1;
            rd_gd = 0;
            ld_ir_gd = 0; 
            halt_gd  = 0;
            inc_pc_gd = 0;
            ld_ac_gd = 0;
            ld_pc_gd = 0;
            wr_gd = 0;
            data_e_gd = 0;
        end
    end
    else begin
        
    end
endtask //autrandomatic*/


initial begin
    @(posedge clk) ;
    rst = 1 ;
    repeat(4)@(posedge clk) ;
    $display("reset released");

    $monitor("Time=%0t sel=%b rd=%b ld_ir=%b halt=%b inc_pc=%b ld_ac=%b ld_pc=%b wr=%b data_e=%b alu_out=%0d",
                  $time, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e, alu_out);

    generate_stim;
    
    repeat(30)@(posedge clk);
    $finish;
end

endmodule