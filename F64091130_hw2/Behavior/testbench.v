`include "Counter.v"
`timescale 10ns / 1ps
`define CYCLE      10.0
`define FILE_PATH "./Gold.dat"

module testbench;
    reg clk, reset, en, sel;
    wire [4:0] out; // output from Counter
    integer i, err; // loop index and error count
    integer IN, ANS; // file handlers for input and expected output
    integer GOLD; // expected output
    integer file;
    parameter tb_size = 100; // total number of test vectors
    reg [17:0]t;
    reg [17:0]pattern[0:tb_size];

    Counter U0(clk, reset, en, sel, out);

    initial begin
        clk = 1'b0;
        forever #(`CYCLE / 2) clk = ~clk; 
    end
    
    initial begin
    $display("**************************************************");
    $display("***********      Simulation Start      ***********");
    $display("**************************************************");
    @(posedge clk);  #2 reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk);  #2 reset = 1'b0;
    end
    
	initial begin
	    file = $fopen(`FILE_PATH,"r");
	    if (!file) begin
		$display ("file open fail");
		$finish;
	    end
	end

    initial begin
        
        err = 0;

        for (i = 0; i < tb_size; i = i + 1) begin
            @(negedge clk);
	        $fscanf(file, "%d %d %d %d", reset, en, sel, GOLD); 
            
            @(posedge clk);
            
            
            # (`CYCLE / 4)
            if (out !== GOLD) begin
                if (en == 0)
                    $display("ERROR: %d Hold counter value, expected %d, got %d\n", i, GOLD, out);
                else if (sel == 0)
                    $display("ERROR: %d Count up, expected %d, got %d\n", i, GOLD, out);
                else if (sel == 1)
                    $display("ERROR: %d Count down, expected %d, got %d\n", i, GOLD, out);
                err = err + 1;
            end
        end


        if (err != 0) begin
            $display("-------------------There are %3d errors!-------------------\n", err);
        end else begin
            $display("**************************************************");
            $display("***********          ALL PASS          ***********");
            $display("**************************************************");
        end

        @(posedge clk);
            $finish;
    end
endmodule
