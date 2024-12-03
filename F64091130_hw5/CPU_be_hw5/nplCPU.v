/* ==========================
* Model of RISC without pipeline.
* Behavioral model of a non-pipelined CPU
* Three main tasks - fetch, execute, write
*/
`timescale 1ns/1ps
module nplCPU;

// Parameter declarations
parameter CYCLE = 10;         // Cycle Time 
parameter WIDTH = 32;         // Width of data paths
parameter ADDRSIZE = 12;      // Size of address field
parameter MEMSIZE = (1 << ADDRSIZE); // Size of memory 
parameter MAXREGS = 16;       // Maximum # of registers
parameter SBITS = 5;          // Status register bits

// Register and Memory declarations  
reg [WIDTH-1:0] MEM[0:MEMSIZE-1];    // Memory
reg [WIDTH-1:0] RFILE[0:MAXREGS-1];  // Register File
reg [WIDTH-1:0] ir;                  // Instruction Register
reg [WIDTH-1:0] src1, src2;          // ALU operand registers
reg [WIDTH:0] result;                // ALU result register (33 bits to include carry)
reg [SBITS-1:0] psr;                 // Processor Status Register
reg [ADDRSIZE-1:0] pc;               // Program Counter
reg dir;                             // Rotate direction
reg reset;                           // System Reset
integer i;                           // Counter for loops

// General definitions
`define TRUE 1
`define FALSE 0

// Instruction fields
`define OPCODE ir[31:28] 
`define SRC ir[23:12]
`define DST ir[11:0]
`define SRCTYPE ir[27]    // source type, 0=reg (mem for LD), 1=imm
`define DSTTYPE ir[26]    // destination type, 0=reg, 1=imm
`define CCODE ir[27:24]
`define SRCNT ir[23:12]   // Shift/rotate count

// Operand Types
`define REGTYPE 0
`define IMMTYPE 1

// Opcodes
`define NOP 4'b0000
`define BRA 4'b0001
`define LD  4'b0010
`define STR 4'b0011
`define ADD 4'b0100
`define MUL 4'b0101
`define CMP 4'b0110
`define SHF 4'b0111
`define ROT 4'b1000
`define HLT 4'b1001
`define OR 4'b1010
`define AND 4'b1011

