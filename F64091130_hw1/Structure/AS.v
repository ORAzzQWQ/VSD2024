module AS(In_1, In_2, Sel, Out);

    parameter N = 30;

    input wire [N-1:0] In_1;
    input wire [N-1:0] In_2;
    input wire         Sel;
    output       [N:0] Out;

    genvar i;
    wire    [N:0] carry;
    wire    [N:0] exten_1;//sgin extension to In_1
    wire    [N:0] comp_2;//2's compliment to In_2
    wire  [N-1:0] r1,r2,r3;
    
    assign exten_1 = {In_1[29], In_1};
    assign comp_2  = (Sel)? {~In_2[29], ~In_2 + 30'd1} : {In_2[29], In_2};

    //0th bit 
    xor x0(Out[0], exten_1[0], comp_2[0]);
    and a0(carry[0], exten_1[0], comp_2[0]);

	generate
		 for(i=1 ; i<=N ; i=i+1) begin: adder
			  xor x2( Out[i], exten_1[i], comp_2[i], carry[i-1]);
			  and a2( r1[i-1], comp_2[i], carry[i-1]);
			  and a3( r2[i-1], exten_1[i], comp_2[i]);
			  and a4( r3[i-1], exten_1[i], carry[i-1]);
			  or  o1( carry[i], r1[i-1], r2[i-1], r3[i-1]);
		 end
    endgenerate

endmodule
