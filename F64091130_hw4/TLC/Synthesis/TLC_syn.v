/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : Q-2019.12
// Date      : Sat Nov  2 14:30:22 2024
/////////////////////////////////////////////////////////////


module TLC ( reset, clk, EW_Red, EW_Green, EW_Yellow, NS_Red, NS_Green, 
        NS_Yellow );
  input reset, clk;
  output EW_Red, EW_Green, EW_Yellow, NS_Red, NS_Green, NS_Yellow;
  wire   N46, N47, N48, N52, N53, N54, N55, N57, N58, N59, N60, N61, N62, n8,
         n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n25, n26,
         n27, n28, n29, n30, n31, n32;
  wire   [2:0] state;
  wire   [5:0] time_cnt;
  wire   [5:2] \add_66/carry ;

  DFFHQX1 \time_cnt_reg[2]  ( .D(N59), .CK(clk), .Q(time_cnt[2]) );
  DFFHQX1 \time_cnt_reg[5]  ( .D(N62), .CK(clk), .Q(time_cnt[5]) );
  DFFHQX1 \time_cnt_reg[1]  ( .D(N58), .CK(clk), .Q(time_cnt[1]) );
  DFFHQX1 \time_cnt_reg[4]  ( .D(N61), .CK(clk), .Q(time_cnt[4]) );
  DFFHQX1 \time_cnt_reg[3]  ( .D(N60), .CK(clk), .Q(time_cnt[3]) );
  DFFHQX1 \time_cnt_reg[0]  ( .D(N57), .CK(clk), .Q(time_cnt[0]) );
  EDFFX1 \state_reg[2]  ( .D(N48), .E(n29), .CK(clk), .Q(state[2]), .QN(n26)
         );
  EDFFX1 \state_reg[0]  ( .D(N46), .E(n29), .CK(clk), .Q(state[0]), .QN(n27)
         );
  EDFFX1 \state_reg[1]  ( .D(N47), .E(n29), .CK(clk), .Q(state[1]), .QN(n25)
         );
  INVX1 U38 ( .A(EW_Green), .Y(n32) );
  OAI2BB2X1 U39 ( .B0(n10), .B1(n30), .A0N(n27), .A1N(n11), .Y(n9) );
  NOR2X1 U40 ( .A(n10), .B(n25), .Y(EW_Green) );
  INVX1 U41 ( .A(n13), .Y(n30) );
  INVX1 U42 ( .A(n18), .Y(n31) );
  INVX1 U43 ( .A(n8), .Y(n29) );
  AOI211X1 U44 ( .A0(n25), .A1(n27), .B0(reset), .C0(n26), .Y(n8) );
  NOR2BX1 U45 ( .AN(N55), .B(n9), .Y(N61) );
  NOR2BX1 U46 ( .AN(N54), .B(n9), .Y(N60) );
  NOR2BX1 U47 ( .AN(N53), .B(n9), .Y(N59) );
  NOR2BX1 U48 ( .AN(N52), .B(n9), .Y(N58) );
  NOR2X1 U49 ( .A(reset), .B(n14), .Y(N47) );
  AOI221X1 U50 ( .A0(NS_Green), .A1(n13), .B0(EW_Green), .B1(n30), .C0(
        NS_Yellow), .Y(n14) );
  NAND2BX1 U51 ( .AN(EW_Yellow), .B(n32), .Y(NS_Red) );
  OR2X2 U52 ( .A(NS_Green), .B(NS_Yellow), .Y(EW_Red) );
  NOR2X1 U53 ( .A(reset), .B(n12), .Y(N48) );
  AOI22X1 U54 ( .A0(EW_Green), .A1(n13), .B0(EW_Yellow), .B1(n31), .Y(n12) );
  NOR3X1 U55 ( .A(state[0]), .B(state[1]), .C(n26), .Y(EW_Yellow) );
  NOR3X1 U56 ( .A(state[0]), .B(state[2]), .C(n25), .Y(NS_Yellow) );
  NOR2BX1 U57 ( .AN(time_cnt[2]), .B(n19), .Y(n13) );
  NAND2X1 U58 ( .A(state[0]), .B(n26), .Y(n10) );
  OAI21XL U59 ( .A0(state[1]), .A1(n31), .B0(n17), .Y(n11) );
  OAI21XL U60 ( .A0(n18), .A1(n25), .B0(n26), .Y(n17) );
  NAND3BX1 U61 ( .AN(time_cnt[0]), .B(time_cnt[1]), .C(n20), .Y(n19) );
  NOR3X1 U62 ( .A(time_cnt[3]), .B(time_cnt[5]), .C(time_cnt[4]), .Y(n20) );
  NOR2X1 U63 ( .A(n19), .B(time_cnt[2]), .Y(n18) );
  NOR2X1 U64 ( .A(n10), .B(state[1]), .Y(NS_Green) );
  ADDHXL U65 ( .A(time_cnt[2]), .B(\add_66/carry [2]), .CO(\add_66/carry [3]), 
        .S(N53) );
  ADDHXL U66 ( .A(time_cnt[1]), .B(time_cnt[0]), .CO(\add_66/carry [2]), .S(
        N52) );
  ADDHXL U67 ( .A(time_cnt[3]), .B(\add_66/carry [3]), .CO(\add_66/carry [4]), 
        .S(N54) );
  NOR2X1 U68 ( .A(n28), .B(n9), .Y(N62) );
  XNOR2X1 U69 ( .A(\add_66/carry [5]), .B(time_cnt[5]), .Y(n28) );
  NOR2X1 U70 ( .A(time_cnt[0]), .B(n9), .Y(N57) );
  ADDHXL U71 ( .A(time_cnt[4]), .B(\add_66/carry [4]), .CO(\add_66/carry [5]), 
        .S(N55) );
  NOR2X1 U72 ( .A(reset), .B(n15), .Y(N46) );
  AOI22X1 U73 ( .A0(n16), .A1(n30), .B0(n11), .B1(n27), .Y(n15) );
  OAI21XL U74 ( .A0(state[2]), .A1(state[1]), .B0(n32), .Y(n16) );
endmodule

