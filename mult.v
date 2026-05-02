module mult #(
    parameter N = 8
) (
    input  wire           clk,
    input  wire           rst,    
    input  wire           enable,
    input  wire [N-1:0]   a,
    input  wire [N-1:0]   b,
    output reg  [2*N-1:0] y,
    output reg            done,
    output reg            busy
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    
    localparam CLOG2_N = (N <= 2) ? 1 : (N <= 4) ? 2 : (N <= 8) ? 3 : (N <= 16) ? 4 : 5;
    
    reg [CLOG2_N:0] ctr;
    wire end_step;
    wire [N-1:0] part_sum;
    wire [2*N-1:0] shifted_part_sum;
    reg [N-1:0] a_reg, b_reg;
    reg [2*N-1:0] part_res;
    reg state;

    assign part_sum = a_reg & {N{b_reg[0]}};
    assign shifted_part_sum = part_sum << ctr;
    assign end_step = (ctr == (N - 1));
    
    always @(*) begin
        busy = state;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctr <= 0;
            part_res <= 0;
            y <= 0;
            state <= IDLE;
            done <= 0;
            a_reg <= 0;
            b_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (enable) begin
                        state <= WORK;
                        a_reg <= a;
                        b_reg <= b;
                        ctr <= 0;
                        part_res <= 0;
                        done <= 0;
                    end
                end
                
                WORK: begin
                    if (end_step) begin
                        y <= part_res + shifted_part_sum;
                        done <= 1;
                        state <= IDLE;
                    end else begin
                        done <= 0;
                        part_res <= part_res + shifted_part_sum;
                        ctr <= ctr + 1;
                        b_reg <= b_reg >> 1;
                    end
                end
            endcase
        end
    end

endmodule
