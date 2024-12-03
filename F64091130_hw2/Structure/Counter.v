`timescale 10ns / 1ps

module Counter(
    input clk,
    input reset,
    input en,
    input sel, 
    output reg [4:0] out 
);
    wire [4:0] count_up, count_down;
    wire [4:0] next_count;
    wire max_val, min_val;

    // Structural logic for max_val and min_val
    wire max_cmp1, max_cmp2, max_cmp3, max_cmp4, max_cmp5;

    // max_val: True when out == 5'd29 == 5'b11101
    and(max_cmp1, out[4], 1'b1);  // 5th bit is 1
    and(max_cmp2, out[3], 1'b1);  // 4th bit is 1
    and(max_cmp3, out[2], 1'b1);  // 3rd bit is 1
    and(max_cmp4, out[1], 1'b0);  // 2nd bit is 0
    and(max_cmp5, out[0], 1'b1);  // 1st bit is 1
    and(max_val, max_cmp1, max_cmp2, max_cmp3, ~max_cmp4, max_cmp5);

    // min_val: True when out == 5'd0
    and(min_val, ~out[4], ~out[3], ~out[2], ~out[1], ~out[0]);

    RippleCarryAdder_5bit adder (
        .out(out),
        .count_up(count_up)
    );
	 
    RippleCarrySubtractor_5bit subtractor (
        .out(out),
        .count_down(count_down)
    );
	 MUX sel_up_down(
	 .count_up(count_up),
    .count_down(count_down),
    .hold_value(out),
    .sel(sel),
    .max_val(max_val),
    .min_val(min_val),
    .next_count(next_count)
);
 
	 

    // Sequential logic to update the counter
    always @(posedge clk) begin
        if (reset) begin
            out <= 5'd0;  // Reset to 0
        end else if (en) begin
            out <= next_count;  // Update counter
        end
    end

endmodule

module RippleCarryAdder_5bit (
    input [4:0] out,       // Current value of the counter
    output [4:0] count_up  // Incremented value (out + 1)
);
    wire c_up1, c_up2, c_up3, c_up4, c_up5, c_up6, c_up7, c_up8;

    // Add 1 to the least significant bit
    xor(c_up1, out[0], 1'b1);  // LSB + 1
    and(c_up2, out[0], 1'b1);  // Carry generated from LSB

    // Add carry to the second bit
    xor(c_up3, out[1], c_up2);  // Second bit sum
    and(c_up4, out[1], c_up2);  // Carry propagated to third bit

    // Add carry to the third bit
    xor(c_up5, out[2], c_up4);  // Third bit sum
    and(c_up6, out[2], c_up4);  // Carry propagated to fourth bit

    // Add carry to the fourth bit
    xor(c_up7, out[3], c_up6);  // Fourth bit sum
    and(c_up8, out[3], c_up6);  // Carry propagated to fifth bit (out[4])

    // Assign the new value to count_up with updated bits
    assign count_up = {out[4] ^ c_up8, c_up7, c_up5, c_up3, c_up1};  // XOR on out[4] to add the carry

endmodule

module RippleCarrySubtractor_5bit (
    input [4:0] out,       // Current value of the counter
    output [4:0] count_down  // Decremented value (out - 1)
);
    wire b_down1, b_down2, b_down3, b_down4, b_down5, b_down6, b_down7, b_down8;

    // Subtract 1 from the least significant bit
    xor(b_down1, out[0], 1'b1);  // LSB - 1
    and(b_down2, ~out[0], 1'b1);  // Borrow generated from LSB

    // Subtract borrow from the second bit
    xor(b_down3, out[1], b_down2);  // Second bit difference
    and(b_down4, ~out[1], b_down2);  // Borrow propagated to third bit

    // Subtract borrow from the third bit
    xor(b_down5, out[2], b_down4);  // Third bit difference
    and(b_down6, ~out[2], b_down4);  // Borrow propagated to fourth bit

    // Subtract borrow from the fourth bit
    xor(b_down7, out[3], b_down6);  // Fourth bit difference
    and(b_down8, ~out[3], b_down6);  // Borrow propagated to fifth bit (out[4])

    // Assign the new value to count_down with updated bits
    assign count_down = {out[4] ^ b_down8, b_down7, b_down5, b_down3, b_down1};  // XOR on out[4] to subtract the borrow

endmodule

module MUX (
    input [4:0] count_up,
    input [4:0] count_down,
    input [4:0] hold_value,
    input sel,
    input max_val,
    input min_val,
    output [4:0] next_count
);

   // Structural logic for MUX
    wire [4:0] mux1_out, mux2_out;
    wire [4:0] out_and1, out_and2, down_and, up_and;
	 
	 

    // MUX1: When sel is 1, choose count_down or hold the value
	 //count_down
    and(down_and[4], count_down[4], ~min_val);   // count_down[4] when min_val is false
    and(down_and[3], count_down[3], ~min_val);
    and(down_and[2], count_down[2], ~min_val);
    and(down_and[1], count_down[1], ~min_val);
    and(down_and[0], count_down[0], ~min_val);
	 
	 //hold
    and(out_and1[4], hold_value[4], min_val);           // out[4] when min_val is true
    and(out_and1[3], hold_value[3], min_val);
    and(out_and1[2], hold_value[2], min_val);
    and(out_and1[1], hold_value[1], min_val);
    and(out_and1[0], hold_value[0], min_val);
	 
	 
    or(mux1_out[4], down_and[4], out_and1[4]);   // Combine both cases
    or(mux1_out[3], down_and[3], out_and1[3]);
    or(mux1_out[2], down_and[2], out_and1[2]);
    or(mux1_out[1], down_and[1], out_and1[1]);
    or(mux1_out[0], down_and[0], out_and1[0]);

    // MUX2: When sel is 0, choose count_up or hold the value
    and(up_and[4], count_up[4], ~max_val);       // count_up[4] when max_val is false
    and(up_and[3], count_up[3], ~max_val);
    and(up_and[2], count_up[2], ~max_val);
    and(up_and[1], count_up[1], ~max_val);
    and(up_and[0], count_up[0], ~max_val);
	 
    and(out_and2[4], hold_value[4], max_val);           // out[4] when max_val is true
    and(out_and2[3], hold_value[3], max_val);
    and(out_and2[2], hold_value[2], max_val);
    and(out_and2[1], hold_value[1], max_val);
    and(out_and2[0], hold_value[0], max_val);
	 
    or(mux2_out[4], up_and[4], out_and2[4]);     // Combine both cases
    or(mux2_out[3], up_and[3], out_and2[3]);
    or(mux2_out[2], up_and[2], out_and2[2]);
    or(mux2_out[1], up_and[1], out_and2[1]);
    or(mux2_out[0], up_and[0], out_and2[0]);

    // Final MUX selection for next_count
    wire [4:0] mux_out1, mux_out2;
    and(mux_out1[4], mux1_out[4], sel);           // Select final output based on sel
    and(mux_out1[3], mux1_out[3], sel);
    and(mux_out1[2], mux1_out[2], sel);
    and(mux_out1[1], mux1_out[1], sel);
    and(mux_out1[0], mux1_out[0], sel);
	 
	 and(mux_out2[4], mux2_out[4], ~sel);           // Select final output based on sel
    and(mux_out2[3], mux2_out[3], ~sel);
    and(mux_out2[2], mux2_out[2], ~sel);
    and(mux_out2[1], mux2_out[1], ~sel);
    and(mux_out2[0], mux2_out[0], ~sel);
	 
    or(next_count[4], mux_out1[4], mux_out2[4]);
    or(next_count[3], mux_out1[3], mux_out2[3]);
    or(next_count[2], mux_out1[2], mux_out2[2]);
    or(next_count[1], mux_out1[1], mux_out2[1]);
    or(next_count[0], mux_out1[0], mux_out2[0]);

endmodule
