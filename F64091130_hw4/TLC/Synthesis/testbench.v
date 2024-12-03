`timescale 1ns/1ps
`include "tsmc18.v"
`include "TLC_syn.v"

module  testbench;

reg	 	clk, reset;
wire	EW_Red, EW_Green, EW_Yellow, NS_Red, NS_Green, NS_Yellow;

TLC DUT (.reset(reset), .clk(clk), 
     .EW_Red(EW_Red), .EW_Green(EW_Green), .EW_Yellow(EW_Yellow),
     .NS_Red(NS_Red), .NS_Green(NS_Green), .NS_Yellow(NS_Yellow)); 


initial $sdf_annotate("TLC_syn.sdf", DUT);

initial
begin
	clk = 1'b0;
	reset = 1;
end

initial #100 reset = 0;

always #50 clk = clk+1;

always @(negedge clk) begin
	if(EW_Red && NS_Green)
		$display("EW_Red & NS_Green");
	else if(EW_Green && NS_Red)
		$display("EW_Green & NS_Red");
	else if(EW_Yellow && NS_Red)
		$display("EW_Yellow & NS_Red");
	else if(EW_Red && NS_Yellow)
		$display("EW_Red & NS_Yellow");
	else
		$display("Wait");	
end

initial #6000 $finish;

// initial begin
// 	$fsdbDumpfile("TLC_syn.fsdb");
// 	$fsdbDumpvars;
// end

endmodule
