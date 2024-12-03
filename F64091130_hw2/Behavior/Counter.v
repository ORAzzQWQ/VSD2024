`timescale 10ns / 1ps

module Counter(
    input clk,
    input reset,
    input en,
    input sel,
    output reg [4:0] out
);
    always @(posedge clk) begin
        if (reset) begin
            out <= 5'd0;
        end 
        else begin
            if (en) begin
                if (sel) begin // Count down
                    if (out > 0) begin
                        out <= out - 1;
                    end
                    else begin
                        out <= 0;
                    end
                end
                else begin // Count up
                    if (out < 29) begin
                        out <= out + 1;
                    end
                    else begin
                        out <= 29; 
                    end
                end
            end
            else begin
                out <= out;
            end
        end
    end
endmodule

//module Counter (clk, reset, en, sel, out);
//
//input clk, reset, en, sel;
//output reg [4:0] out;

//always @(posedge clk) begin
//    if (reset)
//        out <= 5'd0; // Reset output to 0
//    else if (en) begin
//        // 0: up, 1: down
//        if (sel == 0 && out < 29)
//            out <= out + 1'd1; // Count up
//        else if (sel == 1 && out > 0)
//            out <= out - 1'd1; // Count down
//    end
//end
    
//endmodule
