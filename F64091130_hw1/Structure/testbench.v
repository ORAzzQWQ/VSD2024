`include "AS.v"
`define FILE_PATH "./formula.dat"
`define ANSWER_PATH "./ans.dat"
`timescale 10ns / 1ps
`define CYCLE 10

module testbench;
reg [29:0] In_1, In_2;
reg Sel;
wire [30:0] Out;
reg [30:0] ans_of_out;
integer i;
integer err;
integer file;
integer callback;
integer answer;

parameter tb_size = 500;

AS as(.In_1(In_1), .In_2(In_2), .Sel(Sel), .Out(Out));

initial begin
   err = 0;
end

initial begin
    file = $fopen(`FILE_PATH,"r");
    answer = $fopen(`ANSWER_PATH,"r");
    if (!file || !answer) begin
        $display ("file open fail");
        $finish;
    end
end

initial begin
    $display("---------------------Start Simulation----------------------\n");
    for (i = 0; i < tb_size; i = i + 1) begin
        #`CYCLE 
        callback = $fscanf(file, "%d %d %b", In_1, In_2, Sel); 
        #`CYCLE 
        callback = $fscanf(answer, "%d", ans_of_out);
        if(Out == ans_of_out) begin
            //answer correct
        end
        else begin
            $display("  Pattern %3d: Expect= %d Get= %d\n  ", i, ans_of_out, Out);
            err = err + 1;
        end
    end
    if(err != 0) begin
		$display("-------------------There are %3d errors!-------------------\n", err);
	end
	else begin
		$display("--------------- Simulation finish, ALL PASS ---------------\n");
	end
    $fclose(file); 
    $fclose(answer);   
    #10 $finish;
end

endmodule