// Status Register bits
`define CARRY psr[0]
`define EVEN  psr[1]
`define PARITY psr[2]
`define ZERO psr[3]
`define NEG psr[4]

// Condition Codes
`define CCC 4'd1    // Carry
`define CCE 4'd2    // Even
`define CCP 4'd3    // Parity
`define CCZ 4'd4    // Zero
`define CCN 4'd5    // Negative
`define CCA 4'd0    // Always

// Shift/Rotate directions
`define RIGHT 1'b0
`define LEFT  1'b1

// Functions for operand access
function [WIDTH-1:0] getsrc;
    input [WIDTH-1:0] inst;
    begin
        getsrc = (`SRCTYPE == `REGTYPE) ? RFILE[`SRC] : `SRC;
    end
endfunction

function [WIDTH-1:0] getdst;
    input [WIDTH-1:0] inst;
    begin
        if (`DSTTYPE == `REGTYPE)
            getdst = RFILE[`DST];
        else begin
            $display("Error: Immediate data can't be destination");
            getdst = {WIDTH{1'b0}}; // Return zeros on error
        end
    end
endfunction

// Functions for condition codes
function checkcond;
    input [3:0] ccode;
    begin
        case (ccode)
            `CCC: checkcond = `CARRY;
            `CCE: checkcond = `EVEN;
            `CCP: checkcond = `PARITY;
            `CCZ: checkcond = `ZERO;
            `CCN: checkcond = `NEG;
            `CCA: checkcond = 1'b1;
            default: checkcond = 1'b0;
        endcase
    end
endfunction

// Tasks for condition code handling
task clearcondcode;
    begin
        psr = {SBITS{1'b0}};
    end
endtask

task setcondcode;
    input [WIDTH:0] res;
    begin
        `CARRY = res[WIDTH];
        `EVEN = ~res[0];
        `PARITY = ^res[WIDTH-1:0];
        `ZERO = ~|res[WIDTH-1:0];
        `NEG = res[WIDTH-1];
    end
endtask

// Main tasks
task fetch;
    begin
        ir = MEM[pc];
        pc = pc + 1;
    end
endtask

task execute;
    begin
        case (`OPCODE)
            `NOP: ; // No operation
            
            `BRA: begin
                if (checkcond(`CCODE))
                    pc = `DST;
            end
            
            `LD: begin
                clearcondcode;
                if (`SRCTYPE)
                    RFILE[`DST] = `SRC;
                else
                    RFILE[`DST] = MEM[`SRC];
                setcondcode({1'b0, RFILE[`DST]});
            end
            
            `STR: begin
                clearcondcode;
                if (`SRCTYPE) begin
                    MEM[`DST] = `SRC;
                    setcondcode({1'b0, `SRC});
                end else begin
                    MEM[`DST] = RFILE[`SRC];
                    setcondcode({1'b0, RFILE[`SRC]});
                end
            end
            
            `ADD: begin
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                result = src1 + src2;
                setcondcode(result);
            end
            
            `MUL: begin
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                result = src1 * src2;
                setcondcode(result);
            end
            
            `CMP: begin
                clearcondcode;
                src1 = getsrc(ir);
                result = ~src1;
                setcondcode(result);
            end

            `AND: begin // 新增 AND 指令
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                result = src1 & src2;
                setcondcode(result);
            end

            `OR: begin // 新增 SUB 指令
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                result = src1 | src2;
                setcondcode(result);
            end
            
            `SHF: begin
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                i = $signed(src1[ADDRSIZE-1:0]);
                // Fixed shift operation
                result = (i >= 0) ? (src2 >> i) : (src2 << (-i));
                setcondcode(result);
            end
            
            `ROT: begin
                clearcondcode;
                src1 = getsrc(ir);
                src2 = getdst(ir);
                dir = (src1[ADDRSIZE-1] >= 0) ? `RIGHT : `LEFT;
                i = (src1[ADDRSIZE-1] >= 0) ? src1 : -src1;
                
                // Perform rotation
                result = src2;
                while (i > 0) begin
                    if (dir == `RIGHT) begin
                        result = {result[0], result[WIDTH-1:1]};
                    end else begin
                        result = {result[WIDTH-2:0], result[WIDTH-1]};
                    end
                    i = i - 1;
                end
                setcondcode(result);
            end
            
            `HLT: begin
                $display("Halt instruction executed at time %0t", $time);
                $stop;
            end
            
            default: begin
                $display("Error: Invalid opcode %b at time %0t", `OPCODE, $time);
                $stop;
            end
        endcase
    end
endtask

task write_result;
    begin
        if ((`OPCODE >= `ADD) && (`OPCODE <= `AND)) begin
            if (`DSTTYPE == `REGTYPE)
                RFILE[`DST] = result[WIDTH-1:0];
            else
                MEM[`DST] = result[WIDTH-1:0];
        end
    end
endtask

// Debug support
task apply_reset;
    begin
        reset = 1'b1;
        #CYCLE;
        reset = 1'b0;
        pc = 0;
        // Clear all registers on reset
        for (i = 0; i < MAXREGS; i = i + 1)
            RFILE[i] = 0;
        psr = 0;
    end
endtask

// Initialization
initial begin : prog_load
    $readmemb("sisc.prog", MEM);
    // 改進monitor格式，確保顯示所有位元
    $monitor("Time=%0t pc=%d ir=%b r0=%h r1=%h r2=%h MEM16=%h psr=%b",
             $time, pc, ir, RFILE[0], RFILE[1], RFILE[2],MEM[16], psr);
    apply_reset;
end


// Main execution loop
always begin : main_process
    if (!reset) begin
        #CYCLE fetch;
        #CYCLE execute;
        #CYCLE write_result;
    end
    else
        #CYCLE;
end

endmodule