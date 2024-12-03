module AS (Out, In_1, In_2, Sel);

    parameter N = 30;

    input signed [N-1:0]In_1, In_2;
    input Sel;
    output reg signed [N:0]Out;

    // 0:In_1+In_2 ; 1:In_1-In_2
    always@(*)
    begin
        if(Sel)
            Out = In_1 - In_2;
        else
            Out = In_1 + In_2;
    end
    
endmodule