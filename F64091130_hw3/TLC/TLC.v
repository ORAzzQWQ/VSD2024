`include "Traffic_time.svh"
`timescale 1ns/1ps

module TLC (reset, clk, EW_Red, EW_Green, EW_Yellow, NS_Red, NS_Green, NS_Yellow);

    input reset;          // 1:Reset system 
    input clk;
    output reg EW_Red, EW_Green, EW_Yellow;  // 東西向紅、綠、黃燈
    output reg NS_Red, NS_Green, NS_Yellow;  // 南北向紅、綠、黃燈

    parameter Idle = 3'b000, 
              EW_Red_NS_Green = 3'b001, EW_Red_NS_Yellow = 3'b010,
              NS_Red_EW_Green = 3'b011, NS_Red_EW_Yellow = 3'b100;

    reg [2:0] state, nx_state;
    reg [5:0] time_cnt;

    always @ (state or time_cnt) begin
        case (state)
            Idle: nx_state = EW_Red_NS_Green;   // 初始狀態進入南北向綠燈狀態

            EW_Red_NS_Green: begin
                if (time_cnt == `G_time)
                    nx_state = EW_Red_NS_Yellow; // 綠燈時間到，切換到南北向黃燈
                else
                    nx_state = state;
            end

            EW_Red_NS_Yellow: begin
                if (time_cnt == `Y_time)
                    nx_state = NS_Red_EW_Green;  // 黃燈時間到，切換到東西向綠燈
                else
                    nx_state = state;
            end

            NS_Red_EW_Green: begin
                if (time_cnt == `G_time)
                    nx_state = NS_Red_EW_Yellow; // 綠燈時間到，切換到東西向黃燈
                else
                    nx_state = state;
            end

            NS_Red_EW_Yellow: begin
                if (time_cnt == `Y_time)
                    nx_state = EW_Red_NS_Green;  // 黃燈時間到，切換回南北向綠燈
                else
                    nx_state = state;
            end

            default: nx_state = state;
        endcase
    end

    always @ (posedge clk) begin
        if (reset)
            state <= Idle;
        else
            state <= nx_state;
    end

    always @ (posedge clk) begin
        if (state == Idle || ((state == EW_Red_NS_Green || state == NS_Red_EW_Green) && time_cnt == `G_time) || 
            ((state == EW_Red_NS_Yellow || state == NS_Red_EW_Yellow) && time_cnt == `Y_time))
            time_cnt <= 6'd0;
        else
            time_cnt <= time_cnt + 1'b1;
    end

    // 東西向燈光控制
    always @ (*) begin
        EW_Red <= (state == EW_Red_NS_Green || state == EW_Red_NS_Yellow);
        EW_Green <= (state == NS_Red_EW_Green);
        EW_Yellow <= (state == NS_Red_EW_Yellow);
    end

    // 南北向燈光控制
    always @ (*) begin
        NS_Red <= (state == NS_Red_EW_Green || state == NS_Red_EW_Yellow);
        NS_Green <= (state == EW_Red_NS_Green);
        NS_Yellow <= (state == EW_Red_NS_Yellow);
    end

endmodule
